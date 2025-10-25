package PSF::Class::Division;
use lib qw( /usr/local/psf/lib );
use base qw( PSF::DBO );
use PSF::Class::Division::Cutoff;
use PSF::Class::Division::SingleElimination;
use PSF::Class::Match;
use PSF::Class::Match::Round;
use PSF::Class::Score;

our $defaults = {
	id             => undef,
	name           => '',
	method         => 'cutoff',
	gender         => undef,
	age            => [ undef, undef ],
	weight         => [ undef, undef ],
	rank           => [],
	contestant     => [],
	pss            => 0,
	round_count    => 1,
	round_duration => 20,
	rest_duration  => undef,
	head_contact   => 'none',
	notes          => undef
};

# ============================================================
sub add_match {
# ============================================================
	my $self   = shift;
	my $round  = shift;
	my $chung  = shift;
	my $hong   = shift;
	my $match  = new PSF::Class::Match();
	my $last   = int((sort { $b <=> $a } map { $_->id() } $self->matches())[ 0 ]);

	# ===== POPULATE MATCH ATTRIBUTES
	$match->id( $last + 1 );
	$match->division( $self );
	$match->contestants([ $chung, $hong ]);
	$match->round( $round );

	# ===== GENERATE MATCH ROUNDS
	my $contestants = { chung => $chung, hong => $hong };
	
	foreach my $rnum ( 1 .. $self->round_count() ) {
		my $round = new PSF::Class::Match::Round();
		$round->match( $self );
		$round->number( $rnum );
		foreach my $color (keys %$contestants) {
			my $contestant = $contestants->{ $color };
			my $score      = new PSF::Class::Score();
			$score->contestant( $contestant );
			$round->$color( $score );
		}
	}
}

# ============================================================
sub add_round {
# ============================================================
	my $self  = shift;
	my $order = shift;
	my $code  = shift;
	my $name  = shift;
	my $round = new PSF::Class::Division::Round( code => $code, name => $name, division => $self );

	return $round;
}

# ============================================================
sub build_bracket {
# ============================================================
	my $self   = shift;
	my $method = $self->method();

	if(      $method eq 'cutoff' ) {
		$method = new PSF::Class::Division::Cutoff( $self );
		$self->round_count( 1 );

	} elsif( $method eq 'se' ) {
		$method = new PSF::Class::Division::SingleElimination( $self );
		$self->round_count( 3 );
	}

	$method->build_bracket();
}

# ============================================================
sub delete {
# ============================================================
	my $self = shift;

	$_->delete() foreach $self->matches();
	$_->delete() foreach $self->rounds();

	$self->SUPER::delete();
}
