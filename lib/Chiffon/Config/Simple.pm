package  Chiffon::Config::Simple;
use strict;
use warnings;

sub load {
    my ($class, $c) = (shift, shift);
    my %conf = @_ == 1 ? %{$_[0]} : @_;

    my $env = $conf{environment} || $c->mode_name || 'development';
    my $file = $c->base_dir->subdir('config')->file("$env.pl")->stringify;
    my $conf = do $file or die "Can't load conf $file cause: $@";

    return $conf;
}


1;
