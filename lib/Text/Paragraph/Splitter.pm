use strict; use warnings;
package Text::Paragraph::Splitter;
use Object::Tiny::Lvalue qw/
							short     indw
							indent    capw
							trail     punctw
							partag    ptres
							tabwidth  _avgll
							blw       _ilcount
							slw       _bgcount
						/;

# ABSTRACT: Guesses the notation used for paragraphs to split them.

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new( @_ );

	$self->short 	//= 50 , # maximum length of a line to still be considered short
	$self->indent	//= 2  , # Mininum length of white space needed to consider line indented
	$self->trail	//= 0  , # include trailing white space in paragraphs?
	$self->partag	//= 'P', # Tag to be used to delimit paragraphs.
	$self->tabwidth	//= 4  , # Tab width (for indentation calculation)

	$self->blw		//= 0.8, # blank 	   line weigth
	$self->slw		//= 0.3, # short 	   line weigth
	$self->indw		//= 0.3, # indented     line weigth
	$self->capw		//= 0.2, # caps-started line weigth
	$self->punctw	//= 0.2, # punct        line weigth
	$self->ptres 	//= 0.5, # Minimum confidence needed to consider paragraph

	$self->_avgll 	//= 80 , # Average line length
	$self->_ilcount   =  0,  # Indented lines count
	$self->_bgcount   =  0,  # Blank gaps count


    return $self;
}

sub offsets {
	my ($self,$text) = @_;
	$text = $$text if ref($text);
	$self->_calc_early_metrics(\$text);
	my $clues 	= $self->_find_clues(\$text);
	my $gaps  	= $self->_clues2gaps($clues);
	my $offsets = $self->_gaps2offsets($gaps,length($text));
	return $offsets;
}

sub split {
	my ($self,$text) = @_;
	$text = $$text if ref($text);
	my $offsets = $self->offsets(\$text);
	my $array   = $self->_offsets2array(\$text, $offsets);
	return $array;
}

sub annotate {
	my ($self,$text) = @_;
	$text = $$text if ref($text);
	my $array = $self->split(\$text);
	my $anno  = '';
	my $ot = '<'.$self->partag.'>';
	my $ct = '</'.$self->partag.">\n";
	$anno.="$ot$_$ct" foreach @$array;
	return $anno;
}

sub _find_clues  {
	my ($self,$text) = @_;
	$text = $$text if ref($text);
	my $clues1 = $self->_find_short(\$text);
	my $clues2 = $self->_find_blank($text);
	my $clues3 = $self->_find_indent(\$text);
	my $clues4 = $self->_find_cap(\$text);
	my $clues5 = $self->_find_punct(\$text);
	my $clues  = [sort {$a->{start} <=> $b->{start}} (@$clues1,@$clues2,@$clues3,@$clues4,@$clues5)];
	return $clues;
}


sub _find_short  {
	my ($self,$text) = @_;
	$text = $$text if ref($text);
	my $clues = [];
	my $l = ($self->short < 1 ? int($self->short*$self->_avgll)+1 : $self->short);
	while($text =~ /^.{0,$l}$/gmp){
		my $line = ${^MATCH};
		my ($start,$end) = ($-[0],$+[0]);
		next if $line =~ /^\s*$/;			# blank line does not count
		#$start+= $+[1] if $line =~ /^\s*(\p{IsUpper})/gmp; # compat. with caps rule
		push @$clues, {
			start 		=> $start,
			end			=> $end,
			type		=> 'short',
			confidence	=> $self->slw,
		};
	}
	return $clues;
}

sub _find_blank  {
	my ($self,$text) = @_;
	$text = $$text if ref($text);
	my $clues = [];
	while($text =~ /\n([ \t]*\n)+/g){
		push @$clues, {
			start		=> $-[0],
			end			=> $+[0],
			type		=> 'blank',
			confidence	=> $self->blw,
		};
		$self->_bgcount++;
	}
	return $clues;
}

