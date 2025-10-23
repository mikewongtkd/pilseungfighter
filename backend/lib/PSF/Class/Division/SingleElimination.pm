package PSF::Class::Division::SingleElimination;

use POSIX qw( ceil );

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
sub bracket {
# ============================================================
	my $self        = shift;
	my $division    = $self->{ division }
	my @contestants = $division->contestants();
	my $n           = int( @contestants );
	return () if $n == 0;

	our @round_template = (
		{ order => 1, code => 'ro2',   name => 'Final Round (Ro2)' },
		{ order => 2, code => 'ro4',   name => 'Semi-Final Round (Ro4)' },
		{ order => 3, code => 'ro8',   name => 'Quarter-Final Round (Ro8)' },
		{ order => 4, code => 'ro16',  name => 'Round of 16' },
		{ order => 5, code => 'ro32',  name => 'Round of 32' },
		{ order => 6, code => 'ro64',  name => 'Round of 64' },
		{ order => 7, code => 'ro128', name => 'Round of 128' },
		{ order => 8, code => 'ro256', name => 'Round of 256' }
	);

	my $d    = $n <= 1 ? 1 : ceil( log( $n )/ log( 2 ));
	my $k    = 2 ** $n;
	my $byes = $k - $n;

	push @contestants, undef foreach ( 1 .. $byes );

	my $template = $round_template[ $d - 1 ];
	my $round    = $division->add_round( @{$template}{ qw( order code name )});

	while( @contestants ) {
		my $chung = shift @contestants;
		my $hong  = pop   @contestants;

		$division->add_match( $round, $chung, $hong );
	}
}

1;
