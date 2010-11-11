package  Chiffon::Web::Controller;
use Chiffon;
use Carp();

sub import {
    my $class  = shift;
    my $caller = caller;

    my @methods = qw/
        new
        add_before_dispatch add_after_dispatch
    /;
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


sub req      { shift->{req} }
sub res      { shift->{res} }
sub request  { shift->{req} }
sub response { shift->{res} }
1;
