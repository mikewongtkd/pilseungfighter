package PSF::Class::Contestant;
use lib qw( /usr/local/psf/lib );
use base qw( PSF::DBO );
our $defaults = {
	name       => undef,
	gender     => undef,
	dob        => undef,
	weight     => undef,
	rank       => 'black',
	team       => undef,
	seed       => 0.0
};

# ============================================================
sub age {
# ============================================================
	my $self = shift;
	my $dob  = $self->{ data }{ dob };
	return _age( $dob );
}

# ============================================================
sub fake {
# ============================================================
	my $doe    = shift || _doe(); # Date of Event
	my $gender = _gender();
	my $dob    = _dob();
	my $age    = _age( $dob, $doe );
	my $name   = _name( $gender );
	my $weight = _weight( $gender, $age );
	my $rank   = _rank( $dob );
	my $team   = _team( $dob );
	my $seed   = _seed( $dob );
}

# ============================================================
sub gender_label {
# ============================================================
	my $self = shift;
	my $gender = $self->{ data }{ gender };
	if(    $gender eq 'f' ) { return 'Women\'s'; }
	elsif( $gender eq 'm' ) { return 'Men\'s'; }
	else                    { return; }
}

# ============================================================
sub gender_sex {
# ============================================================
	my $self = shift;
	my $gender = $self->{ data }{ gender };
	if(    $gender eq 'f' ) { return 'Female'; }
	elsif( $gender eq 'm' ) { return 'Male'; }
	else                    { return; }
}

# ============================================================
sub _age {
# ============================================================
	my $dob = shift;
	my $doe = shift;
	my ($yob, $mob, $dayob) = split /\//, $dob, 3;
	my ($yoe, $moe, $dayoe) = split /\//, $doe, 3;
	my $age  = $yoe - $yob;
	return $age;
}

# ============================================================
sub _doe {
# ============================================================
	my $localtime = localtime();
	my $doe = sprintf( "%04d/%02d/%02d", $localtime[ 5 ] + 1900, $localtime[ 4 ] + 1, $localtime[ 3 ]);
	return $doe;
}

# ============================================================
sub _gender {
# ============================================================
	return rand() > 0.5 ? 'f' : 'm';
}

# ============================================================
sub _name {
# ============================================================
	my $gender = shift;
	return ''; # Use Data::Faker to create a gender-based name
}

# ============================================================
sub _seed {
# ============================================================
	my $rank = shift;
	return ''; # Use Data::Faker to create a gender-based name
}

# ============================================================
sub _team {
# ============================================================
	return ''; # Use Data::Faker to create a gender-based name
}

# ============================================================
sub _weight {
# ============================================================
	my $gender = shift;
	my $age    = shift;
}

1;
