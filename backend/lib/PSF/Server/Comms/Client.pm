package PSF::Server::Comms::Client;

use lib qw( /usr/local/psf/lib );
use base qw( PSF::Server::Comms::Protocol );

# ============================================================
sub pong {
# ============================================================
	my $self    = shift;
	my $request = shift;
	my $client  = shift;
	my $ring    = $client->ring();
	my $ping    = $request->{ server }{ ping };
	my $changed = $client->ping->pong( $ping );

	# Only broadcast when there is a change of status
	return unless $changed;

	my $status   = $client->status();
	my $response = { type => 'users', ring => $ring, status => $status, request => $request };
	$self->send->group( $response );
}

1;
