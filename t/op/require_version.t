#!perl

# tests for proposed require_version()
#
# require_version returns true if the version is <= the current Perl version.
# It throws an exception otherwise.

use strict;
use warnings;

BEGIN { require './test.pl'; }

note "Testing good versions"; {
    my @good_versions = (
        4,
        5,
        5.014,
        5.14.0,
        v5.14.0,
        5.005_63,
        $],
        $] - 0.000_001,
    );

    for my $version (@good_versions) {
        ok require_version $version, $version;
    }
}


note "Testing bad versions"; {
    my @bad_versions = (
        6,
        10.0.2,
        $] + 0.000_001,
        "blah",
        "",
        " ",
        " 5 ",
        undef,
        "5\n",
    );

    for my $version (@bad_versions) {
        ok !eval { require_version $version }, $version;
    }
}


note "Testing wrong # of args"; {
    ok !eval "require_version()";
    ok !eval "require_version(5, 5)";
}


note "Testing does not load modules"; {
    ok !eval { require_version("integer") };
    ok !eval { require_version("./test.pl") };
}

done_testing;
