// main.zig - Factor VM entry point

const std = @import("std");
const builtin = @import("builtin");

const bignum = @import("bignum.zig");
const bump_allocator = @import("bump_allocator.zig");
const c_api = @import("c_api.zig");
const callbacks = @import("callbacks.zig");
const code_blocks = @import("code_blocks.zig");
const contexts = @import("contexts.zig");
const data_heap = @import("data_heap.zig");
const execution = @import("execution.zig");
const free_list = @import("free_list.zig");
const gc = @import("gc.zig");
const image = @import("image.zig");
const inline_cache = @import("inline_cache.zig");
const jit = @import("jit.zig");
const layouts = @import("layouts.zig");
const mark_bits = @import("mark_bits.zig");
const math = @import("fixnum.zig");
const object_start_map = @import("object_start_map.zig");
const objects = @import("objects.zig");
const primitives = @import("primitives.zig");
const primitives_ffi = @import("primitives/alien.zig");
const segments = @import("segments.zig");
const signals = @import("signals.zig");
const slot_visitor = @import("slot_visitor.zig");
const vm_mod = @import("vm.zig");

// Comptime verification of struct layouts that JIT code relies on
comptime {
    // Context offsets (must match basis/compiler/constants/constants.factor)
    if (@offsetOf(contexts.Context, "callstack_top") != 0) @compileError("callstack_top must be at offset 0");
    if (@offsetOf(contexts.Context, "callstack_bottom") != 8) @compileError("callstack_bottom must be at offset 8");
    if (@offsetOf(contexts.Context, "datastack") != 16) @compileError("datastack must be at offset 16");
    if (@offsetOf(contexts.Context, "retainstack") != 24) @compileError("retainstack must be at offset 24");
    if (@offsetOf(contexts.Context, "callstack_save") != 32) @compileError("callstack_save must be at offset 32");

    // VMAssemblyFields offsets (must match basis/compiler/constants/constants.factor)
    if (@offsetOf(vm_mod.VMAssemblyFields, "ctx") != 0) @compileError("ctx must be at offset 0 in VMAssemblyFields");
}

// C stdio FILE* pointers — macOS-specific symbol names.
// Other platforms use `stdin`/`stdout`/`stderr` and need porting.
comptime {
    if (builtin.os.tag != .macos) @compileError("C stdio externs use macOS-specific names (__stdinp, etc.)");
}
extern "c" var __stdinp: *std.c.FILE;
extern "c" var __stdoutp: *std.c.FILE;
extern "c" var __stderrp: *std.c.FILE;

extern "c" fn fprintf(*std.c.FILE, [*:0]const u8, ...) c_int;
extern "c" fn fflush(*std.c.FILE) c_int;
extern "c" fn realpath(path: [*:0]const u8, resolved: ?[*:0]u8) ?[*:0]u8;
extern "c" fn setenv(name: [*:0]const u8, value: [*:0]const u8, overwrite: c_int) c_int;
extern "c" fn free(ptr: ?*anyopaque) void;
const c_fprintf = fprintf;
const c_fflush = fflush;

const build_options = @import("build_options");

// Version/build info strings
const FACTOR_CPU_STRING = switch (builtin.cpu.arch) {
    .x86_64 => "x86.64",
    .aarch64 => "arm.64",
    .x86 => "x86.32",
    else => @compileError("unsupported CPU architecture"),
};
const FACTOR_OS_STRING = switch (builtin.os.tag) {
    .macos => "macos",
    .linux => "linux",
    .windows => "windows",
    else => @compileError("unsupported OS"),
};
const FACTOR_VM_VERSION = "0.102";
const FACTOR_COMPILE_TIME = build_options.compile_time;
const FACTOR_COMPILER_VERSION = std.fmt.comptimePrint("Zig {f} {s}", .{
    builtin.zig_version,
    @tagName(builtin.mode),
});
const FACTOR_GIT_LABEL = build_options.git_label;

