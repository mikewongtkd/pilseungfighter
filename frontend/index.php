<?php
  include_once( 'include/php/session.php' );
  include_once( 'include/php/app.php' );
  include_once( 'include/php/psfclasses.php' );

  $afw   = new AppFramework();
  $psfc  = new PSFClasses([ 'ring' ]);
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
      <h1>Pilseung Fighter</h1>
      <section class="row section-ring-select">
        <h2>Select a Ring</h2>
        <div class="btn-group-ring-select btn-group">
        </div>
      </section>
      <section class="row section-role-select">
      </section>
    </div>
  </body>
  <?= $afw->scripts() ?>
  <?= $psfc->scripts() ?>
  <script>
    let app = new PilseungFighter.App( 'staging' );
    app.on.connect( "<?= $comms ?>" ).list.ring();

    app.network.on
      .heard( 'ring' )
        .response( 'list' ).respond( update => {
          if( update?.rings && update.rings.length > 0 ) {
            let rings = [{ id: 'staging', name: 'Staging' }];
            for( let i = 1; i <= 6; i++ ) { rings.push({ id: i, name: `Ring ${i}` }); }
            $( '.btn-group-ring-select' ).empty();
            rings.forEach( ring => {
              let button = $( `<button type="button" class="btn btn-secondary" data-ring-id="${ring.id}">${ring.name}</button>` );
              button.off( 'click' ).click( ev => {
                let message = { subject: 'ring', action: 'write', ring: { id: ring.id }};
                app.network.send( message );
              });
              $( '.btn-group-ring-select' ).append( button );
            });

            update.rings.forEach( rdata => {
              let ring   = new PilseungFighter.Ring( rdata );
              let button = $( '.btn-group-ring-select' ).find( `button[data-ring-id="${ring.id}"]` );
              button.removeClass( 'btn-secondary' ).addClass( 'btn-primary' ).off( 'click' ).click( ev => {
                app.sound.next.play();
                app.alertify.notify( `${ring.name} selected.` );
              });
            });

          } else {
            $( '.section-ring-select' ).hide();
            $( '.section-ring-remove' ).hide();
            let message = { subject: 'ring', action: 'write', ring: { id: 'staging' }};
            app.network.send( message );
          }
        })
        .response( 'write' ).respond( update => {
          let ring = new PilseungFighter.Ring( update.ring );
          app.alertify.success( `${ring.name} opened` );
          let message = { subject: 'ring', action: 'list' };
          app.network.send( message );
        });
  </script>
</html>
<!-- vim: set nowrap ts=2 sw=2 expandtab -->
