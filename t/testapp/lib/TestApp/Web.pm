package  TestApp::Web;
use strict;
use warnings;

use parent qw(TestApp Chiffon::Web);

__PACKAGE__->set_use_modules(
    request  => 'TestApp::Web::Request',
    response => 'TestApp::Web::Response',
    router   => 'TestApp::Web::Router',
);

1;
