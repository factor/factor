CC = gcc

EXECUTABLE = factor
VERSION = 0.91

IMAGE = factor.image
BUNDLE = Factor.app
LIBPATH = -L/usr/X11R6/lib
CFLAGS = -Wall

ifdef DEBUG
	CFLAGS += -g
else
	CFLAGS += -O3 -fomit-frame-pointer $(SITE_CFLAGS)
endif

ifdef CONFIG
	include $(CONFIG)
endif

ENGINE = $(DLL_PREFIX)factor$(DLL_SUFFIX)$(DLL_EXTENSION)

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
	vm/types.o \
	vm/jit.o \
	vm/utilities.o

EXE_OBJS = $(PLAF_EXE_OBJS)

default:
	@echo "Run 'make' with one of the following parameters:"
	@echo ""
	@echo "freebsd-x86-32"
	@echo "freebsd-x86-64"
	@echo "linux-x86-32"
	@echo "linux-x86-64"
	@echo "linux-ppc"
	@echo "linux-arm"
	@echo "openbsd-x86-32"
	@echo "openbsd-x86-64"
	@echo "macosx-x86-32"
	@echo "macosx-ppc"
	@echo "solaris-x86-32"
	@echo "solaris-x86-64"
	@echo "windows-ce-arm"
	@echo "windows-nt-x86-32"
	@echo ""
	@echo "Additional modifiers:"
	@echo ""
	@echo "DEBUG=1  compile VM with debugging information"
	@echo "SITE_CFLAGS=...  additional optimization flags"
	@echo "NO_UI=1  don't link with X11 libraries (ignored on Mac OS X)"
	@echo "X11=1  force link with X11 libraries instead of Cocoa (only on Mac OS X)"

openbsd-x86-32:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.openbsd.x86.32

openbsd-x86-64:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.openbsd.x86.64

freebsd-x86-32:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.freebsd.x86.32

freebsd-x86-64:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.freebsd.x86.64

macosx-freetype:
	ln -sf libfreetype.6.dylib \
		Factor.app/Contents/Frameworks/libfreetype.dylib

macosx-ppc: macosx-freetype
	$(MAKE) $(EXECUTABLE) macosx.app CONFIG=vm/Config.macosx.ppc

macosx-x86-32: macosx-freetype
	$(MAKE) $(EXECUTABLE) macosx.app CONFIG=vm/Config.macosx.x86.32

linux-x86-32:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.linux.x86.32

linux-x86-64:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.linux.x86.64

linux-ppc:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.linux.ppc

linux-arm:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.linux.arm

solaris-x86-32:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.solaris.x86.32

solaris-x86-64:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.solaris.x86.64

windows-nt-x86-32:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.windows.nt.x86.32

windows-ce-arm:
	$(MAKE) $(EXECUTABLE) CONFIG=vm/Config.windows.ce.arm

macosx.app: factor
	mkdir -p $(BUNDLE)/Contents/MacOS
	cp $(EXECUTABLE) $(BUNDLE)/Contents/MacOS/factor
	cp $(ENGINE) $(BUNDLE)/Contents/Frameworks

	install_name_tool \
		-id @executable_path/../Frameworks/libfreetype.6.dylib \
		Factor.app/Contents/Frameworks/libfreetype.6.dylib
	install_name_tool \
		-change libfactor.dylib \
		@executable_path/../Frameworks/libfactor.dylib \
		Factor.app/Contents/MacOS/factor

factor: $(DLL_OBJS) $(EXE_OBJS)
	$(LINKER) $(ENGINE) $(DLL_OBJS)
	$(CC) $(LIBS) $(LIBPATH) -L. $(LINK_WITH_ENGINE) \
		$(CFLAGS) -o $@$(EXE_SUFFIX)$(EXE_EXTENSION) $(EXE_OBJS)

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
