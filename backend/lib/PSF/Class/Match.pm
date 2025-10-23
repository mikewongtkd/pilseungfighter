package PSF::Class::Match;
use lib qw( /usr/local/psf/lib );
our $defaults = {
	id         => undef,
	division   => undef,
	ring       => undef,
	round      => undef,
	contestant => [],
	winner     => undef
};

use PSF::Class::Match::Round;

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
