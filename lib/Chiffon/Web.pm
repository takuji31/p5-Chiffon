package Chiffon::Web;
use Chiffon::Core;
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

sub app {
    my $class = shift;

    return sub {
        my $env = shift;

        my $context = $class->create_context( $env );
        $class->dispatch($context);

        return $context->finalize;
    };
}

sub create_context {
    my ( $class, $env ) = @_;
    my $context = $class->context_class->new(
        {
            env           => $env,
            dispatcher    => $class->dispatcher_class->new({ env => $env }),
            req           => $class->request_class->new( $env ),
            res           => $class->response_class->new,
            view          => $class->view_class,
            stash         => {},
            config        => $class->container_class->get('conf') || {},
        }
    ) or Carp::croak("Can't load context class! cause : $@");
}

#TODO ViewもInstance化したほうがよい？
sub view_class       { shift->used_modules->{view} }
sub container_class  { shift->used_modules->{container} }
sub context_class    { shift->used_modules->{context} }
sub dispatcher_class { shift->used_modules->{dispatcher} }
sub request_class    { shift->used_modules->{request} }
sub response_class   { shift->used_modules->{response} }


sub dispatch {
    my ($class, $context) = @_;

    my $dispatch_rule = $context->dispatcher->match( $context->env );
    # StaticはMiddlewareかサーバー側でうまいことやってる前提
    unless ( $dispatch_rule ) {
        $context->handle_response('404 Not Found',404);
        return;
    }

    $context->dispatch_rule($dispatch_rule);

    my $controller = join '::',$class,'C',$dispatch_rule->{controller};

    $controller->use or do{
        #TODO デバッグモードの時だけStackTrace的なモノを出力
        my $msg =  "Can't load Controller $controller cause : $@";
        warn $msg;
        $context->handle_response( $msg, 404 );
        return;
    };

    eval {
        my $action = 'do_'.$dispatch_rule->{action};
        unless ( $controller->can($action) ) {
            warn "Action $controller\::$action not found!";
            $context->handle_response("Action $controller\::$action not found !",404);
            detach;
        }

        $controller->call_trigger( 'before_action', $context );
        $controller->$action( $context );
        $controller->call_trigger( 'after_action', $context );

        $controller->call_trigger( 'before_render', $context );
        $class->view_class->render( $context );
        $controller->call_trigger( 'after_render', $context );
    };

    if ( $class->is_detached($@) ) {
        return;
    }

    if ( $@ ) {
        warn $@;
        $context->handle_response("Internal Server Error cause: $@",500);
        return;
    }

}

sub is_detached {
    my ($class, $message) = @_;
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
