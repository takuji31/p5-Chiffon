package  Chiffon::Dispatcher::Simple;
use Chiffon;
use Router::Simple;
use Chiffon::Utils;

sub import {
    my $class  = shift;
    my $caller = caller;

    my @functions = qw/ new route all_action /;
    for my $function (@functions) {
        $class->add_method($caller,$function);
    }

    my $rule = [];
    $class->add_method_by_coderef($caller,'rule',sub{$rule});
}

sub new{
    my $class = shift;
    my $args  = +{ router => Router::Simple->new()};
    my $self  =bless $args,$class;
    for my $rule (@{$class->rule}) {
        $self->{router}->connect(@$rule);
    }
    warn $self->{router}->as_string();
    return $self;
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

1;
