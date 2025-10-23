package PSF::Class::Clock;
use lib qw( /usr/local/psf/lib );

use base qw( PSF::DBO );
our $defaults = {
	name     => undef,
	start    => undef,
	finish   => undef,
	duration => undef,
	current  => undef,
	status   => 'ready'
};

# ============================================================
sub delete {
# ============================================================
	my $self = shift;

	$_->delete() foreach $self->clock_updates();
	$self->SUPER::delete();
}

# ============================================================
sub finish {
# ============================================================
	my $self   = shift;
	my $finish = $self->SUPER::finish();

	if( $finish ) {
		return $finish;
	} else {
		$self->now( 'finish' );
	}
}

# ============================================================
sub start {
# ============================================================
	my $self  = shift;
	my $start = $self->SUPER::start();

	if( $start ) {
		return $start;
	} else {
		$self->now( 'start' );
	}
}
