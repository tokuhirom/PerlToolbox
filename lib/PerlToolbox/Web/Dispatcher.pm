package PerlToolbox::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;
use PerlToolbox::Data;
use PerlToolbox::MetaCPAN;

get '/' => sub {
    my ($c) = @_;
    return $c->render('index.tx', {
        categories => [PerlToolbox::Set::Category->all()],
    });
};

any '/category/{name:.+}' => sub {
    my ($c, $args) = @_;

    my $category = PerlToolbox::Set::Category->retrieve($args->{name});
    return $c->render('category.tx', {
        category => $category,
    });
};

1;
