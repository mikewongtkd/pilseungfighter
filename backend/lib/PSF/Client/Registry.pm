package PSF::Client::Registry;
use lib qw( /usr/local/psf/lib );
use PSF::Client::Group;
use PSF::Client;

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
	my $self = shift;
	$self->{ client } = {};
	$self->{ group }  = {};
}

# ============================================================
sub add {
# ============================================================
	my $self       = shift;
	my $websocket  = shift;
	my $ring       = shift;
	my $client     = new PSF::Client( $websocket );
	my $group      = new PSF::Client::Group( $ring );
	my $gid        = $group->id();

	if( exists $self->{ group }{ $gid }) { $group = $self->{ group }{ $gid } } 
	else                                 { $self->{ group }{ $gid } = $group; }

	$group->add( $client );
	$self->{ client }{ $id } = $client;
	$client->group( $group );

	return $client;
}

# ============================================================
sub client {
# ============================================================
	my $self      = shift;
	my $id        = shift;
	my $client    = exists $self->{ client }{ $id } ? $self->{ client }{ $id } : undef;
	return $client;
}

# ============================================================
sub clients {
# ============================================================
	my $self    = shift;
	my $filter  = shift;
	my @clients = sort { $a->description() cmp $b->description() } values %{ $self->{ client }};

	@clients = grep { $_->role() =~ /^$filter/ } @clients if $filter;

	return @clients;
}

# ============================================================
sub group {
# ============================================================
	my $self  = shift;
	my $ring  = shift;
	my $group = new PSF::Client::Group( $ring );
	my $gid   = $group->id();

	return $self->{ group }{ $gid } if exists $self->{ group }{ $gid };
	return undef;
}

# ============================================================
sub remove {
# ============================================================
	my $self       = shift;
	my $client     = shift;
	my $id         = undef;
	my $group      = undef;

	if( ref $client ) { $id = $client->id(); } 
	else {
		$id     = $client;
		$client = $self->{ client }{ $id };
	}
	my $user = $client->description();
	print STDERR "$user connection closed.\n";

	$group = $client->group();

	if( $group ) {
		$group->remove( $id );
		my $gid = $group->id();
		delete $self->{ group }{ $gid } if( int( $group->clients()) == 0 );
	}
	delete $self->{ client }{ $id } if exists $self->{ client }{ $id };
}

1;
