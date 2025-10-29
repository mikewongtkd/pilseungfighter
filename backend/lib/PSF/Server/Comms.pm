package PSF::Server::Comms;

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

	$cleint->send({ json => $response });
}

# ============================================================
sub group {
# ============================================================
 	my $self      = shift;
	my $response  = shift;
	my $request   = $response->{ request };
	my $cid       = $request->{ from };
	my $ring      = $request->{ ring };
	my $registry  = $self->server->registry();
	my $group     = defined $cid && $cid == 0 ?  $registry->group( $ring ) : $registry->client( $cid )->group();
	my $json      = $self->{ _json };
	my $status    = $group->status();
	my $division  = defined $request->{ divid } ? $progress->find( $request->{ divid } ) : $progress->current();
	my $message   = $division->clone();
	my $unblessed = unbless( $message ); 
	my $encoded   = $json->canonical->encode( $unblessed );
	my $digest    = sha1_hex( $encoded );
	my $mid       = substr( $digest, 0, 4 );

	print STDERR "  Broadcasting division information (message ID: $mid) to:\n" if $DEBUG;

	foreach my $client ($group->clients()) {
		my $now       = (new Date::Manip::Date( 'now GMT' ))->printf( '%O' ) . 'Z';
		my $cstatus   = $client->status();
		printf STDERR "    %-17s  %s  %s\n", $cstatus->{ role }, $cstatus->{ cid }, $cstatus->{ health } if $DEBUG;
		$client->send( { json => $response });
	}
	print STDERR "\n" if $DEBUG;
}

1;
