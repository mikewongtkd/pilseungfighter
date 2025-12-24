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
        <div class="p-3"></div>
        <div class="p-3">
          <div class="btn-group-ring-select btn-group-vertical">
            <button type="button" class="btn btn-primary">
          </div>
        <div>
      </div>
    </div>
  </body>
  <?= $afw->scripts() ?>
  <script>
  </script>
</html>
<!-- vim: set nowrap ts=2 sw=2 expandtab -->
