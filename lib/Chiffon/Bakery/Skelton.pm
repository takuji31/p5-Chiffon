package  Chiffon::Bakery::Skelton;
use strict;
use warnings;

use parent qw/Chiffon::Bakery::Base/;
use Chiffon::Utils;

sub bake {
    my ( $class, $proj ) = @_;
    print "Bake project $proj...\n";

    #ファイル名とかディレクトリ名作る
    unless ( $proj =~ /^[a-zA-Z0-9]+(::[a-zA-Z0-9]+)*$/ ) {
        die "$proj is invalid package name! \n";
    }

    # Hoge::Fuga
    my $package = $proj;

    #Hoge-Fuga
    ( my $projpath = $proj ) =~ s/::/-/;

    #hoge_huga
    ( my $app    = $proj ) =~ s/::/_/;
    my $app_name = decamelize($app);

    #Hoge
    ( my $parent = $proj ) =~ s/(::)?[a-zA-Z0-9]+$//;

    #lib/Hoge
    ( my $libpath = 'lib/' . $parent ) =~ s{::}{/};

    #Fuga
    ( my $basename = $proj ) =~ s/^.+:://;

    #Fuga.pm
    my $rootpm = $basename . '.pm';

    my $param = { package => $package, app_name => $app_name };

    my $output_files = [
        ['app.psgi.tx',"$projpath/",'app.psgi',$param],
        ['config.pl.tx',"$projpath/config",'development.pl',$param],
        ['config.pl.tx',"$projpath/config",'production.pl',$param],
        ['Root.tx',"$projpath/$libpath/",$rootpm,$param],
        ['Web.tx',"$projpath/$libpath/$basename/",'Web.pm',$param],
        ['Router.tx',"$projpath/$libpath/$basename/Web/",'Router.pm',$param],
        ['Request.tx',"$projpath/$libpath/$basename/Web/",'Request.pm',$param],
        ['Response.tx',"$projpath/$libpath/$basename/Web/",'Response.pm',$param],
        ['BaseController.tx',"$projpath/$libpath/$basename/Web/",'Controller.pm',$param],
        ['Controller.tx',"$projpath/$libpath/$basename/Web/C/",'Root.pm',{%$param, controller => 'Root'}],
        ['layout.tx',"$projpath/assets/template/",'layout.html',$param],
        ['template.tx',"$projpath/assets/template/root/",'index.html',$param],
    ];

    map { $class->output_template(@$_) } @$output_files;

}

1;
