package PSF::Class::Score::Update;
use lib qw( /usr/local/psf/lib );
use base qw( PSF::DBO );
our $defaults = {
	score        => undef,
	from         => undef,
	to           => undef,
	presentation => 0.0,
	technical    => 0.0,
	deduction    => 0.0,
	decision     => undef
};


