#!/usr/bin/env perl
use v5.38;
use Data::Dumper;


my $ans = 0;
while (<>) {
    chomp;
    my @nums = split /\s*\|\s*/, (split /\s*:\s*/)[1];
    my @left = split /\s+/, $nums[0]; 
    my @right = split /\s+/, $nums[1];
    my $p = 0;
    for my $n (@left) {
        my @ret = grep {$n eq $_} @right;
        for (@ret) {
            if ($p == 0) {
                $p = 1;
                next;
            }
            $p <<= 1;
        }
    }
    $ans += $p;
}
say $ans;