// Compile code in boot image so that we can execute the startup quotation.
// Matches C++ prepare_boot_image() in factor.cpp:
//   1. JIT compile all words (using their def quotation)
//   2. Set uncompiled quotations to lazy_jit_compile entry point
//   3. Initialize deferred code blocks (updateCodeHeapWords)
//   4. Set OBJ_STAGE2 = canonical_true
fn prepareBootImage(vm: *vm_mod.FactorVM) void {
    const free_list_mod = @import("free_list.zig");

    _ = c_fprintf(__stdoutp, "*** Stage 2 early init... ");

    const heap = vm.data orelse return;

    // Phase 1: JIT compile all words
    var scan = heap.tenured.start;
    const tenured_end = heap.tenured.end;
    var words_compiled: usize = 0;

    while (scan < tenured_end) {
        const header: layouts.Cell = @as(*const layouts.Cell, @ptrFromInt(scan)).*;
        if (header & 1 == 1) {
            // Free block
            const size = header & ~@as(layouts.Cell, 7);
            if (size == 0) break;
            scan += size;
            continue;
        }
        const size = free_list_mod.objectSizeFromHeader(scan);
        if (size == 0) break;

        const obj: *const layouts.Object = @ptrFromInt(scan);
        if (obj.getType() == .word) {
            const word: *layouts.Word = @ptrFromInt(scan);
            if (word.entry_point == 0) {
                // Root the word across JIT compilation (can trigger GC via nursery alloc)
                // Matches C++ jit_compile_word: data_root<word> word(word_, this);
                var rooted_word: layouts.Cell = scan | @intFromEnum(layouts.TypeTag.word);
                vm.data_roots.append(vm.allocator, &rooted_word) catch break;
                defer _ = vm.data_roots.pop();

                const compiled = vm.jitCompileQuotationWithOwner(rooted_word, word.def, false);

                // Re-derive word pointer after potential GC
                var word_after: *layouts.Word = @ptrFromInt(layouts.UNTAG(rooted_word));

                if (compiled) |cb| {
                    word_after.entry_point = cb.entryPoint();
                }

                // Also compile pic_def and pic_tail_def quotations (like C++ jit_compile_word)
                // These are needed for polymorphic inline cache (PIC) method dispatch
                if (word_after.pic_def != layouts.false_object and word_after.pic_def != 0) {
                    vm.jitCompileQuotation(word_after.pic_def, false);
                    // Re-derive after potential GC
                    word_after = @ptrFromInt(layouts.UNTAG(rooted_word));
                }
                if (word_after.pic_tail_def != layouts.false_object and word_after.pic_tail_def != 0) {
                    vm.jitCompileQuotation(word_after.pic_tail_def, false);
                }

                words_compiled += 1;
            }
        }

        scan += size;
    }

    vm.gc_off = false;

    // Phase 2: Initialize all deferred code blocks (must happen before
    // reading lazy_jit_compile entry point, since it needs relocated code)
    const primitives_mod = @import("primitives.zig");
    primitives_mod.updateCodeHeapWords(vm, true);

    // Phase 3: Set uncompiled quotations to lazy_jit_compile entry point
    // (must be after phase 2 so the lazy_jit_compile word has a valid entry point)
    const lazy_ep = vm.lazyJitCompileEntryPoint();
    scan = heap.tenured.start;
    var quotations_set: usize = 0;
    while (scan < tenured_end) {
        const header: layouts.Cell = @as(*const layouts.Cell, @ptrFromInt(scan)).*;
        if (header & 1 == 1) {
            const size = header & ~@as(layouts.Cell, 7);
            if (size == 0) break;
            scan += size;
            continue;
        }
        const size = free_list_mod.objectSizeFromHeader(scan);
        if (size == 0) break;

        const obj2: *const layouts.Object = @ptrFromInt(scan);
        if (obj2.getType() == .quotation) {
            const quot: *layouts.Quotation = @ptrFromInt(scan);
            if (quot.entry_point == 0) {
                quot.entry_point = lazy_ep;
                quotations_set += 1;
            }
        }

        scan += size;
    }

    // Phase 4: Set OBJ_STAGE2 = canonical_true
    vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.stage2)] =
        vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.canonical_true)];

    _ = c_fprintf(__stdoutp, "done\n");
    _ = c_fflush(__stdoutp);
}

