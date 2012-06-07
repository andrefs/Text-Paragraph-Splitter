#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 1;
use Text::Paragraph::Splitter;
use Data::Dump qw/dump/;

my $text = <<'END'
    Aut sapiente voluptas aut aut harum sed. Hic atque quibusdam
molestiae. Laboriosam architecto perspiciatis ut qui.

    Eum consequatur sed sint voluptate. Magni magni cum id sed
voluptatem sit ex. Excepturi similique sed voluptates velit quasi vitae
tempore.

    Incidunt autem voluptates excepturi sunt velit optio. Consequatur ex
est fugiat rerum non. Sunt est ratione molestiae ea vero. Ipsum facere
ut vel. Et rerum id recusandae tenetur temporibus est blanditiis.
Voluptatem cum quo itaque soluta aut et cum sunt.

END
;

my $sp = Text::Paragraph::Splitter->new;
my $got = $sp->_findshort($text);
my $expected = [
  { confidence => 0.3, end => 263, start => 255, type => "short" },
  { confidence => 0.3, end => 524, start => 476, type => "short" },
];

is_deeply($got,$expected,"Finding short lines");

