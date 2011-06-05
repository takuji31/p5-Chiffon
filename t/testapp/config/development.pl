use strict;
use warnings;

use TestApp;

return +{
    hoge => 'fuga',
    view => {
        'Chiffon::View::Xslate' => {
            path      => TestApp->base_dir."/tmpl/",
            cache     => 1,
            cache_dir => '/tmp/test_app',
            syntax    => 'Kolon',
            type      => 'html',
            suffix    => '.html',
        },
    },
};
