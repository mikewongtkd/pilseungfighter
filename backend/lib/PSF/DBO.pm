package PSF::DBO;

use base qw( Clone );
use Clone qw( clone );
use Data::Dumper;
use Data::Structure::Util qw( unbless );
use DBI;
use JSON::XS;
use Lingua::EN::Inflexion qw( noun verb );
use List::Util qw( any all );
use Scalar::Util qw( looks_like_number );
use UUID;
use vars '$AUTOLOAD';

our $dbh  = undef;
our $sth  = {};
our $json = new JSON::XS();
our $statement = {
	delete     => "update document set deleted = datetime( 'now' ) where uuid=? and deleted is null",
	exists     => 'select count(*) > 0 from document where uuid=? and deleted is null',
	get        => 'select * from document where uuid=? and deleted is null',
	insert     => 'insert into document (uuid, class, data) values (?, ?, ?)',
	now        => "update document json_set( data, ?, datetime( 'now' )) where uuid = ? and deleted is null",
	references => "select * from document where upper( class ) like :class and case when :column = :uuid or :column like '[%:uuid%]' and deleted is null",
	restore    => 'update document set deleted = null where uuid=? and deleted is not null',
	update     => "update document set data=?, modified = datetime( 'now' ) where uuid=?"
};

# ============================================================
sub new {
# ============================================================
# \brief Creates a new object or, given a UUID, retrieves an 
# existing object
# ------------------------------------------------------------
	my ($package) = map { ref || $_ } shift;
	my $class     = _class( $package );
	my $self      = bless {}, $package;
	my $n         = int( @_ );
	my $guuid     = _generate_uuid();

	# No parameters provided; create a new object
	if( $n == 0 ) {
		$self->{ uuid }  = $guuid;
		$self->{ class } = $class;
		$self->{ data }  = $package->defaults();

	# One parameter provided; if it's a UUID, then look it up
	} elsif( $n == 1 ) {
		my $uuid = shift;
		die "DB Error: Invalid UUID provided '$uuid' for $package lookup $!" unless _is_uuid( $uuid );

		# If the object exists, return it
		return _get( $uuid ) if( _exists( $uuid ));

		# Otherwise create a new object
		$self->{ uuid }  = $uuid;
		$self->{ class } = $class;
		$self->{ data }  = $package->defaults();

	# More than one parameter provided, create a new object and assign given parameters
	} elsif( $n > 1 ) { 
		die "DB Error: Ambiguous instantiation; odd number of parameters provided $!" if $n % 2;
		$self->{ uuid }  = $guuid;
		$self->{ class } = $class;
		$self->{ data }  = { %{ $package->defaults() }, @_ };
		$self->{ uuid }  = $self->{ data }{ uuid } if( exists $self->{ data }{ uuid });

	}

	$self->write();
	return $self;
}

# ============================================================
sub class {
# ============================================================
	my $self = shift;
	return $self->{ class };
}

# ============================================================
sub defaults {
# ============================================================
	my $class = shift;
	return clone( ${"$class\:\:defaults"} );
}

# ============================================================
sub delete {
# ============================================================
	my $self = shift;
	my $uuid = $self->uuid();
	_db_connect();

	my $sth = _prepared_statement( 'delete' );

	$sth->execute( $uuid );
}

# ============================================================
sub document {
# ============================================================
	my $self   = shift;
	my $clone  = $self->clone();
	my $uuid   = $clone->uuid();

	delete $clone->{ uuid }; # Remove UUID prior to pruning
	
	$clone = unbless( $clone );
	$clone = _prune( $clone );

	$clone->{ uuid } = $uuid; # Add UUID back in prior to writing to DB

	return $clone;
}

# ============================================================
sub first {
# ============================================================
# \brief Searches the database and return the first document entry 
# where the entry matches the given criteria
# ------------------------------------------------------------
	my $class = _class( shift );
	my @rows  = $class->search( @_ );
	return $rows[ 0 ];
}

