#! /usr/bin/sh

# ============================================================
# Devel Tools
# ============================================================
apt-get update
apt-get install -y sudo vim zip libssl-dev cpanminus

cpanm install \
	Carp \
	Clone \
	DBI \
	DBD::SQLite \
	Data::Structure::Util \
	Date::Calc \
	Date::Manip \
	Digest::SHA1 \
	Encode \
	EV \
	Filesys::Notify::Simple \
	File::Copy \
	File::Path \
	File::Slurp \
	GD::Barcode \
	JSON::XS \
	LWP::UserAgent \
	Lingua::EN::Inflexion \
	List::MoreUtils \
	Math::Round \
	Math::Utils \
	Mojolicious \
	Mojo::IOLoop::Delay \
	PHP::Functions::Password \
	PHP::Session \
	Scalar::Util \
	Statistics::Descriptive \
	Test::Tester \
	Test::NoWarnings \
	Test::Deep \
	Test::Warn \
	Time::HiRes \
	Time::Piece \
	Try::Tiny \
	UUID \
	YAML

a2enmod proxy proxy_http proxy_wstunnel
