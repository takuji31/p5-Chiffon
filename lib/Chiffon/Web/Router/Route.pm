package  Chiffon::Web::Router::Route;
use strict;
use warnings;

use Carp ();

use Chiffon::Utils;

sub new {
    my ($class, $pattern, $match, $option) = @_;
    $match  ||= {};
    $option ||= {};

    my $args = {
        match  => $match,
        option => $option,
    };
    # Reference From Router::Simple::Route
    my @capture;
    $args->{pattern} = do {
        $pattern =~ s!
            :([A-Za-z0-9_]+)              | # /hoge/:year
            ([^{:*]+)                       # normal string
        !
            if ($1) {
                push @capture, $1;
                my $p = $option->{$1};
                $p ? "($p)" : "([^/]+)";
            } else {
                quotemeta($2);
            }
        !gex;
        qr{^$pattern$};
    };

    for my $s ( qw(controller action) ) {
        unless ( $match->{$s} || grep /^$s$/,@capture ) {
            Carp::croak("$s is undefined!");
        }
    }
    $args->{capture} = \@capture;
    bless $args, $class;
}

sub match {
    my ($self, $req) = @_;

    if ( my @captured = $req->{PATH_INFO} =~ $self->{pattern} ) {
        my %args;
        my @pass;
        my $cap = $self->{capture};
        for my $i ( 0..@$cap-1 ) { 
            $args{$cap->[$i]} = $captured[$i];
        }

        my $controller = camelize(delete $args{controller} || '') || $self->{match}->{controller};
        my $action     = delete $args{action} || $self->{match}->{action};

        for my $key ( @{$self->{option}->{pass} || []} ) {
            my $val = delete $args{$key};
            push @pass,$val;
        }

        return ( $controller, $action, \@pass );

    }
    return;
}

1;
