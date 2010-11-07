package Chiffon::Handler;
use Chiffon;

our $VERSION = '0.01';

sub new {
    my ( $class, $args ) = @_;
    my $self = bless $args, $class;
    return $self;
}


sub to_app {
    my $class = shift;

    sub {
        my $env = shift;
        my $self = $class->new( { env => $env } );
        $self->dispatch;
    };
}


#Instance methods

sub env { shift->{env} };
sub dispatcher { shift->{dispatcher} };

sub dispatch { return [200,['Content-Type'=>'text/plain'],['test']]}

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
