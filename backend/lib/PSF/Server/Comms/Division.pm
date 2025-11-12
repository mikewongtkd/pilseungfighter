package PSF::Server::Comms::Division;

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
		return new PSF::Class::Division( $uuid );
	} else {
		return new PSF::Class::Division();
	}
}

# ============================================================
sub _search {
# ============================================================
	my $self    = shift;
	my $request = shift;
	my $subject = $self->_subject();

	return PSF::Class::Division->search( $request->{ $subject });
}

# ============================================================
sub _subject {
# ============================================================
	my $self = shift;
	return 'division';
}

1;

