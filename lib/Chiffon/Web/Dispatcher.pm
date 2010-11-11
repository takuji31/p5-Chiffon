package  Chiffon::Web::Dispatcher;
use Chiffon;

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

sub match {
    my $self = shift;
    my $match = $self->SUPER::match(@_);
    if ( $match ) {
        if( $match->{with_param} ) {
            $match->{controller} = shift @{$match->{splat}};
            $match->{action} = shift @{$match->{splat}};
            my $params_str = shift @{$match->{splat}};
            my @params = split '/',$params_str;
            # hoge:fuga => { hoge => fuga }
            my $parsed_params = [];
            for my $param (@params){
                $param = ( $param =~ /([^:]+)\:(.+)/ ) ? +{ $1 => $2 } : $param;
                push @$parsed_params,$param;
            }
            $match->{splat} = $parsed_params;
        }
        my $controller = $match->{controller};
        if($controller =~ /^[_0-9]/) {
            return undef;
        }
        $match->{controller} = camelize($controller);
        my $action     = $match->{action};
        if($action =~ /^[_0-9]/) {
            return undef;
        }
        $match->{template} = "$controller/$action";
    }
    return $match;

}
