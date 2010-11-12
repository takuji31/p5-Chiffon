package  Chiffon::Web::Controller;
use Chiffon;
use Chiffon::Utils;
use Carp();

sub import {
    my $class  = shift;
    my $caller = caller;

    my @methods = qw/
        new call_trigger
        req res request response view
        stash redirect
    /;
    for my $method ( @methods ) {
        $class->add_method($caller,$targer,$method);
    }
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

    for my $code = ( @codes ) {
        $code->( $self );
    }
}

sub redirect {
    my $self = shift;
    return $self->res->redirect(@_);
}

sub req      { shift->{req} }
sub res      { shift->{res} }
sub request  { shift->{req} }
sub response { shift->{res} }
sub view     { shift->{view} }
sub stash    { shift->view->{stash} }

1;
