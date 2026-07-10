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
    if (@offsetOf(contexts.Context, "callstack_top") != 0) @compileError("callstack_top must be at offset 0");
    if (@offsetOf(contexts.Context, "callstack_bottom") != 8) @compileError("callstack_bottom must be at offset 8");
    if (@offsetOf(contexts.Context, "datastack") != 16) @compileError("datastack must be at offset 16");
    if (@offsetOf(contexts.Context, "retainstack") != 24) @compileError("retainstack must be at offset 24");
    if (@offsetOf(contexts.Context, "callstack_save") != 32) @compileError("callstack_save must be at offset 32");

    if (@offsetOf(vm_mod.VMAssemblyFields, "ctx") != 0) @compileError("ctx must be at offset 0 in VMAssemblyFields");
}

// C stdio FILE* pointers — needed for Factor's OBJ_STDIN/STDOUT/STDERR aliens.
// Platform-specific symbol names: macOS uses __stdinp, Linux uses stdin.
// On both macOS and Linux, stdin/stdout/stderr are global variables of type
// FILE*. @extern gives us the address of the variable itself, so we need
// *const *FILE (pointer to the variable) and dereference to get the FILE*.
fn getCStdin() *std.c.FILE {
    const name = if (builtin.os.tag == .macos) "__stdinp" else "stdin";
    return @extern(*const *std.c.FILE, .{ .name = name }).*;
}

fn getCStdout() *std.c.FILE {
    const name = if (builtin.os.tag == .macos) "__stdoutp" else "stdout";
    return @extern(*const *std.c.FILE, .{ .name = name }).*;
}

fn getCStderr() *std.c.FILE {
    const name = if (builtin.os.tag == .macos) "__stderrp" else "stderr";
    return @extern(*const *std.c.FILE, .{ .name = name }).*;
}

extern "c" fn realpath(path: [*:0]const u8, resolved: ?[*:0]u8) ?[*:0]u8;
extern "c" fn setenv(name: [*:0]const u8, value: [*:0]const u8, overwrite: c_int) c_int;
extern "c" fn free(ptr: ?*anyopaque) void;

