#! /usr/bin/env perl
use Chiffon::Bakery::Skelton;

if($ARGV[0]) {
    Chiffon::Bakery::Skelton->bake($ARGV[0]);
    exit;
}
