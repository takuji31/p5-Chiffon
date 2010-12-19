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
    enable 'Static',
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
                path   => $home->file('assets/template')->stringify,
                cache     => 1,
                cache_dir => '/tmp/[% app_name %]',
                syntax    => 'Kolon',
                type      => 'html',
                suffix    => '.html',
            },
        },
        datasource => +{
            master => +{
                dsn => 'dbi:mysql:[% app_name %];user=root',
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
                dsn => 'dbi:mysql:[% app_name %];user=root',
            },
        },
    },
    production => {
        datasource => +{
            master => +{
                dsn => 'dbi:mysql:[% app_name %];user=root',
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
use [% package %]::Web::Context;
use [% package %]::Web::Request;
use [% package %]::Web::Response;
use [% package %]::Web::Dispatcher;
use [% package %]::Container;
use parent qw/ Chiffon::Web /;

__PACKAGE__->used_modules({
    container  => '[% package %]::Container',
    context    => '[% package %]::Web::Context',
    request    => '[% package %]::Web::Request',
    response   => '[% package %]::Web::Response',
    dispatcher => '[% package %]::Web::Dispatcher',
    view       => 'Chiffon::View::Xslate',
});

1;

@@ Context.tx
package  [% package %]::Web::Context;
use Chiffon::Core;
use [% package %]::Container;
use parent qw/ Chiffon::Web::Context /;

1;

@@ Dispatcher.tx
package  [% package %]::Web::Dispatcher;
use Chiffon::Core;
use Chiffon::Web::Dispatcher::RailsLike;

1;

@@ Request.tx
package  [% package %]::Web::Request;
use Chiffon::Core;
use [% package %]::Container;
use parent qw/ Chiffon::Web::Request /;

1;

@@ Response.tx
package  [% package %]::Web::Response;
use Chiffon::Core;
use [% package %]::Container;
use parent qw/ Chiffon::Web::Response /;

1;

@@ Controller.tx
package  [% package %]::Web::C::Root;
use Chiffon::Core;
use Chiffon::Web::Controller;
use [% package %]::Container;

sub do_index {
    my ( $class, $c ) = @_;
    $c->stash->{body} = "Hello Chiffon World!";
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

