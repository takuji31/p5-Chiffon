package Chiffon::Utils;
use Chiffon;
use parent qw/Exporter/;
use Carp ();
use UNIVERSAL::can;

our @EXPORT = qw/ add_method add_method_by_coderef /;

sub add_method {
    my ( $class, $target, $method_name ) = @_;
    if ( ref($target) ) {
        $target = ref($target);
    }
    my $code = $class->can($method_name);
    unless ($code) {
        Carp::croak("Method $class\::$method_name does not exists!");
    }
    $class->add_method_by_coderef( $target, $method_name, $code );
}

sub add_method_by_coderef {
    my ( $class, $target, $method_name, $code ) = @_;
    if ( ref($target) ) {
        $target = ref($target);
    }
    unless ( ref($code) ne 'CODE' ) {
        Carp::croak("This is not code reference! $code");
    }
    {
        no strict 'refs';    ## no critic
        *{"$target\::$method_name"} = $code;
    }
}

1;
