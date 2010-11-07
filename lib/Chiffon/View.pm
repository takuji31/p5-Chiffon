package  Chiffon::View;
use Chiffon;

sub new {
    my ($class, $args) = @_;
    
    $args           ||= +{};
    $args->{config} ||= +{};
    $args->{stash}  ||= +{};

    my $self = bless $args,$class;
    $self->setup_renderer;
    return $self;
}

sub render { die 'Abstruct method render !' }

sub setup_renderer { }

sub set_renderer { shift->{renderer} = $_[0] }

sub renderer { shift->{renderer} }
