use strict;
use warnings;
use Test::More;
use t::Utils;
use TestApp::Web::Router;

subtest "Export methods" => sub {
    can_ok('TestApp::Web::Router',qw( routes connect match ));
    done_testing;
};

done_testing;
