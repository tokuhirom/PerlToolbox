package PerlToolbox::Web;
use strict;
use warnings;
use utf8;
use parent qw/PerlToolbox Amon2::Web/;
use File::Spec;

# dispatcher
use PerlToolbox::Web::Dispatcher;
sub dispatch {
    warn $_[0]->req->env->{PATH_INFO};
    return (PerlToolbox::Web::Dispatcher->dispatch($_[0]) or die "response is not generated");
}

# load plugins
__PACKAGE__->load_plugins(
    'Web::FillInFormLite',
    'Web::CSRFDefender' => {
        post_only => 1,
    },
);

# setup view
use PerlToolbox::Web::View;
{
    sub create_view {
        my $view = PerlToolbox::Web::View->make_instance(__PACKAGE__);
        no warnings 'redefine';
        *PerlToolbox::Web::create_view = sub { $view }; # Class cache.
        $view
    }
}

# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;

        # http://blogs.msdn.com/b/ie/archive/2008/07/02/ie8-security-part-v-comprehensive-protection.aspx
        $res->header( 'X-Content-Type-Options' => 'nosniff' );

        # http://blog.mozilla.com/security/2010/09/08/x-frame-options/
        $res->header( 'X-Frame-Options' => 'DENY' );

        # Cache control.
        $res->header( 'Cache-Control' => 'private' );
    },
);

__PACKAGE__->add_trigger(
    BEFORE_DISPATCH => sub {
        my ( $c ) = @_;
        # ...
        return;
    },
);

1;
