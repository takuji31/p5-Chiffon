use strict;
use warnings;
use Test::More;
use Test::Exception;
use t::Utils;

use Chiffon;
use TestApp;

subtest "Config not found" => sub {
    local $ENV{PLACK_ENV} = 'production';
    dies_ok(sub{TestApp->config()}, "Configuration file was not found");
    done_testing;
};

subtest "Load config" => sub {
    my $conf = TestApp->config();
    ok($conf, "Config was loaded");
    is($conf->{hoge}, 'fuga', "Config value is correct");
    done_testing;
};

done_testing;
