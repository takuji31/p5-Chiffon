#! /usr/bin/env perl
use Chiffon::Bakery::Project;
use opts;

opts my $project => { isa => 'Str', required => 1 };

if($project) {
    Chiffon::Bakery::Project->bake($project);
}
