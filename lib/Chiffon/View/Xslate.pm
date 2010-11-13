package  Chiffon::View::Xslate;
use Chiffon;
use Text::Xslate;

use parent qw/Chiffon::View/;

my $xslate;

sub render {
    my ( $class, $c ) = @_;

    my $conf          = $c->config->{view}->{$class} || {};
    my $app_name      = $c->config->{app_name} || 'chiffon_app';
    my $xslate_config = {
        path      => $conf->{path},
        cache     => 1,
        cache_dir => '/tmp/' . $app_name . '/',
        syntax    => $conf->{tterse} ? 'TTerse' : 'Kolon',
        type      => 'html',
        suffix    => '.html',
        %$conf,
    };
    $xslate ||= Text::Xslate->new(%$xslate_config);
    my $template_name = $c->template || 'default';
    $template_name .= ($conf->{suffix} || '.html');
    my $result = $xslate->render(
        $template_name,
        {
            %{$c->stash},
            req => $c->req,
            res => $c->res
        }
    ) or die "Chiffon::View::Xslate error $@" ;
    my $res = $c->res;
    $res->status('200');
    $res->body($result);
    $res->headers([ 'Content-Type' => 'text/html' ]);
    return $res;
}

1;
