package  Chiffon::View::Xslate;
use Chiffon;
use Text::Xslate;

use parent qw/Chiffon::View/;

sub setup_renderer {
    my $self = shift;
    my $conf = $self->config;
    my $app_name = $self->app_name;
    my $xslate_config = {
        path  => $conf->{template_path},
        cache => 1,
        cache_dir => $conf->{cache_dir} || '/tmp/'.$app_name.'/',
        module => $conf->{module} || [],
        syntax => $conf->{tterse} ? 'TTerse' : 'Kolon',
        type => 'html',
        suffix => $conf->{suffix} || '.html',
    };
    my $xslate = Text::Xslate->new(%$xslate_config);
    $self->set_renderer($xslate);
}

sub render {
    my ($self, $template) = @_;

    $self->renderer->render($template,$self->stash);
}

1;
