use inc::Module::Install;
name 'Chiffon';
all_from 'lib/Chiffon.pm';
readme_pod_from 'lib/Chiffon.pm';
githubmeta;

# requires '';
requires 'Class::Accessor::Lite';
requires 'Class::Data::Inheritable';
requires 'Class::Load';
requires 'Data::Section::Simple';
requires 'HTML::FillInForm::Lite' => '1.09';
requires 'parent';
requires 'Path::Class';
requires 'Plack::Request';
requires 'Plack::Response';
requires 'Plack::Session';
requires 'Router::Simple';
requires 'String::CamelCase';
requires 'Text::Xslate' => '0.1038';
requires 'UNIVERSAL::can';

tests 't/*.t';
recursive_author_tests 'xt';
install_script 'script/chiffon.pl';

build_requires 'Test::More';
build_requires 'Test::LoadAllModules';
auto_install;
auto_set_repository;
auto_include;
WriteAll;
