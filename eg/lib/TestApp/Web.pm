package  TestApp::Web;
use Chiffon::Core;
use Chiffon::View::Xslate;
use TestApp::Web::Context;
use TestApp::Web::Request;
use TestApp::Web::Response;
use TestApp::Web::Dispatcher;
use TestApp::Container;
use parent qw/ Chiffon::Web /;

__PACKAGE__->used_modules({
    container  => 'TestApp::Container',
    context    => 'TestApp::Web::Context',
    request    => 'TestApp::Web::Request',
    response   => 'TestApp::Web::Response',
    dispatcher => 'TestApp::Web::Dispatcher',
    view       => 'Chiffon::View::Xslate',
});

1;

