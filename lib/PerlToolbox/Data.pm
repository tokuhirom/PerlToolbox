package PerlToolbox::Data;
use strict;
use warnings;
use utf8;
use 5.010_001;
use mop;

sub c() { PerlToolbox->context() }

class PerlToolbox::User {
    has $!asciiname is ro;
    has $!pauseid is ro;
    has $!country is ro;
    has $!gravatar_url is ro;
}

class PerlToolbox::Module {
    use Log::Minimal;

    has $!name is ro;

    has $!favs_cache is lazy = $_->_build_favs_cache();
    
    method _build_favs_cache() {
        my $mc = c->metacpan;
        my $favs = $mc->dist_feavorites($!name);
        my $anonymous_cnt = 0;
        my @users;
        for my $user_hash (map { $_->{fields}{user} } @{$favs->{hits}->{hits}}) {
            my $user = eval { $mc->user($user_hash)->{hits}{hits}[0]{_source} };
            if ($@) {
                warnf("%s", $@);
                next;
            }

            if (defined $user) {
                push @users, PerlToolbox::User->new($user);
            } else {
                $anonymous_cnt++;
            }
        }
        [\@users, $anonymous_cnt];
    };

    method favs() {
        $!favs_cache->[0];
    }
    method faved_anonymous() {
        $!favs_cache->[1];
    }
}

class PerlToolbox::Category {
    use URI::Escape qw(uri_escape);

    has $!name is ro;
    has $!description is ro;
    has $!modules is ro;

    method new ($class: $args) {
        $args->{modules} = [map { PerlToolbox::Module->new(name => $_) } @{$args->{modules}}];
        $class->next::method( $args );
    }

    method path() {
        '/category/' . uri_escape($!name);
    }
}

class PerlToolbox::Set::Category {
    our @CATEGORIES = map { PerlToolbox::Category->new($_) } (
        {
            name => 'Class Builder',
            description => 'Modules to create class',
            modules => [
                'Moose',
                'Moo',
                'Mouse',
                'Any::Moose',
                'Class-Accessor',
                'Class-Accessor-Lite',
                'Class-Accessor-Lite-Lazy',
                'mop',
            ],
        },
        {
            name => 'O/R Mapper',
            description => 'Database and Object mapping library',
            modules => [
                'Teng',
                'DBIx-Class',
            ],
        },
    );

    method all {
        @CATEGORIES
    }
    method retrieve($name) {
        my ($category) = grep { $_->name eq $name } @CATEGORIES;
        return $category;
    }
}

1;

