use Plack::Builder;
use TestApp::Web::Handler;

builder {
    enable 'StackTrace';
    TestApp::Web::Handler->to_app;
};
