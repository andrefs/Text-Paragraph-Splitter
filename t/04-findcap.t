#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 1;
use Text::Paragraph::Splitter;
use Data::Dump qw/dump/;

my $text = <<'END'
    Ea deleniti deserunt sed illum et dolores voluptate ratione. Quia
totam aut voluptatem. Dolor voluptate error laborum sed dolores
corporis. Ut molestiae laboriosam porro suscipit. Ipsa et dolorem
voluptas ut blanditiis et.

    Voluptatem nisi animi sequi eveniet dolore ipsam incidunt unde. Nisi
qui itaque reiciendis sed ea ipsam. Id provident praesentium
voluptatibus cupiditate. Nulla iusto sequi laboriosam minus molestias.
Occaecati possimus quia dolores perferendis aut non eos sunt. Ut
repudiandae eligendi autem.

    Voluptates voluptas quibusdam sed quo reiciendis ut doloremque.
Tempora similique et vel delectus corporis nemo eum aut. Et aliquid id
facere. Unde mollitia accusamus debitis.

END
;

my $sp = Text::Paragraph::Splitter->new;
my $got = $sp->_findcap($text);
my $expected = [
  { confidence => 0.2, end => 5, start => 4, type => "caps" },
  { confidence => 0.2, end => 233, start => 232, type => "caps" },
  { confidence => 0.2, end => 434, start => 433, type => "caps" },
  { confidence => 0.2, end => 532, start => 531, type => "caps" },
  { confidence => 0.2, end => 596, start => 595, type => "caps" },
];

is_deeply($got,$expected,"Finding caps-started lines");

