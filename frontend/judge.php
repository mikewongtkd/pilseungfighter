<?php
  include_once( 'include/php/session.php' );
  include_once( 'include/php/app.php' );
  include_once( 'include/php/psfclasses.php' );

  if( isset( $_GET[ 'ring' ])) {
    $ringid = $_GET[ 'ring' ];
  } else {
    $ringid = '"staging"';
  }

  if( isset( $_GET[ 'judge' ])) {
    $jid = intval( $_GET[ 'judge' ]);
  }

  $afw   = new AppFramework();
  $psfc  = new PSFClasses([ 'contestant', 'division', 'judge', 'match', 'score' ]);
  $comms = $afw->websocket();
?>
<!DOCTYPE html>
<html>
  <head>
    <title>Pilseung Fighter</title>
    <?= $afw->links() ?>
  </head>
  <body>
    <div class="container">
      <section class="section-judge-division-match-header">
      </section>
      <section class="score">
        <div class="chung-score">
        </div>
        <div class="hong-score">
        </div>
        <div class="mean-score">
        </div>
      </section>
      <section class="score-controls">
      </section>
    </div>
  </body>
  <?= $afw->scripts() ?>
  <?= $psfc->scripts() ?>
  <script>
    let judge = new PilseungFighter.Judge( <?= $jid ?> );
    let app = new PilseungFighter.App( <?= $ringid ?>, judge.code );
    app.on.connect( "<?= $comms ?>" ).read.ring();
    app.state.judge = judge;

    app.network.on
      .heard( 'ring' )
        .response( 'read' ).respond( update => {
          console.log( 'RING', update ); // MW
        });
  </script>
</html>
<!-- vim: set nowrap ts=2 sw=2 expandtab : -->
