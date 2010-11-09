package  Chiffon::Web::Dispatcher::Simple;
use Chiffon;
use Router::Simple;
use Chiffon::Utils;

sub import {
    my $class  = shift;
    my $caller = caller;

    my @functions = qw/ new route all_action _create_instance _create_router _set_rule match /;
    for my $function (@functions) {
        $class->add_method($caller,$function);
    }

    my $rule = [];
    $class->add_method_by_coderef($caller,'rule',sub{$rule});
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
    my $args  = \%_ || {};
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

sub route {
    my $pattern    = shift;
    my $controller = shift;
    my $action     = shift;
    my %params     = %_;
    push @{caller->rule},[$pattern,{ controller => $controller, action => $action, %params }];
}

sub all_action {
    my $pattern    = shift;
    my $controller = shift;
    my %params     = %_;
    push @{caller->rule},["$pattern/:action",{ controller => $controller, %params }];
}

sub match {
    my ( $self, $path ) = @_;

    return $self->{router}->match($path);
}

1;
