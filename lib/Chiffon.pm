package Chiffon;
use strict;
use warnings;
use UNIVERSAL::require;

our $VERSION = '0.01';

sub import {
    strict->import;
    warnings->import;

    my $caller    = caller(0);
    my @functions = qw/ base_name load_class /;
    for my $function (@functions) {
        no strict 'refs';
        *{"$caller\::$function"} = \&$function;
    }
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
__END__

=head1 NAME

Chiffon - Web application framework for PSGI/Plack

=head1 SYNOPSIS

  chiffon.pl -p MyApp;

=head1 DESCRIPTION

Chiffon is web application framework for PSGI/Plack

=head1 AUTHOR

Nishibayashi Takuji E<lt>takuji {at} senchan.jpE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
