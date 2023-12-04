#!/usr/bin/env perl
use v5.38;
use Data::Dumper;

my $s = "aaa";
my @a = grep /a/, $s;
say scalar @a;
my @b = grep /a/, (split //, $s); 
say scalar @b;
my @c = 0 x 2;
print Dumper(\@c);
for (1 .. -1) {
    say "he";
}

my $f = $ARGV[0];
while (<>) {
    print;
}

open ARGV, "<", $f;
while (<>) {
    print;
}
