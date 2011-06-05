use strict;
use warnings;
use Test::More;
use Test::Exception;
use t::Utils;

use File::Spec;
use TestApp;

ok( TestApp->can('base_dir'), "TestApp has base_dir method");
isa_ok( TestApp->base_dir(), 'Path::Class::Dir', "TestApp::base_dir returns instance of Path::Class::Dir");
is( TestApp->base_dir()->stringify, File::Spec->rel2abs('./t/testapp'), "TestApp::base_dir returns true value");

done_testing;
