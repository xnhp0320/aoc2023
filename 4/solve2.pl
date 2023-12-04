#!/usr/bin/env perl
use v5.38;
use Data::Dumper;


say $ARGV[0];
open my $f, "<", $ARGV[0] or die $!;

my $l = 0;
while (<$f>) {
    $l ++;
}
say $l;
my @v = (1) x $l;
use Data::Dumper;

my $i = 0;
my $ans = 0;
while (<>) {
    chomp;
    my @nums = split /\s*\|\s*/, (split /\s*:\s*/)[1];
    my @left = split /\s+/, $nums[0]; 
    my @right = split /\s+/, $nums[1];
    my $m = 0;
    for my $n (@left) {
        my @ret = grep {$n eq $_} @right;
        $m += @ret;
    }
    my $j = $i;
    for (0 .. $m - 1) {
        if ($j == $l - 1) {
            last;
        }
        $v[++$j] += $v[$i]; 
    }
    $i ++;
}
#print Dumper(\@v);

$ans += $_ for (@v);
say $ans;
