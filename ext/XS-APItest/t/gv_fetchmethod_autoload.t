#!perl

use strict;
use warnings;

use Test::More tests => 22; #34;

use_ok('XS::APItest');

my $autoload = 1;
my @types    = map { 'gv_fetchmethod_autoload' . $_ } '', qw( _sv _pv _pvn );

sub AUTOLOAD { our $AUTOLOAD; }

ok XS::APItest::gv_fetchmethod_autoload_type(\%::, "nothing", 1, $autoload, 0);

for my $type ( 0..3 ) {
    is XS::APItest::gv_fetchmethod_autoload_type(\%::, "method", $type, $autoload, 0), "*main::AUTOLOAD", "*main::AUTOLOAD if autoload is true in $types[$type].";
    ok !XS::APItest::gv_fetchmethod_autoload_type(\%::, "method", $type, !$autoload, 0), "...but turning it off means we get nothing";
}

{
    no warnings 'once';
    *method = sub { 1 };
}

for my $type ( 0..3 ) {
    is XS::APItest::gv_fetchmethod_autoload_type(\%::, "method", $type, $autoload, 0),
        "*main::method", "But no matter the setting, we get *main::method if it exists.";
    is XS::APItest::gv_fetchmethod_autoload_type(\%::, "method", $type, !$autoload, 0),
        "*main::method";
}

$autoload = 0;
ok XS::APItest::gv_fetchmethod_autoload_type(\%::, "method\0not quite!", 0, $autoload, 0), "gv_fetchmethod_autoload() is not nul-clean";
ok !XS::APItest::gv_fetchmethod_autoload_type(\%::, "method\0not quite!", 1, $autoload, 0), "gv_fetchmethod_autoload_sv() is nul-clean";
is XS::APItest::gv_fetchmethod_autoload_type(\%::, "method\0not quite!", 2, $autoload, 0), "*main::method", "gv_fetchmethod_autoload_pv() is not nul-clean";
ok !XS::APItest::gv_fetchmethod_autoload_type(\%::, "method\0not quite!", 3, $autoload, 0), "gv_fetchmethod_autoload_pvn() is nul-clean";

=begin
{
    use utf8;
    use open qw( :utf8 :std );

    package ｍａｉｎ;

    sub AUTOLOAD { our $AUTOLOAD; }

    $autoload = 1;
    for my $type ( 1..3 ) {
        ::is XS::APItest::gv_fetchmethod_autoload_type(\%ｍａｉｎ::, "ｍｅｔｈｏｄ", $type, $autoload, 0), "*ｍａｉｎ::AUTOLOAD";
        ::is XS::APItest::gv_fetchmethod_autoload_type(\%ｍａｉｎ::, "method", $type, $autoload, 0), "*ｍａｉｎ::AUTOLOAD";
        
        {
            no strict 'refs';
            ::ok !XS::APItest::gv_fetchmethod_autoload_type(
                            \%{"\357\275\215\357\275\201\357\275\211\357\275\216::"},
                            "ｍｅｔｈｏｄ", $type, $autoload, 0);
            ::ok !XS::APItest::gv_fetchmethod_autoload_type(
                            \%{"\357\275\215\357\275\201\357\275\211\357\275\216::"},
                            "method", $type, $autoload, 0);
        }
    }
}
=cut