// Initialize special objects for stdin/stdout/stderr file handles
// Matches C++ VM init_factor() in factor.cpp
fn initSpecialObjects(vm: *vm_mod.FactorVM, image_path: []const u8, executable_path: []const u8) void {
    const stdin_ptr = __stdinp;
    const stdout_ptr = __stdoutp;
    const stderr_ptr = __stderrp;

    // OBJ_CELL_SIZE = 7
    vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.cell_size)] = layouts.tagFixnum(8);

    // OBJ_ARGS = 10 - initialized to false, will be set by passArgsToFactor
    vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.args)] = layouts.false_object;

    // OBJ_EMBEDDED = 15 - we're not embedded
    vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.embedded)] = layouts.false_object;

    // OBJ_STAGE2 = 67 - set to canonical_true (will be set from image)
    // Note: This is typically set from the image's canonical_true value
    // For now, leave as loaded from image

    // OBJ_STDIN = 11 (stdin)
    const stdin_alien = vm.allotAlien(layouts.false_object, @intFromPtr(stdin_ptr));
    vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.stdin)] = stdin_alien;

    // OBJ_STDOUT = 12 (stdout)
    const stdout_alien = vm.allotAlien(layouts.false_object, @intFromPtr(stdout_ptr));
    vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.stdout)] = stdout_alien;

    // OBJ_STDERR = 66 (stderr)
    const stderr_alien = vm.allotAlien(layouts.false_object, @intFromPtr(stderr_ptr));
    vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.stderr)] = stderr_alien;

    // OBJ_CPU = 8 (CPU architecture string)
    const cpu_alien = vm.allotAlien(layouts.false_object, @intFromPtr(FACTOR_CPU_STRING.ptr));
    vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.cpu)] = cpu_alien;

    // OBJ_OS = 9 (operating system string)
    const os_alien = vm.allotAlien(layouts.false_object, @intFromPtr(FACTOR_OS_STRING.ptr));
    vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.os)] = os_alien;

    // OBJ_EXECUTABLE = 14 (runtime executable path)
    const executable_alien = vm.allotAlien(layouts.false_object, @intFromPtr(executable_path.ptr));
    vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.executable)] = executable_alien;

    // OBJ_IMAGE = 13 (image path)
    const image_alien = vm.allotAlien(layouts.false_object, @intFromPtr(image_path.ptr));
    vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.image)] = image_alien;

    // OBJ_VM_COMPILE_TIME = 75
    const compile_time_alien = vm.allotAlien(layouts.false_object, @intFromPtr(FACTOR_COMPILE_TIME.ptr));
    vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.vm_compile_time)] = compile_time_alien;

    // OBJ_VM_COMPILER = 72
    const compiler_alien = vm.allotAlien(layouts.false_object, @intFromPtr(FACTOR_COMPILER_VERSION.ptr));
    vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.vm_compiler)] = compiler_alien;

    // OBJ_VM_GIT_LABEL = 77
    const git_label_alien = vm.allotAlien(layouts.false_object, @intFromPtr(FACTOR_GIT_LABEL.ptr));
    vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.vm_git_label)] = git_label_alien;

    // OBJ_VM_VERSION = 76
    const version_alien = vm.allotAlien(layouts.false_object, @intFromPtr(FACTOR_VM_VERSION.ptr));
    vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.vm_version)] = version_alien;
}

