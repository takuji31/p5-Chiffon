package  Chiffon::Container;
use Chiffon;
use parent qw/Object::Container/;
use Exporter::AutoClean;
use Cwd qw/realpath/;
use String::CamelCase qw/camelize/;
use Path::Class qw/file dir/;

sub import {
    my $class  = shift;
    my $caller = caller;

    my ( $mode, $args ) = @_;
    # use Chiffon::Container -base;
    if( $mode eq '-base' ) {
        # Nothing to do ?
        $args ||= {};
        {
            no strict 'refs';
            push @{"${caller}::ISA"}, $class;
        }
        my $r = $class->can('register');
        my %exports = (
            register => sub { $r->($caller, @_) },
            preload  => sub {
                $caller->instance->get($_) for @_;
            },
            preload_all_except => sub {
                $caller->instance->load_all_except(@_);
            },
            preload_all => sub {
                $caller->instance->load_all;
            },
        );

        Exporter::AutoClean->export( $caller, %exports );
        #register home and conf
        $caller->initialize;
    }
    # use MyApp::Container;
    # or
    # use MyApp::Container qw/api/;
    else {
        # forked from Kamui::Container
        my @export_names = @_;

        my $self = $class->instance;

        for my $name (@export_names) {

            my $code = sub {
                my $target = shift;
                my $class_name = join '::', $class->base_name, camelize($name), camelize($target);
                return $target ? $class->get($class_name) : $class;
            };

            {
                no strict 'refs';
                *{"${caller}::${name}"} = $code;
            }
        }

        # export container
        {
            no strict 'refs';
            *{"${caller}::container"} = sub {
                my ($target) = @_;
                return $target ? $class->get($target) : $class;
            };
        }
    }

}

sub initialize {
    my $class = shift;

    # forked form Kamui::Container
    &Object::Container::register(
        $class,
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
    &Object::Container::register(
        $class,
        conf => sub {
            my $class = shift;
            my $home = $class->get('home');
            # dev test product etc...
            my $env  = $ENV{CHIFFON_APP_ENV} || 'product';

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

1;
