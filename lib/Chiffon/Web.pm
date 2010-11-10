package Chiffon::Web;
use Chiffon;
use Chiffon::Utils;
use Chiffon::Web::Request;
use Chiffon::Web::Response;

sub import {
    my $class  = shift;
    my $caller = caller;

    #Export method
    my @methods
        = qw/new app env create_dispatcher get_dispatcher dispatch dispatcher
        view container plugin handle_response req res/;
    for my $method (@methods) {
        $class->add_method( $caller, $method );
    }

}

sub new {
    my ( $class, $args ) = @_;
    my $self = bless $args, $class;
    return $self;
}

sub app {
    my $class = shift;

    sub {
        my $env = shift;
        my $self = $class->new( { env => $env } );
        $self->create_dispatcher;
        $self->dispatch;
    };
}

sub dispatcher {
    my $class = shift;
    return "$class\::Dispatcher";
}

sub view { "Chiffon::View::Xslate" }

sub plugin {
    return [];
}

sub container {
    my $class = shift;
    $class =~ /^(.+)::[^:]+$/;
    return "$1\::Container";
}

#Instance methods

sub env      { shift->{env} }
sub req      { shift->{req} }
sub res      { shift->{res} }

sub create_dispatcher {
    my $self       = shift;
    my $dispatcher = $self->attr->{dispatcher_class}->new({ env => $self->env })
        or Carp::croak('Dispatcher not found!');
    $self->{dispatcher} = $dispatcher;
}
sub get_dispatcher { shift->{dispatcher} }

sub dispatch {
    my $self = shift;

    $self->{req} = Chiffon::Web::Request->new( $self->env );
    $self->{res} = Chiffon::Web::Response->new;
    my $dispatch_rule = $self->get_dispatcher->match;
    unless ( $dispatch_rule ) {
        return $self->handle_response('404 Not Found',404);
    }

    return $self->handle_response( 'Dummy response!',
        200, [ 'Content-type' => 'text/plain' ] );
}

sub handle_response {
    my ( $self, $body, $status, $header ) = @_;

    $status ||= 200;
    $header ||= [ 'Content-Type' => 'text/html;charset=UTF-8' ];

    my $res = $self->res;
    $res->status($status);
    $res->headers($header);
    $res->body($body);
    return $res->finalize;
}

1;
__END__

=head1 NAME

Chiffon::Handler - Plack app handler for Chiffon

=head1 SYNOPSIS

package MyApp::Handler;
use Chiffon::Handler;

dispatcher 'MyApp::Dispatcher';
view       'Chiffon::View::Xslate';


app.psgi

use MyApp::Handler;
use Plack::Builder;

builder {
    MyApp::Handler->to_app;
};

=head1 DESCRIPTION

Plack app handler for Chiffon

=head1 AUTHOR

Nishibayashi Takuji E<lt>takuji {at} senchan.jpE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