// macOS: locate factor.image relative to a .app bundle, independent of cwd.
// Mirrors the C++ VM's default_image_path (vm/os-macos.mm): when the executable
// lives at .../Foo.app/Contents/MacOS/<name>, look for <name>.image in the
// bundle's Contents/Resources (deployed layout), else next to the .app (dev
// layout, where Factor.app and factor.image are siblings). Without this,
// `open Factor.app` launches with cwd=/ and the cwd-relative factor.image
// search fails. Returns an owned resolved path (process-lifetime) or null.
fn findBundleImage(allocator: std.mem.Allocator) ?[]const u8 {
    if (comptime builtin.os.tag != .macos) return null;
    const _NSGetExecutablePath = struct {
        extern "c" fn _NSGetExecutablePath(buf: [*]u8, bufsize: *u32) c_int;
    }._NSGetExecutablePath;

    var exe_buf: [4096]u8 = undefined;
    var exe_size: u32 = exe_buf.len;
    if (_NSGetExecutablePath(&exe_buf, &exe_size) != 0) return null;
    const abs_exe = realpath(@ptrCast(&exe_buf), null) orelse return null;
    defer free(abs_exe);
    const exe: []const u8 = std.mem.span(abs_exe);

    const marker = ".app/Contents/MacOS/";
    const idx = std.mem.indexOf(u8, exe, marker) orelse return null;
    const app_path = exe[0 .. idx + 4]; // ".../Foo.app"
    const app_dir = std.fs.path.dirname(app_path) orelse return null;
    const name = std.fs.path.basename(exe); // e.g. "factor"

    const candidates = [_][:0]const u8{
        std.fmt.allocPrintSentinel(allocator, "{s}/Contents/Resources/{s}.image", .{ app_path, name }, 0) catch return null,
        std.fmt.allocPrintSentinel(allocator, "{s}/{s}.image", .{ app_dir, name }, 0) catch return null,
    };
    for (candidates) |c| {
        if (realpath(c.ptr, null)) |abs| return std.mem.span(abs);
    }
    return null;
}

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
//   1. JIT compile all words (using their def quotation)
//   2. Set uncompiled quotations to lazy_jit_compile entry point
//   3. Initialize deferred code blocks (updateCodeHeapWords)
//   4. Set OBJ_STAGE2 = canonical_true
fn prepareBootImage(vm: *vm_mod.FactorVM) void {
    const free_list_mod = @import("free_list.zig");

    std.debug.print("*** Stage 2 early init... ", .{});

    const heap = vm.data orelse return;
    vm.gc_off = false;

    // Snapshot every word and quotation before compiling. Compilation can
    // allocate in both heaps and compact/move the data heap, so walking the
    // original tenured addresses across a compile is unsafe. cellsToArray
    // roots the malloc-side snapshot while materializing one heap array; from
    // then on that single registered array keeps all entries current.
    var words: std.ArrayList(layouts.Cell) = .empty;
    defer words.deinit(vm.allocator);
    var quotations: std.ArrayList(layouts.Cell) = .empty;
    defer quotations.deinit(vm.allocator);

    var scan = heap.tenured.start;
    const tenured_end = heap.tenured.end;
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

        const obj: *const layouts.Object = @ptrFromInt(scan);
        switch (obj.getType()) {
            .word => words.append(vm.allocator, scan | @intFromEnum(layouts.TypeTag.word)) catch vm.memoryError(),
            .quotation => quotations.append(vm.allocator, scan | @intFromEnum(layouts.TypeTag.quotation)) catch vm.memoryError(),
            else => {},
        }

        scan += size;
    }

    const word_count = words.items.len;
    words.ensureUnusedCapacity(vm.allocator, quotations.items.len) catch vm.memoryError();
    words.appendSliceAssumeCapacity(quotations.items);

    var boot_array_cell = vm.cellsToArray(words.items) orelse vm.memoryError();
    vm.data_roots.appendAssumeCapacity(&boot_array_cell);
    defer _ = vm.data_roots.pop();

    // Phase 1: JIT compile all words.
    for (0..word_count) |i| {
        var boot_array: *const layouts.Array = @ptrFromInt(layouts.UNTAG(boot_array_cell));
        const word_cell = boot_array.data()[i];
        const word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(word_cell));
        if (word.entry_point != 0) continue;

        const compiled = vm.jitCompileQuotationWithOwner(word_cell, word.def, false);

        // Re-read the array slot after every allocating call. The array and
        // word can both have moved, but the registered slot is current.
        boot_array = @ptrFromInt(layouts.UNTAG(boot_array_cell));
        var word_after: *layouts.Word = @ptrFromInt(layouts.UNTAG(boot_array.data()[i]));
        if (compiled) |cb| word_after.entry_point = cb.entryPoint();

        if (word_after.pic_def != layouts.false_object and word_after.pic_def != 0) {
            vm.jitCompileQuotation(word_after.pic_def, false);
            boot_array = @ptrFromInt(layouts.UNTAG(boot_array_cell));
            word_after = @ptrFromInt(layouts.UNTAG(boot_array.data()[i]));
        }
        if (word_after.pic_tail_def != layouts.false_object and word_after.pic_tail_def != 0) {
            vm.jitCompileQuotation(word_after.pic_tail_def, false);
        }
    }

    // Phase 2: Initialize all deferred code blocks (must happen before
    // reading lazy_jit_compile entry point, since it needs relocated code)
    const primitives_mod = @import("primitives.zig");
    primitives_mod.updateCodeHeapWords(vm, true, null);

    // Phase 3: Set uncompiled quotations to lazy_jit_compile entry point
    // (must be after phase 2 so the lazy_jit_compile word has a valid entry point)
    const lazy_ep = vm.lazyJitCompileEntryPoint();
    for (word_count..words.items.len) |i| {
        const boot_array: *const layouts.Array = @ptrFromInt(layouts.UNTAG(boot_array_cell));
        const quot: *layouts.Quotation = @ptrFromInt(layouts.UNTAG(boot_array.data()[i]));
        if (quot.entry_point == 0) quot.entry_point = lazy_ep;
    }

    // Phase 4: Set OBJ_STAGE2 = canonical_true
    vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.stage2)] =
        vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.canonical_true)];

    std.debug.print("done\n", .{});
}

