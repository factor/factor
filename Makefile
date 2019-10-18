CC = gcc

BINARY = f
IMAGE = factor.image
BUNDLE = Factor.app
DISK_IMAGE_DIR = Factor-0.81
DISK_IMAGE = Factor-0.81.dmg

ifdef DEBUG
	DEFAULT_CFLAGS = -g
	STRIP = touch
else
	DEFAULT_CFLAGS = -Wall -O3 -ffast-math -fomit-frame-pointer $(SITE_CFLAGS)
	STRIP = strip
endif

DEFAULT_LIBS = -lm

ifdef NO_UI
	UNIX_UI_LIBS =
else
	UNIX_UI_LIBS = -lfreetype -lGL -lGLU -L/usr/X11R6/lib -lX11
endif

WINDOWS_OBJS = native/windows/ffi.o \
	native/windows/file.o \
	native/windows/misc.o \
	native/windows/run.o \
	native/windows/memory.o

UNIX_OBJS = native/unix/file.o \
	native/unix/signal.o \
	native/unix/ffi.o \
	native/unix/memory.o \
	native/unix/icache.o

MACOSX_OBJS = $(UNIX_OBJS) \
	native/macosx/run.o \
	native/macosx/mach_signal.o

GENERIC_UNIX_OBJS = $(UNIX_OBJS) \
	native/unix/run.o

ifdef WINDOWS
 	PLAF_OBJS = $(WINDOWS_OBJS)
 	PLAF_SUFFIX = .exe
else
	ifdef MACOSX
		PLAF_OBJS = $(MACOSX_OBJS)
	else
		PLAF_OBJS = $(GENERIC_UNIX_OBJS)
	endif
endif

OBJS = $(PLAF_OBJS) native/array.o native/bignum.o \
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
	native/io.o \
	native/wrapper.o \
	native/ffi_test.o

default:
	@echo "Run 'make' with one of the following parameters:"
	@echo ""
	@echo "bsd"
	@echo "linux"
	@echo "linux-ppc"
	@echo "macosx"
	@echo "solaris"
	@echo "windows"
	@echo ""
	@echo "On Unix, pass NO_UI=1 if you don't want to link with the"
	@echo "X11 and OpenGL libraries."
	@echo
	@echo "Also, you might want to set the SITE_CFLAGS environment"
	@echo "variable to enable some CPU-specific optimizations; this"
	@echo "can make a huge difference. Eg:"
	@echo ""
	@echo "export SITE_CFLAGS=\"-march=pentium4 -ffast-math\""

bsd:
	$(MAKE) $(BINARY) \
		CFLAGS="$(DEFAULT_CFLAGS) -export-dynamic -pthread" \
		LIBS="$(DEFAULT_LIBS) $(UI_LIBS)" 
	$(STRIP) $(BINARY)

macosx:
	$(MAKE) $(BINARY) \
		CFLAGS="$(DEFAULT_CFLAGS)" \
		LIBS="$(DEFAULT_LIBS) -framework Cocoa -framework OpenGL -lfreetype" \
		MACOSX=y

macosx.app:
	cp $(BINARY) $(BUNDLE)/Contents/MacOS/Factor

	rm -rf $(BUNDLE)/Contents/Resources/
	mkdir -p $(BUNDLE)/Contents/Resources/fonts/
	cp -R fonts/*.ttf $(BUNDLE)/Contents/Resources/fonts/

	find doc library contrib \( -name '*.factor' \
		-o -name '*.facts' \
		-o -name '*.txt' \
		-o -name '*.html' \
		-o -name '*.js' \) \
		-exec ./cp_dir {} $(BUNDLE)/Contents/Resources/{} \;

	cp $(IMAGE) $(BUNDLE)/Contents/Resources/factor.image

	install_name_tool \
		-id @executable_path/../Frameworks/libfreetype.6.dylib \
		Factor.app/Contents/Frameworks/libfreetype.6.dylib
	install_name_tool \
		-change /usr/local/lib/libfreetype.6.dylib \
		@executable_path/../Frameworks/libfreetype.6.dylib \
		Factor.app/Contents/MacOS/Factor

macosx.dmg:
	rm $(DISK_IMAGE)
	rm -rf $(DISK_IMAGE_DIR)
	mkdir $(DISK_IMAGE_DIR)
	cp -R $(BUNDLE) $(DISK_IMAGE_DIR)/$(BUNDLE)
	hdiutil create -srcfolder "$(DISK_IMAGE_DIR)" -fs HFS+ \
		-volname "$(DISK_IMAGE_DIR)" "$(DISK_IMAGE)"

linux linux-x86 linux-amd64:
	$(MAKE) $(BINARY) \
		CFLAGS="$(DEFAULT_CFLAGS) -export-dynamic" \
		LIBS="-ldl $(DEFAULT_LIBS) $(UNIX_UI_LIBS)"
	$(STRIP) $(BINARY)

linux-ppc:
	$(MAKE) $(BINARY) \
		CFLAGS="$(DEFAULT_CFLAGS) -export-dynamic -mregnames" \
		LIBS="-ldl $(DEFAULT_LIBS) $(UNIX_UI_LIBS)"
	$(STRIP) $(BINARY)

solaris solaris-x86:
	$(MAKE) $(BINARY) \
		CFLAGS="$(DEFAULT_CFLAGS) -D_STDC_C99 -Drestrict=\"\" " \
		LIBS="-ldl -lsocket -lnsl $(DEFAULT_LIBS) -R/opt/PM/lib -R/opt/csw/lib -R/usr/local/lib -R/usr/sfw/lib -R/usr/X11R6/lib -R/opt/sfw/lib $(UNIX_UI_LIBS)"
	$(STRIP) $(BINARY)

windows:
	$(MAKE) $(BINARY) \
		CFLAGS="$(DEFAULT_CFLAGS) -DWINDOWS" \
		LIBS="$(DEFAULT_LIBS)" WINDOWS=y

f: $(OBJS)
	$(CC) $(LIBS) $(CFLAGS) -o $@$(PLAF_SUFFIX) $(OBJS)

clean:
	rm -f $(OBJS)

.c.o:
	$(CC) -c $(CFLAGS) -o $@ $<

.S.o:
	$(CC) -c $(CFLAGS) -o $@ $<

.m.o:
	$(CC) -c $(CFLAGS) -o $@ $<

boot:
	echo "USE: image \"$(ARCH)\" make-image bye" | ./f factor.image
	./f boot.image.$(ARCH) $(BOOTSTRAP_FLAGS)
	
