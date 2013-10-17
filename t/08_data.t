use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

use PerlToolbox::Data;
use Test::Power;

my $c = PerlToolbox->bootstrap();

my $module = PerlToolbox::Module->new(name => 'Furl');
expect { $module->isa('PerlToolbox::Module') };
expect { $module->can('name') && $module->name eq 'Furl' };
expect { $module->favs };

done_testing;

