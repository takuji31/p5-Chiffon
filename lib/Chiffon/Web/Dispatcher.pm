package  Chiffon::Web::Dispatcher;
use Chiffon::Core;

sub match {
    my ( $self, $env ) = @_;
    $env ||= $self->{env};
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
        $match->{controller} = camelize($controller);
        my $action     = $match->{action};
        if($action =~ /^[_0-9]/) {
            return;
        }
        $match->{template} = "$controller/$action";
    }
    return $match;
}
sub _create_instance {
    my $class = shift;
    my $args  = shift;
    my $self  = bless $args,$class;
    return $self;
}

sub _create_router { Carp::croak("This method is abstract!") }
sub _set_rule      { Carp::croak("This method is abstract!") }
sub _route         { Carp::croak("This method is abstract!") }
sub _all_action    { Carp::croak("This method is abstract!") }

1;
