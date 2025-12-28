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
      <section class="row section-role-select" style="display: none;">
        <h2>Select a Role</h2>
        <div class="row">
          <div class="btn-group-ring-action btn-group col-6">
            <button type="button" class="btn btn-warning btn-back-to-ring-select">Back</button>
            <button type="button" class="btn btn-danger btn-delete-ring">Delete Ring</button>
          </div>
          <div class="btn-group-role-select btn-group col-6">
            <a class="btn btn-success" href="judge.php">Judge</a>
            <a class="btn btn-info"    href="operator.php">Computer Operator</a>
            <a class="btn btn-primary" href="admin.php">Admin</a>
          </div>
        </div>
      </section>
    </div>
  </body>
  <?= $afw->scripts() ?>
  <?= $psfc->scripts() ?>
  <script>
    let app = new PilseungFighter.App( 'staging' );
    app.on.connect( "<?= $comms ?>" ).list.ring();
    app.state.ring = null;

    // BUTTON BEHAVIOR
    $( '.btn-back-to-ring-select' ).off( 'click' ).click( ev => {
      app.sound.prev.play();
      app.state.ring = null;
      $( '.section-role-select' ).hide();
      $( '.section-ring-select' ).show();
    });

    $( '.btn-delete-ring' ).off( 'click' ).click( ev => {
      let ring = app.state.ring;
      app.network.send( ring.message.delete() );
    });

    app.network.on
      .heard( 'ring' )
        .response( 'delete' ).respond( update => {
          let ring = new PilseungFighter.Ring( update.ring );
          app.network.send( ring.message.list() );
          app.alertify.notify( `${ring.name} deleted` );
        })
        .response( 'list' ).respond( update => {
          app.state.ring = null;
          $( '.section-role-select' ).hide();
          $( '.section-ring-select' ).show();
          // There are some rings; show them
          if( update?.rings && update.rings.length > 0 ) {
            let rings = [ 'staging' ];
            for( let i = 1; i <= 6; i++ ) { rings.push( i ); }
            rings = rings.map( ringid => new PilseungFighter.Ring( ringid ));
            $( '.btn-group-ring-select' ).empty();
            rings.forEach( ring => {
              let button = $( `<button type="button" class="btn btn-secondary" data-ring-id="${ring.id}">${ring.name}</button>` );
              button.off( 'click' ).click( ev => {
                app.network.send( ring.message.create() );
              });
              $( '.btn-group-ring-select' ).append( button );
            });

            update.rings.forEach( rdata => {
              let ring   = new PilseungFighter.Ring( rdata );
              let button = $( '.btn-group-ring-select' ).find( `button[data-ring-id="${ring.id}"]` );
              button.removeClass( 'btn-secondary' ).addClass( 'btn-primary' ).off( 'click' ).click( ev => {
                app.sound.next.play();
                app.state.ring = ring;
                app.alertify.notify( `${ring.name} selected.` );
                $( '.section-ring-select' ).hide();
                $( '.section-role-select' ).show();
                $( '.section-role-select' ).find( 'h2' ).html( `Select a Role for ${ring.name}` );
              });
            });

          } else {
            // There are no rings in the DB; create the staging ring automatically
            let ring = new PilseungFighter.Ring( 'staging' );
            app.network.send( ring.message.create() );
          }
        })
        .response( 'write' ).respond( update => {
          let ring = new PilseungFighter.Ring( update.ring );
          app.alertify.success( `${ring.name} opened` );
          app.network.send( ring.message.list() );
        });
  </script>
</html>
<!-- vim: set nowrap ts=2 sw=2 expandtab -->
