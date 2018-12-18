#
#   github.com/tuupola/avr_demo
#   https://www.avrfreaks.net/forum/error-building-avr-gcc
#   --enable-device-lib https://www.eit.lth.se/fileadmin/eit/courses/edi021/avr-libc-user-manual/install_tools.html
#   https://www.nongnu.org/avr-libc/user-manual/install_tools.html
#   https://www.pololu.com/docs/0J31/all#4
#   https://radioprog.ru/post/4
#
#   apt install libgmp-dev libmpfr-dev libmpc-dev gcc-7-multilib-i686-linux-gnu libisl-dev curl texinfo
#

.PHONY: build download

TOPDIR=$(shell pwd)
VENV=$(TOPDIR)/.venv
CORES=$(shell grep processor /proc/cpuinfo | wc -l)

build: | .venv/bin/avrdude .venv/avr/bin/as .venv/bin/avr-gdb .venv/bin/activate .venv/avr/lib/libc.a
	echo cpus $(CORES)


download: | .tmp/avrdude.tar.gz .tmp/avrlibc.tar.bz2 .tmp/binutils.tar.xz .tmp/gcc-8.2.0.tar.xz .tmp/gdb-8.2.tar.xz
	echo js_download

.venv:
	mkdir -p .venv

.tmp:
	mkdir -p .tmp

.tmp/binutils.tar.xz: | .tmp .venv
	curl http://ftp.gnu.org/gnu/binutils/binutils-2.31.tar.xz > .tmp/binutils.tar.xz

.tmp/avrlibc.tar.bz2: | .tmp .venv
	curl https://bigsearcher.com/mirrors/nongnu/avr-libc/avr-libc-2.0.0.tar.bz2 > .tmp/avrlibc.tar.bz2

.tmp/avrdude.tar.gz: | .tmp .venv
	curl http://www.namesdir.com/mirrors/nongnu/avrdude/avrdude-6.3.tar.gz > .tmp/avrdude.tar.gz

.tmp/gcc-8.2.0.tar.xz: | .tmp .venv
	curl https://ftp.gnu.org/gnu/gcc/gcc-8.2.0/gcc-8.2.0.tar.xz > .tmp/gcc-8.2.0.tar.xz

.tmp/gdb-8.2.tar.xz: | .tmp .venv
	curl https://ftp.gnu.org/gnu/gdb/gdb-8.2.tar.xz > .tmp/gdb-8.2.tar.xz

.tmp/avrdude-6.3: | .tmp/avrdude.tar.gz
	tar xvf .tmp/avrdude.tar.gz -C .tmp

.tmp/avr-libc-2.0.0: | .tmp/avrlibc.tar.bz2
	tar xvf .tmp/avrlibc.tar.bz2 -C .tmp

.tmp/binutils-2.31: | .tmp/binutils.tar.xz
	tar xvf .tmp/binutils.tar.xz -C .tmp

.tmp/gcc-8.2.0: | .tmp/gcc-8.2.0.tar.xz
	tar xvf .tmp/gcc-8.2.0.tar.xz -C .tmp

.tmp/gdb-8.2: | .tmp/gdb-8.2.tar.xz
	tar xvf .tmp/gdb-8.2.tar.xz -C .tmp

.venv/bin/avrdude: | .tmp/avrdude-6.3
	cd .tmp/avrdude-6.3 && ./configure --prefix=$(VENV) --exec-prefix=$(VENV)
	cd .tmp/avrdude-6.3 && $(MAKE) -j $(CORES)
	cd .tmp/avrdude-6.3 && $(MAKE) install

.venv/avr/bin/as: | .tmp/binutils-2.31
	cd .tmp/binutils-2.31         && mkdir -p obj-avr
	cd .tmp/binutils-2.31/obj-avr && ../configure --prefix=$(VENV) --exec-prefix=$(VENV) --target=avr --disable-nls
	cd .tmp/binutils-2.31/obj-avr && $(MAKE) -j $(CORES)
	cd .tmp/binutils-2.31/obj-avr && $(MAKE) install

.venv/bin/avr-gcc: | .tmp/gcc-8.2.0 .venv/avr/bin/as
	cd .tmp/gcc-8.2.0         && mkdir -p obj-avr
	cd .tmp/gcc-8.2.0/obj-avr && ../configure --prefix=$(VENV) --exec-prefix=$(VENV) --target=avr  --enable-languages=c,c++ --disable-nls --disable-libssp
#	--program-prefix=avr- --program-suffix=""
	cd .tmp/gcc-8.2.0/obj-avr && $(MAKE) -j $(CORES)
	cd .tmp/gcc-8.2.0/obj-avr && $(MAKE) install

.venv/avr/lib/libc.a: | .tmp/avr-libc-2.0.0 .venv/bin/avr-gcc
	# --with-debug-info in (stabs, dwarf-2, dwarf-4)
	cd .tmp/avr-libc-2.0.0 && export PATH=$(VENV)/bin:$$PATH; ./configure --prefix=$(VENV) --build=`./config.guess` --host=avr --with-debug-info=dwarf-2 --disable-nls
	cd .tmp/avr-libc-2.0.0 && export PATH=$(VENV)/bin:$$PATH; make -j $(CORES)
	cd .tmp/avr-libc-2.0.0 && export PATH=$(VENV)/bin:$$PATH; make install


.venv/bin/avr-gdb: | .tmp/gdb-8.2
	cd .tmp/gdb-8.2 && mkdir -p obj-avr
	cd .tmp/gdb-8.2/obj-avr && ../configure --prefix=$(VENV) --target=avr
	cd .tmp/gdb-8.2/obj-avr && $(MAKE) -j $(CORES)
	cd .tmp/gdb-8.2/obj-avr && $(MAKE) install

.venv/bin/activate: | .venv
	echo PATH="$(TOPDIR)/.venv/bin:\$$PATH" > $(TOPDIR)/.venv/bin/activate
	echo export PATH >> $(TOPDIR)/.venv/bin/activate
