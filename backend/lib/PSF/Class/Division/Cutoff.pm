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
sub advance_contestants {
# ============================================================
	my $self        = shift;
	my $round       = shift;
	my $division    = $self->{ division };
	my @contestants = $round->contestants();
	my @matches     = $round->matches();
	my @rankings    = $self->rank_contestants( $round );

	# Finish this method by including advancement logic and finally tiebreaking logic
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
		{ order => 4, code => 'tiebk1', name => 'Tiebreaker Round' },
		{ order => 5, code => 'tiebk2', name => 'Tiebreaker Round' }
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

# ============================================================
sub rank_contestants {
# ============================================================
# \brief Returns a list of cutoff ranking criteria for each 
# contestant, and labels the list with information on ties
# ------------------------------------------------------------
	my $self        = shift;
	my $round       = shift;
	my @contestants = $round->contestants();
	my @matches     = $round->matches();

	my $criteria    = [];
	foreach my $contestant (@contestants) {
		next unless defined $contestant;
		my $uuid    = $contestant->uuid();
		my $matches = [ grep { 
			my $complete       = $_->complete();
			my $has_contestant = grep { defined( $_ ) && $_->uuid() eq $uuid } $_->contestants();

			$complete && $has_contestant;
		} @matches ];

		my $n = int( @$matches );
		if( $n == 0 ) {
			push @$criteria, { contestant => $contestant, dsq => 0, wdr => 0, presentation => 0, win => 0, technical => 0, deductions => 0 };
			next;

		} elsif( $n == 1 ) {
			my $match    = $matches->[ 0 ];
			my $chung    = $match->match_round->chung();
			my $hong     = $match->match_round->hong();
			my $is_chung = defined( $chung->contestant ) && $uuid eq $chung->contestant->uuid();
			my $color    = $is_chung ? 'chung' : 'hong';
			my $score    = $is_chung ? $chung : $hong;
			my $dsq      = $score->decision() eq 'dsq' ? 1 : 0;
			my $wdr      = $score->decision() eq 'wdr' ? 1 : 0;
			my $win      = $score->winner() eq $color;

			push @$criteria, { contestant => $contestant, dsq => $dsq, wdr => $wdr, presentation => $score->presentation(), win => $win, technical => $score->technical(), deductions => $score->deduction() };

		} else {
			my $mean = { dsq => 0, wdr => 0, presentation => 0, win => 0, technical => 0, deduction => 0 };
			foreach my $match (@$matches) {
				my $chung    = $match->match_round->chung();
				my $hong     = $match->match_round->hong();
				my $is_chung = defined( $chung->contestant ) && $uuid eq $chung->contestant->uuid();
				my $color    = $is_chung ? 'chung' : 'hong';
				my $score    = $is_chung ? $chung : $hong;
				my $dsq      = $score->decision() eq 'dsq' ? 1 : 0;
				my $wdr      = $score->decision() eq 'wdr' ? 1 : 0;
				my $win      = $score->winner() eq $color;

				$mean->{ dsq } = $sums->{ dsq } || $dsq ? 1 : 0;
				$mean->{ wdr } = $sums->{ wdr } || $wdr ? 1 : 0;

				foreach my $field ( qw( presentation win technical deduction )) {
					$mean->{ $field } += $score->$field();
				}
			}
			foreach my $field ( qw( presentation win technical deduction )) {
				$mean->{ $field } /= $n
				$mean->{ $field } = 0.0 + sprintf( "%.3f", $mean->{ $field });
			}

			push @$criteria, { contestant => $contestant, %$mean };
		}
	}

	my @rankings = sort {
		if(    $a->{ dsq } && $b->{ dsq }) { return  0 }
		elsif( $a->{ dsq })                { return  1 }
		elsif( $b->{ dsq })                { return -1 }
		elsif( $a->{ wdr } && $b->{ wdr }) { return  0 }
		elsif( $a->{ wdr })                { return  1 }
		elsif( $b->{ wdr })                { return -1 }
		else { return $b->{ presentation } <=> $a->{ presentation } || $b->{ win } <=> $a->{ win } || $b->{ technical } <=> $a->{ technical } || $a->{ deduction } <=> $b->{ deduction }; }
	} @$criteria;

	my $k = $#rankings;
	TIE: foreach my $i ( 0 .. $k ) {
		my $a = $rankings[ $i ];
		next if exists $a->{ tied } && defined( $a->{ tied };

		my $tied = { place => 0, contestants => []};

		FOUND: foreach my $j ( $i + 1 .. $k ) {
			my $b = $rankings[ $j ];

			foreach my $field ( qw( presentation win technical deduction )) {
				last FOUND if( $a->{ $field } != $b->{ $field });
				if( $tied->{ place }  == 0 ) {
					$tied->{ place } = $i + 1; # Rank of the tie (e.g. tied for 1st place)
					push @{$tied->{ contestants }}, $a->{ contestant }; # First contestant that is tied
					$a->{ tied } = $tied;
				}
				push @{$tied->{ contestants }}, $b->{ contestant }; # Next contestant that is tied
				$b->{ tied } = $tied;
			}
		}
	}

	return @rankings;
}

1;
