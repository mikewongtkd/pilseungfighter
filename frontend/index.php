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
      <section class="row section-role-select">
        <h2>Select a Role</h2>
        <div class="btn-group-role-select btn-group">
          <button type="button" class="btn btn-success btn-judge-role" >Judge</button>
          <button type="button" class="btn btn-info btn-operator-role" >Computer Operator</button>
          <button type="button" class="btn btn-primary btn-admin-role" >Admin</button>
        </div>
      </section>
      <section class="row section-judge-select" style="display: none;">
        <h2>Select Judge Role</h2>
        <div class="row">
          <div class="col-1">
            <button type="button" class="btn btn-warning btn-back-to-role-select">Back</button>
          </div>
          <div class="col-11">
            <div class="btn-group-ring-action btn-group">
              <button type="button" class="btn btn-primary btn-judge-select" data-judge="0">Referee</button>
              <button type="button" class="btn btn-primary btn-judge-select" data-judge="1">Judge 1</button>
              <button type="button" class="btn btn-primary btn-judge-select" data-judge="2">Judge 2</button>
              <button type="button" class="btn btn-primary btn-judge-select" data-judge="3">Judge 3</button>
              <button type="button" class="btn btn-primary btn-judge-select" data-judge="4">Judge 4</button>
            </div>
          </div>
        </div>
      </section>
      <section class="row section-ring-select" style="display: none;">
        <h2>Select a Ring</h2>
        <div class="row">
          <div class="col-1">
            <button type="button" class="btn btn-warning btn-back-to-role-select">Back</button>
          </div>
          <div class="col-11">
            <div class="btn-group-ring-select btn-group">
            </div>
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
    app.state.ring = { id: 'staging' };
    app.state.role = null;

    // BUTTON BEHAVIOR
    $( '.btn-select-role' ).off( 'click' ).click( ev => {
      let target = $( ev.target );
      let ring   = app.state.ring;
      let role   = target.attr( 'data-role' );
      app.state.role = role;
    });

    $( '.btn-back-to-role-select' ).off( 'click' ).click( ev => {
      app.sound.prev.play();
      app.state.ring = null;
      $( '.section-judge-select' ).hide();
      $( '.section-role-select' ).show();
      $( '.section-ring-select' ).hide();
    });

    $( '.btn-judge-role' ).off( 'click' ).click( ev => {
      app.sound.next.play();
      $( '.section-judge-select' ).show();
      $( '.section-role-select' ).hide();
      $( '.section-ring-select' ).hide();
    });

    $( '.btn-operator-role' ).off( 'click' ).click( ev => {
      app.sound.next.play();
      app.state.role = 'operator';

      $( '.section-judge-select' ).hide();
      $( '.section-role-select' ).hide();
      $( '.section-ring-select' ).show();
    });

    $( '.btn-admin-role' ).off( 'click' ).click( ev => {
      window.location = `admin.php?ring=staging`;
    });

    $( '.btn-judge-select' ).off( 'click' ).click( ev => {
      app.sound.next.play();
      let target     = $( ev.target );
      app.state.role = target.attr( 'data-judge' );

      $( '.section-judge-select' ).hide();
      $( '.section-role-select' ).hide();
      $( '.section-ring-select' ).show();

    });

    app.network.on
      .heard( 'ring' )
        .response( 'list' ).respond( update => {
          app.state.ring = null;
          $( '.section-role-select' ).show();
          $( '.section-judge-select' ).hide();
          $( '.section-ring-select' ).hide();
          // There are some rings; show them
          if( update?.rings && update.rings.length > 0 ) {
            let rings = [ 'staging' ];
            for( let i = 1; i <= 6; i++ ) { rings.push( i ); }
            rings = rings.map( ringid => new PilseungFighter.Ring( ringid ));
            $( '.btn-group-ring-select' ).empty();
            rings.forEach( ring => {
              let button = $( `<button type="button" class="btn btn-secondary" data-ring-id="${ring.id}">${ring.name}</button>` );
              button.off( 'click' );
              $( '.btn-group-ring-select' ).append( button );
            });

            update.rings.forEach( rdata => {
              let ring   = new PilseungFighter.Ring( rdata );
              let button = $( '.btn-group-ring-select' ).find( `button[data-ring-id="${ring.id}"]` );
              button.removeClass( 'btn-secondary' ).addClass( 'btn-primary' ).off( 'click' ).click( ev => {
                app.state.ring = ring;

                if( app.state.role == 'operator' ) {
                  window.location = `operator.php?ring=${app.state.ring.id}`;
                } else {
                  window.location = `judge.php?ring=${app.state.ring.id}&judge=${app.state.role}`;
                }

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
<!-- vim: set nowrap ts=2 sw=2 expandtab : -->
