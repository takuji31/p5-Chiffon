use strict;
use warnings;
use Test::More;
use t::Utils;
use TestApp;

use Chiffon;

subtest "Set context" => sub {
    my $instance = TestApp->new();
    ok(!Chiffon->context(), "Default context is empty");
    Chiffon->set_context($instance);
    isa_ok(Chiffon->context(), "TestApp", "Set context");
    done_testing;
};

subtest "Localize context" => sub {
    my $instance = TestApp->new();
    local $Chiffon::CONTEXT = $instance;
    isa_ok(Chiffon->context(), "TestApp", "Set context");
    done_testing;
};

done_testing;
