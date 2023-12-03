#!/usr/bin/env perl
use warnings;
use strict;
use v5.38;
use Scalar::Util qw( looks_like_number );

my $ans = 0;
while (<>) {
    my @c = split //;
    my @ret;
    my $num = "";
    for my $c (@c) {
        if (looks_like_number($c)) {
            push @ret, $c;
        } 
    }
    if (@ret == 1) {
        $num = $ret[0] . $ret[0];
    }

    if (@ret == 2) {
        $num = $ret[0] . $ret[1];
    }

    if (@ret > 2) {
        $num = $ret[0] . $ret[-1];
    }
    $ans += $num;
}

say $ans;
