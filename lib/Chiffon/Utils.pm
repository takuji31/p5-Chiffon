package  Chiffon::Utils;
use strict;
use warnings;

use Exporter::Lite;
use File::Spec;
use Carp ();
use Path::Class qw(dir);

our @EXPORT = qw(
    add_method
    base_dir
    camelize
    decamelize
);

sub add_method {
    my ($class, $name, $code) = @_;
    Carp::croak("2nd parameter must be code reference") unless ref($code) eq 'CODE';
    {
        no strict 'refs';
        *{"$class\::$name"} = $code;
    }
}

sub base_dir($) { ## no critic
    my $class = shift;

    $class =~ s{::}{/}g;
    my $path;
    if ( my $libpath = $INC{"$class.pm"} ) {
        $libpath =~ s{(?:blib/)?lib/+$class\.pm$}{};
        $path = File::Spec->rel2abs($libpath || './');
    } else {
        $path = File::Spec->rel2abs('./');
    }
    return dir($path);
}

sub camelize {
    my $str = shift;
    return join( "", map{ ucfirst $_ } split( /_/, $str));
}

sub decamelize {
    my $str = shift;
    $str =~ s{([^a-zA-Z]?)([A-Z]*)([A-Z])([a-z]?)}{
        my $fc = pos($str) == 0;
        my ($p0,$p1,$p2,$p3) = ($1,lc $2,lc $3, $4);
        my $t = $p0 || $fc ? $p0 : '_';
        $t .= $p3 ? $p1 ? $p1."_$p2$p3" : "$p2$p3" : "$p1$p2";
        $t;
    }ge;
    $str;
}

1;
