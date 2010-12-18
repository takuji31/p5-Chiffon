package  Chiffon::Web::Context;
use Chiffon::Core;

use Class::Accessor::Lite (
    new => 1,
    ro  => [qw/ env req res config view session dispatch_rule /],
);

sub stash :lvalue { shift->{stash} }
sub template { shift->{dispatch_rule}->{template} }
*request = \&req;
*response = \&res;
