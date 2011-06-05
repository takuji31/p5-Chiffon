package  Chiffon::Web::Router;
use strict;
use warnings;

use Chiffon::Web::Router::Route;

my $DEFAULT_ROUTES = [];

sub import {
    my $class  = shift;
    my $caller = caller;

    if( $caller eq 'main' ) {
        return;
    }

    my $routes = [];
    {
        no strict 'refs';
        *{"$caller\::routes"} = sub { $routes };
        *{"$caller\::match"} = \&match;
        *{"$caller\::connect"} = sub { &connect($caller,@_) };
    }
}

sub match {
    my ($class, $env) = @_;

    for my $router ( @{$class->routes}, @$DEFAULT_ROUTES ) {
        my @match = $router->match($env);
        return @match if @match;
    }
    return;
}

sub connect {
    my ($class, $pattern, $match, $option) = @_;
    push @{$class->routes}, Chiffon::Web::Router::Route->new($pattern, $match, $option);
}

sub routes { $DEFAULT_ROUTES }
__PACKAGE__->connect('/',{controller => 'Root', action => 'index'},{});
__PACKAGE__->connect('/:action',{controller => 'Root'},{});
__PACKAGE__->connect('/:controller/',{action => 'index'},{});
__PACKAGE__->connect('/:controller/:action',{},{});

1;
__DATA__

=pod

=head1 NAME

Chiffon::Web::Router

=head1 SYNOPSIS

  package  MyApp::Router;
  use strict;
  use warnings;
  use Chiffon::Web::Router;

  connect(
      "/some/path",
      {
          controller => 'Hoge',
          action => 'fuga'
      }
  );
  connect(
      "/foo/:action",
      {
          controller => 'Hoge'
      }
  );
  connect(
      "/:controller/:action/:year/:month/:date",
      {
          controller => 'Hoge'
      },
      {
          pass => [qw( year month date )],
          year => '[1-2][0-9]{3}',
          month => '[0-3][1-9]',
          date => '[0-3][0-9]' 
      }
  );


=cut