# ============================================================
sub get {
# ============================================================
# \brief Retrieves a given field for an object. If the field
# value is a UUID or an array of UUIDs, returns the 
# corresponding object.
# \param $query: Object field query
# \param $filter: Object filter
# ------------------------------------------------------------
	my $self   = shift;
	my $query  = shift;
	my $filter = shift;

	$query = _field( $query );

	if( $query eq 'DESTROY' ) {
		$self->SUPER::DESTROY();
		return;
	}

	my $plural = noun( $query )->is_plural;

	$query = lc( $plural ? noun( $query )->singular : $query );

	# ===== RETURN DATA OR INTERNAL REFERENCE IF IT EXISTS
	# Internal references are provided within the data (e.g. belongs-to relationships)
	if( exists $self->{ data }{ $query }) {
		my $results = $self->{ data }{ $query };

		# ===== IF REQUESTED AS A PLURAL, RETURN AN ARRAY
		if( $plural ) {
			if( ref $results eq 'ARRAY' ) {
				if( any { _is_uuid( $_ ) } @$results ) {
					@$results = map { _is_uuid( $_ ) ? _get( $_ ) : $_ } @$results;
				}
				_filter( $results, $filter );
				return @$results;

			} else {
				$results = _get( $results ) if( _is_uuid( $results ));
				return ( $results );
			}

		# ===== IF REQUESTED AS SINGULAR, RETURN AN A SINGLE VALUE OR DOCUMENT
		} else {
			if( ref $results eq 'ARRAY' ) {
				_filter( $results, $filter );
				$results = shift @$results;
			}
			$results = _get( $results ) if( _is_uuid( $results ));
			return $results;
		}

	# ===== RETURN EXTERNAL REFERENCE IF THEY EXISTS
	# External references are provided by documents that have the current class
	# as a field
	} else {
		my $docs       = _class( $query );
		my $column     = _field( ref $self );
		my $uuid       = $self->uuid();
		my $references = _find_references( $docs, $column, $uuid );
		my @allowed    = qw( bracket contestant match ring round update chung hong );

		if( ! grep { $_ eq $column } @allowed ) {
			warn "$column is not valid.\n";
			return ();

		}

		if( $plural ) {
			return @$references;

		} else {
			return undef unless int( @$references );
			return shift @$references;
		}
	}

	return undef;
}

# ============================================================
sub json {
# ============================================================
	my $self     = shift;
	my $json     = new JSON::XS();
	my $document = $self->document();

	return $json->canonical->encode( $document );
}

# ============================================================
sub now {
# ============================================================
	my $self  = shift;
	my $field = shift;

	_db_connect();

	my $sth = _prepared_statement( 'now' );
	$sth->execute( "\$.$field", $self->uuid() );
}

# ============================================================
sub search {
# ============================================================
# \brief Searches the database and return all document entries 
# where the entry matches the given criteria
# ------------------------------------------------------------
	my $class = _class( shift );
	my $where = shift;
	my $query = shift;

	die "Malformed query for $AUTOLOAD (use: where => { ... } instead) $!" unless $where eq 'where';

	_db_connect();

	my $sql    = 'select uuid, ';
	my @select = map { "json_extract( data, \"\$.$_\" ) as $_" } keys %$query;

	$sql .= join( ', ', @select );

	my @where = ();
	my $np    = {}; # Named Placeholders
	foreach my $key (keys %$query) {
		my $value = $query->{ $key };
		if( ref( $value ) eq 'ARRAY' ) {

			# Min, max bounds
			if( int( @$value ) == 2 && all { looks_like_number( $_ ) } @$value ) {
				my $min = sprintf( ":%s_min", $key );
				my $max = sprintf( ":%s_max", $key );
				push @where, "$key >= :min_$key and $key <= :max_$key";
				$np->{ $min } = $value->[ 0 ];
				$np->{ $max } = $value->[ 1 ];

			# List of acceptable values
			} else {
				my $list = sprintf( ":%s_list", $key );
				push @where, "$key in ($list)";
				my @values = ();
				foreach my $val (@$value) {
					if( looks_like_number( $val )) {
						push @values, $val;

					} elsif( ref( $val )) {
						my $uuid = _uuid( $val );
						push @values, $uuid ? $uuid : $val;

					} else {
						push @values, "\"$val\"";
					}
				}
				$np->{ $list } = join( ',', @values );
			}

		} elsif( ref( $value )) {
			push @where, "$key like \:$key";
			my $uuid = _uuid( $value );
			$value = $uuid ? $uuid : $value;
			$np->{ $key } = "\%$value\%";

		} else {
			push @where, "$key like \:$key";
			$np->{ $key } = "\%$value\%";
		}
	}

	$sql .= ' from document where class="' . $class . '" and ' . join( ' and ', @where ) . ' and deleted is null';
	my $sth = $PSF::DBO::dbh->prepare( $sql );
	$sth->execute( $np );
	my @rows = ();
	while( my $row = $sth->fetchrow_hashref()) {
		my $uuid = $row->{ uuid };
		push @rows, "PSF::$class"->new( $uuid );
	}
	return @rows;
}

