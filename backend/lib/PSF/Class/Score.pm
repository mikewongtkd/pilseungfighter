package PSF::Class::Score;
use lib qw( /usr/local/psf/lib );
use base qw( PSF::DBO );
our $defaults = {
	contestant   => undef,
	presentation => 8.0,
	technical    => 0.0,
	deduction    => 0.0,
	decision     => undef
};

use PSF::Class::Score::Update;


# ============================================================
sub delete {
# ============================================================
	my $self = shift;

	$_->delete() foreach $self->score_updates();
	$self->SUPER::delete();
}

# ============================================================
sub update {
# ============================================================
	my $self     = shift;
	my $update   = shift;
	my $decision = $update->decision();

	if( $self->complete() && $update ne 'clear' ) {
		$update->delete();
		return;
	}

	# Clear decision
	if( defined( $self->decision())) {
		if( $decision eq 'clear' ) {
			$self->decision( undef );
			$self->complete( 0 );
		}

	# Apply decision
	} else {
		if( $decision ne 'clear' ) {
			$self->decision( $decision );
			$self->complete( 1 );
		}
	}

	# Only one field can be populated per update message
	foreach my $field (qw( presentation technical deduction )) {
		my $value = $update->$field();
		next unless $value;
		$self->$field( $self->$field() + $update->$field());
	}
}

1;

