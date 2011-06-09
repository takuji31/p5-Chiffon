package  Chiffon::Bakery::Base;
use strict;
use warnings;

use Text::Xslate;
use Data::Section::Simple;
use Path::Class;
use Cwd ();

sub bake { die 'Method bake is abstract' }

sub render {
    my ( $class, $template, $args ) = @_;

    my $tx = Text::Xslate->new(
        path => [ Data::Section::Simple->new(__PACKAGE__)->get_data_section, Data::Section::Simple->new($class)->get_data_section ],
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
use strict;
use warnings;

use [% package %]::Web;
use Plack::Builder;

my $home = [% package %]::Web->base_dir;
builder {
    enable 'Static',
        path => qr{^/(img/|js/|css/|favicon\.ico)},
        root => $home->file('assets/htdocs')->stringify;
    enable 'StackTrace';
    enable 'Session';
    [% package %]::Web->app;
};

@@ config.pl.tx
use strict;
use warnings;

use [% package %];

my $home = [% package %]->base_dir;
return +{
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
};


@@ Root.tx
package [% package %];
use strict;
use warnings;

use parent 'Chiffon';
our $VERSION = '0.01';

1;

@@ Container.tx
package  [% package %]::Container;
use strict;
use warnings;

use Chiffon::Container;

1;

@@ Web.tx
package  [% package %]::Web;
use strict;
use warnings;

use parent qw([% package %] Chiffon::Web);

__PACKAGE__->set_use_modules(
    request    => '[% package %]::Web::Request',
    response   => '[% package %]::Web::Response',
    router     => '[% package %]::Web::Router',
    view       => 'Chiffon::View::Xslate',
);

1;

@@ Router.tx
package  [% package %]::Web::Router;
use strict;
use warnings;

use Chiffon::Web::Router;

1;

@@ Request.tx
package  [% package %]::Web::Request;
use strict;
use warnings;

use parent 'Chiffon::Web::Request';

1;

@@ Response.tx
package  [% package %]::Web::Response;
use strict;
use warnings;

use parent 'Chiffon::Web::Response';

1;

@@ BaseController.tx
package  [% package %]::Web::Controller;
use strict;
use warnings;

use parent 'Chiffon::Web::Controller';

1;

@@ Controller.tx
package  [% package %]::Web::C::[% controller %];
use strict;
use warnings;

use parent qw/[% package %]::Web::Controller/;

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

