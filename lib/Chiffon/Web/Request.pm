package  Chiffon::Web::Request;
use Chiffon;

use parent qw/Plack::Request/;

sub is_post_request { $_[0]->method eq 'POST' }

sub http_host { $_[0]->env->{HTTP_HOST} }

1;
