package  Chiffon::Web::Dispatcher::Simple;
use Chiffon::Core;
use Router::Simple;


sub import {
    my $class  = shift;
    my $caller = caller;

    my @functions = qw/ new _route _all_action _create_instance _create_router _set_rule match /;
    for my $function (@functions) {
        $class->add_method($caller,$function);
    }

    my $rule = [];
    add_method_by_coderef($caller,'rule',sub{$rule});
    add_method_by_coderef($caller,'route',sub{ _route($caller,@_) });
    add_method_by_coderef($caller,'all_action',sub{ _all_action($caller,@_) });
}

sub new {
    my $class = shift;
    my $self  = $class->_create_instance(@_);
    $self->_create_router;
    $self->_set_rule;
    return $self;
}

sub _create_instance {
    my $class = shift;
    my $args  = shift;
    my $self  = bless $args,$class;
    return $self;
}

sub _create_router {
    my $self = shift;
    $self->{router} = Router::Simple->new();
}

sub _set_rule {
    my $self = shift;
    for my $rule (@{$self->rule}) {
        $self->{router}->connect(@$rule);
    }
}

sub _route {
    my $class      = shift;
    my $pattern    = shift;
    my $controller = shift;
    my $action     = shift;
    my %params     = %_;
    push @{$class->rule},[$pattern,{ controller => $controller, action => $action, %params }];
}

sub _all_action {
    my $class      = shift;
    my $pattern    = shift;
    my $controller = shift;
    my $params     = shift;
    push @{$class->rule},["$pattern/:action",{ controller => $controller, %$params }];
}

sub match {
    my ( $self, $env ) = @_;
    $env ||= $self->{env};
    return $self->{router}->match($env);
}

1;
