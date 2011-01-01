use Chiffon::Core;
use TestApp::Container;
use Path::Class;

my $home = container('home');
return +{
    common => {
        app_name => 'test_app',
        view => {
            'Chiffon::View::Xslate' => +{
                path   => $home->file('assets/template')->stringify,
                cache     => 1,
                cache_dir => '/tmp/test_app',
                syntax    => 'Kolon',
                type      => 'html',
                suffix    => '.html',
            },
        },
        datasource => +{
            master => +{
                dsn => 'dbi:mysql:test_app;user=root',
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
                dsn => 'dbi:mysql:test_app;user=root',
            },
        },
    },
    production => {
        datasource => +{
            master => +{
                dsn => 'dbi:mysql:test_app;user=root',
            },
        },
    },
};


