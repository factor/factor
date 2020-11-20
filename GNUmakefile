ARCH = $(shell uname -m)
$(info TARGET is $(TARGET))


ifdef $$TARGET
	OUTPUT_DIR ?= vm-$(TARGET)
else
	OUTPUT_DIR ?= vm-$(ARCH)
endif

ifdef CONFIG
	VERSION = 0.99
	GIT_LABEL = $(shell echo `git describe --all`-`git rev-parse HEAD`)
	GIT_BRANCH = $(shell git describe --all --exact-match 2>/dev/null | sed 's=.*/==')
	#$(info GIT_BRANCH123 is $(GIT_BRANCH))

	ifeq (${ARCH},arm64)
		BUNDLE = Factor-arm64.app
		FACTOR = factor-arm64
	else
		BUNDLE = Factor.app
		FACTOR = factor
	endif

	DEBUG ?= 0
	REPRODUCIBLE ?= 0

	# gmake's default CXX is g++, we prefer c++
	SHELL_CXX = $(shell printenv CXX)
	ifeq ($(SHELL_CXX),)
		CXX=c++
	else
		CXX=$(SHELL_CXX)
	endif

	XCODE_PATH ?= /Applications/Xcode.app
	MACOSX_32_SDK ?= MacOSX10.11.sdk

	include $(CONFIG)

	CFLAGS += -Wall \
		-pedantic \
		-DFACTOR_VERSION="$(VERSION)" \
		-DFACTOR_GIT_LABEL="$(GIT_LABEL)" \
		$(SITE_CFLAGS)

	# c++2a if supported
	CXXFLAGS += -std=c++11

	ifneq ($(DEBUG), 0)
		CFLAGS += -g -DFACTOR_DEBUG
	else
		CFLAGS += -O3
	endif

	ifneq ($(REPRODUCIBLE), 0)
		CFLAGS += -DFACTOR_REPRODUCIBLE
	endif

	ENGINE = $(OUTPUT_DIR)/$(DLL_PREFIX)$(FACTOR)$(DLL_SUFFIX)$(DLL_EXTENSION)
	EXECUTABLE = $(OUTPUT_DIR)/$(FACTOR)$(EXE_SUFFIX)$(EXE_EXTENSION)
	CONSOLE_EXECUTABLE = $(OUTPUT_DIR)/$(FACTOR)$(EXE_SUFFIX)$(CONSOLE_EXTENSION)

	DLL_SRCS = $(PLAF_DLL_SRCS) \
		vm/aging_collector.cpp \
		vm/alien.cpp \
		vm/arrays.cpp \
		vm/bignum.cpp \
		vm/byte_arrays.cpp \
		vm/callbacks.cpp \
		vm/callstack.cpp \
		vm/code_blocks.cpp \
		vm/code_heap.cpp \
		vm/compaction.cpp \
		vm/contexts.cpp \
		vm/data_heap.cpp \
		vm/data_heap_checker.cpp \
		vm/debug.cpp \
		vm/dispatch.cpp \
		vm/entry_points.cpp \
		vm/errors.cpp \
		vm/factor.cpp \
		vm/full_collector.cpp \
		vm/gc.cpp \
		vm/image.cpp \
		vm/inline_cache.cpp \
		vm/instruction_operands.cpp \
		vm/io.cpp \
		vm/jit.cpp \
		vm/math.cpp \
		vm/mvm.cpp \
		vm/nursery_collector.cpp \
		vm/object_start_map.cpp \
		vm/objects.cpp \
		vm/primitives.cpp \
		vm/quotations.cpp \
		vm/run.cpp \
		vm/safepoints.cpp \
		vm/sampling_profiler.cpp \
		vm/strings.cpp \
		vm/to_tenured_collector.cpp \
		vm/tuples.cpp \
		vm/utilities.cpp \
		vm/vm.cpp \
		vm/words.cpp
	
	DLL_OBJS = $(DLL_SRCS:vm/%.cpp=$(OUTPUT_DIR)/%.o)

	MASTER_HEADERS = $(PLAF_MASTER_HEADERS) \
		vm/aging_space.hpp \
		vm/allot.hpp \
		vm/arrays.hpp \
		vm/assert.hpp \
		vm/bignum.hpp \
		vm/bignumint.hpp \
		vm/bitwise_hacks.hpp \
		vm/booleans.hpp \
		vm/bump_allocator.hpp \
		vm/byte_arrays.hpp \
		vm/callbacks.hpp \
		vm/callstack.hpp  \
		vm/code_blocks.hpp \
		vm/code_heap.hpp \
		vm/code_roots.hpp \
		vm/contexts.hpp \
		vm/data_heap.hpp \
		vm/data_roots.hpp \
		vm/debug.hpp \
		vm/dispatch.hpp \
		vm/errors.hpp \
		vm/factor.hpp \
		vm/fixup.hpp \
		vm/float_bits.hpp \
		vm/free_list.hpp \
		vm/gc.hpp \
		vm/gc_info.hpp \
		vm/generic_arrays.hpp \
		vm/image.hpp \
		vm/inline_cache.hpp \
		vm/instruction_operands.hpp \
		vm/io.hpp \
		vm/jit.hpp \
		vm/layouts.hpp \
		vm/mark_bits.hpp \
		vm/math.hpp \
		vm/mvm.hpp \
		vm/object_start_map.hpp \
		vm/objects.hpp \
		vm/platform.hpp \
		vm/primitives.hpp \
		vm/quotations.hpp \
		vm/run.hpp \
		vm/sampling_profiler.hpp \
		vm/segments.hpp \
		vm/slot_visitor.hpp \
		vm/tagged.hpp \
		vm/tenured_space.hpp \
		vm/to_tenured_collector.hpp \
		vm/utilities.hpp \
		vm/vm.hpp \
		vm/write_barrier.hpp

	EXE_SRCS = $(PLAF_EXE_SRCS)

	EXE_OBJS = $(EXE_SRCS:vm/%.cpp=$(OUTPUT_DIR)/%.o)

	FFI_TEST_LIBRARY = $(OUTPUT_DIR)/libfactor-ffi-test$(SHARED_DLL_EXTENSION)

	TEST_SRCS = vm/ffi_test.c
	TEST_OBJS = $(TEST_SRCS:vm/%.c=$(OUTPUT_DIR)/%.o)

	EXECUTABLE_FILES = $(EXECUTABLE) $(CONSOLE_EXECUTABLE)
