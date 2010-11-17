package  Chiffon::Container;
use Chiffon;
use Object::Container::Namespace -base;
use Cwd qw/realpath/;
use String::CamelCase qw/camelize/;
use Path::Class qw/file dir/;

sub initialize {
    my $class = shift;

    # forked form Kamui::Container
    $class->_register(
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
    $class->_register(
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
