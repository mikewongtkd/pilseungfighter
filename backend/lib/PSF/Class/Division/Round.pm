package PSF::Class::Division::Round;
use lib qw( /usr/local/psf/lib );
use base qw( PSF::DBO );

our $defaults = {
	name       => '',
	code       => '',
	order      => 0,
	division   => undef,
	contestant => []
};

1;
