# build-<target> or build
ifeq ($(INTEGER_ONLY),1)
BUILD_DIR ?= build-integer-only
else
BUILD_DIR ?= build
endif

ifdef CONFIG
	VERSION := 0.103
	GIT_LABEL := $(shell echo $(shell git describe --all)-$(shell git rev-parse HEAD))
	BUNDLE := Factor.app
	DEBUG ?= 0
	REPRODUCIBLE ?= 0

	SHELL_CC := $(shell printenv CC)
	ifeq ($(SHELL_CC),)
		CC := $(shell which clang cc 2>/dev/null | head -n 1)
	else
		CC := $(SHELL_CC)
	endif

	# gmake's default CXX is g++, we prefer c++
	SHELL_CXX := $(shell printenv CXX)
	ifeq ($(SHELL_CXX),)
		CXX := $(shell which clang++ c++ 2>/dev/null | head -n 1)
	else
		CXX := $(SHELL_CXX)
	endif

	IS_CLANG = $(shell $(CC) -dM -E - < /dev/null | grep -q '__clang__' && echo 1 || echo 0)

	XCODE_PATH ?= /Applications/Xcode.app
	MACOS_32_SDK ?= MacOSX10.11.sdk

	ARCHITECTURE_FLAG :=

	include $(CONFIG)

	# Aligned FFI fixtures use the current ABI for both callers and callees.
	# Suppress GCC's historical i386 ABI transition notes for this library.
	ifeq ($(IS_CLANG),0)
		ifneq ($(filter -m32,$(ARCHITECTURE_FLAG)),)
			FFI_TEST_CFLAGS += -Wno-psabi
		endif
	endif

	COMMON_FLAGS := -Wall \
		-Wextra \
		-pedantic \
		-DFACTOR_VERSION="$(VERSION)" \
		-DFACTOR_GIT_LABEL="$(GIT_LABEL)"

	ifeq ($(INTEGER_ONLY),1)
		COMMON_FLAGS += -DFACTOR_INTEGER_ONLY
	endif

	SITE_CFLAGS += $(SITE_COMMON_FLAGS)
	SITE_CXXFLAGS += $(SITE_COMMON_FLAGS)
	ASFLAGS += $(COMMON_FLAGS) $(ARCHITECTURE_FLAG)
	CFLAGS += $(SITE_CFLAGS) $(COMMON_FLAGS) $(ARCHITECTURE_FLAG)
	# Use C++20 standard
	CXX_STD := c++17
	CXXFLAGS += -std=$(CXX_STD) $(SITE_CXXFLAGS) $(COMMON_FLAGS) $(ARCHITECTURE_FLAG)
	LINKER_FLAGS += $(SITE_COMMON_LINKER_FLAGS) $(CC_OPT) $(LDFLAGS)

	# WARNINGS=1 ./build.sh compile - enable all reasonable warnings
	ifdef WARNINGS
		WARNING_FLAGS := -Wcast-align -Wcast-qual -Wwrite-strings \
			-Wconversion -Wsign-conversion -Wformat=2 -Wformat-security \
			-Wnull-dereference -Wstack-protector -Wtrampolines -Walloca \
			-Wvla -Warray-bounds=2 -Wimplicit-fallthrough=3 \
			-Wshift-overflow=2 -Wstringop-overflow=4 -Wlogical-op \
			-Wduplicated-cond -Wduplicated-branches -Wformat-signedness \
			-Wshadow -Wstrict-overflow=4 -Wundef -Wstrict-prototypes \
			-Wswitch-default -Wswitch-enum -Wstack-usage=8192 \
			-Wcast-function-type -Wdouble-promotion

		# C++ specific warnings
		CXX_WARNING_FLAGS := -Woverloaded-virtual -Wsign-promo \
			-Wstrict-null-sentinel -Wnoexcept -Wold-style-cast \
			-Wzero-as-null-pointer-constant -Wextra-semi -Wuseless-cast

		ifeq ($(IS_CLANG), 1)
			# For Clang, use -Weverything and disable specific warnings that are too noisy
			WARNING_FLAGS := -Weverything -Wno-c++98-compat -Wno-c++98-compat-pedantic \
				-Wno-padded -Wno-global-constructors -Wno-exit-time-destructors \
				-Wno-weak-vtables -Wno-poison-system-directories \
				-Wno-missing-prototypes -Wno-reserved-macro-identifier \
				-Wno-reserved-identifier -Wno-documentation -Wno-documentation-unknown-command \
				-Wno-float-equal -Wno-unused-macros -Wno-switch-enum \
				-Wno-covered-switch-default -Wno-cast-qual -Wno-unused-parameter \
				-Wno-disabled-macro-expansion -Wno-c++20-compat \
				-Wno-sign-conversion -Wno-implicit-int-float-conversion \
				-Wno-double-promotion -Wno-shadow-field-in-constructor \
				-Wno-implicit-float-conversion -Wno-shorten-64-to-32 \
				-Wno-old-style-cast -Wno-zero-as-null-pointer-constant \
				-Wno-suggest-override -Wno-suggest-destructor-override \
				-Wno-c++17-compat-mangling -Wno-comma -Wno-conditional-uninitialized \
				-Wno-unsafe-buffer-usage -Wno-date-time
			CXX_WARNING_FLAGS :=
		endif

		CFLAGS += $(WARNING_FLAGS)
		CXXFLAGS += $(WARNING_FLAGS) $(CXX_WARNING_FLAGS)
	endif

	# SANITIZER=address ./build.sh compile
	# address,thread,undefined,leak
	ifdef SANITIZER
		CFLAGS += -fsanitize=$(SANITIZER)
		CXXFLAGS += -fsanitize=$(SANITIZER)
	endif

	ifneq ($(DEBUG), 0)
		CFLAGS += -g -DFACTOR_DEBUG
		CXXFLAGS += -g -DFACTOR_DEBUG
	else
		OPTIMIZATION := -O3
		CFLAGS += $(CC_OPT) $(OPTIMIZATION)
		CXXFLAGS += $(CXX_OPT) $(OPTIMIZATION)
		ifeq ($(IS_CLANG), 1)
			LDFLAGS += -Wl,-x
			PCHFLAGS = -Winvalid-pch -include-pch $(BUILD_DIR)/master.hpp.gch
		else
			LDFLAGS += -Wl,-s
			PCHFLAGS =
		endif

	endif

	ifneq ($(REPRODUCIBLE), 0)
		CFLAGS += -DFACTOR_REPRODUCIBLE
	endif

	ENGINE := $(DLL_PREFIX)factor$(DLL_SUFFIX)$(DLL_EXTENSION)
	EXECUTABLE := factor$(EXE_SUFFIX)$(EXE_EXTENSION)
	CONSOLE_EXECUTABLE := factor$(EXE_SUFFIX)$(CONSOLE_EXTENSION)

	DLL_OBJS := $(PLAF_DLL_OBJS) \
		$(BUILD_DIR)/aging_collector.o \
		$(BUILD_DIR)/alien.o \
		$(BUILD_DIR)/arrays.o \
		$(BUILD_DIR)/atomic-netbsd-sparc.o \
		$(BUILD_DIR)/atomic-netbsd-hppa.o \
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
		$(BUILD_DIR)/ieee_float.o \
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

	MASTER_HEADERS := $(PLAF_MASTER_HEADERS) \
		$(wildcard vm/*.hpp) \
		vm/assert.hpp \
		vm/debug.hpp \
		vm/layouts.hpp \
		vm/vm_float.hpp \
		vm/ieee_binary64.hpp \
		vm/ieee_float.hpp \
		vm/ieee_float.h \
		vm/software_fp_state.hpp \
		vm/ieee_decimal.hpp \
		vm/ieee_integer.hpp \
		vm/platform.hpp \
		vm/cpu-stack-pointer-signals.hpp \
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
		vm/zstd.hpp

	EXE_OBJS := $(PLAF_EXE_OBJS)

	FFI_TEST_LIBRARY := libfactor-ffi-test$(SHARED_DLL_EXTENSION)

	TEST_OBJS := $(BUILD_DIR)/ffi_test.o
endif

# if CONFIG is not set, call build.sh and find a CONFIG
# build.sh will call GNUMakefile again to start the build
default:
	$(MAKE) $(shell ./build.sh make-target)

ifndef CONFIG
test-vm:
	$(MAKE) test-vm CONFIG=vm/Config.$(subst -,.,$(shell ./build.sh make-target))
endif

help:
	@echo "Run '$(MAKE)' with one of the following parameters:"
	@echo ""
	@echo "linux-hppa-32"
	@echo "linux-m68k-32"
	@echo "netbsd-m68k-32"
	@echo "linux-x86-32"
	@echo "linux-x86-64"
	@echo "openbsd-ppc-32"
	@echo "openbsd-ppc-64"
	@echo "linux-ppc-32"
	@echo "linux-ppc-64"
	@echo "linux-arm-32"
	@echo "linux-arm-64"
	@echo "linux-sparc-32"
	@echo "linux-sparc-64"
	@echo "linux-riscv-32"
	@echo "linux-riscv-64"
	@echo "freebsd-x86-32"
	@echo "freebsd-x86-64"
	@echo "dragonflybsd-x86-64"
	@echo "macos-x86-32"
	@echo "macos-x86-64"
	@echo "macos-x86-fat"
	@echo "macos-arm-64"
	@echo "windows-x86-32"
	@echo "windows-x86-64"
	@echo "windows-arm-64"
	@echo ""
	@echo "Additional modifiers:"
	@echo ""
	@echo "DEBUG=1  compile VM with debugging information"
	@echo "REPRODUCIBLE=1  compile VM without timestamp"
	@echo "WARNINGS=1  compile VM with comprehensive warning flags"
	@echo "SITE_CFLAGS=...  additional C optimization flags"
	@echo "SITE_CXXFLAGS=...  additional C++ optimization flags"
	@echo "INTEGER_ONLY=1    explicit no-FP mode (opaque float payloads; FP operations rejected)"
	@echo "LTO=1  compile VM with Link Time Optimization"
	@echo "X11=1  force link with X11 libraries instead of Cocoa (only on macOS)"

ALL = factor-executable factor-ffi-test factor-lib

freebsd-x86-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.freebsd.x86.32

freebsd-x86-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.freebsd.x86.64

freebsd-arm-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.freebsd.arm.32

freebsd-arm-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.freebsd.arm.64

dragonflybsd-x86-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.dragonflybsd.x86.64

netbsd-x86-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.netbsd.x86.32

netbsd-x86-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.netbsd.x86.64

netbsd-arm-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.netbsd.arm.32
	/usr/sbin/paxctl +m factor

netbsd-arm-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.netbsd.arm.64

netbsd-riscv-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.netbsd.riscv.64

openbsd-x86-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.openbsd.x86.32

openbsd-x86-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.openbsd.x86.64

openbsd-arm-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.openbsd.arm.64

openbsd-riscv-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.openbsd.riscv.64

freebsd-riscv-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.freebsd.riscv.64

macos-x86-32:
	$(MAKE) $(ALL) macos.app CONFIG=vm/Config.macos.x86.32

macos-x86-64:
	$(MAKE) $(ALL) macos.app CONFIG=vm/Config.macos.x86.64

macos-x86-fat:
	$(MAKE) $(ALL) macos.app CONFIG=vm/Config.macos.x86.fat

macos-arm-64:
	$(MAKE) $(ALL) macos.app CONFIG=vm/Config.macos.arm.64

netbsd-m68k-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.netbsd.m68k.32

linux-hppa-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.hppa.32
netbsd-sh3-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.netbsd.sh3.32

linux-sh4-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.sh4.32

linux-m68k-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.m68k.32

linux-arm-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.arm.32

linux-arm-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.arm.64

linux-s390x:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.s390x

linux-sparc-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.sparc.32

linux-sparc-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.sparc.64

linux-riscv-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.riscv.32

linux-loongarch-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.loongarch.64

linux-riscv-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.riscv.64

linux-x86-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.x86.32

linux-x86-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.x86.64

openbsd-ppc-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.openbsd.ppc.32

.PHONY: openbsd-ppc-64
openbsd-ppc-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.openbsd.ppc.64

.PHONY: netbsd-ppc-32
netbsd-ppc-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.netbsd.ppc.32

freebsd-ppc-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.freebsd.ppc.32

freebsd-ppc-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.freebsd.ppc.64

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

windows-arm-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.windows.arm.64
	$(MAKE) factor-console CONFIG=vm/Config.windows.arm.64

# Actually build Factor
ifdef CONFIG

$(BUILD_DIR):
	@echo BUILD_DIR: $(BUILD_DIR)
	@mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/master.hpp.gch: vm/master.hpp $(MASTER_HEADERS) | $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)$(CXX) -c -x c++-header $(CXXFLAGS) -o $@ $<

ifeq ($(NO_PCH),1)
PCH_DEPENDENCY :=
PCHFLAGS :=
else
PCH_DEPENDENCY := $(BUILD_DIR)/master.hpp.gch
endif

$(BUILD_DIR)/math.o: vm/mips-soft-float.hpp
$(BUILD_DIR)/ieee_float.o: CXXFLAGS += -fno-exceptions -fno-rtti
$(BUILD_DIR)/ieee_float.o: vm/ieee_float.cpp vm/ieee_float.h vm/ieee_float.hpp | $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)$(CXX) -c $(CXXFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: vm/%.cpp $(PCH_DEPENDENCY) | $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)$(CXX) -c $(CXXFLAGS) $(PCHFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: vm/%.mm $(BUILD_DIR)/master.hpp.gch | $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)$(CXX) -c $(CXXFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: vm/%.S | $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)$(CC) -c $(ASFLAGS) -o $@ $<

$(FFI_TEST_LIBRARY): $(BUILD_DIR)/ffi_test.o | $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)$(CC) $(CFLAGS) $(FFI_TEST_CFLAGS) $(SHARED_FLAG) -o $@ $(TEST_OBJS)

$(BUILD_DIR)/resources.o: vm/factor.rs | $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)$(WINDRES) --preprocessor=cat $< $@

$(BUILD_DIR)/ffi_test.o: vm/ffi_test.c vm/ffi_test.h vm/ffi_test_features.h vm/ffi_test_small.h vm/ffi_test_arm64.c vm/ffi_test_arm64.h vm/tests/ffi_uint_callback.c vm/tests/ffi_array_struct.c vm/tests/ffi_fp_status.c vm/mips-soft-float.hpp vm/ffi_test_varargs.c vm/ffi_test_varargs.h vm/ffi_test_varargs_outgoing.c vm/ffi_test_varargs_promotions.c vm/ffi_test_arm64_unions.c vm/ffi_test_riscv.c | $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)$(CC) -c $(CFLAGS) $(FFI_TEST_CFLAGS) -std=c99 -o $@ $<

macos.app: $(EXECUTABLE)
	mkdir -p $(BUNDLE)/Contents/MacOS
	mkdir -p $(BUNDLE)/Contents/Frameworks
	mv $(EXECUTABLE) $(BUNDLE)/Contents/MacOS/factor
	ln -s $(BUNDLE)/Contents/MacOS/factor ./factor
	codesign --force --sign - $(BUNDLE)

$(ENGINE): $(DLL_OBJS)
ifeq ($(IS_CLANG), 1)
	$(TOOLCHAIN_PREFIX)$(LINKER) $(ENGINE) $(LINKER_FLAGS) $(DLL_OBJS)
else
	$(TOOLCHAIN_PREFIX)$(LINKER) $(ENGINE) $(DLL_OBJS)
endif

factor-lib: $(ENGINE)

factor-executable: $(EXECUTABLE)

$(EXECUTABLE): $(EXE_OBJS) $(DLL_OBJS)
	$(TOOLCHAIN_PREFIX)$(CXX) -L. $(DLL_OBJS) $(CXXFLAGS) $(LDFLAGS) -o $@ $(LIBS) $(EXE_OBJS)

factor-console: $(CONSOLE_EXECUTABLE)

ifneq ($(CONSOLE_EXECUTABLE),$(EXECUTABLE))

$(CONSOLE_EXECUTABLE): $(EXE_OBJS) $(DLL_OBJS)
	$(TOOLCHAIN_PREFIX)$(CXX) -L. $(DLL_OBJS) $(CXXFLAGS) $(LDFLAGS) $(CFLAGS_CONSOLE) -o $@ $(LIBS) $(EXE_OBJS)

endif

factor-ffi-test: $(FFI_TEST_LIBRARY)

$(BUILD_DIR)/gc-tests$(EXE_EXTENSION): vm/tests/gc.cpp vm/tests/jit_templates.hpp $(DLL_OBJS)
	$(TOOLCHAIN_PREFIX)$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $< $(DLL_OBJS) $(LIBS)

# Run with the same CONFIG and build flags used for the VM.
test-vm: $(BUILD_DIR)/gc-tests$(EXE_EXTENSION)
	./$(BUILD_DIR)/gc-tests$(EXE_EXTENSION)

$(BUILD_DIR)/diagnostics-tests$(EXE_EXTENSION): vm/tests/diagnostics.cpp $(DLL_OBJS)
	$(TOOLCHAIN_PREFIX)$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $< $(DLL_OBJS) $(LIBS)

.PHONY: test-diagnostics
test-diagnostics: $(BUILD_DIR)/diagnostics-tests$(EXE_EXTENSION)
	$(BUILD_DIR)/diagnostics-tests$(EXE_EXTENSION)

test-vm: test-diagnostics

$(BUILD_DIR)/riscv-tests$(EXE_EXTENSION): vm/tests/riscv.cpp vm/riscv.hpp | $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $< $(LIBS)

.PHONY: test-riscv
test-riscv: $(BUILD_DIR)/riscv-tests$(EXE_EXTENSION)
	./$(BUILD_DIR)/riscv-tests$(EXE_EXTENSION)

test-vm: test-riscv

ifneq ($(filter $(BUILD_DIR)/os-unix.o,$(DLL_OBJS)),)
$(BUILD_DIR)/unix-signals-tests$(EXE_EXTENSION): vm/tests/unix_signals.cpp $(DLL_OBJS)
	$(TOOLCHAIN_PREFIX)$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $< $(DLL_OBJS) $(LIBS)

.PHONY: test-unix-signals
test-unix-signals: $(BUILD_DIR)/unix-signals-tests$(EXE_EXTENSION)
	./$(BUILD_DIR)/unix-signals-tests$(EXE_EXTENSION)

test-vm: test-unix-signals
endif

ifneq ($(filter $(BUILD_DIR)/os-windows.o,$(DLL_OBJS)),)
$(BUILD_DIR)/windows-process-wait-tests$(EXE_EXTENSION): vm/tests/windows_process_wait.cpp vm/windows_process_wait.hpp | $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $< $(LIBS)

.PHONY: test-windows-process-wait
test-windows-process-wait: $(BUILD_DIR)/windows-process-wait-tests$(EXE_EXTENSION)
	$(BUILD_DIR)/windows-process-wait-tests$(EXE_EXTENSION)

test-vm: test-windows-process-wait
endif

$(BUILD_DIR)/ieee-bits-tests$(EXE_EXTENSION): vm/tests/ieee_bits.cpp vm/ieee_bits.hpp | $(BUILD_DIR)
	$(TOOLCHAIN_PREFIX)$(CXX) $(CXXFLAGS) -o $@ $<

.PHONY: test-ieee-bits
test-ieee-bits: $(BUILD_DIR)/ieee-bits-tests$(EXE_EXTENSION)
	./$(BUILD_DIR)/ieee-bits-tests$(EXE_EXTENSION)

.PHONY: test-ieee-float
test-ieee-float:
	$(MAKE) -f vm/tests/Makefile.ieee-float check BUILD_DIR=$(BUILD_DIR)/ieee-float CXX="$(TOOLCHAIN_PREFIX)$(CXX)" CC="$(TOOLCHAIN_PREFIX)$(CC)" CXXFLAGS="$(CXXFLAGS)" CFLAGS="$(CFLAGS)"

.SUFFIXES: .mm

endif

clean:
	@echo make clean CONFIG: $(CONFIG)
	@echo make clean BUILD_DIR: $(BUILD_DIR)
	if [ -n "$(BUILD_DIR)" ] && [ "$(BUILD_DIR)" != "/" ]; then rm -f $(BUILD_DIR)/*.o; rm -f $(BUILD_DIR)/*.gch; fi
	rm -f build/*.o
	rm -f build/*.gch
	rm -f vm/*.o
	rm -f vm/*.gch
	rm -f factor factor.com factor.exe
	rm -f factor.dll
	rm -f factor.lib
	rm -f factor.dll.lib
	rm -f libfactor.*
	rm -f libfactor-ffi-test.*
	rm -f Factor.app/Contents/Frameworks/libfactor.dylib

.PHONY: factor-executable factor-lib factor-console factor-ffi-test test-vm tags clean help macos.app
.PHONY: openbsd-ppc-32 freebsd-ppc-32 freebsd-ppc-64 netbsd-m68k-32 linux-m68k-32 dragonflybsd-x86-64 linux-riscv-32 linux-riscv-64 linux-x86-32 linux-x86-64 linux-ppc-32 linux-ppc-64 linux-arm-64 freebsd-x86-32 freebsd-x86-64 macos-x86-32 macos-x86-64 macos-x86-fat macos-arm64 windows-x86-32 windows-x86-64 windows-arm-64

.PHONY: freebsd-arm-32 netbsd-arm-32 freebsd-arm-64 netbsd-x86-32 netbsd-x86-64 netbsd-arm-64 netbsd-riscv-64 openbsd-x86-32 openbsd-x86-64 openbsd-arm-64 openbsd-riscv-64 freebsd-riscv-64
.PHONY: linux-sparc-32 linux-sparc-64

.PHONY: linux-alpha-64 netbsd-alpha-64 openbsd-alpha-64
linux-alpha-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.linux.alpha.64
netbsd-alpha-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.netbsd.alpha.64
openbsd-alpha-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.openbsd.alpha.64

netbsd-sparc-32:
	$(MAKE) $(ALL) CONFIG=vm/Config.netbsd.sparc.32

netbsd-sparc-64:
	$(MAKE) $(ALL) CONFIG=vm/Config.netbsd.sparc.64

.PHONY: netbsd-sparc-32 netbsd-sparc-64

.PHONY: linux-hppa-32
.PHONY: linux-sh4-32 netbsd-sh3-32