// Pass command line arguments to Factor via OBJ_ARGS special object
// Matches C++ VM pass_args_to_factor() in factor.cpp
fn passArgsToFactor(vm: *vm_mod.FactorVM, args: []const [:0]const u8) void {
    const argc: usize = args.len;

    // Allocate array for argument aliens
    var args_array = vm.allotUninitializedArray(argc) orelse return;

    // CRITICAL: Store in special_objects BEFORE allocating aliens.
    // This makes the array a GC root so it won't become a stale pointer if GC runs.
    // We'll update the slots below, and the array is already in place as a root.
    vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.args)] = args_array;

    // Create an alien for each argument string
    // NOTE: allotAlien can trigger GC, but args_array is now a GC root via special_objects
    for (args, 0..) |arg, i| {
        // Re-fetch array pointer after potential GC (special_objects is scanned by GC)
        args_array = vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.args)];
        const arr: *layouts.Array = @ptrFromInt(layouts.UNTAG(args_array));
        const data = arr.data();

        // Create alien pointing to the C string (null-terminated)
        const alien = vm.allotAlien(layouts.false_object, @intFromPtr(arg.ptr));
        data[i] = alien;
    }
}

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;

    // Store global Io for use by image loader and other subsystems
    c_api.global_io = init.io;
    c_api.global_io_initialized = true;

    // Collect command line arguments into a slice
    var args_list: std.ArrayList([:0]const u8) = .{};
    defer args_list.deinit(allocator);
    var args_iter = init.minimal.args.iterate();
    while (args_iter.next()) |arg| {
        try args_list.append(allocator, arg);
    }
    const args = args_list.items;

    // Parse command line arguments - we only extract -i= for ourselves
    // All other arguments (including -e=..., -run=...) are passed to Factor via OBJ_ARGS
    // Note: Unlike the old code, we do NOT treat positional arguments as image paths
    // The C++ VM uses default_image_path() and passes ALL args to Factor unchanged
    var params = image.VMParameters{};
    var image_path: ?[]const u8 = null;

    for (1..args.len) |i| {
        const arg = args[i];

        if (std.mem.startsWith(u8, arg, "-i=")) {
            image_path = arg[3..];
        } else if (std.mem.eql(u8, arg, "-fep")) {
            params.fep = true;
        } else if (std.mem.eql(u8, arg, "-no-signals")) {
            params.signals = false;
        }
        // All other arguments (including -e=..., -run=..., and positional args)
        // are passed to Factor via OBJ_ARGS - we don't consume them here
    }

    // Default image path search order:
    // 1. FACTOR_IMAGE env var (set by parent Factor process, inherited by children)
    // 2. <exe_path>.image (C++ VM approach)
    // 3. factor.image in cwd
    if (image_path == null) {
        if (std.c.getenv("FACTOR_IMAGE")) |env_path| {
            const span = std.mem.span(env_path);
            if (span.len > 0) image_path = span;
        }
    }
    if (image_path == null) {
        if (args.len > 0) {
            if (realpath(args[0].ptr, null)) |abs_exe| {
                defer free(abs_exe);
                const exe_span: []const u8 = std.mem.span(abs_exe);
                const buf = allocator.alloc(u8, exe_span.len + 7) catch null;
                if (buf) |b| {
                    defer allocator.free(b);
                    @memcpy(b[0..exe_span.len], exe_span);
                    @memcpy(b[exe_span.len..][0..7], ".image\x00");
                    const candidate: [*:0]const u8 = @ptrCast(b.ptr);
                    if (realpath(candidate, null)) |abs_img| {
                        image_path = std.mem.span(abs_img);
                    }
                }
            }
        }
    }
    if (image_path == null) {
        const default_paths = [_][*:0]const u8{ "factor.image", "../factor.image" };
        for (default_paths) |path| {
            if (realpath(path, null)) |abs| {
                image_path = std.mem.span(abs);
                break;
            }
        }
    }

    if (image_path == null) {
        _ = c_fprintf(__stderrp, "Error: No image file specified. Use -i=<path> or provide image as argument.\nUsage: factor [-i=<image>] [-e=<code>] [-fep]\n");
        std.process.exit(1);
    }

    // Export image path so child processes (launched via io.launcher) inherit it.
    // Factor's launcher calls cd(current-directory) before exec, so the child's
    // cwd may differ from the parent's — the env var ensures the child finds the image.
    if (image_path) |ip| {
        if (realpath(@ptrCast(ip.ptr), null)) |abs| {
            defer free(abs);
            _ = setenv("FACTOR_IMAGE", abs, 1);
        }
    }

    // Force keep all primitives in release builds
    keepPrimitives();

    // Create VM instance
    const vm = try vm_mod.FactorVM.init(allocator);
    defer vm.deinit();

    // Set global VM for callbacks and error handlers
    c_api.setGlobalVM(vm);

    // Set up VM parameters
    vm.datastack_size = params.datastack_size;
    vm.retainstack_size = params.retainstack_size;
    vm.callstack_size = params.callstack_size;
    vm.max_pic_size = params.max_pic_size;

    // Create initial context and spare context (for callbacks)
    const ctx = try vm.newContext();
    vm.vm_asm.ctx = ctx;
    const spare = try vm.newContext();
    vm.vm_asm.spare_ctx = spare;

    // Initialize FFI subsystem before image load (matches C++ init_ffi timing)
    primitives_ffi.initFfi();

    // Load the image FIRST (this initializes the nursery)
    var loader = image.ImageLoader.init(vm, init.io, params);
    defer loader.deinit();

    loader.loadImage(image_path.?) catch |err| {
        _ = c_fprintf(__stderrp, "Failed to load image: %d\n", @intFromError(err));
        std.process.exit(1);
    };

    // Initialize contexts AFTER image load (needs nursery for alien allocation)
    vm.initContext(ctx);
    vm.initContext(spare);

    // Initialize special objects (stdin, stdout, stderr, etc.)
    // Resolve executable and image paths to absolute (matching C++ VM's NSBundle behavior).
    // Factor derives resource-path from image-path's parent directory, so relative
    // paths break when current-directory changes (e.g. in with-test-directory).
    const executable_path: []const u8 = blk: {
        const raw: [*:0]const u8 = if (args.len > 0) args[0].ptr else "";
        if (realpath(raw, null)) |resolved| break :blk std.mem.span(resolved);
        break :blk if (args.len > 0) args[0] else "";
    };
    const abs_image_path: []const u8 = blk: {
        const raw: [*:0]const u8 = @ptrCast(image_path.?.ptr);
        if (realpath(raw, null)) |resolved| break :blk std.mem.span(resolved);
        break :blk image_path.?;
    };
    initSpecialObjects(vm, abs_image_path, executable_path);

    // Pass ALL command line arguments to Factor via OBJ_ARGS
    // Factor's startup quotation handles parsing -e=... and other flags
    passArgsToFactor(vm, args);

    // If the image is a boot image (stage2 not set), JIT compile all words
    // and quotations before running the startup quotation.
    // Matches C++ prepare_boot_image() in factor.cpp
    const stage2 = vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.stage2)];
    if (stage2 == layouts.false_object or stage2 == 0) {
        prepareBootImage(vm);
    }

    // Initialize safepoint system after image load (code heap must exist)
    const safepoints = @import("safepoints.zig");
    safepoints.initSafepoints(vm) catch @panic("safepoint init failed");

    // Initialize signal handlers (unless disabled)
    if (params.signals) {
        signals.initSignals(vm) catch @panic("signal init failed");
    }

    // Initialize stdin handling pipes (unless console disabled)
    if (params.console) {
        c_api.open_console();
    }

    // Execute the startup quotation
    const startup_quot = vm.specialObject(objects.SpecialObject.startup_quot);
    if (startup_quot != layouts.false_object and layouts.hasTag(startup_quot, .quotation)) {
        execution.runFactor(vm) catch |err| {
            _ = c_fprintf(__stderrp, "Execution error: %d\n", @intFromError(err));
        };
    } else {
        _ = c_fprintf(__stderrp, "No startup quotation found\n");
    }
}