// Initialize special objects for stdin/stdout/stderr file handles
fn initSpecialObjects(vm: *vm_mod.FactorVM, image_path: []const u8, executable_path: []const u8) void {
    const stdin_ptr = getCStdin();
    const stdout_ptr = getCStdout();
    const stderr_ptr = getCStderr();

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
fn passArgsToFactor(vm: *vm_mod.FactorVM, args: []const [:0]const u8) void {
    const argc: usize = args.len;

    // Allocate array for argument aliens
    var args_array = vm.allotArray(argc, layouts.false_object) orelse return;

    // CRITICAL: Store in special_objects BEFORE allocating aliens.
    // This makes the array a GC root so it won't become a stale pointer if GC runs.
    // We'll update the slots below, and the array is already in place as a root.
    vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.args)] = args_array;

    // Create an alien for each argument string
    // NOTE: allotAlien can trigger GC, but args_array is a GC root via special_objects.
    for (args, 0..) |arg, i| {
        const alien = vm.allotAlien(layouts.false_object, @intFromPtr(arg.ptr));

        // Re-fetch the array pointer AFTER the allocation. It may have moved,
        // and after its first promotion this old->young store also needs the
        // generational write barrier.
        args_array = vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.args)];
        const arr: *layouts.Array = @ptrFromInt(layouts.UNTAG(args_array));
        const data = arr.data();
        data[i] = alien;
        vm.writeBarrierKnownHeapWithValue(&data[i], alien);
    }
}

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;

    // Store global Io for use by image loader and other subsystems
    c_api.global_io = init.io;
    c_api.global_io_initialized = true;

    // Collect command line arguments into a slice
    var args_list: std.ArrayList([:0]const u8) = .empty;
    defer args_list.deinit(allocator);
    var args_iter = init.minimal.args.iterate();
    while (args_iter.next()) |arg| {
        try args_list.append(allocator, arg);
    }
    const args = args_list.items;

    // Parse VM heap/runtime flags (-codeheap, -callbacks, -young, …) the same
    // way as the C++ VM. Remaining args (-e=, -run=, positionals) still go to
    // Factor via OBJ_ARGS; Factor ignores the heap flags it does not understand.
    var params = image.VMParameters{};
    var image_path = params.initFromArgs(args);

    // Embedded image: a deployed Factor binary has its image appended, marked
    // by a footer at EOF. When no -i= was given, prefer the executable's own
    // embedded image (matches C++ factor.cpp embedded_image_p). This must come
    // BEFORE the FACTOR_IMAGE env / defaults below: a deployed binary launched
    // as a child of Factor inherits FACTOR_IMAGE pointing at the parent's image,
    // and must still run its own embedded image, not the parent's.
    if (image_path == null and args.len > 0) {
        if (realpath(args[0].ptr, null)) |abs_exe| {
            if (image.hasEmbeddedImage(abs_exe)) {
                image_path = std.mem.span(abs_exe); // kept for process lifetime
                params.embedded_image = true;
            } else {
                free(abs_exe);
            }
        }
    }

    // Default image path search order:
    // 1. FACTOR_IMAGE env var (set by parent Factor process, inherited by children)
    // 2. <exe_path>.image
    // 3. factor.image in cwd
    if (image_path == null) {
        if (std.c.getenv("FACTOR_IMAGE")) |env_path| {
            const span = std.mem.span(env_path);
            if (span.len > 0) image_path = span;
        }
    }
    // macOS .app bundle: locate the image relative to the bundle (Resources or
    // sibling of the .app), so `open Factor.app` works despite cwd=/.
    if (image_path == null) {
        if (findBundleImage(allocator)) |p| image_path = p;
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
        std.debug.print(
            \\Error: No image file specified. Use -i=<path>.
            \\Usage: factor [-i=<image>] [-e=<code>] [-fep]
            \\  [-datastack=N] [-retainstack=N] [-callstack=N]   (kilobytes)
            \\  [-young=N] [-aging=N] [-tenured=N] [-codeheap=N] (megabytes)
            \\  [-callbacks=N]  (kilobytes)
            \\  [-pic=N] [-no-signals]
            \\
        , .{});
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

    // Pre-allocate data_roots: primitives push/pop roots but aren't recursive
    // via Factor (JIT handles recursion), so the max depth is bounded by the
    // deepest C call chain nesting (~10-15 roots). 32 is generous.
    try vm.data_roots.ensureTotalCapacity(allocator, 32);

    // Set global VM for callbacks and error handlers
    c_api.setGlobalVM(vm);

    // Set up VM parameters (byte sizes after CLI unit conversion)
    vm.datastack_size = params.datastack_size;
    vm.retainstack_size = params.retainstack_size;
    vm.callstack_size = params.callstack_size;
    vm.callback_size = params.callback_size;
    vm.max_pic_size = params.max_pic_size;

    // Create initial context and spare context (for callbacks)
    const ctx = try vm.newContext();
    vm.vm_asm.ctx = ctx;
    const spare = try vm.newContext();
    vm.vm_asm.spare_ctx = spare;

    // Initialize FFI subsystem before image load
    primitives_ffi.initFfi();

    // Load the image FIRST (this initializes the nursery)
    var loader = image.ImageLoader.init(vm, init.io, params);
    defer loader.deinit();

    loader.loadImage(image_path.?) catch |err| {
        std.debug.print("Failed to load image: {}\n", .{err});
        std.process.exit(1);
    };

    // Initialize contexts AFTER image load (needs nursery for alien allocation)
    vm.initContext(ctx);
    vm.initContext(spare);

    // Initialize special objects (stdin, stdout, stderr, etc.)
    // Factor derives resource-path from image-path's parent directory, so relative
    // paths break when current-directory changes (e.g. in with-test-directory).
    const executable_path: []const u8 = blk: {
        const raw: [*:0]const u8 = if (args.len > 0) args[0].ptr else "";
        if (realpath(raw, null)) |resolved| break :blk std.mem.span(resolved);
        break :blk if (args.len > 0) args[0] else "";
    };

    // image path goes into the image-path special object exactly as received
    initSpecialObjects(vm, image_path.?, executable_path);

    // Pass ALL command line arguments to Factor via OBJ_ARGS
    // Factor's startup quotation handles parsing -e=... and other flags
    passArgsToFactor(vm, args);

    // If the image is a boot image (stage2 not set), JIT compile all words
    // and quotations before running the startup quotation.
    const stage2 = vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.stage2)];
    if (stage2 == layouts.false_object or stage2 == 0) {
        prepareBootImage(vm);
    }

    // Initialize safepoint system after image load (code heap must exist)
    const safepoints = @import("safepoints.zig");
    safepoints.initSafepoints(vm) catch |err| std.debug.panic("safepoint init failed: {s}", .{@errorName(err)});

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
            std.debug.print("Execution error: {}\n", .{err});
        };
    } else {
        std.debug.print("No startup quotation found\n", .{});
    }
}

