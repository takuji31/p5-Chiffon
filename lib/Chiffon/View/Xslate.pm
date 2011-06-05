package  Chiffon::View::Xslate;
use strict;
use warnings;

use Text::Xslate qw/html_builder/;
use HTML::FillInForm::Lite qw/fillinform/;

use parent qw/Chiffon::View/;

sub render {
    my ( $class, $c ) = @_;

    my $conf          = $c->config->{view}->{$class} || {};
    my $function      = $conf->{function} || {};
    my $xslate_config = {
        cache     => 1,
        cache_dir => '/tmp/',
        syntax    => 'Kolon',
        type      => 'html',
        suffix    => '.html',
        %$conf,
        function => { fillinform => html_builder(\&fillinform), %$function },
    };
    my $xslate = Text::Xslate->new(%$xslate_config);
    my $template_name = $c->template || 'default';
    $template_name .= $xslate_config->{suffix};
    my $result = $xslate->render(
        $template_name,
        {
            %{$c->stash},
            req     => $c->req,
            config  => $c->config,
            c       => $c,
        }
    ) or die "Chiffon::View::Xslate error $@";

    return $result;
}

1;
