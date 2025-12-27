package PSF::Server::Comms::Protocol;
use lib qw( /usr/local/psf/lib );
use Clone qw( clone );
use Lingua::EN::Inflexion qw( noun );

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
sub delete {
# ============================================================
	my $self    = shift;
	my $request = shift;
	my $subject = $self->_subject();

	die "Response Error: No UUID specified for delete request $!" unless( exists $request->{ $subject });
	my $uuid = $request->{ $subject };
	die "Response Error: '$uuid' is not a valid UUID for delete request $!" unless( $uuid =~ /^[0-9A-Fa-f]{8}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{12}$/ );

	my $instance = $self->_factory( $request );
	my $response = { request => $request, subject => $subject, $subject => $instance->document() };
	$instance->delete();

	$self->send->group( $response );
}

# ============================================================
sub first {
# ============================================================
	my $self     = shift;
	my $request  = shift;
	my @rows     = $self->_search( $request );
	my $first    =  int( @rows ) ? $rows[ 0 ] : undef;
	my $subject  = $self->_subject();
	my $response = { request => $request, subject => $subject, $subject => $first };
	$self->send->client( $response );
}

# ============================================================
sub list {
# ============================================================
	my $self     = shift;
	my $request  = shift;
	my @rows     = map { $_->document() } $self->_list();
	my $subject  = $self->_subject();
	my $subjects = noun( $subject )->plural();

	my $response = { request => $request, subject => $subject, $subjects => [ @rows ]};
	$self->send->client( $response );
}

# ============================================================
sub read {
# ============================================================
	my $self    = shift;
	my $request = shift;
	my $subject = $self->_subject();

	die "Response Error: No UUID specified for read request $!" unless( exists $request->{ $subject });
	my $uuid = $request->{ $subject };
	die "Response Error: '$uuid' is not a valid UUID for read request $!" unless( $uuid =~ /^[0-9A-Fa-f]{8}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{12}$/ );

	my $instance = $self->_factory( $request );
	my $response = { request => $request, subject => $subject, $subject => $instance->document() };
	$self->send->client( $response );
}

# ============================================================
sub search {
# ============================================================
	my $self     = shift;
	my $request  = shift;

	return $self->_search( $request );
}

# ============================================================
sub send {
# ============================================================
	my $self = shift;
	return $self->server->send();
}

# ============================================================
sub server {
# ============================================================
	my $self = shift;
	return $self->{ _server };
}

# ============================================================
sub write {
# ============================================================
	my $self     = shift;
	my $request  = shift;
	my $subject  = $self->_subject();
	my $instance = $self->_factory( $request );

	my $response = { request => $request, subject => $subject, $subject => $instance->document() };
	$self->send->group( $response );
}

# ============================================================
sub _factory {
# ============================================================
	my $self     = shift;
	my $request  = shift;
	my $handler  = shift;
	my $subject  = $self->_subject();
	my $values   = exists $request->{ $subject } ? $request->{ $subject } : {};
	my $uuid     = ref $values ? (exists $values->{ uuid } ? $values->{ uuid } : undef ) : $values;

	if( $uuid ) {
		return $handler->{ uuid }( $uuid );
	} else {
		return $handler->{ values }( $values );
	}
}

# ============================================================
sub _list {
# ============================================================
	my $self = shift;
	return ();
}

# ============================================================
sub _search {
# ============================================================
	my $self = shift;
	return ();
}

# ============================================================
sub _subject {
# ============================================================
	my $self = shift;
	return undef;
}

1;
