VERSION=1.0

all: clean build run

build:
	docker build -f Dockerfile -t pilsung:$(VERSION) .

run:
	docker run -d -p 8037:80 -p 3030:3030 --name pilsung-local -v `pwd`/../backend:/usr/local/psf -v `pwd`/../frontend:/var/www/html pilsung:$(VERSION)
	sleep 3
	docker exec pilsung-local make all-start

stop:
	docker stop pilsung-local

clean:
	docker image rm pilsung:$(VERSION)
