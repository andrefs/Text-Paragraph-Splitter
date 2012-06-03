use strict; use warnings;
use MooseX::Declare;

# ABSTRACT: Guesses the notation used for paragraphs to split them.


class Text::Paragraph::Splitter {
	has 'blw'	=> ( is => 'rw', isa => Num,  default => 0.8 );  # blank line weigth
	has 'sl' 	=> ( is => 'rw', isa => Int,  default => 50  );  # short length
	has 'slw'	=> ( is => 'rw', isa => Num,  default => 0.5 );  # short line weigth
	has 'indl'	=> ( is => 'rw', isa => Int,  default => 2   );  # Mininum length of white space needed to consider line indented
	has 'indw'	=> ( is => 'rw', isa => Num,  default => 0.3 );  # indented line weigth
	has 'ie'	=> ( is => 'rw', isa => Bool, default => 0   );  # include trailing white space in paragraphs?
	has 'ptag'	=> ( is => 'rw', isa => Str,  default => 'P' );  # Tag to be used to delimit paragraphs.
	has 'ptres' => ( is => 'rw', isa => Num,  default => 0.5 );  # Minimum confidence needed to consider paragraph

	method offsets (Str|ScalarRef[Str] $text) {
	}

	method split (Str|ScalarRef[Str] $text) {
	}

	method annotate (Str|ScalarRef[Str] $text) {
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

