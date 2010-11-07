package  Chiffon::View;
use Chiffon;

sub new {
    my ($class, $args) = @_;
    $args ||= +{ config => {} };
    my $self = bless $args,$class;
    $self->setup_renderer;
    return $self;
}

sub render { die 'Abstruct method render !' }

sub setup_renderer { }
