package PSF::Server;
use lib qw( /usr/local/psf/lib );
use base Clone;
use Try::Tiny;
use JSON::XS;
use Digest::SHA1 qw( sha1_hex );
use List::Util (qw( first shuffle ));
use List::MoreUtils (qw( first_index part ));
use Date::Manip;
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use Clone qw( clone );
use File::Slurp qw( read_file );
use Encode qw( encode );
use PSF::Config;
use PSF::Client::Registry;
use PSF::Server::Comms;
use PSF::Server::Comms::Client;
use PSF::Server::Comms::Division;
use PSF::Server::Comms::Match;
use PSF::Server::Comms::Ring;
use PSF::Server::Comms::Server;
use PSF::Server::Comms::Tournament;

our $DEBUG = 1;

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
	my $self               = shift;
	$self->{ _config }     = new PSF::Config();
	$self->{ _registery }  = new PSF::Client::Registry();
	$self->{ _comms }      = new PSF::Server::Comms( $self );
	$self->{ _json }       = (new JSON::XS())->boolean_values( 0, 1 );
	$self->{ client }      = new PSF::Server::Comms::Client( $self );
	$self->{ division }    = new PSF::Server::Comms::Division( $self );
	$self->{ match }       = new PSF::Server::Comms::Match( $self );
	$self->{ ring }        = new PSF::Server::Comms::Ring( $self );
	$self->{ server }      = new PSF::Server::Comms::Server( $self );
	$self->{ tournament }  = new PSF::Server::Comms::Tournament( $self );

}

# ============================================================
sub config {
# ============================================================
	my $self = shift;
	return $self->{ _config };
}

# ============================================================
sub json {
# ============================================================
	my $self = shift;
	return $self->{ _json };
}

# ============================================================
sub registry {
# ============================================================
	my $self = shift;
	return $self->{ _registry };
}

# ============================================================
sub send {
# ============================================================
	my $self = shift;
	return $self->{ _comms };
}

# ============================================================
sub client_health_check {
# ============================================================
	my $self  = shift;
	my $ring  = shift;
	my $group = shift;

	return unless $ring ne 'staging' && $group->changed();

	my $response = { type => 'users', action => 'update', ring => $ring };
	$self->send->group( $response );
}

# ============================================================
sub handle {
# ============================================================
	my $self     = shift;
	my $request  = shift;
	my $action   = $request->{ action }; $action =~ s/\s+/_/g;
	my $type     = $request->{ type };   $type =~ s/\s+/_/g;
	my $cid      = $request->{ from };
	my $client   = $self->registry->client( $cid );

	die "Server Error: Subject $type not defined $!" unless exists $self->{ $type };
	die "Server Error: Subject $type does not implement Server Comms Protocol $!" unless( ref( $self->{ $type }) && $self isa PSF::Server::Comms::Protocol )

	my $subject = $self->{ $type };

	die "Server Error: Subject $type cannot implement the requested action $action $!" unless $subject->can( $action );

	return $subject->$action( $request, $client );
}

# ============================================================
sub handle_match_update {
# ============================================================
 	my $self    = shift;
	my $request = shift;
	my $client  = shift;
	my $mid     = $request->{ mid };

	print STDERR "$user message.\n" if $DEBUG;

	my $response = { type => 'division', action => 'update', ring => $ring, division => $division, request => $request };
	$self->send->group( $response );
}

1;
