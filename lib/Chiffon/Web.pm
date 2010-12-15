package Chiffon::Web;
use Chiffon::Core;

use Chiffon::Web::Request;
use Chiffon::Web::Response;
use UNIVERSAL::require;

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

        $self->dispatch;

        return $self->res->finalize;
    };
}

#class name methods

sub dispatcher_class {
    my $self = shift;
    my $class = ref($self) || $self;
    return "$class\::Dispatcher";
}

sub plugins { [] }

sub container_class {
    my $self = shift;
    my $class = ref($self) || $self;
    my $basename = $class->base_name;
    return "$basename\::Container";
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

sub env { shift->{env} }
sub req { shift->{req} }
sub res { shift->{res} }
sub dispatcher { shift->{dispatcher} }
sub view { 'Chiffon::View::Xslate' }

sub dispatch {
    my $self = shift;

    my $dispatch_rule = $self->dispatcher->match;
    # StaticはMiddlewareかサーバー側でうまいことやってる前提
    unless ( $dispatch_rule ) {
        return $self->handle_response('404 Not Found',404);
    }

    my $class = ref($self);
    my $controller_class = join '::',$class,'C',$dispatch_rule->{controller};

    eval {
        $controller_class->use or do{
            warn "404 Controller not found";
            $self->handle_response('404 Not Found',404);
            detach;
        };

        my $c = $controller_class->new(
            {
                req           => $self->req,
                res           => $self->res,
                view          => $self->view,
                dispatch_rule => $dispatch_rule,
                stash         => {},
                config        => $self->container_class->get('conf') || {},
                session       => $self->env->{'psgix.session'},
            }
        );
        
        my $action = 'do_'.$dispatch_rule->{action};
        unless ( $c->can($action) ) {
            $self->handle_response("Action $controller_class\::$action not found !",404);
            return;
        }

        $c->call_trigger('before_action');
        $c->$action();
        $c->call_trigger('after_action');

        $c->call_trigger('before_render');
        $self->view->render($c);
        $c->call_trigger('after_render');
    };

    if ( $self->is_detached($@) ) {
        return;
    }

    if ( $@ ) {
        warn $@;
        $self->handle_response("Internal Server Error",500);
        return;
    }
}

sub handle_response {
    my ( $self, $body, $status, $header ) = @_;

    $status ||= 200;
    $header ||= [ 'Content-Type' => 'text/html;charset=UTF-8' ];

    my $res = $self->res;
    $res->status($status);
    $res->headers($header);
    $res->body($body);
}

sub is_detached {
    my ($self, $message) = @_;
    unless ( $message ) {
        return;
    }
    return $message =~ /CHIFFON_DETACH at/;
}

1;
__END__

=head1 NAME

Chiffon::Web - Plack Web app handler for Chiffon

=head1 SYNOPSIS

package MyApp::Web;
use Chiffon::Core;
use Chiffon::Web;
use Chiffon::View::Xslate;
use MyApp::Web::Dispatcher;
use MyApp::Container;


app.psgi

use MyApp::Web;
use Plack::Builder;

builder {
    MyApp::Web->app;
};

=head1 DESCRIPTION

Plack app handler for Chiffon

=head1 AUTHOR

Nishibayashi Takuji E<lt>takuji {at} senchan.jpE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
