package PSF::Class::Clock;
use lib qw( /usr/local/psf/lib );

use base qw( PSF::DBO );
our $defaults = {
	name     => undef,
	start    => undef,
	finish   => undef,
	duration => undef,
	current  => undef,
	status   => 'paused'
};
