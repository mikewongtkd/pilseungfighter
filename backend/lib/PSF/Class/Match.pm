package PSF::Class::Match;
use lib qw( /usr/local/psf/lib );
use base qw( PSF::DBO );
our $defaults = {
	id         => undef,
	division   => undef,
	ring       => undef,
	round      => undef,
	contestant => [],
	winner     => undef
};

1;
