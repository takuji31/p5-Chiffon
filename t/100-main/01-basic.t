use strict;
use warnings;
use Test::More;
use t::Utils;
use TestApp;

subtest "Create instance" => sub {
    can_ok('TestApp',qw( new ));
    my $instance = TestApp->new();
    isa_ok($instance, 'TestApp', "Instance of TestApp");
    isa_ok($instance, 'Chiffon', "Instance of Chiffon");
    done_testing;
};

done_testing;
