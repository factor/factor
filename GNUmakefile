# build-<target> or build
BUILD_DIR ?= build

ifdef CONFIG
	VERSION = 0.100
	GIT_LABEL = $(shell echo `git describe --all`-`git rev-parse HEAD`)
	BUNDLE = Factor.app
	DEBUG ?= 0
	REPRODUCIBLE ?= 0

	SHELL_CC = $(shell printenv CC)
	ifeq ($(SHELL_CC),)
		CC := $(shell which clang cc 2>/dev/null | head -n 1)
	else
		CC = $(SHELL_CC)
	endif

	# gmake's default CXX is g++, we prefer c++
	SHELL_CXX = $(shell printenv CXX)
	ifeq ($(SHELL_CXX),)
		CXX := $(shell which clang++ c++ 2>/dev/null | head -n 1)
	else
		CXX = $(SHELL_CXX)
	endif

	XCODE_PATH ?= /Applications/Xcode.app
	MACOSX_32_SDK ?= MacOSX10.11.sdk

	include $(CONFIG)

	CFLAGS += -Wall \
		-Wextra \
		-pedantic \
		-Wno-unused-command-line-argument \
		-DFACTOR_VERSION="$(VERSION)" \
		-DFACTOR_GIT_LABEL="$(GIT_LABEL)" \
		$(SITE_CFLAGS)

	CXXFLAGS += -std=c++11

	# SANITIZER=address ./build.sh compile
	# address,thread,undefined,leak
	ifdef SANITIZER
		CFLAGS += -fsanitize=$(SANITIZER)
		CXXFLAGS += -fsanitize=$(SANITIZER)
	endif

	ifneq ($(DEBUG), 0)
		CFLAGS += -g -DFACTOR_DEBUG
	else
		CFLAGS += -O3
		CFLAGS += -Wl,-s
		CFLAGS += $(CC_OPT)
	endif

	ifneq ($(REPRODUCIBLE), 0)
		CFLAGS += -DFACTOR_REPRODUCIBLE
	endif

	ENGINE = $(DLL_PREFIX)factor$(DLL_SUFFIX)$(DLL_EXTENSION)
	EXECUTABLE = factor$(EXE_SUFFIX)$(EXE_EXTENSION)
	CONSOLE_EXECUTABLE = factor$(EXE_SUFFIX)$(CONSOLE_EXTENSION)

	DLL_OBJS = $(PLAF_DLL_OBJS) \
		$(BUILD_DIR)/aging_collector.o \
		$(BUILD_DIR)/alien.o \
		$(BUILD_DIR)/arrays.o \
		$(BUILD_DIR)/bignum.o \
		$(BUILD_DIR)/byte_arrays.o \
		$(BUILD_DIR)/callbacks.o \
		$(BUILD_DIR)/callstack.o \
		$(BUILD_DIR)/code_blocks.o \
		$(BUILD_DIR)/code_heap.o \
		$(BUILD_DIR)/compaction.o \
		$(BUILD_DIR)/contexts.o \
		$(BUILD_DIR)/data_heap.o \
		$(BUILD_DIR)/data_heap_checker.o \
		$(BUILD_DIR)/debug.o \
		$(BUILD_DIR)/dispatch.o \
		$(BUILD_DIR)/entry_points.o \
		$(BUILD_DIR)/errors.o \
		$(BUILD_DIR)/factor.o \
		$(BUILD_DIR)/full_collector.o \
		$(BUILD_DIR)/gc.o \
		$(BUILD_DIR)/image.o \
		$(BUILD_DIR)/inline_cache.o \
		$(BUILD_DIR)/instruction_operands.o \
		$(BUILD_DIR)/io.o \
		$(BUILD_DIR)/jit.o \
		$(BUILD_DIR)/math.o \
		$(BUILD_DIR)/mvm.o \
		$(BUILD_DIR)/nursery_collector.o \
		$(BUILD_DIR)/object_start_map.o \
		$(BUILD_DIR)/objects.o \
		$(BUILD_DIR)/primitives.o \
		$(BUILD_DIR)/quotations.o \
		$(BUILD_DIR)/run.o \
		$(BUILD_DIR)/safepoints.o \
		$(BUILD_DIR)/sampling_profiler.o \
		$(BUILD_DIR)/strings.o \
		$(BUILD_DIR)/to_tenured_collector.o \
		$(BUILD_DIR)/tuples.o \
		$(BUILD_DIR)/utilities.o \
		$(BUILD_DIR)/vm.o \
		$(BUILD_DIR)/words.o \
		$(BUILD_DIR)/zstd.o

	MASTER_HEADERS = $(PLAF_MASTER_HEADERS) \
		vm/assert.hpp \
		vm/debug.hpp \
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
		vm/write_barrier.hpp \
		vm/object_start_map.hpp \
		vm/aging_space.hpp \
		vm/tenured_space.hpp \
		vm/data_heap.hpp \
		vm/code_heap.hpp \
		vm/gc.hpp \
		vm/float_bits.hpp \
		vm/io.hpp \
		vm/image.hpp \
		vm/callbacks.hpp \
		vm/dispatch.hpp \
		vm/vm.hpp \
		vm/allot.hpp \
		vm/tagged.hpp \
		vm/data_roots.hpp \
		vm/code_roots.hpp \
		vm/generic_arrays.hpp \
		vm/callstack.hpp \
		vm/slot_visitor.hpp \
		vm/to_tenured_collector.hpp \
		vm/arrays.hpp \
		vm/math.hpp \
		vm/byte_arrays.hpp \
		vm/jit.hpp \
		vm/quotations.hpp \
		vm/inline_cache.hpp \
		vm/mvm.hpp \
		vm/factor.hpp \
		vm/utilities.hpp \
		vm/zstd.hpp vm/zstd.h

	EXE_OBJS = $(PLAF_EXE_OBJS)

	FFI_TEST_LIBRARY = libfactor-ffi-test$(SHARED_DLL_EXTENSION)

	TEST_OBJS = $(BUILD_DIR)/ffi_test.o
