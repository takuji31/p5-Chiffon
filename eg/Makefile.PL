use inc::Module::Install;
use Module::Install::ReadmeFromPod;
use Module::Install::Repository;
name 'TestApp';
all_from 'lib/TestApp.pm';
readme_from 'lib/TestApp.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
build_requires 'Test::LoadAllModules';
build_requires 'Module::Install::ReadmeFromPod';
use_test_base;
auto_include;
auto_set_repository;
WriteAll;
