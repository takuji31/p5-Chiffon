package  Chiffon::Web::Dispatcher::RailsLike;
use Chiffon::Core;

use parent qw/Chiffon::Web::Dispatcher::Simple/;
use String::CamelCase qw/camelize/;

our $default_rules = [
    ['root_index','/',{ controller => 'root', action => 'index'}],
    ['root','/:action',{ controller => 'root' }],
    ['default_index','/:controller/',{ action => 'index'}],
    ['default','/:controller/:action',{}],
    [qr{^/([a-zA-Z][a-zA-Z0-9_]*)/([a-zA-Z][a-zA-Z0-9_]*)/(.*[^/])/?},{ with_param => 1, }],
];

sub new {
    my $class = shift;
    my $self  = $class->_create_instance(@_);
    $self->_create_router;
    $self->_set_rule;
    for my $default_rule (@{$default_rules}) {
        $self->{router}->connect(@$default_rule);
    }
    return $self;
}
1;
