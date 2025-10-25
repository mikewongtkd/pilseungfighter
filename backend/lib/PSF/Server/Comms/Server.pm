package PSF::Server::Comms::Server;

use lib qw( /usr/local/psf/lib );
use base qw( PSF::Server::Comms::Protocol );

# ============================================================
sub stop_ping {
# ============================================================
 	my $self    = shift;
	my $request = shift;
	my $client  = shift;
	my $user    = $client->description();
	my $ring    = $client->ring();
	my $status  = $client->status();

	print STDERR "$user requests server stop pinging them.\n" if $DEBUG;

	$client->ping->quit();

	my $response = { type => 'users', ring => $ring, status => $status, request => $request };
	$self->send->group( $response );
}

1;
