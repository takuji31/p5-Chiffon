package  Chiffon::Web::Context;
use Chiffon::Core;
use Plack::Session;

use parent qw/Class::Data::Inheritable/;

use Class::Accessor::Lite (
    new => 1,
    ro  => [qw/ env req res config view dispatcher /],
    rw  => [qw/ dispatch_rule /],
);

__PACKAGE__->mk_classdata(
    default_response_header => [
        'Content-Type' => 'text/html;charset=UTF-8',
    ],
);

sub stash : lvalue {
    shift->{stash};
}
sub template { shift->{dispatch_rule}->{template} }
*request  = \&req;
*response = \&res;

sub session {
    my $self = shift;
    $self->{session} ||= Plack::Session->new( $self->env );
}

sub uri_with {
    my ( $self, $args ) = @_;

    Carp::carp('No arguments passed to uri_with()') unless $args;

    for my $value ( values %{$args} ) {
        next unless defined $value;
        for ( ref $value eq 'ARRAY' ? @{$value} : $value ) {
            $_ = "$_";
            utf8::encode($_);
        }
    }

    $self->load_class('URI::QueryParam');

    my $uri = $self->req->uri->clone;
    $uri->query_form( { %{ $uri->query_form_hash }, %{$args}, } );
    return $uri;
}

sub finalize {
    my $self     = shift;
    $self->res->finalize;
}

sub redirect {
    my $class = shift;
    $class->res->redirect(@_);
    detach;
}

sub handle_response {
    my ( $self, $body, $status, $header ) = @_;

    $status ||= 200;
    $header ||= $self->default_response_header;

    my $res = $self->res;
    $res->status($status);
    $res->headers($header);
    $res->body($body);
}


1;
