package PSF::Class::Division::Cutoff;
use List::Util qw( shuffle );

# ============================================================
sub new {
# ============================================================
	my ($class) = map { ref || $_ } shift;
	my $self = bless {}, $class;
	$self->init( @_ );
	return $self;
}

# ============================================================
sub init {
# ============================================================
	my $self     = shift;
	my $division = shift;

	$self->{ division } = $division;
}

# ============================================================
sub build_bracket {
# ============================================================
	my $self        = shift;
	my $division    = $self->{ division };
	my @contestants = sort { $b->seed() cmp $a->seed() } shuffle $division->contestants();
	my $n           = int( @contestants );

	our @round_template = (
		{ order => 1, code => 'finals', name => 'Final Round' },
		{ order => 2, code => 'semfin', name => 'Semi-Final Round' },
		{ order => 3, code => 'prelim', name => 'Preliminary Round' },
		{ order => 4, code => 'tiebrk', name => 'Tiebreaker Round' }
	);

	my $template = undef;
	if(    $n >= 20 ) { $template = $round_template[ 2 ]; }
	elsif( $n >   8 ) { $template = $round_template[ 1 ]; }
	else              { $template = $round_template[ 0 ]; }

	my $round = $division->add_round( @{$template}{ qw( order code name )});

	push @contestants, undef if( $n % 2 == 1 );

	while( @contestants ) {
		my $chung = shift @contestants;
		my $hong  = pop   @contestants;

		$division->add_match( $round, $chung, $hong );
	}
}

1;
