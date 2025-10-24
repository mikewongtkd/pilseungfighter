package PSF::Class::Clock;
use lib qw( /usr/local/psf/lib );
use base qw( PSF::DBO );

our $defaults = {
	clock    => undef,
	at       => undef,
	action   => undef
};

# ============================================================
sub delete {
# ============================================================
	my $self = shift;

	$_->delete() foreach $self->clock_updates();
	$self->SUPER::delete()
}

1;
