package PSF::Client::Ping;
use lib qw( /usr/local/psf/lib );
use base qw( Clone );
use List::Util qw( sum );
use Data::Structure::Util qw( unbless );
use JSON::XS;
use Mojolicious::Controller;
use Mojo::IOLoop;
use Statistics::Descriptive;
use Try::Tiny;

# ============================================================
sub new {
# ============================================================
	my ($class) = map { ref || $_ } shift;
	my $self = bless {}, $class;
	$self->init( @_ );
	return $self;
}

# ============================================================
sub init {
# ============================================================
	my $self   = shift;
	my $client = shift;

	$self->{ pings }       = {};
	$self->{ client }      = $client;
	$client->{ drop_time } = 0;
	$self->{ timestats }   = new Statistics::Descriptive::Full();
	$self->{ speed } = { normal => 30, fast => 15, faster => 5, fastest => 1 };
	$self->{ rates } = { strong => 1 / $self->{ speed }{ normal }, good => 1 / $self->{ speed }{ fast }, weak => 1 / $self->{ speed }{ faster }, bad => 1 / $self->{ speed }{ fastest }};
}

# ============================================================
sub changed {
# ============================================================
	my $self = shift;
	return 0 unless exists $self->{ health };
	my $health = $self->health();

	return $self->{ health } eq $health;
}

# ============================================================
sub fast {
# ============================================================
	my $self = shift;
	$self->go( $self->{ speed }{ fast });
}

# ============================================================
sub faster {
# ============================================================
	my $self = shift;
	$self->go( $self->{ speed }{ faster });
}

# ============================================================
sub fastest {
# ============================================================
	my $self = shift;
	$self->go( $self->{ speed }{ fastest });
}

# ============================================================
sub go {
# ============================================================
	my $self     = shift;
	my $interval = shift;
	return if $self->{ interval } == $interval;

	$self->stop();
	$self->start( $interval );
}

# ============================================================
sub health {
# ============================================================
	my $self      = shift;
	my $drop_time = $self->{ drop_time };
	my $dropped   = int( keys %{$self->{ pings }});

	my $drop_rate = $drop_time == 0 ? 0 : $dropped / $drop_time;

	return 'strong' if( $drop_rate <= $self->{ rates }{ strong });
	return 'good'   if( $drop_rate <= $self->{ rates }{ good });
	return 'weak'   if( $drop_rate <= $self->{ rates }{ weak });
	return 'bad'    if( $drop_rate <= $self->{ rates }{ bad });
	return 'dead'   if( $drop_rate >  $self->{ rates }{ bad });
}

# ============================================================
sub normal {
# ============================================================
	my $self = shift;
	$self->go( $self->{ speed }{ normal });
}

# ============================================================
sub pong {
# ============================================================
	my $self      = shift;
	my $ping      = shift;
	my $client    = $self->{ client };
	my $pingts    = $ping->{ timestamp };
	my $pongts    = time();
	my $dropped   = [ keys %{ $self->{ pings }}];

	delete $self->{ pings }{ $pingts } if( exists $self->{ pings }{ $pingts });

	$self->{ timestats }->add_data( abs( $pongts - $pingts ));
	$client->{ drop_time } = $self->{ timestats }->mean();

	my $health = $self->health();

	if(    $health eq 'strong' ) { $self->normal();  }
	elsif( $health eq 'good'   ) { $self->fast();    }
	elsif( $health eq 'weak'   ) { $self->faster();  }
	elsif( $health eq 'bad '   ) { $self->fastest(); }
	elsif( $health eq 'dead'   ) { $self->stop();    }

	my $changed = $health eq $self->{ health } ? 0 : 1;
	$self->{ health } = $health;

	# Clear out older pings
	if( int( @$dropped ) > 30 ) {
		my ($oldest) = sort { $a <=> $b } map { int( $_ ) } @$dropped;
		my $limit    = 0;

		while( int( @$dropped ) > 30 && $limit < 10 ) {
			delete $self->{ pings }{ $oldest };
			my $dropped = [ keys %{ $self->{ pings }}];
			$limit++;
		}
	}

	return $changed;
}

# ============================================================
sub quit {
# ============================================================
	my $self   = shift;
	my $client = $self->{ client };
	my $id     = $self->{ id };

	return unless $id;

	Mojo::IOLoop->remove( $id );
	delete $self->{ id };
	delete $client->{ ping };
}

# ============================================================
sub start {
# ============================================================
	my $self     = shift;
	my $interval = shift || $self->{ speed }{ normal };
	my $client   = $self->{ client };
	my $ws       = $client->{ websocket };

	$self->{ interval } = $interval;

	$self->{ id } = Mojo::IOLoop->recurring( $interval => sub ( $ioloop ) {
		my $now = time();
		$self->{ pings }{ $now } = 1;

		my $ping = { type => 'server', action => 'ping', ring => $client->ring(), cid => $client->cid(), gid => $client->gid(), role => $client->role(), server => { timestamp => $now }};
		$ws->send({ json => $ping });
	});
}

# ============================================================
sub stop {
# ============================================================
	my $self   = shift;
	my $id     = $self->{ id };

	return unless $id;

	Mojo::IOLoop->remove( $id );
	delete $self->{ id };
}

1;
