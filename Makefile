CC = gcc

BINARY = f
IMAGE = factor.image
BUNDLE = Factor.app
VERSION = 0.87
DISK_IMAGE_DIR = Factor-$(VERSION)
DISK_IMAGE = Factor-$(VERSION).dmg
LIBPATH = -L/usr/X11R6/lib

ifdef DEBUG
	CFLAGS = -g
	STRIP = touch
else
	CFLAGS = -Wall -O3 -ffast-math $(SITE_CFLAGS)
	STRIP = strip
endif

ifdef CONFIG
	include $(CONFIG)
endif

OBJS = $(PLAF_OBJS) \
	vm/alien.o \
	vm/bignum.o \
	vm/compiler.o \
	vm/debug.o \
	vm/factor.o \
	vm/ffi_test.o \
	vm/image.o \
	vm/io.o \
	vm/math.o \
	vm/data_gc.o \
	vm/code_gc.o \
	vm/primitives.o \
	vm/run.o \
	vm/stack.o \
	vm/types.o

default:
	@echo "Run 'make' with one of the following parameters:"
	@echo ""
	@echo "freebsd"
	@echo "linux-x86"
	@echo "linux-amd64"
	@echo "linux-ppc"
	@echo "macosx-x86"
	@echo "macosx-ppc"
	@echo "solaris"
	@echo "windows"
	@echo ""
	@echo "On Unix, pass NO_UI=1 if you don't want to link with the"
	@echo "X11 and OpenGL libraries."
	@echo ""
	@echo "On Mac OS X, pass X11=1 if you want to link with the"
	@echo "X11 library instead of Cocoa. You will also need to bootstrap"
	@echo "Factor with the -no-cocoa -x11 switches."
	@echo
	@echo "Also, you might want to set the SITE_CFLAGS environment"
	@echo "variable to enable some CPU-specific optimizations; this"
	@echo "can make a huge difference. Eg:"
	@echo ""
	@echo "export SITE_CFLAGS=\"-march=pentium4 -ffast-math\""

freebsd:
	$(MAKE) $(BINARY) CONFIG=vm/Config.freebsd

macosx-freetype:
	ln -sf libfreetype.6.dylib \
		Factor.app/Contents/Frameworks/libfreetype.dylib

macosx-ppc: macosx-freetype
	$(MAKE) $(BINARY) CONFIG=vm/Config.macosx.ppc

macosx-x86: macosx-freetype
	$(MAKE) $(BINARY) CONFIG=vm/Config.macosx.x86

linux-x86:
	$(MAKE) $(BINARY) CONFIG=vm/Config.linux.x86
	# $(STRIP) $(BINARY)

linux-amd64:
	$(MAKE) $(BINARY) CONFIG=vm/Config.linux.amd64
	$(STRIP) $(BINARY)

linux-ppc:
	$(MAKE) $(BINARY) CONFIG=vm/Config.linux.ppc
	$(STRIP) $(BINARY)

solaris solaris-x86 solaris-amd64:
	$(MAKE) $(BINARY) CONFIG=vm/Config.solaris
	$(STRIP) $(BINARY)

windows:
	$(MAKE) $(BINARY) CONFIG=vm/Config.windows

macosx.app:
	cp $(BINARY) $(BUNDLE)/Contents/MacOS/Factor

	install_name_tool \
		-id @executable_path/../Frameworks/libfreetype.6.dylib \
		Factor.app/Contents/Frameworks/libfreetype.6.dylib
	install_name_tool \
		-change /usr/X11R6/lib/libfreetype.6.dylib \
		@executable_path/../Frameworks/libfreetype.6.dylib \
		Factor.app/Contents/MacOS/Factor

macosx.dmg:
	rm -f $(DISK_IMAGE)
	rm -rf $(DISK_IMAGE_DIR)
	mkdir $(DISK_IMAGE_DIR)
	mkdir -p $(DISK_IMAGE_DIR)/Factor/
	cp -R $(BUNDLE) $(DISK_IMAGE_DIR)/Factor/$(BUNDLE)
	chmod +x cp_dir
	cp factor.image license.txt README.txt TODO.FACTOR.txt \
		$(DISK_IMAGE_DIR)/Factor/
	find doc library contrib examples fonts \( -name '*.factor' \
		-o -name '*.facts' \
		-o -name '*.txt' \
		-o -name '*.html' \
		-o -name '*.ttf' \
		-o -name '*.el' \
		-o -name '*.vim' \
		-o -name '*.fgen' \
		-o -name '*.tex' \
		-o -name '*.fhtml' \
		-o -name '*.xml' \
		-o -name '*.js' \) \
		-exec ./cp_dir {} $(DISK_IMAGE_DIR)/Factor/{} \;
	hdiutil create -srcfolder "$(DISK_IMAGE_DIR)" -fs HFS+ \
		-volname "$(DISK_IMAGE_DIR)" "$(DISK_IMAGE)"

tags:
	ctags-exuberant vm/*.[chm]

f: $(OBJS)
	$(CC) $(LIBS) $(LIBPATH) $(CFLAGS) -o $@$(PLAF_SUFFIX) $(OBJS)

clean:
	rm -f vm/*.o

clean.app:
	rm -f $(BUNDLE)/Contents/MacOS/Factor

.c.o:
	$(CC) -c $(CFLAGS) -o $@ $<

.S.o:
	$(CC) -c $(CFLAGS) -o $@ $<

.m.o:
	$(CC) -c $(CFLAGS) -o $@ $<
