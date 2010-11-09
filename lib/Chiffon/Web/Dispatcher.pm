package  Chiffon::Web::Dispatcher;
use Chiffon;

use parent qw/Chiffon::Web::Dispatcher::Simple/;

our $default_rules = [
    ['root_index','/',{ controller => 'root', action => 'index'}],
    ['root','/:action',{ controller => 'root' }],
    ['default_index','/:controller/',{ action => 'index'}],
    ['default','/:controller/:action',{}],
    ['default_with_param','/:controller/:action/(:?([^/:]+)/?)+',{}],
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
