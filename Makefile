html_src := $(shell find src -type f -name "*.html")
html_dst := $(patsubst src/%,dst/%,$(html_src))
html_inc := $(shell find include/html -type f -name "*.html")
conf_src := $(shell find conf -type f -name "*.conf")

.PHONY: html dist install clean

html: $(html_dst)

$(html_dst): dst/% : src/% m4/stddef.m4 $(html_inc)
	mkdir -p "$$(dirname "$@")"
	cat m4/stddef.m4 $< | m4 >$@

m4/stddef.m4: m4/redef.m4

m4/redef.m4: m4/mkredef.sh
	./m4/mkredef.sh >$@

dist: dist.tar

dist.tar: $(html_dst) $(conf_src)
	mkdir -p dist
	rm -rf dist/* $@
	mkdir -p dist/etc/nginx
	cp -R conf/* dist/etc/nginx
	mkdir -p dist/var/www
	cp -R dst/* dist/var/www
	tar -C dist -cf $@ .

install:
	ln -s $(PWD)/conf/* /etc/nginx

clean:
	rm -rf dst m4/redef.m4 dist dist.tar
