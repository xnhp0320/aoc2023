#!/usr/bin/env perl
use v5.38;
use Data::Dumper;
use Scalar::Util qw( looks_like_number );


my @input;
while (<>) {
    chomp;
    my @row = split //;
    push @input, \@row;
}

sub detect {
    my ($input, $i, $j) = @_;
    my $v = $input->[$i]->[$j];
    if ($v ne "." && !looks_like_number($v)) {
        return 1;
    }

    return 0;
}

sub check {
    my ($input, $i, $j) = @_;
    my $row = $input->[$i];
    if ($j < $#{$row} && detect($input, $i, $j+1)) {
        return 1;
    }
    if ($i < $#{$input} && detect($input, $i+1, $j)) {
        return 1;
    }
    if ($j < $#{$row} && $i < $#{$input} && detect($input, $i+1, $j+1)) {
        return 1;
    }

    if ($i > 0 && detect($input, $i - 1, $j)) {
        return 1;
    }

    if ($j > 0 && detect($input, $i, $j -1 )) {
        return 1;
    }

    if ($i > 0 && $j > 0 && detect($input, $i - 1, $j - 1)) {
        return 1;
    }

    if ($i > 0 && $j < $#{$row} && detect($input, $i-1, $j +1)) {
        return 1;
    }

    if ($j > 0 && $i < $#{$input} && detect($input, $i+1, $j-1)) {
        return 1;
    }

    return 0;
}

sub process {
    my ($input, $i, $j) = @_;
    my $v = $input->[$i]->[$$j];

    if (!looks_like_number($v)) {
        $$j = $$j + 1;
        return 0;
    }

    my $num = 0;
    my $col = $$j;
    my $row = $input->[$i];
    while ($col <= $#{$row}) {
        $v = $input->[$i]->[$col];
        if (!looks_like_number($v)) {
            last;
        }
        $col ++;
    }

    my $end = $col > $$j ? $col - 1 : $col;
    my $check = 0;
    for my $c ($$j .. $end) {
        if (check($input, $i, $c)) {
            $check = 1;
            last;
        }
    }
    
    if ($check) {
        #say "$i ", "$$j ", $end;
        #print $input->[$i]->@[$$j .. $end], " ";
        $num = join("", $input->[$i]->@[$$j .. $end]) + 0;
        $$j = $end + 1;
    } else {
        $$j = $$j + 1;
    }
    
    return $num;
}

my $ans = 0;
my $i = 0;
while ($i <= $#input) {
    my $row = $input[$i];
    my $j = 0;
    #print "line $i: ";
    while ($j <= $#{$row}) {
        $ans += process(\@input, $i, \$j);
    }
    #print "\n";
    $i ++;
}

say $ans;

