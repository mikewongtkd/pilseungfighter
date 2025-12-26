package PSF::Class::Ring;
use lib qw( /usr/local/psf/lib );
use base qw( PSF::DBO );
our $defaults = {
	id         => undef
};

use base qw( PSF::DBO );

# ============================================================
sub new {
# ============================================================
	my ($class) = map { ref || $_ } shift;
	my $self    = bless {}, $class;

	$self->SUPER::new( @_ );
}

# ============================================================
sub code {
# ============================================================
	my $self = shift;
	my $id   = $self->{ data }{ id };
	return $id if( $id eq 'staging' );
	return sprintf( "ring%02d", int( $id ));
}

# ============================================================
sub delete {
# ============================================================
	my $self = shift;

	$self->SUPER::delete();
}

# ============================================================
sub id {
# ============================================================
	my $self = shift;
	return $self->{ data }{ id };
}

# ============================================================
sub name {
# ============================================================
	my $self = shift;
	my $id   = $self->{ data }{ id };
	return ucfirst $id if( $id eq 'staging' );
	return sprintf( "Ring %d", int( $id ));
}


1;
