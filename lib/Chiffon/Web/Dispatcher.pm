package  Chiffon::Web::Dispatcher;
use Chiffon::Core;
use String::CamelCase qw/camelize decamelize/;

sub export_attr_function {
    my ($class, $caller ) = @_;

    my $attr = {};
    add_method_by_coderef($caller,'attr',sub{ $attr });
    add_method_by_coderef($caller,'base_controller',sub{ _base_controller($caller,@_) });
}

sub match {
    my ( $self, $env ) = @_;
    my $match = $self->{router}->match($env);
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
            return;
        }
        my $camelized_controller = camelize($controller);
        if($self->_base_controller){
            $camelized_controller = join '::', $self->_base_controller, $camelized_controller;
        }
        $match->{controller} = $camelized_controller;
        my $action     = $match->{action};
        if($action =~ /^[_0-9]/) {
            return;
        }
        $match->{template} = $self->guess_template_name($camelized_controller,$action);
    }
    return $match;
}
sub _create_instance {
    my $class = shift;
    my $args  = shift;
    my $self  = bless $args,$class;
    return $self;
}

sub _base_controller {
    my ($class, $base_controller) = @_;
    return $class->attr->{base_controller} unless $base_controller;
    $class->attr->{base_controller} = $base_controller;
    return $base_controller;
}

sub guess_template_name {
    my $class = shift;
    my $namespace = join '::',@_;
    my $namespace_dc = decamelize($namespace);
    $namespace_dc =~ s{::}{/}g;
    return $namespace_dc;
}

sub _create_router { Carp::croak("This method is abstract!") }
sub _set_rule      { Carp::croak("This method is abstract!") }
sub _route         { Carp::croak("This method is abstract!") }
sub _all_action    { Carp::croak("This method is abstract!") }

1;
