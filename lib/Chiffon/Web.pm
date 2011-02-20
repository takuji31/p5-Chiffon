package Chiffon::Web;
use Chiffon::Core;
use Class::Accessor::Lite (
    new => 0,
    ro => [ qw/ context dispatcher env req res session / ],
);
use parent qw/ Class::Data::Inheritable /;


__PACKAGE__->mk_classdata(
    used_modules => {
        context    => '',
        request    => 'Chiffon::Web::Request',
        response   => 'Chiffon::Web::Response',
        dispatcher => '',
        view       => 'Chiffon::View::Xslate',
        container  => '', 
    },
);
__PACKAGE__->mk_classdata(
    default_response_header => [
        'Content-Type' => 'text/html;charset=UTF-8',
    ],
);

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
        my $context = $self->create_context;

        $self->dispatch($context);

        return $self->context->finalize;
    };
}

sub create_context {
    my $self     = shift;
    my $context = $self->used_modules->{context}->new(
        {
            env           => $self->env,
            req           => $self->req,
            res           => $self->res,
            view          => $self->view_class,
            stash         => {},
            config        => $self->container_class->get('conf') || {},
        }
    ) or Carp::croak("Can't load request class! cause : $@");
    $self->{context} = $context;
}
sub create_request {
    my $self     = shift;
    my $request = $self->used_modules->{request}->new($self->env)
        or Carp::croak("Can't load request class! cause : $@");
    $self->{req} = $request;
}
sub create_response {
    my $self     = shift;
    my $response = $self->used_modules->{response}->new
        or Carp::croak("Can't load response class! cause : $@");
    $self->{res} = $response;
}
sub create_dispatcher {
    my $self       = shift;
    my $dispatcher = $self->used_modules->{dispatcher}->new({ env => $self->env })
        or Carp::croak("Can't load dispatcher class! cause : $@");
    $self->{dispatcher} = $dispatcher;
}

#TODO ViewもInstance化したほうがよい？
sub view_class { shift->used_modules->{view} }
sub container_class { shift->used_modules->{container} }
sub context_class { shift->used_modules->{context} }


sub dispatch {
    my ($self, $context) = @_;

    my $dispatch_rule = $self->dispatcher->match;
    # StaticはMiddlewareかサーバー側でうまいことやってる前提
    unless ( $dispatch_rule ) {
        $self->handle_response('404 Not Found',404);
        return;
    }

    $context->dispatch_rule($dispatch_rule);

    my $class = ref($self);
    my $controller = join '::',$class,'C',$dispatch_rule->{controller};

    eval {
        $controller->use or do{
            #TODO デバッグモードの時だけStackTrace的なモノを出力
            warn "Can't load Controller $controller cause : $@";
            $self->handle_response($@,404);
            detach;
        };

        my $action = 'do_'.$dispatch_rule->{action};
        unless ( $controller->can($action) ) {
            warn "Action $controller\::$action not found!";
            $self->handle_response("Action $controller\::$action not found !",404);
            detach;
        }

        $controller->call_trigger( 'before_action', $context );
        $controller->$action( $context );
        $controller->call_trigger( 'after_action', $context );

        $controller->call_trigger( 'before_render', $context );
        $self->view_class->render( $context );
        $controller->call_trigger( 'after_render', $context );
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
    $header ||= $self->default_response_header;

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
    return $message =~ /CHIFFON_DETACH/;
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
