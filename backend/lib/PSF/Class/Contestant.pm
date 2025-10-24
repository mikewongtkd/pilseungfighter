package PSF::Class::Contestant;
use lib qw( /usr/local/psf/lib );

use base qw( PSF::DBO );
our $defaults = {
	name   => undef,
	gender => undef,
	age    => undef,
	weight => undef,
	rank   => 'black',
	seed   => 0.0
};

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

1;