endif

$(info OUTPUT_DIR is $(OUTPUT_DIR))
$(info ENGINE is $(ENGINE))
$(info FFI_TEST_LIBRARY is $(FFI_TEST_LIBRARY))

$(info EXE_SRCS is $(EXE_SRCS))
$(info EXE_OBJS is $(EXE_OBJS))
$(info DLL_SRCS is $(DLL_SRCS))
$(info DLL_OBJS is $(DLL_OBJS))
$(info TEST_SRCS is $(TEST_SRCS))
$(info TEST_OBJS is $(TEST_OBJS))
$(info EXECUTABLE_FILES is $(EXECUTABLE_FILES))
$(info CONFIG is $(CONFIG))
$(info default goal $(.DEFAULT_GOAL))
$(info MAKECMDGOALS is $(MAKECMDGOALS))
$(info BUNDLE is $(BUNDLE))
$(info FACTOR is $(FACTOR))
$(info $$ARCH is [[${ARCH}]])
$(info $$TARGET is [[${TARGET}]])
# make -pnr

default: $(OUTPUT_DIR) printvars
	$(MAKE) `./build.sh make-target`

$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

printvars:
	@$(foreach V,$(sort $(.VARIABLES)), $(if $(filter-out environment% default automatic, $(origin $V)),$(warning $V=$($V) ($(value $V)))))

help:
	@echo "Run '$(MAKE)' with one of the following parameters:"
	@echo ""
	@echo "linux-x86-32"
	@echo "linux-x86-64"
	@echo "linux-ppc-32"
	@echo "linux-ppc-64"
	@echo "linux-arm"
	@echo "freebsd-x86-32"
	@echo "freebsd-x86-64"
	@echo "macosx-x86-32"
	@echo "macosx-x86-64"
	@echo "macosx-x86-fat"
	@echo "macosx-arm64-64"
	@echo "windows-x86-32"
	@echo "windows-x86-64"
	@echo ""
	@echo "Additional modifiers:"
	@echo ""
	@echo "DEBUG=1  compile VM with debugging information"
	@echo "REPRODUCIBLE=1  compile VM without timestamp"
	@echo "SITE_CFLAGS=...  additional optimization flags"
	@echo "X11=1  force link with X11 libraries instead of Cocoa (only on Mac OS X)"

ALL = $(OUTPUT_DIR)/factor $(OUTPUT_DIR)/factor-ffi-test $(OUTPUT_DIR)/factor-lib

$(info ALL is $(ALL))


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

macosx-arm64-64:
	$(MAKE) $(ALL) macosx.app CONFIG=vm/Config.macosx.arm64.64

