package PSF::Class::Tournament;
use lib qw( /usr/local/psf/lib );
use base qw( PSF::DBO );
our $defaults = {
	id         => undef,
	name       => undef,
	host       => undef,
	location   => undef,
	start      => undef,
	end        => undef,
	rings      => undef
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
sub delete {
# ============================================================
	my $self = shift;

	$self->SUPER::delete();
}

1;
