package PSF::Class::Match::Round;
use lib qw( /usr/local/psf/lib );
use base qw( PSF::DBO );
use PSF::Class::Clock;
our $defaults = {
	name     => undef,
	code     => undef,
	division => undef
};

# ============================================================
sub new {
# ============================================================
# \brief Creates new uninitialized object; the Division class
# provides the default values, as they vary by division.
# ------------------------------------------------------------
	my ($class) = map { ref || $_ } shift;
	my $self    = bless {}, $class;

	$self->SUPER::new( @_ );
	my $clock   = new PSF::Class::Clock( name => 'clock' );
	my $kyeshi  = new PSF::Class::Clock( name => 'kyeshi' );
	my $medical = new PSF::Class::Clock( name => 'medical' );

	$self->clock( $clock );
	$self->kyeshi( $kyeshi );
	$self->medical( $medical );

	my $chung = new PSF::Class::Score();
	my $hong  = new PSF::Class::Score();

	$self->chung( $chung );
	$self->hong( $hong );

}

# ============================================================
sub delete {
# ============================================================
	my $self = shift;

	$self->clock->delete();
	$self->kyeshi->delete();
	$self->medical->delete();

	$self->chung->delete();
	$self->hong->delete();

	$self->SUPER::delete();
}

1;