// Tests
test "layouts" {
    // Test tag operations
    const tagged = layouts.tagFixnum(42);
    try std.testing.expectEqual(@as(isize, 42), layouts.untagFixnum(tagged));
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
    // Verify critical offsets.
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

test "passArgsToFactor survives repeated nursery collections" {
    const allocator = std.testing.allocator;
    const vm = try vm_mod.FactorVM.init(allocator);
    vm.vm_asm.ctx = try vm.newContext();
    vm.vm_asm.spare_ctx = try vm.newContext();

    const heap = try data_heap.DataHeap.init(allocator, 4096, 1024 * 1024, 1024 * 1024);
    vm.setDataHeap(heap);

    var collector = gc.GarbageCollector.init(allocator, vm, heap);
    vm.gc = &collector;
    defer {
        vm.gc = null;
        collector.deinit();
        vm.cards_array = null;
        vm.decks_array = null;
        vm.deinit();
        heap.deinit();
    }

    // The minimum nursery is one deck (256 KiB). Enough aliens to collect it
    // twice exercise both hazards: re-deriving the promoted args array after
    // each allocation and remembering its later old->young stores.
    const arg_count = 12_000;
    var args: [arg_count][:0]const u8 = undefined;
    @memset(&args, "gc-root");
    passArgsToFactor(vm, &args);

    try std.testing.expect(heap.nursery_collections >= 2);
    const args_cell = vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.args)];
    const args_array: *const layouts.Array = @ptrFromInt(layouts.UNTAG(args_cell));
    try std.testing.expectEqual(@as(layouts.Cell, arg_count), args_array.getCapacity());

    for (args_array.data()[0..arg_count]) |alien_cell| {
        try std.testing.expect(layouts.hasTag(alien_cell, .alien));
        const alien: *const layouts.Alien = @ptrFromInt(layouts.UNTAG(alien_cell));
        try std.testing.expectEqual(layouts.false_object, alien.base);
        try std.testing.expectEqual(@intFromPtr(args[0].ptr), alien.address);
    }
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