sub _find_indent  {
	my ($self,$text) = @_;
	$text = $$text if ref($text);
	my $clues = [];
	while($text =~ /^[^\S\n]+/gpm){
		my ($start,$end) = ($-[0],$+[0]);
		my $indent = ${^MATCH};
		my $width = $self->tabwidth*($indent =~ s/\t//g);
		$width+= ($indent =~ s/ //g);
		if ($width >= $self->indw) {
			push @$clues, {
				start		=> $start,
				end			=> $end,
				type 		=> 'indent',
				confidence	=> $self->indw,
			}; 
			$self->_ilcount++;
		}
	}
	return $clues;
}

sub _find_cap  {
	my ($self,$text) = @_;
	$text = $$text if ref($text);
	my $clues = [];
	while($text =~ /^\s*(\p{IsUpper})/gpm){
		my ($start,$end) = ($-[1],$+[1]);
		push @$clues, {
			start 		=> $start,
			end			=> $end,
			type		=> 'caps',
			confidence	=> $self->capw,
		};
	}
	return $clues;
}

sub _find_punct  {
	my ($self,$text) = @_;
	$text = $$text if ref($text);
	my $clues = [];
	while($text =~ /[,;\-]$/gpm){
		my ($start,$end) = ($-[0],$+[0]);
		push @$clues, {
			start		=> $start,
			end			=> $end,
			type		=> 'punctuation',
			confidence	=> -0.5,
		};
	}
	while($text =~ /[?!\.]$/gpm){
		my ($start,$end) = ($-[0],$+[0]);
		push @$clues, {
			start		=> $start,
			end			=> $end,
			type		=> 'punctuation',
			confidence	=> 0.2,
		};
	}
	return $clues;
}


sub _clues2gaps  {
	my ($self,$clues) = @_;
	$clues  = [sort {$a->{start} <=> $b->{start}} @$clues];
	my $gaps = [];
	for (my $i = 0; $i<@$clues; $i++){
		my $order = ['short','punctuation','blank','indent','caps'];
		my $merge = {};

		$merge->{clues_start}	= $clues->[$i]{start};
		$merge->{clues_end}		= $clues->[$i]{start};
		$merge->{start} 		= undef;
		$merge->{end}   		= undef;
		$merge->{confidence} 	= 0;

		my $j = $i;
		my $c = $clues->[$j];
		shift @$order while (@$order and $order->[0] ne $c->{type});

		while (@$order and $j < @$clues and $c->{start} <= $merge->{clues_end}){
			shift @$order;
			$merge->{clues_end} = $c->{end};
			if($c->{type} eq 'short' or $c->{type} eq 'punctuation'){
				$merge->{start} = $c->{end};
				$merge->{end}	= $c->{end};
			}
			elsif($c->{type} eq 'blank'){
				$merge->{start} = ($self->trail ? $c->{end} : $c->{start});
				$merge->{end} 	= $c->{end};
			}
			elsif($c->{type} eq 'indent' or $c->{type} eq 'caps'){
				$merge->{start} //= $c->{start};
				$merge->{end} 	//= $c->{start};
			}
			$merge->{confidence} += $c->{confidence};

			$j++;
			next if $j >= @$clues;
			$c = $clues->[$j];
			shift @$order while (@$order and $order->[0] ne $c->{type});
		}

		push @$gaps, $merge;
		$i=$j-1;
	}
	return [ grep { $_->{confidence} >= $self->ptres } @$gaps ];
}

sub _gaps2offsets  {
	my ($self,$gaps,$text_length) = @_;
	my $offsets = [];
	my $start = 0;
	for my $g (@$gaps){
		my $end = $g->{start};
		push @$offsets, [$start,$end] unless $start == $end;
		$start = $g->{end};
	}
	push @$offsets, [$start,$text_length];
	return $offsets;
}

sub _offsets2array  {
	my ($self,$text,$offsets) = @_;
	$text = $$text if ref($text);
	my $pars = [];
	foreach my $o (@$offsets){
		my $str = substr($text, $o->[0], ($o->[1]-$o->[0]));
		push @$pars, $str;
	}
	return $pars;
}

sub _calc_early_metrics  {
	my ($self,$text) = @_;
	$text = $$text if ref($text);

	my $avgll = length($text)/(split /\n/,$text);
	$self->_avgll($avgll);

}


1;

=method offsets

Finds paragraphs boundaries and returns a reference to an array of pairs, each consisting of a paragraph's first and last character offsets.

=method split

Split the paragraphs and returns them in an array reference.

=method annotate

Returns the original text with paragraphs annotated XML-style.

=cut

