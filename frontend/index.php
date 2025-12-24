<?php
  include_once( 'include/php/app.php' );
  $afw = new AppFramework();
?>
<!DOCTYPE html>
<html>
  <head>
    <title>Pilseung Fighter</title>
    <?= $afw->links() ?>
  </head>
  <body>
    <div class="container">
      <div class="d-flex flex-row">
        <div class="p-3"><h1>Pilseung Fighter</h1></div>
        <div class="p-3">
          <div class="btn-group-ring-select btn-group-vertical">
          </div>
        <div>
      </div>
    </div>
  </body>
  <?= $afw->scripts() ?>
  <script>
    let app = new PilseungFighter.App( 'staging' );
    app.alertify.success( "Hello World" );
  </script>
</html>
<!-- vim: set nowrap ts=2 sw=2 expandtab -->
