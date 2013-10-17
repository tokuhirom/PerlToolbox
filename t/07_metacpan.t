use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;
use Test::Power;
use Data::Dumper;

use PerlToolbox::MetaCPAN;

my $mc = PerlToolbox::MetaCPAN->new();
my $favs = $mc->dist_feavorites('Test-Power');
expect { exists $favs->{hits}{total} };
note Dumper($favs);

my $user = $mc->user('1tGkRYqZQr63HmlobKhT4A');
expect { $user->{hits}{hits}[0]{_source}{pauseid} eq 'TOBYINK' };
note Dumper($user);

done_testing;