# ============================================================
sub set {
# ============================================================
	my $self   = shift;
	my $key    = shift;
	my $value  = shift;
	my $ref    = ref $value;
	my $plural = noun( $key )->is_plural;

	$key = noun( $key )->is_plural ? noun( $key )->singular : $key;

	if((! $ref)) {
		$self->{ data }{ $key } = $value;

	# Prune hashref
	} elsif( $ref eq 'HASH' ) {
		my $pruned = {};
		foreach my $key (keys %$value) {
			my $uuid = _uuid( $value->{ $key });
			$pruned->{ $key } = $uuid ? $uuid : $value->{ $key };
		}

	# Prune arrayref
	} elsif( $ref eq 'ARRAY' ) {
		$value = [ map { my $uuid = _uuid( $_ ); $uuid ? $uuid : $_ } @$value ];

	# Prune PSF objects
	} elsif( $ref && $value->can( 'uuid' )) {
		$self->{ data }{ $key } = $value->uuid();

	} else {
		die "Data Integrity Error: Assigning object without UUID to $key $!";
	}
	$self->write();
}

# ============================================================
sub uuid {
# ============================================================
	my $self = shift;
	return $self->{ uuid };
}

# ============================================================
sub write {
# ============================================================
	my $self   = shift;
	my $doc    = $self->document();
	my $uuid   = $self->uuid();
	my $exists = _exists( $uuid );

	if( $exists ) {
		_update( $doc );
	} else {
		_put( $doc );
	}
}

# ============================================================
sub AUTOLOAD {
# ============================================================
	my $self   = shift;
	my $n      = int( @_ );

	# ===== No values provided; get field
	if( $n == 0 ) {
		return $self->get( $AUTOLOAD );

	# ===== One value provided; set field to value
	} elsif ( $n == 1 ) {
		my $value = shift;
		my $field = _field( $AUTOLOAD );

		$self->set( $field, $value );

	# ===== Two fields; a WHERE clause, and a hashref of conditions
	} elsif( $n == 2 ) {
		if( $_[ 0 ] eq 'where' ) {
			my $filter = $_[ 1 ];
			return $self->get( $AUTOLOAD, $filter );

		} else {
			die "Malformed query for $AUTOLOAD (use: where => { ... } instead) $!";
		}

	} else {
		die "Malformed query $AUTOLOAD $!";
	}

	return;
}

# ============================================================
sub _class {
# ============================================================
# \brief Converts string to Perl package notation (sans PSF::Class)
# ------------------------------------------------------------
	my $class = shift;
	my @namespaces = map { ucfirst( $_ ) } grep { ! /^(?:PSF|Class)$/ } split /(?:::|_)/, $class;

	$class = join( '::', @namespaces );
	return $class;
}

# ============================================================
sub _db_connect {
# ============================================================
	$PSF::DBO::dbh = DBI->connect( 'dbi:SQLite:db.sqlite' ) if( ! defined $PSF::DBO::dbh );
}

# ============================================================
sub _exists {
# ============================================================
	_db_connect();
	my $uuid  = shift;
	my $sth   = _prepared_statement( 'exists' );
	$sth->execute( $uuid );

	my $count = $sth->fetchrow_arrayref();
	$count = int( $count->[ 0 ]);

	return $count;
}

# ============================================================
sub _factory {
# ============================================================
	my $document = shift;
	my $class    = sprintf( "PSF::Class::%s", $document->{ class });
	my $data     = $json->decode( $document->{ data });
	my $result   = bless { uuid => $document->{ uuid }, class => $document->{ class }, data => $data }, $class;

	return $result;
}

# ============================================================
sub _field {
# ============================================================
# \brief Converts string to snake case, which is SQLite3-safe
# ------------------------------------------------------------
	my $field = shift;
	my @namespaces = grep { ! /^(?:PSF|Class)$/ } split /::/, $field;
	my $command = $namespaces[ -1 ];
	return $command if( $command =~ /^[A-Z]$/ ); # Forward special commands (e.g. DESTROY)
	return lc join( '_', @namespaces );
}

# ============================================================
sub _filter {
# ============================================================
	my $results = shift;
	my $filter  = shift;

	return $results unless $filter;

	foreach my $field (keys %$filter) {
		my $uuid = _uuid( $filter->{ $field });
		@$results = grep { 
			my $ref = ref( $_ );
			return 0 unless $ref && $ref ne 'ARRAY' && exists $ref->{ data } && exists $ref->{ data }{ $field };
			return _uuid( $ref->{ data }{ $field }) eq $uuid;
		} @$results;
	}

	return $results;
}

