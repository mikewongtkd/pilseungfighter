package PSF::Class::Clock;
use lib qw( /usr/local/psf/lib );
use base qw( PSF::DBO );
use PSF::Class::Clock::Update;

our $defaults = {
	name     => undef,
	start    => undef,
	finish   => undef,
	duration => undef,
	current  => undef,
	status   => 'ready'
};

# ============================================================
sub add_update {
# ============================================================
	my $self   = shift;
	my $action = shift;
	my $update = new PSF::Class::Clock::Update( 
		clock  => $self, 
		at     => $self->current(), 
		action => $action 
	);

	my $status = $self->status();

	if(      $status eq 'ready' && $action eq 'start' ) {
		$self->status( 'running' );
		$self->now( 'start' );

	} elsif( $status eq 'paused' && $action eq 'resume' ) {
		$self->status( 'running' );

	} elsif( $status eq 'running' && $action eq 'pause' ) {
		$self->status( 'paused' );

	} elsif(( $status eq 'paused' || $status eq 'expired' ) && $action eq 'reset' ) {
		$self->status( 'ready' );
		$self->current( $self->duration() );
		$self->start( undef );
	}
	return $update
}

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

1;
