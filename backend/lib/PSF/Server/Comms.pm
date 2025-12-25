package PSF::Server::Comms;
use lib qw( /usr/local/psf/lib );
use PSF::DBO;
use Clone qw( clone );
use Data::Structure::Util qw( unbless );
use Digest::SHA1 qw( sha1_hex );
use JSON::XS;

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
	my $server = shift;

	$self->{ _server } = $server;
}

# ============================================================
sub server {
# ============================================================
	my $self = shift;
	return $self->{ _server };
}

# ============================================================
sub client {
# ============================================================
 	my $self      = shift;
	my $response  = shift;
	my $request   = $response->{ request };
	my $cid       = $request->{ from }; die "Comms Error: Cannot have server talk to itself (CID: $cid) $!" unless $cid;
	my $client    = $self->server->registry->client( $cid );
	my $cstatus   = $client->status();

	print STDERR "  Sending division information (message ID: $mid) to:\n" if $DEBUG;
	printf STDERR "    %-17s  %s  %s\n", $cstatus->{ role }, $cstatus->{ cid }, $cstatus->{ health } if $DEBUG;

	$client->send({ json => $response });
}

# ============================================================
sub group {
# ============================================================
 	my $self        = shift;
	my $response    = shift;
	my $request     = $response->{ request };
	my $cid         = $request->{ from };
	my $ring        = $request->{ ring };
	my $registry    = $self->server->registry();
	my $from_server = defined( $cid ) && $cid == 0;
	my $client      = $from_server ? undef : $registry->client( $cid ); die "Client '$cid' not found $!" unless ($client || $from_server);
	my $group       = $from_server ? $registry->group( $ring ) : $client->group();
	my $status      = $group->status();
	my $json        = new JSON::XS();
	my $digest      = sha1_hex( $json->canonical->encode( $response ));
	my $mid         = substr( $digest, 0, 4 );

	print STDERR "  Broadcasting division information (message ID: $mid) to:\n" if $DEBUG;

	foreach my $client ($group->clients()) {
		my $now       = (new Date::Manip::Date( 'now GMT' ))->printf( '%O' ) . 'Z';
		my $cstatus   = $client->status();
		printf STDERR "    %-17s  %s  %s\n", $cstatus->{ role }, $cstatus->{ cid }, $cstatus->{ health } if $DEBUG;
		$client->send({ json => $response });
	}
	print STDERR "\n" if $DEBUG;
}

# ============================================================
sub stringify {
# ============================================================
	my $self  = shift;
	my $data  = shift; $data = defined $data ? $data : $self;
	my $json  = new JSON::XS();
	my $ref   = ref $data;

	if( $ref ) {
		if( $ref eq 'ARRAY' ) {
			return $json->canonical->encode( $data );

		} else {
			my $clone = unbless( clone( $data ));
			my $uuid  = undef;
			if( exists $clone->{ uuid }) {
				$uuid = $clone->{ uuid };
				delete $clone->{ uuid };
			}
			PSF::DBO::_prune( $clone );
			return $json->canonical->encode( $clone );
		}
	} else {
		return $data;
	}
}

1;
