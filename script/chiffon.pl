#! /usr/bin/env perl
use Chiffon::Bakery::Project;

if($ARGV[0]) {
    Chiffon::Bakery::Project->bake($ARGV[0]);
}
