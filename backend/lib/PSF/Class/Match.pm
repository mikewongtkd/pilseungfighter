package PSF::Class::Match;
use lib qw( /usr/local/psf/lib );
use base qw( PSF::DBO );
use Time::Piece;
use Time::Seconds;
our $defaults = {
	id         => undef,
	number     => undef,
	division   => undef,
	ring       => undef,
	round      => undef,
	contestant => [],
	winner     => undef,
	start      => undef,
	finish     => undef
};

# ============================================================
sub status {
# ============================================================
	my $self   = shift;
	my $start  = $self->start();
	my $finish = $self->finish();

	if(    ! defined $start  ) { return 'ready'; }
	elsif( ! defined $finish ) { return 'in progress'; }
	else                       { return 'finished'; }
}

# ============================================================
sub time {
# ============================================================
	my $self   = shift;
	my $start  = $self->start();
	my $finish = $self->finish();
	my $format = '%Y-%m-%d %:%M:%S%Z';

	$start  = defined $start  ? Time::Piece->strptime( $start . 'Z', $format ) : undef;
	$finish = defined $finish ? Time::Piece->strptime( $finish . 'Z', $format ) : undef;

	return 0 unless( defined $start && defined $finish );

	my $delta   = $finish - $start;
	my $seconds = $delta->seconds();

	return $seconds;
}

1;
