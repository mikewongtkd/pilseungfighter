.PHONY: all psf

all: all-start

all-start: psf-start

psf-start:
	sudo hypnotoad -f ./bin/psf &

psf-stop:
	sudo pkill -f 'hypnotoad -f ./bin/psf'

all-stop: psf-stop
