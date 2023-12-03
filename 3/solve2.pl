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
    my $v = shift;
    if ($v ne "." && !looks_like_number($v)) {
        return 1;
    }

    return 0;
}

my %char;
sub add_hash {
    my ($i, $j, $num) = @_;
    #print "($i, $j, $num) ";
    my $key = join(",", $i, $j);
    if (!defined($char{$key})) {
        $char{$key} = [$num];
    } else {
        push @{$char{$key}}, $num;
    }
}

sub check {
    my $ret = 0;
    my ($input, $i, $j0, $j1, $num) = @_;
    my $row = $input->[$i];
    my ($bi, $bj, $ei, $ej);

    $bj = $j0 == 0 ? $j0 : $j0 - 1;
    $ej = $j1 == $#{$row} ? $j1 : $j1 + 1;
    if ($i != 0) {
        $bi = $i - 1; 
        for my $xj ($bj .. $ej) {
            my $v = $input->[$bi]->[$xj];
            if (detect($v)) {
                add_hash($bi, $xj, $num);
                $ret = 1;
            }
        }
    }

    if ($i != $#{$row}) {
        $bi = $i + 1;
        for my $xj ($bj .. $ej) {
            my $v = $input->[$bi]->[$xj];
            if (detect($v)) {
                add_hash($bi, $xj, $num);
                $ret = 1;
            }
        }
    }

    if ($j0 != 0) {
        $bi = $i;
        my $v = $input->[$bi]->[$j0 - 1];
        if (detect($v)) {
            add_hash($bi, $j0 -1, $num);
            $ret = 1;
        }
    }

    if ($j1 != $#{$row}) {
        $bi = $i;
        my $v = $input->[$bi]->[$j1 + 1];
        if (detect($v)) {
            add_hash($bi, $j1 + 1, $num);
            $ret = 1;
        }
    }

    return $ret;
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
    $num = join("", $input->[$i]->@[$$j .. $end]) + 0;
    if (check($input, $i, $$j, $end, $num)) {
        $$j = $end + 1;
    } else {
        $$j = $$j + 1;
    }
}

my $i = 0;
while ($i <= $#input) {
    my $row = $input[$i];
    my $j = 0;
    #print "line $i: ";
    while ($j <= $#{$row}) {
        process(\@input, $i, \$j);
    }
    #print "\n";
    $i ++;
}

#say Dumper(\%char);

my $ans = 0;
for my $k (keys %char) {
    if (@{$char{$k}} == 2) {
        $ans += $char{$k}->[0] * $char{$k}->[1];
    } 
}
say $ans;



