package  Chiffon::Container;
use Chiffon::Core;
use Cwd qw/realpath/;
use String::CamelCase qw/camelize/;
use Path::Class qw/file dir/;

sub import {
    my $class  = shift;
    my $caller = caller;

    if ( $class eq __PACKAGE__ ) {

        # base

        {
            no strict 'refs';
            push @{"$caller\::ISA"}, $class;
        }

        my $instance_table   = {};
        my $registered_class = {};
        {
            no strict 'refs';
            *{"$caller\::_instance_table"}     = sub {$instance_table};
            *{"$caller\::_registered_classes"} = sub {$registered_class};
            *{"$caller\::register"}            = sub { _register( $caller, @_ ) };
        }
        $caller->_register(
            home => sub{
                if( $ENV{CHIFFON_APP_HOME} ){
                    return dir($ENV{CHIFFON_APP_HOME}) if $ENV{CHIFFON_APP_HOME};
                }
                my $class = shift;

                $class = ref $class || $class;
                my $class_file = "$class.pm";
                $class_file =~ s{::}{/}g;
                if (my $class_path = $INC{$class_file} ){
                    my $realpath = realpath($class_path);
                    $realpath =~ s/$class_file$//;
                    my $path = dir($realpath);
                    if(-d $path) {
                        $path = $path->absolute;
                    }
                    while ($path->dir_list(-1) =~ /^b?lib$/) {
                        $path = $path->parent;
                    }
                    return $path;
                }
                die 'Home directory not found. Please set $ENV{CHIFFON_APP_HOME}';
            }
        );
        $caller->_register(
            conf => sub {
                my $class = shift;
                my $home = $class->get('home');
                # dev test product etc...
                my $env  = $ENV{PLACK_ENV} || 'production';

                my $conf = {};
                my $file = $home->file('config.pl');
                if (-e $file) {
                    my $c = do $file;
                    die 'config should return HASHREF'
                        unless ref($c) and ref($c) eq 'HASH';
                    #merge common and env config
                    my $conf_common = $c->{common} || {};
                    my $conf_env = $c->{$env} || {};
                    $conf = { %$conf_common, %$conf_env };
                }
                return $conf;
            },
        );
    }
    else {
        no strict 'refs';
        *{"$caller\::container"} = sub {
            my $pkg = shift;
            return $pkg ? $class->get($pkg) : $class;
        };
    }
}

sub _register {
    my $class       = shift;
    my $pkg         = shift;
    my $initializer = $_[0];
    my @options     = @_;

    unless ($pkg) {
        Carp::croak("Register name is empty!");
    }
    unless ( defined $initializer
        && ref($initializer) eq 'CODE'
        && scalar @options == 1 )
    {
        $initializer = sub {
            my $self = shift;
            load_class($pkg);
            $pkg->new(@options);
        };
    }

    #register classes
    $class->_registered_classes->{$pkg} = $initializer;
}

sub get {
    my ( $class, $pkg ) = @_;

    my $obj = $class->_instance_table->{$pkg};

    unless ($obj) {
        my $code = $class->_registered_classes->{$pkg};
        unless ($code) {
            Carp::croak("$pkg is not registered!");
        }
        $obj = $code->($class);
        $class->_instance_table->{$pkg} = $obj;
    }
    return $obj;

}

1;
