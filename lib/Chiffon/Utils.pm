package Chiffon::Utils;
use Chiffon;
use parent qw/Exporter/;
use Carp ();

our @EXPORT = qw/ add_method add_method_by_coderef /;

sub add_method {
    my ( $class, $target, $method_name ) = @_;
    if ( ref($target) ) {
        $target = ref($target);
    }
    my $code = \&$class->$method_name;
    $class->add_method_by_coderef( $target, $code );
}

sub add_method_by_coderef {
    my ( $class, $target, $code ) = @_;
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
