use strict;
use warnings;
use Test::More;
use Test::Exception;
use t::Utils;

use Chiffon::Utils;

subtest "camelize non underscored string" => sub {
    my $str = "foo";
    is(camelize($str), "Foo", "foo -> Foo");
    $str = "bar";
    is(camelize($str), "Bar", "bar -> Bar");
    done_testing;
};

subtest "camelize underscored string" => sub {
    my $str = "foo_bar";
    is(camelize($str), "FooBar", "foo_bar -> FooBar");
    $str = "hoge_fuga_foo";
    is(camelize($str), "HogeFugaFoo", "hoge_fuga_foo -> HogeFugaFoo");

    done_testing;
};
done_testing;
