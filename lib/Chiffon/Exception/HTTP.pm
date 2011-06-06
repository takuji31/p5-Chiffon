package  Chiffon::Exception::HTTP;
use strict;
use warnings;

use parent qw/Chiffon::Exception/;

use Class::Accessor::Lite (
    new => 1,
    rw => [qw/ res /],
);

sub response { croak("Please override response method!") }

package  Chiffon::Exception::HTTP::Success;
use parent qw/Chiffon::Exception::HTTP/;

sub response {
    my $self = shift;
    my $res  = $self->res;

    if( ref($res) eq 'ARRAY' ) {
        return $res;
    } elsif ( ref($res) eq 'HASH' ) {
        return [
            $res->{status},
            $res->{headers},
            [$res->{body}],
        ];
    } elsif ( ref($res) && $res->isa('Plack::Response') ) {
        return $res->finalize;
    } else {
        return [
            200,
            ['Content-Type' => 'text/html', 'Content-Length' => length $res],
            [$res],
        ];
    }
}



package  Chiffon::Exception::HTTP::NotFound;
use parent qw/Chiffon::Exception::HTTP/;

sub response {
    my $self = shift;
    my $res  = $self->res;
    my $headers;
    my $body;
    if (ref($res) eq 'HASH') {
        $headers = $res->{headers};
        $body    = $res->{body};
    } else {
        $body = $res;
    }
    $body    ||= '404 Not Found';
    $headers ||= [ 'Content-Type' => 'text/plain', 'Content-Length' => length $body ];

    return [
        404,
        $headers,
        [$body],
    ];
}

package  Chiffon::Exception::HTTP::Redirect;
use parent qw/Chiffon::Exception::HTTP/;

sub response {
    my $self = shift;
    my $location = $self->{location};
    my $body = 'Redirect';
    my $headers = [ 'Content-Type' => 'text/plain', 'Content-Length' => length $body, 'Location' => $location ];

    return [
        302,
        $headers,
        [$body],
    ];
}


1;
