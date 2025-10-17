package PSF::Config;

use List::Util qw( uniq );
use JSON::XS;
use File::Slurp qw( read_file );
use lib qw( /usr/local/psf/lib );
use PSF::Security;

# ============================================================
sub new {
# ============================================================
	my ($class) = map { ref || $_ } shift;
	my $self = bless {}, $class;
	$self->init();
	return $self;
}

# ============================================================
sub init {
# ============================================================
	my $self  = shift;
	my $paths = [ qw( /usr/local/psf /usr/psf /home/ubuntu/psf /psf /home/root/psf )];
	foreach my $path (@$paths) {
		my $file = "$path/config.json";
		next unless -e $file;
		my $text = read_file( $file );
		my $json = new JSON::XS();
		my $data = $json->decode( $text );
		foreach my $key (keys %$data) { $self->{ $key } = $data->{ $key }; }
	}
	return unless $self->{ host };

	my @rings = ();
	foreach my $service (sort keys %{$self->{ service }}) {
		next unless $service->{ path };
		my $path = "/usr/local/psf/data/$self->{ db }/$service->{ path }";
		next unless -d $path;
		opendir my $dh, $path;
		push @rings, map { /^ring(\d+)$/; int( $1 ); } grep { /^(?:ring)/ } readdir $dh;
		closedir $dh;
	}
	@rings = uniq @rings;
	$self->{ rings } = [ @rings ];
}

# ============================================================
sub host {
# ============================================================
	my $self = shift;
	if( $self->{ port }) {
		my $port = int( $self->{ port });
		if   ( $port == 80 )  { return "http://$self->{ host }"; } 
		elsif( $port == 443 ) { return "https://$self->{ host }"; } 
		else                  { return "http://$self->{ host }:$self->{ port }"; }
	} else {
		return $self->{ host };
	}
}

# ============================================================
sub password {
# ============================================================
	my $self = shift;
	my $ring = shift;

	$ring = sprintf( 'ring%02d', $ring ) if( $ring =~ /^\d+$/ );
	return undef if( ! exists( $self->{ password }));
	return undef if( ! $self->{ password });
	return undef if( $ring && ! exists( $self->{ password }{ $ring }));

	return $self->{ password }{ $ring };
}

# ============================================================
sub secured {
# ============================================================
	my $self = shift;
	return exists( $self->{ password }) && defined $self->{ password };
}

# ============================================================
sub security {
# ============================================================
	my $self = shift;
	return new PSF::Security( $self );
}


1;
