ifdef CONFIG
	CC = gcc
	CPP = g++
	AR = ar
	LD = ld

	VERSION = 0.94

	BUNDLE = Factor.app
	LIBPATH = -L/usr/X11R6/lib

	CFLAGS = -Wall $(SITE_CFLAGS)

	ifdef DEBUG
		CFLAGS += -g -DFACTOR_DEBUG
	else
		CFLAGS += -O3
	endif

	include $(CONFIG)

	ENGINE = $(DLL_PREFIX)factor$(DLL_SUFFIX)$(DLL_EXTENSION)
	EXECUTABLE = factor$(EXE_SUFFIX)$(EXE_EXTENSION)
	CONSOLE_EXECUTABLE = factor$(EXE_SUFFIX)$(CONSOLE_EXTENSION)

	DLL_OBJS = $(PLAF_DLL_OBJS) \
		vm/aging_collector.o \
		vm/alien.o \
		vm/arrays.o \
		vm/bignum.o \
		vm/booleans.o \
		vm/byte_arrays.o \
		vm/callbacks.o \
		vm/callstack.o \
		vm/code_blocks.o \
		vm/code_heap.o \
		vm/compaction.o \
		vm/contexts.o \
		vm/data_heap.o \
		vm/data_heap_checker.o \
		vm/debug.o \
		vm/dispatch.o \
		vm/entry_points.o \
		vm/errors.o \
		vm/factor.o \
		vm/free_list.o \
		vm/full_collector.o \
		vm/gc.o \
		vm/image.o \
		vm/inline_cache.o \
		vm/instruction_operands.o \
		vm/io.o \
		vm/jit.o \
		vm/math.o \
		vm/mvm.o \
		vm/nursery_collector.o \
		vm/object_start_map.o \
		vm/objects.o \
		vm/primitives.o \
		vm/profiler.o \
		vm/quotations.o \
		vm/run.o \
		vm/strings.o \
		vm/to_tenured_collector.o \
		vm/tuples.o \
		vm/utilities.o \
	        vm/vm.o \
		vm/words.o

	EXE_OBJS = $(PLAF_EXE_OBJS)

	FFI_TEST_LIBRARY = libfactor-ffi-test$(SHARED_DLL_EXTENSION)

	TEST_OBJS = vm/ffi_test.o
endif

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

ALL = factor factor-ffi-test factor-lib

openbsd-x86-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.openbsd.x86.32

openbsd-x86-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.openbsd.x86.64

freebsd-x86-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.freebsd.x86.32

freebsd-x86-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.freebsd.x86.64

netbsd-x86-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.netbsd.x86.32

netbsd-x86-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.netbsd.x86.64

macosx-ppc:
	$(MAKE) $(ALL) macosx.app CONFIG=vm/Config.macosx.ppc

macosx-x86-32:
	$(MAKE) $(ALL) macosx.app CONFIG=vm/Config.macosx.x86.32

macosx-x86-64:
	$(MAKE) $(ALL) macosx.app CONFIG=vm/Config.macosx.x86.64

linux-x86-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.x86.32

linux-x86-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.x86.64

linux-ppc:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.ppc

linux-arm:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.arm

solaris-x86-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.solaris.x86.32

solaris-x86-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.solaris.x86.64

winnt-x86-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.windows.nt.x86.32
	$(MAKE) factor-console CONFIG=vm/Config.windows.nt.x86.32

winnt-x86-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.windows.nt.x86.64
	$(MAKE) factor-console CONFIG=vm/Config.windows.nt.x86.64

wince-arm:
	$(MAKE) $(ALL) CONFIG=vm/Config.windows.ce.arm

ifdef CONFIG

macosx.app: factor
	mkdir -p $(BUNDLE)/Contents/MacOS
	mkdir -p $(BUNDLE)/Contents/Frameworks
	mv $(EXECUTABLE) $(BUNDLE)/Contents/MacOS/factor
	ln -s Factor.app/Contents/MacOS/factor ./factor

$(ENGINE): $(DLL_OBJS)
	$(TOOLCHAIN_PREFIX)$(LINKER) $(ENGINE) $(DLL_OBJS)

factor-lib: $(ENGINE)

factor: $(EXE_OBJS) $(DLL_OBJS)
	$(TOOLCHAIN_PREFIX)$(CPP) $(LIBS) $(LIBPATH) -L. $(DLL_OBJS) \
		$(CFLAGS) -o $(EXECUTABLE) $(EXE_OBJS)

factor-console: $(EXE_OBJS) $(DLL_OBJS)
	$(TOOLCHAIN_PREFIX)$(CPP) $(LIBS) $(LIBPATH) -L. $(DLL_OBJS) \
		$(CFLAGS) $(CFLAGS_CONSOLE) -o $(CONSOLE_EXECUTABLE) $(EXE_OBJS)

factor-ffi-test: $(FFI_TEST_LIBRARY)

$(FFI_TEST_LIBRARY): vm/ffi_test.o
	$(TOOLCHAIN_PREFIX)$(CC) $(LIBPATH) $(CFLAGS) $(FFI_TEST_CFLAGS) $(SHARED_FLAG) -o $(FFI_TEST_LIBRARY) $(TEST_OBJS)

vm/resources.o:
	$(TOOLCHAIN_PREFIX)$(WINDRES) vm/factor.rs vm/resources.o

vm/ffi_test.o: vm/ffi_test.c
	$(TOOLCHAIN_PREFIX)$(CC) -c $(CFLAGS) $(FFI_TEST_CFLAGS) -o $@ $<

.cpp.o:
	$(TOOLCHAIN_PREFIX)$(CPP) -c $(CFLAGS) -o $@ $<

.S.o:
	$(TOOLCHAIN_PREFIX)$(CC) -x assembler-with-cpp -c $(CFLAGS) -o $@ $<

.mm.o:
	$(TOOLCHAIN_PREFIX)$(CPP) -c $(CFLAGS) -o $@ $<

.SUFFIXES: .mm

endif

clean:
	rm -f vm/*.o
	rm -f factor.dll
	rm -f factor.lib
	rm -f factor.dll.lib
	rm -f libfactor.*
	rm -f libfactor-ffi-test.*
	rm -f Factor.app/Contents/Frameworks/libfactor.dylib

tags:
	etags vm/*.{cpp,hpp,mm,S,c}

.PHONY: factor factor-lib factor-console factor-ffi-test tags clean macosx.app