// Tests
test "layouts" {
    // Test tag operations
    const tagged = layouts.tagFixnum(42);
    try std.testing.expectEqual(@as(layouts.Cell, 42), layouts.untagFixnum(tagged));
    try std.testing.expectEqual(@as(layouts.Cell, 0), layouts.TAG(tagged));

    // Test alignment
    try std.testing.expectEqual(@as(layouts.Cell, 16), layouts.alignCell(1, 16));
    try std.testing.expectEqual(@as(layouts.Cell, 16), layouts.alignCell(16, 16));
    try std.testing.expectEqual(@as(layouts.Cell, 32), layouts.alignCell(17, 16));
}

test "bump_allocator" {
    const alloc = bump_allocator.BumpAllocator.init(1024, 0x1000);
    try std.testing.expectEqual(@as(layouts.Cell, 0x1000), alloc.here);
    try std.testing.expectEqual(@as(layouts.Cell, 0x1000), alloc.start);
    try std.testing.expectEqual(@as(layouts.Cell, 0x1400), alloc.end);
    try std.testing.expectEqual(@as(layouts.Cell, 1024), alloc.freeBytes());
}

test "context" {
    var ctx = try contexts.Context.init(std.testing.allocator, 4096, 4096, 16384);
    defer ctx.deinit(std.testing.allocator);

    // Test stack operations
    ctx.push(layouts.tagFixnum(1));
    ctx.push(layouts.tagFixnum(2));
    ctx.push(layouts.tagFixnum(3));

    try std.testing.expectEqual(@as(layouts.Fixnum, 3), layouts.untagFixnum(ctx.pop()));
    try std.testing.expectEqual(@as(layouts.Fixnum, 2), layouts.untagFixnum(ctx.pop()));
    try std.testing.expectEqual(@as(layouts.Fixnum, 1), layouts.untagFixnum(ctx.pop()));
}

