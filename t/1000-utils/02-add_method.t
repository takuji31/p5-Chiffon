use strict;
use warnings;
use Test::More;
use Test::Exception;
use t::Utils;

use TestApp;

subtest "Correct export" => sub {

    ok( !TestApp->can('hoge'), "TestApp does't have hoge method");
    TestApp->add_method("hoge", sub{1} );
    ok( TestApp->can('hoge'), "Export hoge method");
    is( TestApp->hoge(), 1, "TestApp::hoge returns true value");

    done_testing;
};

subtest "Wrong export" => sub {

    ok( !TestApp->can('fuga'), "TestApp does't have hoge method");
    dies_ok(sub{TestApp->add_method("fuga", +{} )}, "2nd parameter must be code reference");
    ok( !TestApp->can('fuga'), "Not exported fuga method");

    done_testing;
};
done_testing;
