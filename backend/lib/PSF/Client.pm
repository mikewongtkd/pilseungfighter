package PSF::Client;
use lib qw( /usr/local/psf/lib );
use base Clone;
use Data::Structure::Util qw( unbless );
use Digest::SHA1 qw( sha1_hex );
use JSON::XS;
use Mojolicious::Controller;
use PSF::Client::Group;
use PSF::Client::Ping;

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
	my $self       = shift;
	my $websocket  = shift;
	my $connection = $websocket->tx();
	my $ring       = $websocket->param( 'ring' );
	my $role       = $websocket->param( 'role' );
	my $sessid     = $websocket->cookie( 'psf-session' );
	my $id         = $role eq 'display' || $role eq 'admin' ? sha1_hex( $connection ) : sha1_hex( $sessid );

	$role = lc $role;
	$role =~ s/\+/ /g;

	$self->{ id }         = $id;
	$self->{ ring }       = _parse_ring( $ring );
	$self->{ sessid }     = $sessid;
	$self->{ role }       = $role;
	$self->{ device }     = $connection;
	$self->{ websocket }  = $websocket;
}

# ============================================================
sub description {
# ============================================================
	my $self   = shift;
	my $cid    = $self->cid();
	my $role   = $self->role();
	$role = join( ' ', map { ucfirst } split( /(?:\s)/, $role ));
	my $jid = $self->jid();
	$role = $jid == 0 ? 'Referee' : "Judge $jid" if defined $jid;

	return sprintf( "%s (%s)", $role, $cid );
}

# ============================================================
sub cid {
# ============================================================
	my $self = shift;
	return sprintf( "%s-%s", substr( $self->sessid(), 0, 4 ), substr( $self->id(), 0, 4 ));
}

# ============================================================
sub group {
# ============================================================
	my $self  = shift;
	my $group = shift;

	if( $group ) {
		$self->{ group } = $group;
		$self->{ gid }   = $group->id();
	}
	return $self->{ group };
}

# ============================================================
sub jid {
# ============================================================
	my $self = shift;
	my $role = $self->role();
	return undef unless $role =~ /^judge/i;
	my ($jid) = $role =~ /^judge(\d+)$/i;
	return $jid;
}

# ============================================================
sub json {
# ============================================================
	my $self  = shift;
	my $clone = unbless( $self->clone());
	my $json  = new JSON::XS();

	# Remove nested objects
	foreach my $key (qw( device ping websocket )) {
		next unless exists $clone->{ $_ };
		delete $clone->{ $_ } 
	}

	return $json->canonical->encode( $clone );
}

# ============================================================
sub ping {
# ============================================================
	my $self = shift;

	return $self->{ ping } if exists $self->{ ping };

	$self->{ ping } = new PSF::Client::Ping( $self );
	return $self->{ ping };
}

# ============================================================
sub Role {
# ============================================================
	my $self = shift;
	my $role = $self->role();
	$role = join( ' ', map { ucfirst } split /\s/, $role );
	return $role;
}

# ============================================================
sub send {
# ============================================================
	my $self = shift;
	$self->device->send( @_ );
}

# ============================================================
sub status {
# ============================================================
	my $self   = shift;
	my $cid    = $self->cid();
	my $ping   = exists $self->{ ping } ? $self->ping() : undef;
	my $role   = $self->Role();
	my $health = $ping ? $ping->health() : 'n/a';

	return { cid => $cid, role => $role, health => $health };
}

sub device     { my $self = shift; return $self->{ device };     }
sub gid        { my $self = shift; return $self->{ gid };        }
sub id         { my $self = shift; return $self->{ id };         }
sub ring       { my $self = shift; return $self->{ ring };       }
sub role       { my $self = shift; return $self->{ role };       }
sub sessid     { my $self = shift; return $self->{ sessid };     }
sub timedelta  { my $self = shift; return $self->{ timedelta };  }

sub _parse_ring {
	my $ring = shift;
	if( $ring =~ /^\d{1,2}$/ ) {
		$ring = sprintf( "ring%02d", int( $ring ));

	} elsif( $ring =~ /^ring\d{2}$/i || $ring =~ /^staging$/i ) {
		$ring = lc $ring;

	} else {
		$self->send( json => "Client Registration Error: Ring $ring is invalid.\n" );
	}
}

1;
