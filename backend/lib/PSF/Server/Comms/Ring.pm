package PSF::Server::Comms::Ring;

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
		return new PSF::Class::Ring( $uuid );
	} else {
		return new PSF::Class::Ring();
	}
}

# ============================================================
sub _search {
# ============================================================
	my $self    = shift;
	my $request = shift;
	my $subject = $self->_subject();

	return PSF::Class::Ring->search( $request->{ $subject });
}

# ============================================================
sub _subject {
# ============================================================
	my $self = shift;
	return 'ring';
}

1;

