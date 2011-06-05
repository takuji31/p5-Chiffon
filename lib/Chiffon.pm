package Chiffon;
use strict;
use warnings;

our $VERSION = '0.01';

use Carp ();

use Chiffon::Config::Simple;
use Chiffon::Utils;

#copied from Amon2
{
    our $CONTEXT; # You can localize this variable in your application.
    sub context { $CONTEXT }
    sub set_context { $CONTEXT = $_[1] }
}


sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{$_[0]} : @_;
    bless {%args}, $class;
}

sub load_config{ Chiffon::Config::Simple->load(shift) }
sub config {
    my $class = shift;

    $class = ref $class if ref $class;

    Carp::croak("Can't call Chiffon->config directly") if $class eq __PACKAGE__;
    my $conf = $class->load_config();

    {
        no strict 'refs';
        *{"$class\::config"} = sub{$conf};
    }
    return $conf;
}

sub mode_name { $ENV{PLACK_ENV} }

1;
__END__

=head1 NAME

Chiffon - Simple web application framework for PSGI/Plack

=head1 SYNOPSIS

  chiffon.pl MyApp

=head1 DESCRIPTION

Chiffon is a simple web application framework.

=head1 AUTHOR

Nishibayashi Takuji E<lt>takuji {at} senchan.jpE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