linux-x86-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.x86.32

linux-x86-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.x86.64

linux-ppc-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.ppc.32

linux-ppc-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.ppc.64

linux-arm-64: printvars
	$(info calling make with: $(MAKE) $(ALL) CONFIG=vm/Config.linux.arm.64)
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.arm.64

windows-x86-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.windows.x86.32
	$(MAKE) factor-console CONFIG=vm/Config.windows.x86.32

windows-x86-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.windows.x86.64
	$(MAKE) factor-console CONFIG=vm/Config.windows.x86.64


ifdef CONFIG

macosx.app: $(OUTPUT_DIR)/factor
	mkdir -p $(BUNDLE)/Contents/MacOS
	mkdir -p $(BUNDLE)/Contents/Frameworks
	cp $(EXECUTABLE) $(BUNDLE)/Contents/MacOS/factor
	ln -s $(BUNDLE)/Contents/MacOS/factor ./$(FACTOR)

$(OUTPUT_DIR)/$(ENGINE): $(DLL_OBJS)
	$(TOOLCHAIN_PREFIX)$(LINKER) $(ENGINE) $(DLL_OBJS)

$(OUTPUT_DIR)/factor-lib: $(OUTPUT_DIR)/$(ENGINE)

$(OUTPUT_DIR)/factor: $(EXE_OBJS) $(DLL_OBJS)
	$(TOOLCHAIN_PREFIX)$(CXX) -L. $(DLL_OBJS) \
		$(TARGET) $(CFLAGS) $(CXXFLAGS) -o $(EXECUTABLE) $(LIBS) $(EXE_OBJS)

$(OUTPUT_DIR)/factor-console: $(EXE_OBJS) $(DLL_OBJS)
	$(TOOLCHAIN_PREFIX)$(CXX) -L. $(DLL_OBJS) \
		$(TARGET) $(CFLAGS) $(CXXFLAGS) $(CFLAGS_CONSOLE) -o $(CONSOLE_EXECUTABLE) $(LIBS) $(EXE_OBJS)

$(OUTPUT_DIR)/factor-ffi-test: $(FFI_TEST_LIBRARY)

$(FFI_TEST_LIBRARY): $(OUTPUT_DIR)/ffi_test.o
	$(TOOLCHAIN_PREFIX)$(CC) $(CFLAGS) $(FFI_TEST_CFLAGS) $(SHARED_FLAG) -o $(FFI_TEST_LIBRARY) $(TEST_OBJS)

$(OUTPUT_DIR)/resources.o:
	$(TOOLCHAIN_PREFIX)$(WINDRES) vm/factor.rs $(OUTPUT_DIR)/resources.o

vm/master.hpp.gch: vm/master.hpp $(MASTER_HEADERS)
	$(TOOLCHAIN_PREFIX)$(CXX) -c -x c++-header $(CFLAGS) $(CXXFLAGS) -o $@ $<

$(DLL_OBJS): $(OUTPUT_DIR)/%.o: vm/%.cpp vm/master.hpp.gch $(OUTPUT_DIR)
	$(TOOLCHAIN_PREFIX)$(CXX) -c $(TARGET) $(CFLAGS) $(CXXFLAGS) -o $@ $<

$(EXE_OBJS): $(OUTPUT_DIR)/%.o: vm/%.cpp vm/master.hpp.gch $(OUTPUT_DIR)
	$(TOOLCHAIN_PREFIX)$(CXX) -c $(TARGET) $(CFLAGS) $(CXXFLAGS) -o $@ $<

$(TEST_OBJS): $(OUTPUT_DIR)/%.o: vm/%.c $(OUTPUT_DIR)
	$(TOOLCHAIN_PREFIX)$(CC) -c $(TARGET) $(CFLAGS) $(FFI_TEST_CFLAGS) -std=c99 -o $@ $<

#.SUFFIXES: .mm

endif

clean:
	rm -f $(OUTPUT_DIR)/*.gch
	rm -f $(OUTPUT_DIR)/*.o
	rm -f factor.dll
	rm -f factor.lib
	rm -f factor.dll.lib
	rm -f libfactor.*
	rm -f libfactor-ffi-test.*
	rm -f factor
	rm -f factor-arm64
	rm -f factor-intel
	rm -f Factor.app/Contents/Frameworks/libfactor.dylib
	rm -f Factor-arm64.app/Contents/Frameworks/libfactor.dylib

.PHONY: factor factor-lib factor-console factor-ffi-test tags clean macosx.app printvars
