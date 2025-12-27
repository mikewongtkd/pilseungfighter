package PSF::Server::Comms::Division;

use lib qw( /usr/local/psf/lib );
use base qw( PSF::Server::Comms::Protocol );
use PSF::Class::Division;

# ============================================================
sub _factory {
# ============================================================
	my $self    = shift;
	my $request = shift;
	my $handler = {
		uuid => sub {
			my $uuid = shift;
			return new PSF::Class::Division( $uuid );
		},
		values => {
			my $values = shift;
			return new PSF::Class::Division( %$values );
		}
	};

	return $self->SUPER::_factory( $request, $handler );
}

# ============================================================
sub _list {
# ============================================================
	my $self   = shift;
	
	return PSF::Class::Division->list();
}

# ============================================================
sub _search {
# ============================================================
	my $self    = shift;
	my $request = shift;
	my $subject = $self->_subject();

	return PSF::Class::Division->search( where => $request->{ $subject });
}

# ============================================================
sub _subject {
# ============================================================
	my $self = shift;
	return 'division';
}

1;

