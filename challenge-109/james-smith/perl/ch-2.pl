#!/usr/local/bin/perl

use strict;

use warnings;
use feature qw(say);
use Test::More;

## Although not given in the question we will assume that the 7 numbers are unique...
## this will be our primary solution...
## We will provide an alternative solution which works when numbers are not-unique...
##
## Before we start we want to apply some logic to reduce the search
## space.
##
## We know that
##
##   a+b + b+c+d + d+e+f + f+g = 4 n
##
## Therefore if we know b,d & f then we can easily work out the total
## for each square (n) ...
##
## The sum above can be re-written as:
##
##   t + b+d+f = 4 n
##
## where t is the total of the seven numbers.
##
## Additionally
##
## If we know b,d,f we can compute a, c, e, g in terms of b, d, f and n:
##
##   a = n - b
##   c = n - b - d = a - d
##   e = n - f - d = g - d
##   g = n - f
##
## This means we do not need to use a full permutation of the numbers...
## Just three loops for b, d & f.
##
## I will present two solutions below - one for cases where there each of the numbers
## are unique and one where duplicates are allowed.
##


say '';
sep(); show( four_square( 1..7            ) );
sep(); show( four_square( -2 .. 4 ) );
sep(); show( four_square( 1,2,3,4,8,9,10  ) );
sep(); show( four_square( 12,2,7,4,8,9,10 ) );
sep();

say '';
sep(); show( four_square_non_unique( 1..7            ) );
sep(); show( four_square_non_unique( -2 .. 4         ) );
sep(); show( four_square_non_unique( 1,2,3,4,8,9,10  ) );
sep(); show( four_square_non_unique( 12,2,7,4,8,9,10 ) );
sep(); show( four_square_non_unique( 1,1,1,2,2,3,3   ) );
sep(); show( four_square_non_unique( 1,1,1,2,2,1,1   ) );
sep();
say '';

## Two helper functions for the dispaly...
sub sep  { say '------------------------------------------------------------------------'; }
sub show { say "@{$_}" foreach @{$_[0]}; }

sub four_square {
  my @n1 = @_;
  my @res;
  my $t = 0;
     $t+=$_ foreach @n1;

## For a start we make the observation that
##
## $a + 2$b + $c + 2$d + $e + 2$f + $g = $n * 4 where $n is the total of a square
##
## $a +  $b + $c +  $d + $e +  $f + $g = $t     where $t is the total of the numbers
##
## Therefore we know that the $n = ( $t + $b + $d + $f ) / 4
## Once we know $b, $d, $f we can compute $n (and check that it is a whole number!
## if knot we know there are no solutions!)
##
## If we have $b, $d, $f & $n - then we can work out $a, $c, $e, $g
##
## $a = $n - $b
## $c = $n - $b - $d = $a - $d;
## $g = $n - $f
## $e = $n - $f - $d = $g - $d;
##
## We check to see if these 4 values are in the remaining list and that they
## are unique....
##
## We use a hash here... delete returns the value deleted (if any so we don't need
## to split the next inequality info a exists & delete as we can do this in one..
##
## We push any valid results to the array
  foreach my $b ( @n1 ) {
    foreach my $f ( my @n2 = grep { $_ - $b } @n1 ) {
      ## next if $b > $f; ### Check for order here so that we can get rid of dupes
      foreach my $d ( my @n3 = grep { $_ - $f } @n2 ) {
        my $n = $t + $b + $d + $f;  ### really 4n...
        next if $n & 3;             ### n must be a whole number
        $n/=4;
        my %X = map { $_ => 1 } @n3;
        delete $X{$d};
        my $a = $n-$b;
        next unless defined delete $X{$a};
        my $g = $n-$f;
        next unless defined delete $X{$g};
        my $c = $a-$d;
        next unless defined delete $X{$c};
        my $e = $g-$d;
        next unless exists $X{$e};
        push @res, [ $a, $b, $c, $d, $e, $f, $g ];
      }
    }
  }
  return \@res;
}

sub four_square_non_unique {
  my @n1 = @_;
  my %res;
  my $t = 0;
     $t+=$_ foreach @n1;

## Now let us make no assumption about the numbers...
## We choose 3 from the list...
## We then compute n (and check for no remainder)
## We compute the other 4 numbers..
## Stitch them together in to two strings...
## String 1 - sorted in order so we can compare it
##            with the original list.... ($check)
## String 2 - unsorted so we can remove duplicate
##            values {if a number is not unique we
##            will end up with 2 entries in the list
##            where you swap the equivalent values...

  my $check = "@{[ sort @n1 ]}";
  foreach my $i ( 0..@n1-1 ) {
    my $b = $n1[$i];
    my @n2 = map { $_ == $i ? () : $n1[$_] } 0..@n1-1;
    foreach my $j ( 0..@n2-1 ) {
      my $f  = $n2[$j];
      my @n3 = map { $_ == $i ? () : $n2[$_] } 0..@n2-1;
      foreach my $k ( 0..@n3-1 ) {
        my $d = $n3[$k];
        my $n = $t + $b + $d + $f;
        next if $n & 3;
        $n/=4;
        my $a = $n-$b;
        my $g = $n-$f;
        my $c = $a-$d;
        my $e = $g-$d;
        my $val =  "@{[ sort $a,$b,$c,$d,$e,$f,$g ]}";
        next unless $check eq $val;
        my $key =  "@{[ $a,$b,$c,$d,$e,$f,$g ]}";
        next if exists $res{$key};
        $res{$key} = [ $a, $b, $c, $d, $e, $f, $g ];
      }
    }
  }
  return [values %res];
}

