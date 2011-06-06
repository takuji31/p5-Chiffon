package  Chiffon::Container;
use strict;
use warnings;

sub import {
    my $class  = shift;
    my $caller = caller;

    if ( $class eq __PACKAGE__ ) {

        # base

        {
            no strict 'refs';
            push @{"$caller\::ISA"}, $class;
        }

        my $instance_table   = {};
        my $registered_class = {};
        {
            no strict 'refs';
            *{"$caller\::_instance_table"}     = sub {$instance_table};
            *{"$caller\::_registered_classes"} = sub {$registered_class};
            *{"$caller\::register"}            = sub { _register( $caller, @_ ) };
        }
    } else {
        no strict 'refs';
        *{"$caller\::container"} = sub {
            my $pkg = shift;
            return $pkg ? $class->get($pkg) : $class;
        };
    }
}

sub _register {
    my $class       = shift;
    my $pkg         = shift;
    my $initializer = $_[0];
    my @options     = @_;

    unless ($pkg) {
        Carp::croak("Register name is empty!");
    }
    unless ( defined $initializer
        && ref($initializer) eq 'CODE'
        && scalar @options == 1 )
    {
        $initializer = sub {
            my $self = shift;
            load_class($pkg);
            $pkg->new(@options);
        };
    }

    #register classes
    $class->_registered_classes->{$pkg} = $initializer;
}

sub get {
    my ( $class, $pkg ) = @_;

    my $obj = $class->_instance_table->{$pkg};

    unless ($obj) {
        my $code = $class->_registered_classes->{$pkg};
        unless ($code) {
            Carp::croak("$pkg is not registered!");
        }
        $obj = $code->($class);
        $class->_instance_table->{$pkg} = $obj;
    }
    return $obj;

}

1;
