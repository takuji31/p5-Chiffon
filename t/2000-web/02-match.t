use strict;
use warnings;
use Test::More;
use Test::Exception;
use t::Utils;

use TestApp::Web::Router;

my $env = {
    PATH_INFO => '',
    REQUEST_METHOD => 'GET',
};

subtest 'default pattern' => sub {
    $env->{PATH_INFO} = '/hello';
    my ( $controller, $action, $passed ) = TestApp::Web::Router->match($env);
    is($controller, 'Root', 'Controller Root');
    is($action, 'hello', 'Action hello');
    ok(!@$passed, 'passed parameter empty');

    $env->{PATH_INFO} = '/bye/';
    ( $controller, $action, $passed ) = TestApp::Web::Router->match($env);
    is($controller, 'Bye', 'Controller Bye');
    is($action, 'index', 'Action index');
    ok(!@$passed, 'passed parameter empty');

    $env->{PATH_INFO} = '/good/bye';
    ( $controller, $action, $passed ) = TestApp::Web::Router->match($env);
    is($controller, 'Good', 'Controller Good');
    is($action, 'bye', 'Action bye');
    ok(!@$passed, 'passed parameter empty');

    done_testing;
};

subtest 'basic pattern' => sub {
    $env->{PATH_INFO} = '/some/path';
    my ( $controller, $action, $passed ) = TestApp::Web::Router->match($env);
    is($controller, 'Hoge', 'Controller Hoge');
    is($action, 'fuga', 'Action fuga');
    ok(!@$passed, 'passed parameter empty');

    done_testing;
};

subtest 'any action pattern' => sub {
    $env->{PATH_INFO} = '/foo/bar';
    my ( $controller, $action, $passed ) = TestApp::Web::Router->match($env);
    is($controller, 'Fou', 'Controller Fou');
    is($action, 'bar', 'Action bar');
    ok(!@$passed, 'passed parameter empty');

    $env->{PATH_INFO} = '/foo/baz';
    ( $controller, $action, $passed ) = TestApp::Web::Router->match($env);
    is($controller, 'Fou', 'Controller Fou');
    is($action, 'baz', 'Action bar');
    ok(!@$passed, 'passed parameter empty');

    done_testing;
};

subtest 'passed parameter pattern' => sub {
    $env->{PATH_INFO} = '/foo/bar/2001/10/01/';
    my ( $controller, $action, $passed ) = TestApp::Web::Router->match($env);
    is($controller, 'Foo', 'Controller Foo');
    is($action, 'bar', 'Action bar');
    is_deeply($passed,['2001','10','01'], 'passed parameter empty');

    $env->{PATH_INFO} = '/foo/bar/2001/baz/01/';
    ( $controller, $action, $passed ) = TestApp::Web::Router->match($env);
    ok(!$controller, 'not match');
    ok(!$action, 'not match');
    ok(!$passed, 'passed parameter empty');

    done_testing;
};

done_testing;
