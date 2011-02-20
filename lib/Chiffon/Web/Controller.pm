package  Chiffon::Web::Controller;
use Chiffon::Core;
use parent qw/Class::Data::Inheritable/;
use Carp();

__PACKAGE__->mk_classdata(
    triggers => {},
);

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
    $class->triggers->{$class} ||= {};
    $class->triggers->{$class}->{$trigger} ||= [];
    push @{$class->triggers->{$class}->{$trigger}},$code;
}

sub call_trigger {
    my ( $class, $trigger, $context ) = @_;
    my $codes = $class->get_triggers ( $trigger );

    for my $code ( @$codes ) {
        $code->( $class, $context );
    }
}

sub get_triggers {
    my ( $class, $trigger_name, $triggers ) = @_;

    $triggers ||= [];
    if ( __PACKAGE__ ne $class ) {
        my @parents;
        {
            no strict 'refs';
            @parents = @{$class.'::ISA'};
        }
        for my $parent ( @parents ) {
            if ( $parent->can('get_triggers') ) {
                $parent->get_triggers( $trigger_name, $triggers );
            }
        }
        my $class_triggers = $class->triggers->{$class} || {};
        my $my_triggers = $class_triggers->{$trigger_name} || [];
        push @$triggers, @$my_triggers;
    }
    return $triggers;

}

1;
