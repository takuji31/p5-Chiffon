package Chiffon::Core;
use strict;
use warnings;
use utf8;
use Carp ();
use UNIVERSAL::can;
use UNIVERSAL::require;

sub import {
    strict->import;
    warnings->import;
    utf8->import;

    my $class  = shift;
    my $caller = caller;
    my @functions = qw/
        add_method
        add_method_by_coderef
        detach
        base_name
        load_class
    /;
    for my $function ( @functions ) {
        $class->add_method($caller,$function);
    }
}

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
    unless ( ref($code) eq 'CODE' ) {
        Carp::croak("This is not code reference! $code");
    }
    {
        no strict 'refs';    ## no critic
        *{"$target\::$method_name"} = $code;
    }
}

sub detach {
    die 'CHIFFON_DETACH';
}

sub base_name {
    my $class = shift;
    $class = ref $class unless $class;
    ( my $base_name = $class ) =~ s/(::.+)?$//g;
    $base_name;
}

sub load_class {
    my ( $class, $load_class ) = @_;
    $load_class->require or Carp::croak $@;
}

1;
