use strict;
use warnings;
use Test::Module::Used;

my $used = Test::Module::Used->new(
    lib_dir => ['lib'],
);
$used->ok;
