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
        = qw/new app env create_dispatcher get_dispatcher create_view get_view dispatch dispatcher
        view container plugin handle_response req res/;
    for my $method (@methods) {
        $class->add_method( $caller, $method );
    }

}

sub new {
    my ( $class, $args ) = @_;
    bless $args, $class;
}

sub app {
    my $class = shift;

    return sub {
        my $env = shift;
        my $self = $class->new( { env => $env } );

        $self->create_request;
        $self->create_response;
        $self->create_dispatcher;
        $self->create_view;
        
        return $self->dispatch;
    };
}

sub dispatcher_class {
    my $self = shift;
    my $class = ref($self) || $self;
    return "$class\::Dispatcher";
}

sub view_class { "Chiffon::View::Xslate" }

sub plugin_classes {
    return [];
}

sub container {
    my $self = shift;
    my $class = ref($self) || $self;
    $class =~ /^(.+)::[^:]+$/;
    return "$1\::Container";
}

#Instance methods

sub create_request {
    my $self     = shift;
    $self->{req} = Chiffon::Web::Request->new( $self->env );
}
sub create_response {
    my $self     = shift;
    $self->{res} = Chiffon::Web::Response->new;
}
sub create_dispatcher {
    my $self       = shift;
    my $dispatcher = $self->dispatcher_class->new({ env => $self->env })
        or Carp::croak('Dispatcher not found!');
    $self->{dispatcher} = $dispatcher;
}
sub create_view {
    my $self       = shift;
    my $view = $self->view_class->new({ env => $self->env })
        or Carp::croak('View not found!');
    $self->{view} = $view;
}

sub env { shift->{env} }
sub req { shift->{req} }
sub res { shift->{res} }
sub dispatcher { shift->{dispatcher} }
sub view { shift->{view} }

sub dispatch {
    my $self = shift;

    $self->{res} = Chiffon::Web::Response->new;
    my $dispatch_rule = $self->dispatcher->match;
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
