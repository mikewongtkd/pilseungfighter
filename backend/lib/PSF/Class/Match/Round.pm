package PSF::Class::Match::Round;
use lib qw( /usr/local/psf/lib );
our $defaults = {
	name     => undef,
	code     => undef,
	division => undef
};

use PSF::Class::Clock;

use base qw( PSF::DBO );

# ============================================================
sub new {
# ============================================================
	my ($class) = map { ref || $_ } shift;
	my $self    = bless {}, $class;

	$self->SUPER::new( @_ );
	my $clock   = new PSF::Class::Clock( name => 'clock' );
	my $kyeshi  = new PSF::Class::Clock( name => 'kyeshi' );
	my $medical = new PSF::Class::Clock( name => 'medical' );
}

# ============================================================
sub delete {
# ============================================================
	my $self = shift;

	$self->clock->delete();
	$self->kyeshi->delete();
	$self->medical->delete();

	$self->SUPER::delete();
}

1;

