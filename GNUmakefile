ifdef CONFIG
	CC = gcc
	CPP = g++

	VERSION = 0.97

	BUNDLE = Factor.app
	LIBPATH = -L/usr/X11R6/lib

	include $(CONFIG)

	CFLAGS = -Wall $(SITE_CFLAGS)

	ifdef DEBUG
		CFLAGS += -g -DFACTOR_DEBUG
	else
		CFLAGS += -O3
	endif

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
		vm/gc_info.o \
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
		vm/quotations.o \
		vm/run.o \
		vm/safepoints.o \
		vm/sampling_profiler.o \
		vm/strings.o \
		vm/to_tenured_collector.o \
		vm/tuples.o \
		vm/utilities.o \
		vm/vm.o \
		vm/words.o

	MASTER_HEADERS = $(PLAF_MASTER_HEADERS) \
		vm/assert.hpp \
		vm/layouts.hpp \
		vm/platform.hpp \
		vm/primitives.hpp \
		vm/segments.hpp \
		vm/gc_info.hpp \
		vm/contexts.hpp \
		vm/run.hpp \
		vm/objects.hpp \
		vm/sampling_profiler.hpp \
		vm/errors.hpp \
		vm/bignumint.hpp \
		vm/bignum.hpp \
		vm/booleans.hpp \
		vm/instruction_operands.hpp \
		vm/code_blocks.hpp \
		vm/bump_allocator.hpp \
		vm/bitwise_hacks.hpp \
		vm/mark_bits.hpp \
		vm/free_list.hpp \
		vm/fixup.hpp \
		vm/tuples.hpp \
		vm/free_list_allocator.hpp \
		vm/write_barrier.hpp \
		vm/object_start_map.hpp \
		vm/nursery_space.hpp \
		vm/aging_space.hpp \
		vm/tenured_space.hpp \
		vm/data_heap.hpp \
		vm/code_heap.hpp \
		vm/gc.hpp \
		vm/debug.hpp \
		vm/strings.hpp \
		vm/words.hpp \
		vm/float_bits.hpp \
		vm/io.hpp \
		vm/image.hpp \
		vm/alien.hpp \
		vm/callbacks.hpp \
		vm/dispatch.hpp \
		vm/entry_points.hpp \
		vm/safepoints.hpp \
		vm/vm.hpp \
		vm/allot.hpp \
		vm/tagged.hpp \
		vm/data_roots.hpp \
		vm/code_roots.hpp \
		vm/generic_arrays.hpp \
		vm/callstack.hpp \
		vm/slot_visitor.hpp \
		vm/collector.hpp \
		vm/copying_collector.hpp \
		vm/nursery_collector.hpp \
		vm/aging_collector.hpp \
		vm/to_tenured_collector.hpp \
		vm/code_block_visitor.hpp \
		vm/compaction.hpp \
		vm/full_collector.hpp \
		vm/arrays.hpp \
		vm/math.hpp \
		vm/byte_arrays.hpp \
		vm/jit.hpp \
		vm/quotations.hpp \
		vm/inline_cache.hpp \
		vm/mvm.hpp \
		vm/factor.hpp \
		vm/utilities.hpp

	EXE_OBJS = $(PLAF_EXE_OBJS)

	FFI_TEST_LIBRARY = libfactor-ffi-test$(SHARED_DLL_EXTENSION)

	TEST_OBJS = vm/ffi_test.o
endif

default:
	$(MAKE) `./build-support/factor.sh make-target`

help:
	@echo "Run '$(MAKE)' with one of the following parameters:"
	@echo ""
	@echo "linux-x86-32"
	@echo "linux-x86-64"
	@echo "linux-ppc-32"
	@echo "linux-ppc-64"
	@echo "linux-arm"
	@echo "macosx-x86-32"
	@echo "macosx-x86-64"
	@echo "macosx-x86-fat"
	@echo "windows-x86-32"
	@echo "windows-x86-64"
	@echo ""
	@echo "Additional modifiers:"
	@echo ""
	@echo "DEBUG=1  compile VM with debugging information"
	@echo "SITE_CFLAGS=...  additional optimization flags"
	@echo "NO_UI=1  don't link with X11 libraries (ignored on Mac OS X)"
	@echo "X11=1  force link with X11 libraries instead of Cocoa (only on Mac OS X)"

ALL = factor factor-ffi-test factor-lib

macosx-x86-32:
	$(MAKE) $(ALL) macosx.app CONFIG=vm/Config.macosx.x86.32

macosx-x86-64:
	$(MAKE) $(ALL) macosx.app CONFIG=vm/Config.macosx.x86.64

macosx-x86-fat:
	$(MAKE) $(ALL) macosx.app CONFIG=vm/Config.macosx.x86.fat

linux-x86-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.x86.32

linux-x86-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.x86.64

linux-ppc-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.ppc.32

linux-ppc-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.ppc.64

linux-arm:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.arm

windows-x86-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.windows.x86.32
	$(MAKE) factor-console CONFIG=vm/Config.windows.x86.32

windows-x86-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.windows.x86.64
	$(MAKE) factor-console CONFIG=vm/Config.windows.x86.64

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
	$(TOOLCHAIN_PREFIX)$(CPP) $(LIBPATH) -L. $(DLL_OBJS) \
		$(CFLAGS) -o $(EXECUTABLE) $(LIBS) $(EXE_OBJS)

factor-console: $(EXE_OBJS) $(DLL_OBJS)
	$(TOOLCHAIN_PREFIX)$(CPP) $(LIBPATH) -L. $(DLL_OBJS) \
		$(CFLAGS) $(CFLAGS_CONSOLE) -o $(CONSOLE_EXECUTABLE) $(LIBS) $(EXE_OBJS)

factor-ffi-test: $(FFI_TEST_LIBRARY)

$(FFI_TEST_LIBRARY): vm/ffi_test.o
	$(TOOLCHAIN_PREFIX)$(CC) $(LIBPATH) $(CFLAGS) $(FFI_TEST_CFLAGS) $(SHARED_FLAG) -o $(FFI_TEST_LIBRARY) $(TEST_OBJS)

vm/resources.o:
	$(TOOLCHAIN_PREFIX)$(WINDRES) vm/factor.rs vm/resources.o

vm/ffi_test.o: vm/ffi_test.c
	$(TOOLCHAIN_PREFIX)$(CC) -c $(CFLAGS) $(FFI_TEST_CFLAGS) -o $@ $<

vm/master.hpp.gch: vm/master.hpp $(MASTER_HEADERS)
	$(TOOLCHAIN_PREFIX)$(CPP) -c -x c++-header $(CFLAGS) -o $@ $<

%.o: %.cpp vm/master.hpp.gch
	$(TOOLCHAIN_PREFIX)$(CPP) -c $(CFLAGS) -o $@ $<

%.o: %.S
	$(TOOLCHAIN_PREFIX)$(CC) -c $(CFLAGS) -o $@ $<

%.o: %.mm vm/master.hpp.gch
	$(TOOLCHAIN_PREFIX)$(CPP) -c $(CFLAGS) -o $@ $<

.SUFFIXES: .mm

endif

clean:
	rm -f vm/*.gch
	rm -f vm/*.o
	rm -f factor.dll
	rm -f factor.lib
	rm -f factor.dll.lib
	rm -f libfactor.*
	rm -f libfactor-ffi-test.*
	rm -f Factor.app/Contents/Frameworks/libfactor.dylib

.PHONY: factor factor-lib factor-console factor-ffi-test tags clean macosx.app
