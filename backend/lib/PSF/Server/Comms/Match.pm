package PSF::Server::Comms::Match;

use lib qw( /usr/local/psf/lib );
use base qw( PSF::Server::Comms::Protocol );
use PSF::Class::Match;
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
sub penalty_timer {
# ============================================================
	my $self       = shift;
	my $contestant = shift;
	my $ptid       = shift;

	if( defined $ptid ) {
		if( $ptid eq 'off' ) {
			my $ptid = $self->{ $color }{ penalty_timer };
			MOJO::IOLoop->remove( $ptid ) if defined( $ptid );
			$self->{ $color }{ penalty_timer } = undef;

		} else {
			$self->{ $color }{ penalty_timer } = $ptid;
		}
	}
	return $self->{ $color }{ penalty_timer };
}

# ============================================================
sub start_deductions_over_time {
# ============================================================
	my $self  = shift;
	my $match = shift;
	my $score = shift;
	my $timer = shift;
	my $color = shift;
	my $rate  = shift;

	my $ring  = $match->ring();

	return Mojo::IOLoop->recurring( $rate => sub ( $loop ) {
		my $current = $timer->current();
		
		$timer->current( $current - $rate );
			
		my $update = new PSF::Class::Score::Update( 
			score        => $score, 
			from         => 'pt', 
			to           => $color, 
			presentation => -0.1 
		);

		$score->add_update( $update );

		my $serverid = $self->server->id()
		my $request  = { %{ $update->document() }, type => "score", action => "update", from => $serverid, ring => $ring };
		my $response = { type => "score", request => $request, score => $score->document() };
		$self->send->group( $response );
	});
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
	my $action = $request->{ timer }{ action };
	my $status = $timer->add_update( $action );

	if(      $status eq 'running' ) {
		my $ptid = $self->start_deductions_over_time( $match, $score, $timer, $color, $rate );
		$self->penalty_timer( $color, $ptid );

	} elsif( $status eq 'paused' ) {
		my $ptid = $self->penalty_timer( $color );
		Mojo::IOLoop->remove( $ptid ) if defined $ptid

	}
}

# ============================================================
sub write {
# ============================================================
	my $self  = shift;
	my $data  = shift;
	my $uuid  = shift;
	my $match = undef;

	if( defined $uuid ) {
		$match = new PSF::Class::Match( $uuid );
	} else {
		if( defined $data ) {
			if( ref $data eq 'HASH' ) {
			} else {
				if( ref $data ) {
					my $json  = new JSON::XS();
					my $clone = unbless( clone( $data ));
					$data = $json->canonical->encode( $clone );
				}
				die "Request Error: Invalid match data: $data $!";
			}
		} else {
		}
	}
}

1;
