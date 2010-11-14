package  Chiffon::Bakery;
use Chiffon;
use Text::Xslate;
use Data::Section::Simple;
sub bake { die 'Method bake is abstract' }

sub render {
    my ( $class, $template, $args ) = @_;

    my $tx = Text::Xslate->new(
        path => [ Data::Section::Simple->new($class)->get_data_section ]
        syntax => 'TTerse',
    );

    return $tx->render( $template , $args || {} );
}

sub output {
    #TODO Output to file
}

1;
__DATA__
@@ app.psgi.tx
use [% package %]::Web;
use [% package %]::Container;
use Plack::Builder;

my $home = container('home');
builder {
   enable 'Plack::Middleware::Static',
           path => qr{^/(img/|js/|css/|favicon\.ico)},
           root => $home->file('assets/htdocs')->stringify;
   enable 'StackTrace';
   [% package %]::Web->app;
};

@@ Root.tx
package [% package %];

use Chiffon;
our $VERSION = '0.01';

1;

@@ Container.tx
package  [% package %]::Container;
use Chiffon;
use Chiffon::Container -base;

1;

@@ Web.tx
package  [% package %]::Web;
use Chiffon;
use Chiffon::Web;
use Chiffon::View::Xslate;
use [% package %]::Web::Dispatcher;
use [% package %]::Container;

1;

@@ Dispacher.tx
package  [% package %]::Web::Dispatcher;
use Chiffon;
use Chiffon::Web::Dispatcher;

1;

@@ Controller.tx
package  [% package %]::Web::C::Root;
use Chiffon;
use Chiffon::Web::Controller;
use [% package %]::Container;

sub do_index {
    my $self = shift;
    $self->stash->{title} = "Hello Chiffon World!";
}

1;

@@ layout.tx
<!DOCTYPE HTML>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title><: $title -> {[% default_title || 'Default title here' %]} :></title>
</head>
<body>
: block content -> {
    body
}
</body>
</html>
@@ template.tx
:cascade [% layout || 'layout' %];
:around content -> {
    content here
:}
