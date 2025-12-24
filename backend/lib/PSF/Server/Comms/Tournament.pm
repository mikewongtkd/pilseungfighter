package PSF::Server::Comms::Tournament;

use lib qw( /usr/local/psf/lib );
use base qw( PSF::Server::Comms::Protocol );

# ============================================================
sub _factory {
# ============================================================
	my $self    = shift;
	my $request = shift;
	my $subject = $self->_subject();

	if( exists $request->{ $subject }{ uuid }) {
		my $uuid = $request->{ $subject }{ uuid };
		return new PSF::Class::Tournament( $uuid );
	} else {
		return new PSF::Class::Tournament();
	}
}

# ============================================================
sub _search {
# ============================================================
	my $self    = shift;
	my $request = shift;
	my $subject = $self->_subject();

	return PSF::Class::Tournament->search( 'where' => $request->{ $subject });
}

# ============================================================
sub _subject {
# ============================================================
	my $self = shift;
	return 'tournament';
}

1;

