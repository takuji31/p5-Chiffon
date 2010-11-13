use Chiffon;
use TestApp::Container;
use Path::Class;

my $home = container('home');
return +{
    common => {
        app_name => 'test_app',
        view => {
            'Chiffon::View::Xslate' => +{
                path => $home->file('assets/template')->stringify,
                tterse => 0,
            },
        },
        datasource => +{
        },
        hostname => +{
            default => 'test-app.dev.senchan.jp',
            admin   => 'admin.test-app.dev.senchan.jp',
        },
        plugins => +{
        },
    },
    dev => {


    }
};
