#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 1;
use Text::Paragraph::Splitter;
use Data::Dump qw/dump/;

my $text = <<'END'
    Quam reprehenderit quos ut nulla autem. Id voluptas cum aliquid,
dolores repellendus et vero et. Non qui dicta deleniti maiores itaque id
neque. Consequuntur accusantium vel mollitia alias eius nulla:
consequuntur. Placeat repellat qui eum quidem.

    Voluptatem iusto dolor labore mollitia excepturi. Delectus eum velit
aut eum. Excepturi ut magnam perspiciatis quod qui voluptate dolor. Et
similique quia optio aliquam labore nemo dolorem aut.

    Perferendis sunt dolore modi. Quia quia harum aut dignissimos -
accusamus voluptatem. Quidem commodi ea dolorum aliquid esse deserunt
voluptas consequatur. Facilis ipsum sint quod eveniet provident!
Provident quia sequi est fugit beatae omnis. Maxime exercitationem
repellendus natus tempore?

END
;


my $sp = Text::Paragraph::Splitter->new;
my $got = $sp->_findpunct($text);
my $expected = [
  { confidence => -0.5, end => 68, start => 67, type => "punctuation" },
  { confidence => -0.5, end => 204, start => 203, type => "punctuation" },
  { confidence => -0.5, end => 519, start => 518, type => "punctuation" },
  { confidence => 0.2, end => 251, start => 250, type => "punctuation" },
  { confidence => 0.2, end => 450, start => 449, type => "punctuation" },
  { confidence => 0.2, end => 654, start => 653, type => "punctuation" },
  { confidence => 0.2, end => 748, start => 747, type => "punctuation" },
];
is_deeply($got,$expected,"Finding punctiation-ending lines");

