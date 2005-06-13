CC = gcc
ifdef DEBUG
	DEFAULT_CFLAGS = -g
	STRIP = touch
else
	DEFAULT_CFLAGS = -Wall -O3 -fomit-frame-pointer $(SITE_CFLAGS)
	STRIP = strip
endif

DEFAULT_LIBS = -lm

UNIX_OBJS = native/unix/file.o \
	native/unix/signal.o \
	native/unix/ffi.o \
	native/unix/run.o \
	native/unix/memory.o

WIN32_OBJS = native/win32/ffi.o \
	native/win32/file.o \
	native/win32/misc.o \
	native/win32/run.o \
	native/win32/memory.o

ifdef WIN32
	PLAF_OBJS = $(WIN32_OBJS)
	PLAF_SUFFIX = .exe
else
	PLAF_OBJS = $(UNIX_OBJS)
endif

OBJS = $(PLAF_OBJS) native/arithmetic.o native/array.o native/bignum.o \
	native/s48_bignum.o \
	native/complex.o native/cons.o native/error.o \
	native/factor.o native/fixnum.o \
	native/float.o native/gc.o \
	native/image.o native/memory.o \
	native/misc.o native/primitives.o \
	native/ratio.o native/relocate.o \
	native/run.o \
	native/sbuf.o native/stack.o \
	native/string.o native/cards.o native/vector.o \
	native/word.o native/compiler.o \
	native/alien.o native/dll.o \
	native/boolean.o \
	native/debug.o \
	native/hashtable.o \
	native/icache.o \
	native/io.o

default:
	@echo "Run 'make' with one of the following parameters:"
	@echo ""
	@echo "bsd"
	@echo "bsd-nopthread - on FreeBSD 4, if you want to use profiling"
	@echo "linux"
	@echo "linux-ppc - to compile Factor on Linux/PowerPC"
	@echo "macosx"
	@echo "windows"
	@echo ""
	@echo "Also, you might want to set the SITE_CFLAGS environment"
	@echo "variable to enable some CPU-specific optimizations; this"
	@echo "can make a huge difference. Eg:"
	@echo ""
	@echo "export SITE_CFLAGS=\"-march=pentium4 -ffast-math\""

bsd:
	$(MAKE) f \
		CFLAGS="$(DEFAULT_CFLAGS) -export-dynamic -pthread" \
		LIBS="$(DEFAULT_LIBS)" 
	$(STRIP) f

bsd-nopthread:
	$(MAKE) f \
		CFLAGS="$(DEFAULT_CFLAGS) -export-dynamic" \
		LIBS="$(DEFAULT_LIBS)"
	$(STRIP) f

macosx:
	$(MAKE) f \
		CFLAGS="$(DEFAULT_CFLAGS)" \
		LIBS="$(DEFAULT_LIBS)" 

linux:
	$(MAKE) f \
		CFLAGS="$(DEFAULT_CFLAGS) -export-dynamic" \
		LIBS="$(DEFAULT_LIBS) -ldl"
	$(STRIP) f

linux-ppc:
	$(MAKE) f \
		CFLAGS="$(DEFAULT_CFLAGS) -export-dynamic -mregnames" \
		LIBS="$(DEFAULT_LIBS) -ldl"
	$(STRIP) f

windows:
	$(MAKE) f \
		CFLAGS="$(DEFAULT_CFLAGS) -DFFI -DWIN32" \
		LIBS="$(DEFAULT_LIBS)" WIN32=y

f: $(OBJS)
	$(CC) $(LIBS) $(CFLAGS) -o $@$(PLAF_SUFFIX) $(OBJS)

clean:
	rm -f $(OBJS)

.c.o:
	$(CC) -c $(CFLAGS) -o $@ $<

.S.o:
	$(CC) -c $(CFLAGS) -o $@ $<
