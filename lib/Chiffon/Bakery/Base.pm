package  Chiffon::Bakery::Base;
use Chiffon::Core;
use Text::Xslate;
use Data::Section::Simple;
use Path::Class;
use Cwd ();

sub bake { die 'Method bake is abstract' }

sub render {
    my ( $class, $template, $args ) = @_;

    my $tx = Text::Xslate->new(
        path => [ Data::Section::Simple->new(__PACKAGE__)->get_data_section ],
        syntax => 'TTerse',
    );

    return $tx->render( $template, $args || {} );
}

sub output {
    my ( $class, $path, $filename, $data ) = @_;

    #Current directory
    my $current = Path::Class::dir(Cwd::getcwd);
    my $dist_dir
        = $current->subdir($path);
    my $dist = $dist_dir->file($filename);

    #mkdir
    $dist_dir->mkpath;

    #write data
    #TODO 上書き確認
    print 'Write file ' . $dist->stringify . "\n";
    my $fh = $dist->openw();
    print $fh $data;
    close $fh;
}

sub output_template {
    my ( $class, $template_name, $path, $filename, $param ) = @_;

    my $data = $class->render($template_name,$param);
    $class->output($path,$filename,$data);
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
   enable 'Session';
   [% package %]::Web->app;
};

@@ config.pl.tx
use Chiffon::Core;
use [% package %]::Container;
use Path::Class;

my $home = container('home');
return +{
    common => {
        app_name => '[% app_name %]',
        view => {
            'Chiffon::View::Xslate' => +{
                path => $home->file('assets/template')->stringify,
                tterse => 0,
            },
        },
        datasource => +{
            master => +{
                dsn => 'dbi:mysql:db_name;user=username',
            },
        },
        hostname => +{
        },
        plugins => +{
        },
    },
    dev     => {
        datasource => +{
            master => +{
                dsn => 'dbi:mysql:db_name;user=username',
            },
        },
    },
    production => {
        datasource => +{
            master => +{
                dsn => 'dbi:mysql:db_name;user=username',
            },
        },
    },
};


@@ Root.tx
package [% package %];
use Chiffon::Core;
our $VERSION = '0.01';

1;

@@ Container.tx
package  [% package %]::Container;
use Chiffon::Core;
use Chiffon::Container -base;

1;

@@ Web.tx
package  [% package %]::Web;
use Chiffon::Core;
use Chiffon::View::Xslate;
use [% package %]::Web::Dispatcher;
use [% package %]::Container;
use parent qw/ Chiffon::Web /;

1;

@@ Dispatcher.tx
package  [% package %]::Web::Dispatcher;
use Chiffon::Core;
use Chiffon::Web::Dispatcher;

1;

@@ Controller.tx
package  [% package %]::Web::C::Root;
use Chiffon::Core;
use Chiffon::Web::Controller;
use [% package %]::Container;

sub do_index {
    my $self = shift;
    $self->stash->{body} = "Hello Chiffon World!";
}

1;

@@ layout.tx
<!DOCTYPE HTML>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title><: block title -> { '[% default_title || "Default title here" %]' } :></title>
</head>
<body>
: block content -> {
    body
:}
</body>
</html>
@@ template.tx
:cascade [% layout || 'layout' %];
:around content -> {
    [% body || 'Hello Chiffon World!' %]
:}

