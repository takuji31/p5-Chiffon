use inc::Module::Install;
name 'Chiffon';
all_from 'lib/Chiffon.pm';

# requires '';
requires 'Class::Accessor::Lite';
requires 'Class::Load';
requires 'Data::Section::Simple';
requires 'Exporter::Lite';
requires 'HTML::FillInForm::Lite' => '1.09';
requires 'MRO::Compat';
requires 'parent';
requires 'Path::Class';
requires 'Plack' => '0.9943';
requires 'Plack::Middleware::Session';
requires 'Text::Xslate' => '0.1038';
requires 'Try::Tiny';
requires 'URI';

tests 't/*.t t/*/*.t t/*/*/*.t';
recursive_author_tests 'xt';
install_script 'script/chiffon.pl';

build_requires 'Test::Exception';
build_requires 'Test::More';
build_requires 'Test::LoadAllModules';
build_requires 'parent';

use_test_base;
auto_install;
auto_include;
WriteAll;
