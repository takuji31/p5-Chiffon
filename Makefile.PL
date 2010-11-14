use inc::Module::Install;
name 'Chiffon';
all_from 'lib/Chiffon.pm';
readme_pod_from 'lib/Chiffon.pm';
githubmeta;

# requires '';
requires 'UNIVERSAL::can';
requires 'UNIVERSAL::require';
requires 'Carp';
requires 'Exporter::AutoClean';
requires 'Router::Simple';
requires 'Data::Section::Simple';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
