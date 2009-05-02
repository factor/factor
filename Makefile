CC = gcc
CPP = g++
AR = ar
LD = ld

EXECUTABLE = factor
CONSOLE_EXECUTABLE = factor-console
TEST_LIBRARY = factor-ffi-test
VERSION = 0.92

BUNDLE = Factor.app
LIBPATH = -L/usr/X11R6/lib
CFLAGS = -Wall

ifdef DEBUG
	CFLAGS += -g -DFACTOR_DEBUG
else
	CFLAGS += -O3
endif

CFLAGS += $(SITE_CFLAGS)

ENGINE = $(DLL_PREFIX)factor$(DLL_SUFFIX)$(DLL_EXTENSION)

ifdef CONFIG
	include $(CONFIG)
endif

DLL_OBJS = $(PLAF_DLL_OBJS) \
	vmpp/alien.o \
	vmpp/arrays.o \
	vmpp/bignum.o \
	vmpp/booleans.o \
	vmpp/byte_arrays.o \
	vmpp/callstack.o \
	vmpp/code_block.o \
	vmpp/code_gc.o \
	vmpp/code_heap.o \
	vmpp/data_gc.o \
	vmpp/data_heap.o \
	vmpp/debug.o \
	vmpp/dispatch.o \
	vmpp/errors.o \
	vmpp/factor.o \
	vmpp/image.o \
	vmpp/inline_cache.o \
	vmpp/io.o \
	vmpp/jit.o \
	vmpp/local_roots.o \
	vmpp/math.o \
	vmpp/primitives.o \
	vmpp/profiler.o \
	vmpp/quotations.o \
	vmpp/run.o \
	vmpp/strings.o \
	vmpp/tuples.o \
	vmpp/utilities.o \
	vmpp/words.o \
	vmpp/write_barrier.o

EXE_OBJS = $(PLAF_EXE_OBJS)

TEST_OBJS = vmpp/ffi_test.o

default:
	$(MAKE) `./build-support/factor.sh make-target`

help:
	@echo "Run '$(MAKE)' with one of the following parameters:"
	@echo ""
	@echo "freebsd-x86-32"
	@echo "freebsd-x86-64"
	@echo "linux-x86-32"
	@echo "linux-x86-64"
	@echo "linux-ppc"
	@echo "linux-arm"
	@echo "openbsd-x86-32"
	@echo "openbsd-x86-64"
	@echo "netbsd-x86-32"
	@echo "netbsd-x86-64"
	@echo "macosx-x86-32"
	@echo "macosx-x86-64"
	@echo "macosx-ppc"
	@echo "solaris-x86-32"
	@echo "solaris-x86-64"
	@echo "wince-arm"
	@echo "winnt-x86-32"
	@echo "winnt-x86-64"
	@echo ""
	@echo "Additional modifiers:"
	@echo ""
	@echo "DEBUG=1  compile VM with debugging information"
	@echo "SITE_CFLAGS=...  additional optimization flags"
	@echo "NO_UI=1  don't link with X11 libraries (ignored on Mac OS X)"
	@echo "X11=1  force link with X11 libraries instead of Cocoa (only on Mac OS X)"

openbsd-x86-32:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vmpp/Config.openbsd.x86.32

openbsd-x86-64:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vmpp/Config.openbsd.x86.64

freebsd-x86-32:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vmpp/Config.freebsd.x86.32

freebsd-x86-64:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vmpp/Config.freebsd.x86.64

netbsd-x86-32:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vmpp/Config.netbsd.x86.32

netbsd-x86-64:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vmpp/Config.netbsd.x86.64

macosx-ppc:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) macosx.app CONFIG=vmpp/Config.macosx.ppc

macosx-x86-32:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) macosx.app CONFIG=vmpp/Config.macosx.x86.32

macosx-x86-64:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) macosx.app CONFIG=vmpp/Config.macosx.x86.64

linux-x86-32:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vmpp/Config.linux.x86.32

linux-x86-64:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vmpp/Config.linux.x86.64

linux-ppc:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vmpp/Config.linux.ppc

linux-arm:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vmpp/Config.linux.arm

solaris-x86-32:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vmpp/Config.solaris.x86.32

solaris-x86-64:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vmpp/Config.solaris.x86.64

winnt-x86-32:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vmpp/Config.windows.nt.x86.32
	$(MAKE) $(CONSOLE_EXECUTABLE) CONFIG=vmpp/Config.windows.nt.x86.32

winnt-x86-64:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vmpp/Config.windows.nt.x86.64
	$(MAKE) $(CONSOLE_EXECUTABLE) CONFIG=vmpp/Config.windows.nt.x86.64

wince-arm:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vmpp/Config.windows.ce.arm

macosx.app: factor
	mkdir -p $(BUNDLE)/Contents/MacOS
	mkdir -p $(BUNDLE)/Contents/Frameworks
	mv $(EXECUTABLE) $(BUNDLE)/Contents/MacOS/factor
	ln -s Factor.app/Contents/MacOS/factor ./factor
	cp $(ENGINE) $(BUNDLE)/Contents/Frameworks/$(ENGINE)

	install_name_tool \
		-change libfactor.dylib \
		@executable_path/../Frameworks/libfactor.dylib \
		Factor.app/Contents/MacOS/factor

$(EXECUTABLE): $(DLL_OBJS) $(EXE_OBJS)
	$(LINKER) $(ENGINE) $(DLL_OBJS)
	$(CPP) $(LIBS) $(LIBPATH) -L. $(LINK_WITH_ENGINE) \
		$(CFLAGS) -o $@$(EXE_SUFFIX)$(EXE_EXTENSION) $(EXE_OBJS)

$(CONSOLE_EXECUTABLE): $(DLL_OBJS) $(EXE_OBJS)
	$(LINKER) $(ENGINE) $(DLL_OBJS)
	$(CPP) $(LIBS) $(LIBPATH) -L. $(LINK_WITH_ENGINE) \
		$(CFLAGS) $(CFLAGS_CONSOLE) -o factor$(EXE_SUFFIX)$(CONSOLE_EXTENSION) $(EXE_OBJS)

$(TEST_LIBRARY): vmpp/ffi_test.o
	$(CC) $(LIBPATH) $(CFLAGS) $(FFI_TEST_CFLAGS) $(SHARED_FLAG) -o libfactor-ffi-test$(SHARED_DLL_EXTENSION) $(TEST_OBJS)

clean:
	rm -f vmpp/*.o
	rm -f factor*.dll libfactor.{a,so,dylib} libfactor-ffi-test.{a,so,dylib} Factor.app/Contents/Frameworks/libfactor.dylib

vmpp/resources.o:
	$(WINDRES) vmpp/factor.rs vmpp/resources.o

vmpp/ffi_test.o: vmpp/ffi_test.c
	$(CC) -c $(CFLAGS) $(FFI_TEST_CFLAGS) -o $@ $<

.c.o:
	$(CC) -c $(CFLAGS) -o $@ $<

.cpp.o:
	$(CPP) -c $(CFLAGS) -o $@ $<

.S.o:
	$(CC) -x assembler-with-cpp -c $(CFLAGS) -o $@ $<

.mm.o:
	$(CPP) -c $(CFLAGS) -o $@ $<

.PHONY: factor

.SUFFIXES: .mm
