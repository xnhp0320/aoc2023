#!/usr/bin/env perl
use v5.38;
use Data::Dumper;


sub process_guess {
    my $in = shift;
    my ($lr, $lb, $lg) = (0, 0, 0);
    

    for my $str (@$in) {
        my @colors = split /,/, $str;
        for my $c (@colors) {
            my ($r, $b, $g);
            $g = $1 if $c =~ /(\d+) green/;
            $b = $1 if $c =~ /(\d+) blue/;
            $r = $1 if $c =~ /(\d+) red/;

            if (defined($r)) {
                $lr = $r > $lr ? $r : $lr; 
            }
            if (defined($b)) {
                $lb = $b > $lb ? $b : $lb; 
            }
            if (defined($g)) {
                $lg = $g > $lg ? $g : $lg; 
            }
        }
    }
    return ($lr,$lb,$lg);
}

sub process_game {
    my $in = shift;
    my @cubes = split /;/, $in;
    my ($lr, $lb, $lg) = (0, 0, 0);

    my ($red, $blue, $green) = process_guess(\@cubes);

    $lr = $red > $lr ? $red : $lr;
    $lb = $blue > $lb ? $blue : $lb;
    $lg = $green > $lg ? $green : $lg;

    if ($lr <= 12 && $lg <= 13 && $lb <= 14) {
        return 1;
    } else {
        return 0;
    }
}

my $ans = 0;
while (<>) {
    chomp;
    my @game = split /:/;
    $game[0] =~ /Game (\d+)/;
    my $gid = $1;
    if (process_game($game[1])) {
        $ans += $gid;
    }
}

say $ans;


