CC = gcc
DEFAULT_CFLAGS = -Os -Wall -export-dynamic -fomit-frame-pointer $(SITE_CFLAGS)
DEFAULT_LIBS = -lm

STRIP = strip

OBJS = native/arithmetic.o native/array.o native/bignum.o \
	native/s48_bignum.o \
	native/complex.o native/cons.o native/error.o \
	native/factor.o native/file.o native/fixnum.o \
	native/float.o native/gc.o \
	native/image.o native/io.o native/memory.o \
	native/misc.o native/port.o native/primitives.o \
	native/ratio.o native/read.o native/relocate.o \
	native/run.o \
	native/sbuf.o native/socket.o native/stack.o \
	native/string.o native/types.o native/vector.o \
	native/write.o native/word.o native/compiler.o \
	native/ffi.o

default:
	@echo "Run 'make' with one of the following parameters:"
	@echo ""
	@echo "bsd"
	@echo "bsd-nopthread - on FreeBSD 4, if you want to use profiling"
	@echo "linux"
	@echo "solaris"
	@echo ""
	@echo "Also, you might want to set the SITE_CFLAGS environment"
	@echo "variable to enable some CPU-specific optimizations; this"
	@echo "can make a huge difference. Eg:"
	@echo ""
	@echo "export SITE_CFLAGS=\"-march=pentium4 -ffast-math\""

bsd:
	$(MAKE) f \
		CFLAGS="$(DEFAULT_CFLAGS) -DFFI -pthread" \
		LIBS="$(DEFAULT_LIBS)"

bsd-nopthread:
	$(MAKE) f \
		CFLAGS="$(DEFAULT_CFLAGS) -DFFI" \
		LIBS="$(DEFAULT_LIBS)"

linux:
	$(MAKE) f \
		CFLAGS="$(DEFAULT_CFLAGS) -DFFI" \
		LIBS="$(DEFAULT_LIBS) -ldl"

solaris:
	$(MAKE) f \
		CFLAGS="$(DEFAULT_CFLAGS)" \
		LIBS="$(DEFAULT_LIBS) -lsocket -lnsl -lm"

f: $(OBJS)
	$(CC) $(LIBS) $(CFLAGS) -o $@ $(OBJS)
	$(STRIP) $@

clean:
	rm -f $(OBJS)

.c.o:
	$(CC) -c $(CFLAGS) -o $@ $<

