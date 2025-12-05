package PSF::Security;

use lib qw( /usr/local/psf/lib );
use PHP::Session;

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
	my $config = shift;
	$self->{ config }  = $config;
}

# ============================================================
sub authenticated {
# ============================================================
	my $self   = shift;
	my $client = shift;
	$self->{ client }  = $client;
	return 1; # MW - TODO Look into how to implement using PHP Sessions using SQLite3

	$self->{ session } = new PHP::Session( $client->sessid(), { save_path => '/usr/local/psf/sessions' });
	my $authenticated = $self->{ session }->get( 'is_auth' );
	return $authenticated;
}

# ============================================================
sub authorized {
# ============================================================
	my $self   = shift;
	my $ring   = shift;
	return 1; # MW

	my $domain = $self->{ session }->get( 'ring' );
	$self->{ ring } = $ring;

	return 1 unless $domain || $domain eq 'staging'; # If no domain specified, all rings are authorized
	return $domain eq $ring;
}

# ============================================================
sub enabled {
# ============================================================
	my $self = shift;
	return $self->{ config }->secured();
}

# ============================================================
sub unauthorized {
# ============================================================
	my $self = shift;
	my $ring = $self->{ ring };
	my $user = $self->{ client }->description();
	return "Unauthorized user $user in ring $ring";
}

1;
