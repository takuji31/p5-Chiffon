use Plack::Builder;
use TestApp::Web;

builder {
    enable 'StackTrace';
    TestApp::Web->app;
};
