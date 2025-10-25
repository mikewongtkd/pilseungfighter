package PSF::Server::Comms::Match;

use lib qw( /usr/local/psf/lib );
use base qw( PSF::Server::Comms::Protocol );
use PSF::Class::Match;
use 
use Mojo::IOLoop;

# ============================================================
sub init {
# ============================================================
	my $self = shift;
	$self->SUPER::init( @_ );
	$self->{ chung } = { penalty_timer => undef };
	$self->{ hong }  = { penalty_timer => undef };
}

# ============================================================
sub update_penalty_timer {
# ============================================================
 	my $self    = shift;
	my $request = shift;
	my $client  = shift;
	my $uuid    = $request->{ match }{ uuid };

	my $match = new PSF::Class::Match( $uuid );
	return unless $match->division->method() eq 'cutoff';

	my $duration = $match->division->round_duration();
	my $color    = $request->{ contestant };
	die "Request Error: Invalid contestant color '$color' $!" unless $color =~ /^(?:chung|hong)$/;

	my $total  = $match->division->pss() ? 2.4 : 4.0; # Total deduction over the duration of the match
	my $rate   = 0.1 * ($duration / $total ); # 0.1 points every $rate seconds
	my $score  = $match->match_round->$color();
	my $timer  = $score->penalty_timer();
	my $status = $timer->status();
	my $action = $request->{ timer }{ action };

	if(( $status eq 'ready' && $action eq 'start' ) || ( $status eq 'paused' && $action eq 'resume' )) {
		$timer->status( 'running' );
		$self->{ $color }{ penalty_timer } = Mojo::IOLoop->recurring( $rate => sub ( $loop ) {
			my $current = $timer->current();
			
			$timer->current( $current - $rate );
				
			my $update = new PSF::Class::Score::Update( 
				score        => $score, 
				from         => 'pt', 
				to           => $color, 
				presentation => -0.1 
			);
		});
}

1;
