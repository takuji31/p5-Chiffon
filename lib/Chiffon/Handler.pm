package Chiffon::Handler;
use Chiffon;
use Chiffon::Utils;
use Chiffon::Web::Request;
use Chiffon::Web::Response;

sub import {
    my $class  = shift;
    my $caller = caller;

    #Export method
    my @methods = qw/new to_app env get_dispatcher dispatch dispatcher view controller plugin/;
    for my $method (@methods){
        $class->add_method($caller,$method);
    }

    #Setup attribute
    my $attr = +{};
    $class->add_method_by_coderef($caller,'attr',sub{ $attr });
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

sub dispatcher($) { ## no critic
    my $dispatcher = shift;
    caller->attr->{dispatcher} = $dispatcher;
}

sub view($) { ## no critic
    my $view = shift;
    caller->attr->{view} = $view;
}

sub controller($) { ## no critic
    my $controller = shift;
    caller->attr->{controller} = $controller;
}

sub plugin($) { ## no critic
    my $plugin = shift;
    caller->attr->{plugin} = $plugin;
}

#Instance methods

sub env { shift->{env} }
sub get_dispatcher { shift->{dispatcher} }

sub dispatch {
    my $self = shift;

    my $req = Chiffon::Web::Request->new($self->env);
    my $res = Chiffon::Web::Response->new;
    my $dispatcher = $self->get_dispatcher;
    return [200,['Content-type' => 'text/plain'],['Dummy response!']];
}

1;
__END__

=head1 NAME

Chiffon - Web application framework for PSGI/Plack

=head1 SYNOPSIS

  chiffon.pl -p MyApp;

=head1 DESCRIPTION

Chiffon is web application framework for PSGI/Plack

=head1 AUTHOR

Nishibayashi Takuji E<lt>takuji {at} senchan.jpE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