# ============================================================
sub _find_references {
# ============================================================
	_db_connect();
	my $class  = shift;
	my $column = shift;
	my $uuid   = shift;

	$class  = uc "\%$class";
	$column = "gc_$column";

	# ===== SEARCH FOR DIRECT REFERENCES
	# Search generated columns (gc_*) for references
	my $sth = _prepared_statement( 'references' );
	$sth->execute({ class => $class, column => $column, uuid => $uuid });

	my $results = [];

	while( my $document = $sth->fetchrow_hashref()) {
		push @$results, _factory( $document );
	}

	return $results;
}

# ============================================================
sub _generate_uuid {
# ============================================================
	my $attempts = 0;
	my $uuid     = lc UUID::uuid();
	while( _exists( $uuid ) && $attempts < 100 ) { $uuid = lc UUID::uuid(); $attempts++; }

	die "Unable to create a unique UUID $!" if( $attempts >= 100 );

	return $uuid;
}

# ============================================================
sub _get {
# ============================================================
	_db_connect();
	my $uuid   = shift;
	my $exists = _exists( $uuid );

	return $uuid if ref $uuid;

	if( ! $exists ) {
		warn "No document with UUID $uuid $!";
		return undef;
	}

	my $sth = _prepared_statement( 'get' );
	$sth->execute( $uuid );

	my $document = $sth->fetchrow_hashref();
	return _factory( $document );
}

# ============================================================
sub _prepare_statement {
# ============================================================
	my $name = shift;
	my $sql  = shift;
	die "System-defined prepared statement named '$name' already exists $!" if exists $PSF::DBO::statement->{ $name };

	# Return Singleton if exists and defined
	return $PSF::DBO::sth->{ $name } if exists $PSF::DBO::sth->{ $name } && $PSF::DBO::sth->{ $name };

	# Else prepare the statement handle and return
	return $PSF::DBO::sth->{ $name } = $PSF::DBO::dbh->prepare( $sql );
}

# ============================================================
sub _prepared_statement {
# ============================================================
	my $name = shift;
	die "No prepared statement named '$name' $!" unless exists $PSF::DBO::statement->{ $name };

	# Return Singleton if exists and defined
	return $PSF::DBO::sth->{ $name } if exists $PSF::DBO::sth->{ $name } && $PSF::DBO::sth->{ $name };

	# Else prepare the statement handle and return
	return $PSF::DBO::sth->{ $name } = $PSF::DBO::dbh->prepare( $PSF::DBO::statement->{ $name });
}

# ============================================================
sub _put {
# ============================================================
	_db_connect();
	my $document = shift;
	my $uuid     = $document->{ uuid };
	my $class    = $document->{ class };
	my $data     = $json->canonical->encode( $document->{ data });

	my $sth = _prepared_statement( 'insert' );
	$sth->execute( $uuid, $class, $data );
}

# ============================================================
sub _prune {
# ============================================================
	my $document = shift;
	my $type     = ref $document;

	# SCALAR
	if( $type eq '' ) { return $document }

	# ARRAY
	if( $type eq 'ARRAY' ) {
		@$document = map { _prune( $_ ) } @$document;
		return $document;
	}

	# HASH
	if( $type eq 'HASH' ) {
		if( exists( $document->{ uuid })) {
			return $document->{ uuid };
		} else {
			return { map { $_ => _prune( $document->{ $_ })} sort keys %$document };
		}
	}
}

# ============================================================
sub _update {
# ============================================================
	_db_connect();
	my $document = shift;
	my $uuid     = $document->{ uuid };
	my $data     = $json->canonical->encode( $document->{ data });

	my $sth = _prepared_statement( 'update' );
	$sth->execute( $data, $uuid );
}

# ============================================================
sub _uuid {
# ============================================================
# \brief Returns an object's UUID, or if the object is a UUID,
# return the UUID, otherwise return undef;
# ------------------------------------------------------------
	my $document = shift;
	return $document if _is_uuid( $document );

	if( ref $document eq 'HASH' || ref $document eq 'ARRAY' ) {
		return undef;

	} elsif( ref $document && $document->can( 'uuid' )) {
		return $document->uuid();

	} else {
		return undef
	}
}

# ============================================================
sub _is_uuid {
# ============================================================
	my $value = shift;
	return 0 if ref $value;
	return $value =~ /^[0-9A-Fa-f]{8}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{12}$/;
}

# ============================================================
sub DESTROY {
# ============================================================
	my $self = shift;
}

1;

