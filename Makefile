CC = gcc

EXECUTABLE = factor

IMAGE = factor.image
BUNDLE = Factor.app
VERSION = 0.89
DISK_IMAGE_DIR = Factor-$(VERSION)
DISK_IMAGE = Factor-$(VERSION).dmg
LIBPATH = -L/usr/X11R6/lib
CFLAGS = -Wall

ifdef DEBUG
	CFLAGS += -g
else
	CFLAGS += -O3 $(SITE_CFLAGS)
endif

ifdef CONFIG
	include $(CONFIG)
endif

ifdef BOOT
	BOOT_CMD = $@$(EXE_SUFFIX)
	
	ifdef X11
		BOOT_FLAGS += -no-cocoa -x11
	endif
else
	BOOT_CMD = echo
endif

BOOT_IMAGE = boot.image.$(BOOT_ARCH)

ifdef IMAGES
	IMAGES_CMD = wget -N http://factorcode.org/images/$(IMAGES)/$(BOOT_IMAGE)
endif

ENGINE = $(DLL_PREFIX)factor$(DLL_SUFFIX)

DLL_OBJS = $(PLAF_DLL_OBJS) \
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

EXE_OBJS = $(PLAF_EXE_OBJS) vm/main.o

default:
	@echo "Run 'make' with one of the following parameters:"
	@echo ""
	@echo "bsd-x86"
	@echo "bsd-amd64"
	@echo "linux-x86"
	@echo "linux-amd64"
	@echo "linux-ppc"
	@echo "linux-arm"
	@echo "solaris-x86"
	@echo "solaris-amd64"
	@echo "macosx-x86"
	@echo "macosx-ppc"
	@echo "windows-nt-x86"
	@echo "windows-ce-arm"
	@echo "windows-ce-x86"
	@echo ""
	@echo "Additional modifiers:"
	@echo ""
	@echo "IMAGES=<version>|latest  automatically download boot image from http://factorcode.org/images/<version>"
	@echo "BOOT=1  automatically bootstrap using current boot image"
	@echo "BOOT_FLAGS=... flags to pass to bootstrap"
	@echo "DEBUG=1  compile VM with debugging information"
	@echo "SITE_CFLAGS=...  additional optimization flags"
	@echo "NO_UI=1  don't link with X11 libraries (ignored on Mac OS X)"
	@echo "X11=1  force link with X11 libraries instead of Cocoa (only on Mac OS X)"

bsd-x86:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.bsd.x86

bsd-amd64:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.bsd.amd64

macosx-freetype:
	ln -sf libfreetype.6.dylib \
		Factor.app/Contents/Frameworks/libfreetype.dylib

macosx-ppc: macosx-freetype
	$(MAKE) $(EXECUTABLE) macosx.app CONFIG=vm/Config.macosx.ppc

macosx-x86: macosx-freetype
	$(MAKE) $(EXECUTABLE) macosx.app CONFIG=vm/Config.macosx.x86

linux-x86:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.linux.x86

linux-amd64:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.linux.amd64

linux-ppc:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.linux.ppc

linux-arm:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.linux.arm

solaris-x86:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.solaris.x86

solaris-amd64:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.solaris.amd64

windows-nt-x86:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.windows.nt.x86

windows-ce-arm:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.windows.ce.arm

windows-ce-x86:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.windows.ce.x86

macosx.app: factor
	cp $(EXECUTABLE) $(BUNDLE)/Contents/MacOS/Factor
	cp $(ENGINE) $(BUNDLE)/Contents/Frameworks

	install_name_tool \
		-id @executable_path/../Frameworks/libfreetype.6.dylib \
		Factor.app/Contents/Frameworks/libfreetype.6.dylib
	install_name_tool \
		-change /usr/X11R6/lib/libfreetype.6.dylib \
		@executable_path/../Frameworks/libfreetype.6.dylib \
		Factor.app/Contents/MacOS/Factor
	install_name_tool \
		-change libfactor.dylib \
		@executable_path/../Frameworks/libfactor.dylib \
		Factor.app/Contents/MacOS/Factor

macosx.dmg:
	rm -f $(DISK_IMAGE)
	rm -rf $(DISK_IMAGE_DIR)
	mkdir $(DISK_IMAGE_DIR)
	mkdir -p $(DISK_IMAGE_DIR)/Factor/
	cp -R $(BUNDLE) $(DISK_IMAGE_DIR)/Factor/$(BUNDLE)
	chmod +x cp_dir
	cp factor.image license.txt README.txt TODO.txt \
		$(DISK_IMAGE_DIR)/Factor/
	find core apps libs demos unmaintained fonts extras -type f \
		-exec ./cp_dir {} $(DISK_IMAGE_DIR)/Factor/{} \;
	hdiutil create -srcfolder "$(DISK_IMAGE_DIR)" -fs HFS+ \
		-volname "$(DISK_IMAGE_DIR)" "$(DISK_IMAGE)"

factor: $(DLL_OBJS) $(EXE_OBJS)
	$(LINKER) $(ENGINE) $(DLL_OBJS)
	$(CC) $(LIBS) $(LIBPATH) -L. $(LINK_WITH_ENGINE) \
		$(CFLAGS) -o $@$(EXE_SUFFIX) $(EXE_OBJS)
	$(IMAGES_CMD)
	$(BOOT_CMD) -i=$(BOOT_IMAGE) $(BOOT_FLAGS)

pull:
	darcs pull http://factorcode.org/repos/

clean:
	rm -f vm/*.o

vm/resources.o:
	windres vm/factor.rs vm/resources.o

.c.o:
	$(CC) -c $(CFLAGS) -o $@ $<

.S.o:
	$(CC) -c $(CFLAGS) -o $@ $<

.m.o:
	$(CC) -c $(CFLAGS) -o $@ $<
	
.PHONY: factor
