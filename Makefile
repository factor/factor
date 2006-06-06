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

WINDOWS_OBJS = vm/windows/ffi.o \
	vm/windows/file.o \
	vm/windows/misc.o \
	vm/windows/run.o \
	vm/windows/memory.o

UNIX_OBJS = vm/unix/file.o \
	vm/unix/signal.o \
	vm/unix/ffi.o \
	vm/unix/memory.o \
	vm/unix/icache.o

MACOSX_OBJS = $(UNIX_OBJS) \
	vm/macosx/run.o \
	vm/macosx/mach_signal.o

GENERIC_UNIX_OBJS = $(UNIX_OBJS) \
	vm/unix/run.o

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

OBJS = $(PLAF_OBJS) vm/array.o vm/bignum.o \
	vm/s48_bignum.o \
	vm/complex.o vm/error.o \
	vm/factor.o vm/fixnum.o \
	vm/float.o vm/gc.o \
	vm/image.o vm/memory.o \
	vm/misc.o vm/primitives.o \
	vm/ratio.o vm/relocate.o \
	vm/run.o \
	vm/sbuf.o vm/stack.o \
	vm/string.o vm/cards.o vm/vector.o \
	vm/word.o vm/compiler.o \
	vm/alien.o vm/dll.o \
	vm/boolean.o \
	vm/debug.o \
	vm/hashtable.o \
	vm/io.o \
	vm/wrapper.o \
	vm/ffi_test.o

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

	chmod +x cp_dir
	find doc library contrib examples fonts \( -name '*.factor' \
		-o -name '*.facts' \
		-o -name '*.txt' \
		-o -name '*.html' \
		-o -name '*.ttf' \
		-o -name '*.js' \) \
		-exec ./cp_dir {} $(BUNDLE)/Contents/Resources/{} \;

	cp version.factor $(BUNDLE)/Contents/Resources/

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
	rm -f $(OBJS) $(UNIX_OBJS) $(WINDOWS_OBJS) $(MACOSX_OBJS)
	rm -rf $(BUNDLE)/Contents/Resources/
	rm -f $(BUNDLE)/Contents/MacOS/Factor

.c.o:
	$(CC) -c $(CFLAGS) -o $@ $<

.S.o:
	$(CC) -c $(CFLAGS) -o $@ $<

.m.o:
	$(CC) -c $(CFLAGS) -o $@ $<

boot:
	echo "USE: image \"$(ARCH)\" make-image bye" | ./f factor.image
	./f boot.image.$(ARCH) $(BOOTSTRAP_FLAGS)
	
