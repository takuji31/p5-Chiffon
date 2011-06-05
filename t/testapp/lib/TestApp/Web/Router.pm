package  TestApp::Web::Router;
use strict;
use warnings;

use Chiffon::Web::Router;

  connect(
      "/some/path",
      {
          controller => 'Hoge',
          action => 'fuga'
      }
  );
  connect(
      "/foo/:action",
      {
          controller => 'Fou'
      }
  );
  connect(
      "/:controller/:action/:year/:month/:date/",
      {
      },
      {
          pass => [qw( year month date )],
          year => '[1-2][0-9]{3}',
          month => '[0-3][0-9]',
          date => '[0-3][0-9]'
      }
  );

1;
