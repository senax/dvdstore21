all: .foo

.foo: Dockerfile
	docker build -t senax/dvdstore21:latest .
	touch .foo
