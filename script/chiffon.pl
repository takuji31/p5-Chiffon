#! /usr/bin/env perl
use Chiffon::Bakery::Project;
use opts;

opts my $project => { isa => 'Str', comment => 'Create project' };

if($project) {
    Chiffon::Bakery::Project->bake($project);
    exit;
}
