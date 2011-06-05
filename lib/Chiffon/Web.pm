package  Chiffon::Web;
use strict;
use warnings;

use Class::Accessor::Lite (
    new => 0,
    rw  => [qw(controller action req)],
);

use Carp ();
use Class::Load qw( load_class );
use Encode ();
use Scalar::Util ();
use Try::Tiny;
use URI;

use Chiffon::Exception;
use Chiffon::Trigger;
use Chiffon::Utils;
use Chiffon::Web::Request;
use Chiffon::Web::Response;

my %DEFAULT_MODULE = (
        request    => 'Chiffon::Web::Request',
        response   => 'Chiffon::Web::Response',
        view       => 'Chiffon::View::Xslate',
);

sub create_request { shift->request_class->new(@_) }
sub create_response { shift->response_class->new(@_) }

sub html_content_type { 'text/html;charset=UTF-8' }

sub encoding { 'utf-8' }

sub set_use_modules {
    my $class = shift;
    my %modules = @_;

    for my $type ( qw( request response router view ) ) {
        my $module = $modules{$type} || $DEFAULT_MODULE{$type};
        Carp::croak("Module for $type does not passed!") unless $module;
        load_class($module);
        {
            no strict 'refs';
            *{"$class\::${type}_class"} = sub { $module };
        }
    }
}

sub res {
    my $self = shift;
    $self->{res} ||= $self->create_response();
}

sub app {
    my $class = shift;

    return sub {
        my $env = shift;
        my $req = $class->create_request($env);

        my $self = $class->new(
            req   => $req,
            stash => {},
        );

        my $res;

        try {
            $res = $self->dispatch;
        } catch {
            my $e = shift;

            unless ( Scalar::Util::blessed($e) && $e->isa('Chiffon::Exception::HTTP') ) {
                #TODO 500 Internal Server Error
                die $e;
            } else {
                $res = $e->response;
            }
        };

        return $res;

    };
}

sub load_controller {
    my ($self, $controller) = @_;
    load_class($controller) or do {
        my $msg = "Can't load controller $controller cause $@";
        warn $msg;
        Chiffon::Exception::HTTP::NotFound->throw(res => $msg);
    };
    unless ( $controller->isa('Chiffon::Web::Controller') ) {
        die "$controller is not a sub class of Chiffon::Web::Controller";
    };
}

sub dispatch {
    my $self = shift;

    my ($controller, $action, $args) = $self->router_class->match($self->req->env);
    unless ( $controller ) {
        my $msg = "Controller $controller not found";
        warn $msg;
        Chiffon::Exception::HTTP::NotFound->throw(res => $msg);
    }

    my $controller_class = join '::', ref($self), 'C', $controller;

    $self->load_controller($controller_class);

    unless ( $controller_class->has_action($action) ) {
        Chiffon::Exception::HTTP::NotFound->throw;
    }

    #set parameter
    $self->controller($controller);
    $self->action($action);

    $self->call_trigger('before_action');

    $controller_class->run_action($self, $action, $args);

    $self->call_trigger('after_action');

    my $res = $self->render($self,$controller_class);

    $res->finalize;
}

sub template {
    my ($self, $path) = @_;
    if ( $path ) {
        $self->{template} = $path;
    } else {
        $path = $self->{template} || $self->guess_template_path;
    }
    return $path;
}

sub guess_template_path {
    my $self = shift;
    return join "/", decamelize($self->controller), $self->action;
}

sub render {
    my ($self, $controller) = @_;
    my $html = $self->view_class->render($self);

    for my $code ( $self->get_trigger_code('html_filter') ) {
        $html = $code->($self,$html);
    }

    for my $code ( $controller->get_trigger_code('html_filter')  ) {
        $html = $code->($controller,$self,$html);
    }

    $html = $self->encode_html($html);

    return $self->create_response(
        200,
        ['Content-Type' => $self->html_content_type, 'Content-Length' => length $html],
        $html,
    );

}

sub encode_html {
    my ($self, $html) = @_;
    return Encode::encode($self->encoding, $html);
}

sub stash : lvalue {
    my $self = shift;
    $self->{stash} ||= {};
    $self->{stash};
}

sub redirect {
    my ($self, $location, $params) = @_;

    $params ||= {};

    if( $location =~ m{^/} ) {
        my $req = $self->req;
        my $scheme = $req->uri->scheme;
        my $port = $req->uri->port;
        $port = (( $scheme eq 'http' && $port != 80 ) || ( $scheme eq 'https' && $port != 443 ) ) ? ":$port" : "";
        $location = $scheme . "://". $req->uri->host . $port . $location;
    }

    my $uri = URI->new($location);
    $uri->query_form(%$params, $uri->query_form);
    $location = $uri->as_string;
    Chiffon::Exception::HTTP::Redirect->throw(location => $location);
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

    load_class('URI::QueryParam');

    my $uri = $self->req->uri->clone;
    $uri->query_form( { %{ $uri->query_form_hash }, %{$args}, } );
    return $uri;
}

1;