test "vm struct layout" {
    // Verify critical offsets match C++
    const cell_size = @sizeOf(layouts.Cell);

    // Test VMAssemblyFields layout
    try std.testing.expectEqual(@as(usize, 0 * cell_size), @offsetOf(vm_mod.VMAssemblyFields, "ctx"));
    try std.testing.expectEqual(@as(usize, 1 * cell_size), @offsetOf(vm_mod.VMAssemblyFields, "spare_ctx"));
    try std.testing.expectEqual(@as(usize, 2 * cell_size), @offsetOf(vm_mod.VMAssemblyFields, "nursery"));
    try std.testing.expectEqual(@as(usize, 6 * cell_size), @offsetOf(vm_mod.VMAssemblyFields, "cards_offset"));
    try std.testing.expectEqual(@as(usize, 7 * cell_size), @offsetOf(vm_mod.VMAssemblyFields, "decks_offset"));
    try std.testing.expectEqual(@as(usize, 8 * cell_size), @offsetOf(vm_mod.VMAssemblyFields, "signal_handler_addr"));
    try std.testing.expectEqual(@as(usize, 10 * cell_size), @offsetOf(vm_mod.VMAssemblyFields, "special_objects"));
}

// Reference all test modules
test {
    _ = bignum;
    _ = mark_bits;
    _ = free_list;
    _ = object_start_map;
    _ = data_heap;
    _ = slot_visitor;
    _ = gc;
    _ = math;
    _ = primitives;
    _ = execution;
    _ = code_blocks;
    _ = callbacks;
    _ = jit;
    _ = inline_cache;
    _ = c_api;
}

// Force linker to keep exported symbols by referencing them
comptime {
    // C API exports
    _ = &c_api.begin_callback;
    _ = &c_api.end_callback;
    _ = &c_api.inline_cache_miss;
    _ = &primitives.getAllPrimitives;
}

// Force keep all primitives at runtime - this prevents LLVM from optimizing them away
// The function is marked noinline and uses doNotOptimizeAway
pub fn keepPrimitives() void {
    const prims = primitives.getAllPrimitives();
    for (prims) |p| {
        std.mem.doNotOptimizeAway(p);
    }
    // Also keep FFI conversion helpers
    std.mem.doNotOptimizeAway(&primitives.to_unsigned_8);
    std.mem.doNotOptimizeAway(&primitives.to_signed_8);
    std.mem.doNotOptimizeAway(&primitives.to_unsigned_4);
    std.mem.doNotOptimizeAway(&primitives.to_signed_4);
}

// Export primitive table
pub export var primitive_table: [primitives.primitive_count]primitives.PrimitiveFn = primitives.getAllPrimitives();
