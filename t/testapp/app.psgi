use strict;
use warnings;
use TestApp::Web;
use Plack::Builder;

builder {
    TestApp::Web->app;
};

