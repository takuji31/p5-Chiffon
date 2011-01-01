use TestApp::Web;
use TestApp::Container;
use Plack::Builder;

my $home = container('home');
builder {
    enable 'Static',
        path => qr{^/(img/|js/|css/|favicon\.ico)},
        root => $home->file('assets/htdocs')->stringify;
    enable 'StackTrace';
    enable 'Session';
    TestApp::Web->app;
};

