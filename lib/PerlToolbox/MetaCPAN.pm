package PerlToolbox::MetaCPAN;
use strict;
use warnings;
use utf8;
use 5.010_001;
use mop;

class PerlToolbox::MetaCPAN {
    use JSON::XS;
    use URI::Escape;
    use Furl;
    use Carp;
    use Log::Minimal;
    use Cache::FileCache;

    has $!ua is ro = Furl->new();
    has $!cache is ro = Cache::FileCache->new({namespace => __PACKAGE__, default_expires_in => 60*60});
    has $!base_uri is ro = 'http://api.metacpan.org';

    # Get favorited user names
    method dist_feavorites($dist_name) {
        $self->get("/v0/favorite/_search?q=distribution:@{[ uri_escape $dist_name ]}&fields=user&size=1000");
    }
    # Users
    method user($user_hash) {
        $self->get("/v0/author/_search?q=user:@{[ uri_escape $user_hash ]}", '1 day');
    }

    method get($path, $cache_seconds="60 minutes") {
        my $uri = $!base_uri . $path;
        {
            my $cached = $!cache->get($path);
            if ($cached) {
                return $cached;
            }
        }
        my $res = $!ua->get($uri);
        infof("%s %s", $uri, $res->code);
        unless ($res->is_success) {
            croak(
                "REQUEST:\n".
                $res->request->as_string.
                "\n".
                "RESPONSE:\n".
                $res->as_string
            );
        }
        my $dat = decode_json($res->content);
        $!cache->set($path, $dat, $cache_seconds);
        return $dat;
    }
}


1;

