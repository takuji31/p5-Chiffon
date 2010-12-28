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
requires 'Plack::Middleware::Session';
requires 'Text::Xslate';
requires 'Class::Accessor::Lite';
requires 'Object::Container::Namespace';

tests 't/*.t';
recursive_author_tests 'xt';
install_script 'script/chiffon.pl';

build_requires 'Test::More';
auto_install;
auto_set_repository;
auto_include;
WriteAll;
