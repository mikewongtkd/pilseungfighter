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
use Mojo::IOLoop;
use Mojo::IOLoop::Delay;
use PSF::Config;
use PSF::Client::Registry;
use PSF::Server::Comms;

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
	$self->{ match }       = {
		read               => \&handle_match_read,
		score              => \&handle_match_score,
		update             => \&handle_match_update,
		write              => \&handle_match_write,
	};
	$self->{ ring }        = {
		read               => \&handle_ring_read,
		update             => \&handle_ring_update,
	};
	$self->{ tournament } = {
		read               => \&handle_tournament_read,
	};
	$self->init_client_server();
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
sub init_client_server {
# ============================================================
	$self = shift;
	$self->{ client } = {
		pong          => \&handle_client_pong
	};
	$self->{ server } = {
		stop_ping     => \&handle_server_stop_ping
	};
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

	my $dispatch = $self->{ $type }{ $action } if exists $self->{ $type } && exists $self->{ $type }{ $action };
	return $self->$dispatch( $request, $client ) if defined $dispatch;
	print STDERR "Unknown request $type, $action\n";
}

# ============================================================
sub handle_client_pong {
# ============================================================
	my $self    = shift;
	my $request = shift;
	my $client  = shift;
	my $ping    = $request->{ server }{ ping };
	my $changed = $client->ping->pong( $ping );

	# Only broadcast when there is a change of status
	return unless $changed;

	my $status   = $client->status();
	my $response = { type => 'users', action => 'update', ring => $ring, status => $status, request => $request };
	$self->send->group( $response );
}

# ============================================================
sub handle_server_stop_ping {
# ============================================================
 	my $self      = shift;
	my $request   = shift;
	my $client    = shift;
	my $user      = $client->description();

	print STDERR "$user requests server stop pinging them.\n" if $DEBUG;

	$client->ping->quit();

	my $response = { type => 'users', action => 'update', ring => $ring, request => $request };
	$self->send->group( $request );
}

# ============================================================
sub handle_match_update {
# ============================================================
 	my $self      = shift;
	my $request   = shift;
	my $client    = shift;
	my $mid       = $request->{ mid };

	print STDERR "$user message.\n" if $DEBUG;

	my $response = { type => 'division', action => 'update', ring => $ring, division => $division, request => $request };
	$self->send->group( $response );
}

# ============================================================
sub autopilot {
# ============================================================
#** @method( request, progress, group )
#   @brief Automatically advances to the next form/athlete/round/division
#*

	my $self     = shift;
	my $request  = shift;
	my $progress = shift;
	my $group    = shift;
	my $division = $progress->current();
	my $cycle    = $division->{ autodisplay } || 2;

	request->{ type } = 'autopilot';

	# ===== ENGAGE AUTOPILOT
	try {
		print STDERR "Engaging autopilot.\n" if $DEBUG;
		$division->autopilot( 'on' );
		$division->write();
	} catch {
		return { error => $_ };
	};

	my @steps = $division->method->autopilot_steps( $self, $request, $progress, $group );
	my $delay = new Mojo::IOLoop::Delay();
	$delay->steps( @steps );
	$delay->wait();
}

1;
