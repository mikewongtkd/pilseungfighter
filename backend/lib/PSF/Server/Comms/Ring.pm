package PSF::Server::Comms::Ring;

use lib qw( /usr/local/psf/lib );
use base qw( PSF::Server::Comms::Protocol );
use PSF::Class::Ring;

# ============================================================
sub _factory {
# ============================================================
	my $self    = shift;
	my $request = shift;
	my $subject = $self->_subject();
	my $values  = exists $request->{ $subject } ? $request->{ $subject } : {};

	if( exists $values->{ uuid }) {
		my $uuid = $values->{ uuid };
		return new PSF::Class::Ring( $uuid );
	} else {
		return new PSF::Class::Ring( %$values );
	}
}

# ============================================================
sub _list {
# ============================================================
	my $self   = shift;
	
	return PSF::Class::Ring->list();
}

# ============================================================
sub _search {
# ============================================================
	my $self    = shift;
	my $request = shift;
	my $subject = $self->_subject();

	return PSF::Class::Ring->search( where => $request->{ $subject });
}

# ============================================================
sub _subject {
# ============================================================
	my $self = shift;
	return 'ring';
}

1;

