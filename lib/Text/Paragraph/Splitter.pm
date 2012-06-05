use strict; use warnings;
use MooseX::Declare;

# ABSTRACT: Guesses the notation used for paragraphs to split them.

class Text::Paragraph::Splitter {
	use Data::Dump qw/dump/;
	use feature qw/say/;

	has 'short' 	=> ( is => 'rw', isa => 'Int',  default => 50  );  # maximum length of a line to still be considered 'short'
	has 'indent'	=> ( is => 'rw', isa => 'Int',  default => 2   );  # Mininum length of white space needed to consider line indented
	has 'trail'		=> ( is => 'rw', isa => 'Bool', default => 0   );  # include trailing white space in paragraphs?
	has 'ptag'		=> ( is => 'rw', isa => 'Str',  default => 'P' );  # Tag to be used to delimit paragraphs.
	has 'tabwidth'	=> ( is => 'rw', isa => 'Int',  default => '4' );  # Tab width (for indentation calculation)

	has 'blw'		=> ( is => 'rw', isa => 'Num',  default => 0.8 );  # blank 	      line weigth
	has 'slw'		=> ( is => 'rw', isa => 'Num',  default => 0.3 );  # short 	      line weigth
	has 'indw'		=> ( is => 'rw', isa => 'Num',  default => 0.3 );  # indented     line weigth
	has 'capw'		=> ( is => 'rw', isa => 'Num',  default => 0.2 );  # caps-started line weigth
	has 'ptres' 	=> ( is => 'rw', isa => 'Num',  default => 0.5 );  # Minimum confidence needed to consider paragraph

	method offsets (Str|ScalarRef[Str] $text) {
	}

	method split (Str|ScalarRef[Str] $text) {
	}

	method annotate (Str|ScalarRef[Str] $text) {
	}

	method _find (Str|ScalarRef[Str] $text) {
		$text = $$text if ref($text);
		my $clues1 = $self->_findshort(\$text);
		my $clues2 = $self->_findblank($text);
		my $clues3 = $self->_findindent(\$text);
		my $clues4 = $self->_findcap(\$text);
		my $clues  = [sort {$a->{start} <=> $b->{start}} (@$clues1,@$clues2,@$clues3,@$clues4)];
		dump $clues;
		return $clues;
	}


	method _findshort (Str|ScalarRef[Str] $text) {
		$text = $$text if ref($text);
		my $clues = [];
		my $l = $self->short;
		while($text =~ /^.{0,$l}$/gmp){
			my $line = ${^MATCH};
			my ($start,$end) = ($-[0],$+[0]);
			next if $line =~ /^\s*$/;			# blank line does not count
			push @$clues, {
				start 		=> $start,
				end			=> $end,
				type		=> 'short',
				confidence	=> $self->slw,
			};
		}
		return $clues;
	}

	method _findblank (Str|ScalarRef[Str] $text) {
		$text = $$text if ref($text);
		my $clues = [];
		while($text =~ /\n([ \t]*\n)+/g){
			push @$clues, {
				start		=> $-[0],
				end			=> $+[0],
				type		=> 'blank',
				confidence	=> $self->blw,
			}
		}
		return $clues;
	}

	method _findindent (Str|ScalarRef[Str] $text) {
		$text = $$text if ref($text);
		my $clues = [];
		while($text =~ /^[^\S\n]+/gpm){
			my ($start,$end) = ($-[0],$+[0]);
			my $indent = ${^MATCH};
			my $width = $self->tabwidth*($indent =~ s/\t//g);
			$width+= ($indent =~ s/ //g);
			push @$clues, {
				start		=> $start,
				end			=> $end,
				type 		=> 'indent',
				confidence	=> $self->indw,
			} if $width >= $self->indw;
		}
		return $clues;
	}

	method _findcap (Str|ScalarRef[Str] $text) {
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
	
	method _clues2gaps (ArrayRef[HashRef] $clues) {
		$clues  = [sort {$a->{start} <=> $b->{start}} @$clues];
		my $gaps = [];
		for (my $i = 0; $i<@$clues; $i++){
			my $order = ['short','blank','indent','caps'];
			my $c = $clues->[$i];
			my $merge = {};
			$merge->{start} 		= ( $c->{type} eq 'short' ? $c->{end} : $c->{start} );
			$merge->{end}   		=   $c->{end};
			$merge->{confidence} 	= $c->{confidence};
			shift @$order while $c->{type} ne $order->[0]; shift @$order;
			my $j = $i;
			while (	@$order 
				and ++$j
				and defined($clues->[$j]) 
				and $clues->[$j]{type} eq $order->[0] 
				and $merge->{end} == $clues->[$j]{start}){
					$merge->{end} 		=  $clues->[$j]{end};
					$merge->{confidence}+= $clues->[$j]{confidence};
					shift @$order;
			}
			$i=$j;
			push @$gaps, $merge if $merge->{confidence} > $self->ptres;
		}
		dump($gaps);
		return $gaps;
	}

	method _gaps2offsets (ArrayRef[HashRef] $gaps, Int $text_length) {
		my $offsets = [];
		my $start = 0;
		for my $g (@$gaps){
			my $end = $g->{start};
			push @$offsets, [$start,$end];
			$start = $g->{end};
		}
		push @$offsets, [$start,$text_length];
dump($offsets);
		return $offsets;
	}
}

1;

=method offsets

Finds paragraphs boundaries and returns a reference to an array of pairs, each consisting of a paragraph's first and last character offsets.

=method split

Split the paragraphs and returns them in an array reference.

=method annotate

Returns the original text with paragraphs annotated XML-style.

=cut

