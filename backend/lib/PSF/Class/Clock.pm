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
	my $self     = shift;
	my $action   = shift;
	my $current  = shift;
	my $duration = shift;

	my $update = new PSF::Class::Clock::Update( 
		clock  => $self, 
		at     => $self->current(), 
		action => $action 
	);

	my $status = $self->status();
	my $name   = $self->name();

	if( $action eq 'set' ) {
		$self->status( 'paused' );
		$self->current( $current );
		$self->duration( $duration );

		return $self->status();
	}

	if(    $action eq 'start'  ) { $self->start(); }
	elsif( $action eq 'resume' ) { $self->resume(); }
	elsif( $action eq 'pause'  ) { $self->pause(); }
	elsif( $action eq 'reset'  ) { $self->reset() if( $name eq 'kyeshi' || $name eq 'medical' ); }
	# The Match Round Clock doesn't reset once expired (instead you're given a
	# new Match Round Clock for each Match Round). The Penalty Timer counts up
	# instead of down and therefore never expires. It simply stops when the
	# Match Round Clock expires.

	return $self->status();
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
	my $status = $self->status()

	if( $status eq 'running' ) {
		$self->status( 'expired' );
		$self->now( 'finish' );
		return $self->SUPER::finish();

	} else {
		return $self->SUPER::finish();
	}
}

# ============================================================
sub pause {
# ============================================================
	my $self   = shift;
	my $status = $self->status();

	if( $status eq 'running' ) {
		return $self->status( 'paused' );

	} else {
		return undef;
	}
}

# ============================================================
sub reset {
# ============================================================
	my $self   = shift;
	my $status = $self->status();

	if( $status eq 'paused' || $status eq 'expired' ) {
		$self->current( $self->duration() );
		$self->start( undef );
		return $self->status( 'ready' );

	} else {
		return undef;
	}
}

# ============================================================
sub resume {
# ============================================================
	my $self   = shift;
	my $status = $self->status();

	if( $status eq 'paused' ) {
		return $self->status( 'running' );

	} else {
		return undef;
	}
}

# ============================================================
sub start {
# ============================================================
	my $self   = shift;
	my $status = $self->status();

	if( $status eq 'ready' ) {
		$self->now( 'start' );
		return $self->status( 'running' );

	} else {
		return $self->SUPER::start();
	}
}

1;
