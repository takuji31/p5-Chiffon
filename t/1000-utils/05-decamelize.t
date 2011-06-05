use strict;
use warnings;
use Test::More;
use Test::Exception;
use t::Utils;

use Chiffon::Utils;

subtest "decamelize non camelcased string" => sub {
    my $str = "Foo";
    is(decamelize($str), "foo", "Foo -> foo");
    $str = "URL";
    is(decamelize($str), "url", "URL -> url");
    done_testing;
};

subtest "decamelize camelcased string" => sub {
    my $str = "FooBar";
    is(decamelize($str), "foo_bar", "FooBar -> foo_bar");
    $str = "HogeFugaFoo";
    is(decamelize($str), "hoge_fuga_foo", "HogeFugaFoo -> hoge_fuga_foo");

    done_testing;
};
done_testing;
