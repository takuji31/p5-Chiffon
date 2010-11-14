package  Chiffon::Web::Controller;
use Chiffon;
use Chiffon::Utils;
use Carp();

sub import {
    my $class  = shift;
    my $caller = caller;

    my @methods = qw/
        new call_trigger
        req res request response view template
        stash redirect config
    /;
    for my $method ( @methods ) {
        $class->add_method( $caller, $method );
    }
    my $t = {
        before_action =>[],
        before_render =>[],
        after_action  =>[],
        after_render  =>[],
    };
    $class->add_method_by_coderef( $caller, 'triggers', sub{ $t } );
}

sub new {
    my ( $class, $args ) = @_;
    bless $args,$class;
}

#trigger

my @triggers = qw/ before_action before_render after_render after_action /;

sub add_trigger {
    my ( $class, $trigger, $code ) = @_;
    unless ( grep /$trigger/,@triggers ){
        Carp::cluck("Trigger $trigger does not exists !");
    }
    unless( ref($code) eq 'CODE' ){
        Carp::cluck('Method add_trigger needs code reference !');
    }
    push @{$class->triggers->{$trigger}},$code;
}

sub call_trigger {
    my ( $self, $trigger ) = @_;
    my $codes = $self->triggers->{$trigger} || [];

    for my $code ( @$codes ) {
        $code->( $self );
    }
}

sub redirect {
    my $self = shift;
    $self->res->redirect(@_);
    detach;
}

sub req           { shift->{req} }
sub res           { shift->{res} }
sub request       { shift->{req} }
sub response      { shift->{res} }
sub config        { shift->{config} }
sub view          { shift->{view} }
sub stash :lvalue { shift->{stash} }
sub template      { shift->{dispatch_rule}->{template} }

1;
