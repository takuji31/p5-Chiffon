package  Chiffon::View::Xslate;
use Chiffon;
use Text::Xslate;

use parent qw/Chiffon::View/;

sub setup_renderer {
    my $self = shift;
    my $conf = $self->{config};
    my $xslate_config = {
        path  => $conf->{template_path},
        cache => 1,
        cache_dir => $conf->{cache_dir} || '/tmp/'.$conf->{app_name}.'/',
        module => $conf->{module} || [],
        syntax => $conf->{tterse} ? 'TTerse' : 'Kolon',
        type => 'html',
        suffix => $conf->{suffix} || '.html',
    };
    my $xslate = Text::Xslate->new(%$xslate_config);
    $self->set_renderer($xslate);
}

sub render {
    my ($self, $controller) = @_;

    my $template = $controller->template_name;
    $self->renderer->render($template,$self->stash);
}

1;
