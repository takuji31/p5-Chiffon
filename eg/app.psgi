use Chiffon;
use Plack::Builder;
use TestApp::Handler;

builder {
    TestApp::Handler->to_app;
};
