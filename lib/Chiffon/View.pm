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

sub set_renderer { shift->{renderer} = shift }

sub renderer { shift->{renderer} }

sub stash :lvalue { shift->{stash} }

sub config {
    my $self = shift;
    my $class = ref ($self);
    return $self->{config}->{$class} || +{};
}

sub app_name {
    my $self = shift;
    my $class = ref ($self);
    return $self->{config}->{app_name} || +{};
}

1;
