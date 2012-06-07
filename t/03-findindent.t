#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 1;
use Text::Paragraph::Splitter;
use Data::Dump qw/dump/;

my $text = <<'END'
    Et et adipisci natus et sed dolorem. Necessitatibus earum dolorem
aut. Facere officia et culpa eos labore saepe. Cum impedit commodi cum.

    Ex quia dolorum dolorem. Perferendis impedit sint in ex. Non aut
facilis et. Animi quo quo facilis aspernatur est ut qui. Consequuntur
consequatur laborum maxime. Et laborum explicabo itaque dolores sed.

    Fuga accusamus vitae veniam et soluta a impedit. Qui qui nisi sequi
laboriosam cupiditate provident vel deleniti. Dolores ea ut voluptates
voluptatibus expedita adipisci.

END
;

my $sp = Text::Paragraph::Splitter->new;
my $got = $sp->_findindent($text);
my $expected = [
  { confidence => 0.3, end => 4, start => 0, type => "indent" },
  { confidence => 0.3, end => 147, start => 143, type => "indent" },
  { confidence => 0.3, end => 356, start => 352, type => "indent" },
];
is_deeply($got,$expected,"Finding indented lines");

