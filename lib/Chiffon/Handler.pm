package Chiffon::Handler;
use Chiffon;
use Chiffon::Utils;
use Chiffon::Web::Request;
use Chiffon::Web::Response;

sub import {
    my $class  = shift;
    my $caller = caller;

    #Export method
    my @methods
        = qw/new to_app env get_dispatcher dispatch dispatcher
        view use_container plugin handle_response/;
    for my $method (@methods) {
        $class->add_method( $caller, $method );
    }

    #Setup attribute
    my $attr = +{};
    $class->add_method_by_coderef( $caller, 'attr', sub {$attr} );
}

sub new {
    my ( $class, $args ) = @_;
    my $self = bless $args, $class;
    return $self;
}

sub to_app {
    my $class = shift;

    sub {
        my $env = shift;
        my $self = $class->new( { env => $env } );
        $self->dispatch;
    };
}

sub dispatcher($) {    ## no critic
    my $pkg = shift;
    $pkg->use or die $@;
    caller->attr->{dispatcher} = $pkg;
}

sub view($) {          ## no critic
    my $pkg = shift;
    $pkg->use or die $@;
    caller->attr->{view} = $pkg;
}

sub plugin($) {        ## no critic
    my $pkg = shift;
    $pkg->use or die $@;
    caller->attr->{plugin} = $pkg;
}

sub use_container($) {    ## no critic
    my $pkg = shift;
    $pkg->use or die $@;
}

#Instance methods

sub env            { shift->{env} }
sub get_dispatcher { shift->{dispatcher} }

sub dispatch {
    my $self = shift;

    my $req        = Chiffon::Web::Request->new( $self->env );
    my $res        = Chiffon::Web::Response->new;
    my $dispatcher = $self->get_dispatcher;
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