endif

# if CONFIG is not set, call build.sh and find a CONFIG
# build.sh will call GNUMakefile again to start the build
default:
	$(MAKE) `./build.sh make-target`

help:
	@echo "Run '$(MAKE)' with one of the following parameters:"
	@echo ""
	@echo "linux-x86-32"
	@echo "linux-x86-64"
	@echo "linux-ppc-32"
	@echo "linux-ppc-64"
	@echo "linux-arm-32"
	@echo "linux-arm-64"
	@echo "freebsd-x86-32"
	@echo "freebsd-x86-64"
	@echo "macosx-x86-32"
	@echo "macosx-x86-64"
	@echo "macosx-x86-fat"
	@echo "macosx-arm-64"
	@echo "windows-x86-32"
	@echo "windows-x86-64"
	@echo ""
	@echo "Additional modifiers:"
	@echo ""
	@echo "DEBUG=1  compile VM with debugging information"
	@echo "REPRODUCIBLE=1  compile VM without timestamp"
	@echo "SITE_CFLAGS=...  additional optimization flags"
	@echo "LTO=1  compile VM with Link Time Optimization"
	@echo "X11=1  force link with X11 libraries instead of Cocoa (only on Mac OS X)"

ALL = factor factor-ffi-test factor-lib

freebsd-x86-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.freebsd.x86.32

freebsd-x86-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.freebsd.x86.64

macosx-x86-32:
	$(MAKE) $(ALL) macosx.app CONFIG=vm/Config.macosx.x86.32

macosx-x86-64:
	$(MAKE) $(ALL) macosx.app CONFIG=vm/Config.macosx.x86.64

macosx-x86-fat:
	$(MAKE) $(ALL) macosx.app CONFIG=vm/Config.macosx.x86.fat

macosx-arm-64:
	$(MAKE) $(ALL) macosx.app CONFIG=vm/Config.macosx.arm.64

linux-arm-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.arm.32

linux-arm-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.arm.64

linux-x86-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.x86.32

linux-x86-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.x86.64

linux-ppc-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.ppc.32

linux-ppc-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.ppc.64

windows-x86-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.windows.x86.32
	$(MAKE) factor-console CONFIG=vm/Config.windows.x86.32

windows-x86-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.windows.x86.64
	$(MAKE) factor-console CONFIG=vm/Config.windows.x86.64

