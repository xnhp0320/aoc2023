#!/usr/bin/env perl
use warnings;
use strict;
use v5.38;
use Scalar::Util qw( looks_like_number );
use Data::Dumper;

my $ans = 0;
my @digits = (
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine");

sub digit_word {
    my $array = shift;

    my $idx = shift;
    my $end = shift;
    my $tlen = $#{$array} - $idx + 1;
    my $ret = 0;

    for my $id (0 .. $#digits) {
        my $d = $digits[$id];
        my $len = length($d);
        if ($len > $tlen) {
            next;
        }

        my $test_str = join("", @$array[$idx .. $idx + $len - 1]);
        if ($test_str eq $d) {
            $$end = $len;
            $ret = $id + 1;
            last;
        }
    }
    return $ret;
}

while (<>) {
    chomp;
    my @c = split //;
    my @ret;
    my $idx = 0;
    next if ($#c == -1);

    while ($idx <= $#c) {
        if (looks_like_number($c[$idx])) {
            push @ret, $c[$idx];
            $idx ++;
            next;
        }

        my $end;
        if (my $id = digit_word(\@c, $idx, \$end)) { 
            push @ret, $id; 
            # $idx += $end;
            $idx ++;
        } else {
            $idx ++;
        }
    }
    print Dumper(\@ret);

    my $num;
    if (@ret == 1) {
        $num = $ret[0] . $ret[0];
    }

    if (@ret == 2) {
        $num = $ret[0] . $ret[1];
    }

    if (@ret > 2) {
        $num = $ret[0] . $ret[-1];
    }
    say $num;
    $ans += $num;
}
say $ans;

