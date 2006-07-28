CC = gcc

BINARY = f
IMAGE = factor.image
BUNDLE = Factor.app
DISK_IMAGE_DIR = Factor-0.83
DISK_IMAGE = Factor-0.83.dmg

ifdef DEBUG
	CFLAGS = -g
	STRIP = touch
else
	CFLAGS = -Wall -O3 -ffast-math -fomit-frame-pointer $(SITE_CFLAGS)
	STRIP = strip
endif

ifdef NO_UI
	X11_UI_LIBS =
else
	X11_UI_LIBS = -lfreetype -lGL -lGLU -L/usr/X11R6/lib -lX11
endif

ifdef CONFIG
	include $(CONFIG)
endif

OBJS = $(PLAF_OBJS) \
	vm/alien.o \
	vm/bignum.o \
	vm/debug.o \
	vm/factor.o \
	vm/ffi_test.o \
	vm/image.o \
	vm/io.o \
	vm/math.o \
	vm/memory.o \
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
	$(MAKE) $(BINARY) CONFIG=vm/Config.macosx

linux-x86 linux-amd64:
	$(MAKE) $(BINARY) CONFIG=vm/Config.linux
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
		-change /usr/X11R6/lib/libfreetype.6.dylib \
		@executable_path/../Frameworks/libfreetype.6.dylib \
		Factor.app/Contents/MacOS/Factor

macosx.dmg:
	rm $(DISK_IMAGE)
	rm -rf $(DISK_IMAGE_DIR)
	mkdir $(DISK_IMAGE_DIR)
	cp -R $(BUNDLE) $(DISK_IMAGE_DIR)/$(BUNDLE)
	hdiutil create -srcfolder "$(DISK_IMAGE_DIR)" -fs HFS+ \
		-volname "$(DISK_IMAGE_DIR)" "$(DISK_IMAGE)"

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
