#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 1;
use Text::Paragraph::Splitter;
use Data::Dump qw/dump/;

my $text = <<'END'
    Dicta qui quis dolor. At repellendus accusamus harum voluptas est
ut. Reiciendis odit eos iure sit nisi architecto aut dignissimos.
Deserunt et et aut quibusdam reprehenderit doloremque error. Est
deleniti et dolorem.

    Dolor cumque optio et ea quis ut omnis. Consequuntur ex nulla cum
soluta. Maiores itaque ut dolores ratione et quia.

    Modi repudiandae animi voluptatem. Porro minus necessitatibus
sapiente. Commodi voluptatum ut ex ullam. Perferendis modi a ratione.
END
;

my $sp = Text::Paragraph::Splitter->new;
my $got = $sp->_findblank($text);
my $expected = [
  { confidence => 0.8, end => 223, start => 221, type => "blank" },
  { confidence => 0.8, end => 345, start => 343, type => "blank" },
];

is_deeply($got,$expected,"Finding blank lines");

