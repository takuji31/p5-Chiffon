package Chiffon::Utils;
use Chiffon;
use parent qw/Exporter/;

our @EXPORT = qw/ add_method /;

sub add_method {
    my ($class, $target, $method_name) = @_;
    if(ref ($target)){
        $target = ref($target);
    }
    {
        no strict 'refs'; ## no critic
        *{"$target\::$method_name"} = \&$class->$method_name;
    }
}

1;
