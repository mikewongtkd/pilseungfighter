package PSF::Class::Division;
use lib qw( /usr/local/psf/lib );
our $defaults = {
	id             => undef,
	name           => '',
	method         => 'cutoff',
	gender         => undef,
	age            => [ undef, undef ],
	weight         => [ undef, undef ],
	rank           => [],
	contestant     => [],
	round_count    => 2,
	round_duration => 20,
	rest_duration  => undef,
	head_contact   => 'none'
};

use PSF::Class::Match;
use PSF::Class::Score;

# ============================================================
sub new_match {
# ============================================================
	my $self  = shift;
	my $chung = shift;
	my $hong  = shift;
	my $match = new PSF::Class::Match();

	$match->contestants([ $chung, $hong ]);
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
