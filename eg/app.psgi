use Plack::Builder;
use TestApp::Handler;

builder {
    enable 'StackTrace';
    TestApp::Handler->to_app;
};