# Actually build Factor
ifdef CONFIG

macosx.app: factor
	mkdir -p $(BUNDLE)/Contents/MacOS
	mkdir -p $(BUNDLE)/Contents/Frameworks
	mv $(EXECUTABLE) $(BUNDLE)/Contents/MacOS/factor
	ln -s $(BUNDLE)/Contents/MacOS/factor ./factor

$(ENGINE): $(DLL_OBJS)
	$(TOOLCHAIN_PREFIX)$(LINKER) $(ENGINE) $(DLL_OBJS)

factor-lib: $(ENGINE)

factor: $(EXE_OBJS) $(DLL_OBJS)
	$(TOOLCHAIN_PREFIX)$(CXX) -L. $(DLL_OBJS) \
		$(CFLAGS) $(CXXFLAGS) -o $(EXECUTABLE) $(LIBS) $(EXE_OBJS)

factor-console: $(EXE_OBJS) $(DLL_OBJS)
	$(TOOLCHAIN_PREFIX)$(CXX) -L. $(DLL_OBJS) \
		$(CFLAGS) $(CXXFLAGS) $(CFLAGS_CONSOLE) -o $(CONSOLE_EXECUTABLE) $(LIBS) $(EXE_OBJS)

factor-ffi-test: $(FFI_TEST_LIBRARY)

$(BUILD_DIR):
	@echo BUILD_DIR: $(BUILD_DIR)
	@mkdir -p $(BUILD_DIR)

$(FFI_TEST_LIBRARY): $(BUILD_DIR)/ffi_test.o | $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)$(CC) $(CFLAGS) $(FFI_TEST_CFLAGS) $(SHARED_FLAG) -o $(FFI_TEST_LIBRARY) $(TEST_OBJS)

$(BUILD_DIR)/resources.o: vm/factor.rs | $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)$(WINDRES) --preprocessor=cat $< $@

$(BUILD_DIR)/ffi_test.o: vm/ffi_test.c | $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)$(CC) -c $(CFLAGS) $(FFI_TEST_CFLAGS) -std=c99 -o $@ $<

$(BUILD_DIR)/master.hpp.gch: vm/master.hpp $(MASTER_HEADERS) | $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)$(CXX) -c -x c++-header $(CFLAGS) $(CXXFLAGS) -o $@ $<

$(BUILD_DIR)/zstd.o: vm/zstd.cpp vm/zstd.c $(BUILD_DIR)/master.hpp.gch | $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)$(CXX) -c $(CFLAGS) $(CXXFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: vm/%.cpp $(BUILD_DIR)/master.hpp.gch | $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)$(CXX) -c $(CFLAGS) $(CXXFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: $(BUILD_DIR)/%.S | $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)$(CC) -c $(CFLAGS) $(CXXFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: vm/%.mm $(BUILD_DIR)/master.hpp.gch | $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)$(CXX) -c $(CFLAGS) $(CXXFLAGS) -o $@ $<

.SUFFIXES: .mm

endif

clean:
	@echo make clean CONFIG: \`$(CONFIG)\`
	@echo make clean BUILD_DIR: \`$(BUILD_DIR)\`
	if [ -n "$(BUILD_DIR)" ] && [ "$(BUILD_DIR)" != "/" ]; then rm -f $(BUILD_DIR)/*.o; rm -f $(BUILD_DIR)/*.gch; fi
	rm -f build/*.o
	rm -f build/*.gch
	rm -f vm/*.o
	rm -f vm/*.gch
	rm -f factor
	rm -f factor.dll
	rm -f factor.lib
	rm -f factor.dll.lib
	rm -f libfactor.*
	rm -f libfactor-ffi-test.*
	rm -f Factor.app/Contents/Frameworks/libfactor.dylib

.PHONY: factor factor-lib factor-console factor-ffi-test tags clean help macosx.app
.PHONY: linux-x86-32 linux-x86-64 linux-ppc-32 linux-ppc-64 linux-arm-64 freebsd-x86-32 freebsd-x86-64 macosx-x86-32 macosx-x86-64 macosx-x86-fat macosx-arm64 windows-x86-32 windows-x86-64
