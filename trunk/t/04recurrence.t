#!/usr/bin/perl -w

use strict;

use Test::More;
plan tests => 9;

use DateTime;
use DateTime::Duration;
use DateTime::Set;
# use warnings;

#======================================================================
# recurrence
#====================================================================== 

use constant INFINITY     =>       100 ** 100 ** 100 ;
use constant NEG_INFINITY => -1 * (100 ** 100 ** 100);

my $res;

my $t1 = new DateTime( year => '1810', month => '08', day => '22' );
my $t2 = new DateTime( year => '1810', month => '11', day => '24' );
my $s1 = DateTime::Set->from_datetimes( dates => [ $t1, $t2 ] );

my $month_callback = sub {
            $_[0]->truncate( to => 'month' );
            # warn " truncate = ".$_[0]->ymd;
            $_[0]->add( months => 1 );
            # warn " add = ".$_[0]->ymd;
            return $_[0];
        };

# "START"
my $months = DateTime::Set->from_recurrence( 
    recurrence => $month_callback, 
    start => $t1,
);
$res = $months->min;
$res = $res->ymd if ref($res);
is( $res, '1810-09-01', 
    "min()" );
$res = $months->max;
$res = $res->ymd if ref($res);
is( $res, INFINITY,
    "max()" );

# "END"
$months = DateTime::Set->from_recurrence(
    recurrence => $month_callback,
    end => $t1,
);
$res = $months->min;
$res = $res->ymd if ref($res);
is( $res, NEG_INFINITY,
    "min()" );

TODO: {
   local $TODO = 'max is broken if recurrence is intersected';
$res = $months->max;
$res = $res->ymd if ref($res);
is( $res, '1810-09-01',   
    "max()" );
}

# "START+END"
$months = DateTime::Set->from_recurrence(
    recurrence => $month_callback,
    start => $t1,
    end => $t2,
);
$res = $months->min;
$res = $res->ymd if ref($res);
is( $res, '1810-09-01',
    "min()" );

TODO: {
   local $TODO = 'max is broken if recurrence is intersected';
$res = $months->max;
$res = $res->ymd if ref($res);
is( $res, '1810-12-01',
    "max()" );
}

# "START+END" at recurrence 
$t1->set( day => 1 );  # month=8
$t2->set( day => 1 );  # month=11
$months = DateTime::Set->from_recurrence(
    recurrence => $month_callback,
    start => $t1,
    end => $t2,
);
$res = $months->min;
$res = $res->ymd if ref($res);
is( $res, '1810-08-01',
    "min()" );

TODO: {
   local $TODO = 'max is broken if recurrence is intersected';
$res = $months->max;
$res = $res->ymd if ref($res);
is( $res, '1810-12-01',
    "max()" );
}

TODO: {
   local $TODO = 'max is broken if recurrence is intersected';
# verify that the set-span when backtracking is ok.
# This is _critical_ for doing correct intersections
$res = $months->intersection( DateTime->new( year=>1810, month=>12, day=>1 ) );
$res = $res->max;
$res = $res->ymd if ref($res);
is( $res, '1810-12-01',
    "intersection at the recurrence" );
}

1;

