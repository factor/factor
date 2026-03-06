// safepoints.zig - Safepoint handling for JIT synchronization
// Based on vm/safepoints.cpp and vm/code_heap.cpp from the C++ VM
//
// Safepoints are used to synchronize threads for:
// 1. Garbage collection - stop all threads to perform GC safely
// 2. Debugger interrupts - Ctrl-C can interrupt compiled code
// 3. Sampling profiler - collect execution samples
//
// How it works:
// - A safepoint page is the first page of the code heap
// - When we need to trigger a safepoint, we protect the page with PROT_NONE (armSafepoint)
// - Compiled code touches this page at strategic points (function prologues)
// - This causes SIGSEGV which is caught by the signal handler (memorySignalHandler in signals.zig)
// - The signal handler checks if it's a safepoint fault via isSafepoint()
// - If yes, it calls handleSafepoint() which processes the event
// - handleSafepoint() disarms the safepoint (PROT_READ|PROT_WRITE) and handles the condition
//
// Integration points:
// 1. Code heap initialization: safepoint_page is set to seg.start (code_blocks.zig, image.zig)
// 2. Signal handler: memorySignalHandler checks isSafepoint() (signals.zig)
// 3. GC: Can call armSafepoint() to stop threads for collection
// 4. Debugger: enqueueFep() arms safepoint and sets safepoint_fep_p flag
// 5. Profiler: enqueueSamples() arms safepoint and accumulates sample counts

const std = @import("std");

const callstack = @import("callstack.zig");
const code_blocks_mod = @import("code_blocks.zig");
const contexts = @import("contexts.zig");
const layouts = @import("layouts.zig");
const objects = @import("objects.zig");
const segments = @import("segments.zig");
const vm_mod = @import("vm.zig");
const write_barrier = @import("write_barrier.zig");

const Cell = layouts.Cell;
const Fixnum = layouts.Fixnum;
const CodeBlock = code_blocks_mod.CodeBlock;

// Atomic flags for safepoint conditions
// These are checked in handle_safepoint()
pub var safepoint_fep_p: std.atomic.Value(bool) = std.atomic.Value(bool).init(false);
pub var sampling_profiler_p: std.atomic.Value(bool) = std.atomic.Value(bool).init(false);

// Sample data for profiler
pub const ProfilingSample = struct {
    const Self = @This();

    sample_count: std.atomic.Value(Cell),
    foreign_thread_sample_count: std.atomic.Value(Cell),
    gc_sample_count: std.atomic.Value(Cell),
    jit_sample_count: std.atomic.Value(Cell),
    foreign_sample_count: std.atomic.Value(Cell),

    pub fn init() ProfilingSample {
        return .{
            .sample_count = std.atomic.Value(Cell).init(0),
            .foreign_thread_sample_count = std.atomic.Value(Cell).init(0),
            .gc_sample_count = std.atomic.Value(Cell).init(0),
            .jit_sample_count = std.atomic.Value(Cell).init(0),
            .foreign_sample_count = std.atomic.Value(Cell).init(0),
        };
    }

    pub fn reset(self: *ProfilingSample) void {
        self.sample_count.store(0, .monotonic);
        self.foreign_thread_sample_count.store(0, .monotonic);
        self.gc_sample_count.store(0, .monotonic);
        self.jit_sample_count.store(0, .monotonic);
        self.foreign_sample_count.store(0, .monotonic);
    }
};

pub var current_sample: ProfilingSample = ProfilingSample.init();

// A recorded profiling sample with drained counters and callstack indices
pub const SampleRecord = struct {
    thread: Cell,
    callstack_begin: Cell,
    callstack_end: Cell,
    sample_count: Cell,
    gc_sample_count: Cell,
    jit_sample_count: Cell,
    foreign_sample_count: Cell,
    foreign_thread_sample_count: Cell,
};

// Protect or unprotect the safepoint page
// When locked=true, the page is protected (PROT_NONE) and will trigger SIGSEGV
// When locked=false, the page is unprotected (PROT_READ | PROT_WRITE)
pub fn setSafepointGuard(vm: *vm_mod.FactorVM, locked: bool) !void {
    const code_heap = vm.code orelse return error.NoCodeHeap;
    const safepoint_page = code_heap.safepoint_page;

    if (safepoint_page == 0) {
        return error.NoSafepointPage;
    }

    const page_size = segments.page_size;
    const ptr: *align(std.heap.page_size_min) anyopaque = @ptrFromInt(safepoint_page);

    const prot: std.c.PROT = if (locked)
        .{}
    else
        .{ .READ = true, .WRITE = true };

    if (std.c.mprotect(ptr, page_size, prot) != 0) return error.MprotectFailed;
}

// Arm the safepoint - protect the page so access will fault
pub fn armSafepoint(vm: *vm_mod.FactorVM) !void {
    try setSafepointGuard(vm, true);
}

// Disarm the safepoint - unprotect the page so access succeeds
pub fn disarmSafepoint(vm: *vm_mod.FactorVM) !void {
    try setSafepointGuard(vm, false);
}

// Check if an address is on the safepoint page
pub fn isSafepoint(vm: *vm_mod.FactorVM, addr: Cell) bool {
    const code_heap = vm.code orelse return false;
    if (code_heap.safepoint_page == 0) return false;

    const page_size = segments.page_size;
    const page_mask = ~(page_size - 1);
    return (addr & page_mask) == code_heap.safepoint_page;
}

// Enqueue a debugger interrupt (Factor Error Protocol)
// This sets a flag that will be checked at the next safepoint
pub fn enqueueFep(vm: *vm_mod.FactorVM) !void {
    if (vm.fep_p) {
        std.debug.print("\nLow-level debugger interrupted, exiting.\n", .{});
        std.process.exit(1);
    }
    safepoint_fep_p.store(true, .monotonic);
    try armSafepoint(vm);
}

// Enqueue profiling samples
// This accumulates sample counts and arms the safepoint so they can be recorded
pub fn enqueueSamples(vm: *vm_mod.FactorVM, samples: Cell, pc: Cell, foreign_thread_p: bool) !void {
    if (!sampling_profiler_p.load(.monotonic)) {
        return;
    }

    _ = current_sample.sample_count.fetchAdd(samples, .monotonic);

    if (foreign_thread_p) {
        _ = current_sample.foreign_thread_sample_count.fetchAdd(samples, .monotonic);
    } else {
        if (vm.current_gc_p) {
            _ = current_sample.gc_sample_count.fetchAdd(samples, .monotonic);
        }
        if (vm.current_jit_count > 0) {
            _ = current_sample.jit_sample_count.fetchAdd(samples, .monotonic);
        }
        const code_heap = vm.code orelse return;
        if (code_heap.seg) |seg| {
            if (!seg.contains(pc)) {
                _ = current_sample.foreign_sample_count.fetchAdd(samples, .monotonic);
            }
        }
    }

    try armSafepoint(vm);
}

// Handle a safepoint fault
// Called from the signal handler when code touches the protected safepoint page.
// On macOS, profiler safepoints are handled directly in the Mach handler
// (recordSampleFromMach), so this path is primarily for FEP and Unix signals.
pub fn handleSafepoint(vm: *vm_mod.FactorVM, pc: Cell) !void {
    // Disarm the safepoint so we can run without faulting again
    try disarmSafepoint(vm);
    vm.vm_asm.faulting_p = false;

    // Check if a debugger interrupt was requested
    if (safepoint_fep_p.load(.monotonic)) {
        // If profiler is active, stop it before entering debugger
        if (sampling_profiler_p.load(.monotonic)) {
            endSamplingProfiler(vm);
        }

        // On Windows with Ctrl-Break, throw an exception instead of entering debugger
        if (vm.stop_on_ctrl_break) {
            safepoint_fep_p.store(false, .monotonic);
            return;
        }

        // Enter the low-level debugger (Factor Error Protocol)
        vm.factorbug();

        safepoint_fep_p.store(false, .monotonic);
    }
    // Check if sampling profiler wants to record a sample
    else if (sampling_profiler_p.load(.monotonic)) {
        const code_heap = vm.code orelse return;

        // Verify we're in the code segment
        if (code_heap.seg) |seg| {
            if (!seg.contains(pc)) {
                return;
            }
        }

        // Find the code block and check if we're at a prolog
        const block = code_heap.codeBlockForAddress(pc) orelse return;
        const prolog_p = block.entryPoint() == pc;

        // Record the sample
        recordSample(vm, prolog_p);
    }

    // Disarm again in case SIGALRM re-armed the safepoint during processing.
    disarmSafepoint(vm) catch {};
}

// --- Heap-based growable array for sample callstacks ---
// The C++ VM stores a two-element Factor array [tagFixnum(count), contents_array]
// in special_objects[OBJ_SAMPLE_CALLSTACKS]. We replicate the same layout.

fn allocSampleCallstacks(vm: *vm_mod.FactorVM) ?Cell {
    // Allocate initial contents array (capacity 10)
    const contents = vm.allotUninitializedArray(10) orelse return null;

    // Root contents since the next allot can trigger GC
    var contents_root = contents;
    vm.data_roots.append(vm.allocator, &contents_root) catch return null;
    defer _ = vm.data_roots.pop();

    // Allocate the 2-element wrapper array
    const wrapper = vm.allotUninitializedArray(2) orelse return null;
    const wrapper_arr: *layouts.Array = @ptrFromInt(layouts.UNTAG(wrapper));
    const data = wrapper_arr.data();
    data[0] = layouts.tagFixnum(0); // count = 0
    data[1] = contents_root; // contents array
    return wrapper;
}

fn sampleCallstacksCount(wrapper_cell: Cell) Cell {
    const wrapper: *layouts.Array = @ptrFromInt(layouts.UNTAG(wrapper_cell));
    return layouts.untagFixnumUnsigned(wrapper.data()[0]);
}

pub fn sampleCallstacksNth(wrapper_cell: Cell, index: Cell) Cell {
    const wrapper: *layouts.Array = @ptrFromInt(layouts.UNTAG(wrapper_cell));
    const contents_cell = wrapper.data()[1];
    const contents: *layouts.Array = @ptrFromInt(layouts.UNTAG(contents_cell));
    return contents.data()[index];
}

// Add an element to the heap growable array. wrapper_ptr is a pointer to the
// tagged wrapper cell (must be rooted by caller). Allocates memory.
fn sampleCallstacksAdd(vm: *vm_mod.FactorVM, wrapper_ptr: *Cell, elt: Cell) void {
    // Root elt since reallotArray can trigger GC
    var elt_root = elt;
    vm.data_roots.append(vm.allocator, &elt_root) catch return;
    defer _ = vm.data_roots.pop();

    var wrapper: *layouts.Array = @ptrFromInt(layouts.UNTAG(wrapper_ptr.*));
    const count = layouts.untagFixnumUnsigned(wrapper.data()[0]);

    // Get contents array and check capacity
    var contents_cell = wrapper.data()[1];
    var contents: *layouts.Array = @ptrFromInt(layouts.UNTAG(contents_cell));
    const cap = contents.getCapacity();

    if (count == cap) {
        // Need to grow - root contents
        vm.data_roots.append(vm.allocator, &contents_cell) catch return;
        defer _ = vm.data_roots.pop();

        const new_contents = vm.reallotArray(contents_cell, 2 * count) orelse return;
        contents_cell = new_contents;

        // Re-derive wrapper after potential GC
        wrapper = @ptrFromInt(layouts.UNTAG(wrapper_ptr.*));
        wrapper.data()[1] = contents_cell;
    }

    // Re-derive contents after potential GC
    contents = @ptrFromInt(layouts.UNTAG(contents_cell));
    contents.data()[count] = elt_root;

    // Write barrier
    vm.writeBarrierKnownHeapWithValue(&contents.data()[count], elt_root);

    // Increment count
    wrapper = @ptrFromInt(layouts.UNTAG(wrapper_ptr.*));
    wrapper.data()[0] = layouts.tagFixnum(@as(Fixnum, @intCast(count + 1)));
}

// Iterator struct for callstack walking during profiling
const ProfilerIterator = struct {
    vm: *vm_mod.FactorVM,
    callstacks_ptr: *Cell,
    skip_p: bool,

    pub fn call(self: *ProfilerIterator, _: Cell, _: Cell, block: *const CodeBlock, _: Cell) void {
        if (self.skip_p) {
            self.skip_p = false;
            return;
        }
        sampleCallstacksAdd(self.vm, self.callstacks_ptr, block.owner);
    }
};

// Drain atomic counters into a local snapshot, subtracting atomically.
fn drainCounters() SampleRecord {
    const sc = current_sample.sample_count.load(.monotonic);
    const gc_sc = current_sample.gc_sample_count.load(.monotonic);
    const jit_sc = current_sample.jit_sample_count.load(.monotonic);
    const foreign_sc = current_sample.foreign_sample_count.load(.monotonic);
    const foreign_thread_sc = current_sample.foreign_thread_sample_count.load(.monotonic);

    _ = current_sample.sample_count.fetchSub(sc, .monotonic);
    _ = current_sample.gc_sample_count.fetchSub(gc_sc, .monotonic);
    _ = current_sample.jit_sample_count.fetchSub(jit_sc, .monotonic);
    _ = current_sample.foreign_sample_count.fetchSub(foreign_sc, .monotonic);
    _ = current_sample.foreign_thread_sample_count.fetchSub(foreign_thread_sc, .monotonic);

    return .{
        .thread = 0,
        .callstack_begin = 0,
        .callstack_end = 0,
        .sample_count = sc,
        .gc_sample_count = gc_sc,
        .jit_sample_count = jit_sc,
        .foreign_sample_count = foreign_sc,
        .foreign_thread_sample_count = foreign_thread_sc,
    };
}

// Record a profiling sample by draining atomic counters and walking the callstack.
// vm_asm.ctx.callstack_top must be set to the current callstack position before calling.
// For prolog safepoints: skip_p=true, current_owner=null (first frame is the caller's
//   return address which we skip since it's the function we're entering).
// For non-prolog safepoints: skip_p=false, current_owner=block.owner (we manually
//   record the current function since its frame can't be walked normally).
fn recordSampleImpl(vm: *vm_mod.FactorVM, skip_p: bool, current_owner: ?Cell) void {
    var counts = drainCounters();
    if (counts.sample_count == 0) return;

    // Get the growarr for callstacks
    var callstacks_cell = vm.specialObject(.sample_callstacks);
    if (callstacks_cell == layouts.false_object or callstacks_cell == 0) return;

    // Root the growarr since callstack walking adds to it (allocates)
    vm.data_roots.append(vm.allocator, &callstacks_cell) catch return;
    defer _ = vm.data_roots.pop();

    const callstack_begin = sampleCallstacksCount(callstacks_cell);

    // For non-prolog safepoints, record the current function's owner first
    if (current_owner) |owner| {
        sampleCallstacksAdd(vm, &callstacks_cell, owner);
    }

    // Walk callstack and add code block owners
    const ctx = vm.vm_asm.ctx;
    var iter = ProfilerIterator{
        .vm = vm,
        .callstacks_ptr = &callstacks_cell,
        .skip_p = skip_p,
    };
    callstack.iterateCallstack(vm, ctx, ProfilerIterator, &iter);

    const callstack_end = sampleCallstacksCount(callstacks_cell);

    // Update special object in case GC moved it
    vm.setSpecialObject(.sample_callstacks, callstacks_cell);

    // Build sample record
    counts.thread = vm.specialObject(.current_thread);
    counts.callstack_begin = callstack_begin;
    counts.callstack_end = callstack_end;

    vm.profiling_samples.append(vm.allocator, counts) catch return;
}

fn recordSample(vm: *vm_mod.FactorVM, prolog_p: bool) void {
    recordSampleImpl(vm, prolog_p, null);
}

fn recordSampleWithCurrentOwner(vm: *vm_mod.FactorVM, current_owner: Cell) void {
    recordSampleImpl(vm, false, current_owner);
}

// Record a sample directly from the Mach exception handler thread.
// The faulted thread is suspended, so its callstack is frozen and walkable.
// This avoids the signal handler word dispatch entirely.
pub fn recordSampleFromMach(vm: *vm_mod.FactorVM, fault_pc: Cell, thread_sp: Cell) void {
    const code_heap = vm.code orelse return;
    if (code_heap.seg) |seg| {
        if (!seg.contains(fault_pc)) return;
    }
    const block = code_heap.codeBlockForAddress(fault_pc) orelse return;
    const prolog_p = block.entryPoint() == fault_pc;

    // Determine the correct callstack_top for the walk.
    // For prolog safepoints (at function entry): RSP points to the return
    // address pushed by `call` — this IS the correct callstack_top.
    // For non-prolog safepoints (mid-function): the function's frame has
    // been set up, so RSP is inside the frame. The caller's return address
    // is at RSP + (frame_size - sizeof(Cell)). We also need to manually
    // record the current function's owner since the walk won't see it.
    var walk_top = thread_sp;
    if (!prolog_p) {
        const frame_size = block.stackFrameSize();
        if (frame_size > 0) {
            walk_top = thread_sp + frame_size - @sizeOf(Cell);
        }
    }

    const ctx = vm.vm_asm.ctx;
    const saved_top = ctx.callstack_top;
    ctx.callstack_top = walk_top;
    defer ctx.callstack_top = saved_top;

    if (!prolog_p) {
        // For non-prolog: record the current function's owner before walking
        recordSampleWithCurrentOwner(vm, block.owner);
    } else {
        recordSample(vm, true);
    }
}

// itimerval and setitimer definitions for Unix platforms
const itimerval = extern struct {
    it_interval: std.posix.timeval,
    it_value: std.posix.timeval,
};

const ITIMER_REAL: c_int = 0;

extern "c" fn setitimer(which: c_int, new_value: *const itimerval, old_value: ?*itimerval) c_int;

// Start the sampling profiler
pub fn startSamplingProfiler(vm: *vm_mod.FactorVM, samples_per_second: Cell) !void {
    // Allocate the heap growable array for callstack entries
    const callstacks = allocSampleCallstacks(vm) orelse return error.AllocFailed;
    vm.setSpecialObject(.sample_callstacks, callstacks);

    vm.samples_per_second = @intCast(samples_per_second);
    current_sample.reset();

    // Clear previous samples
    vm.profiling_samples.clearRetainingCapacity();
    vm.profiling_samples.ensureTotalCapacity(vm.allocator, 10 * samples_per_second) catch {};

    // Set both the atomic flag (checked in handleSafepoint) and the VM field
    // (checked in sampleSignalHandler in signals.zig)
    vm.sampling_profiler_p = true;
    sampling_profiler_p.store(true, .monotonic);

    // Set up timer to fire at the specified rate
    const interval_usec: i64 = @intCast(1_000_000 / samples_per_second);
    const timer = itimerval{
        .it_value = .{
            .sec = 0,
            .usec = @intCast(interval_usec),
        },
        .it_interval = .{
            .sec = 0,
            .usec = @intCast(interval_usec),
        },
    };

    const result = setitimer(ITIMER_REAL, &timer, null);
    if (result != 0) {
        return error.SetTimerFailed;
    }
}

// End the sampling profiler
pub fn endSamplingProfiler(vm: *vm_mod.FactorVM) void {
    vm.sampling_profiler_p = false;
    sampling_profiler_p.store(false, .monotonic);

    // Stop the timer
    const timer = itimerval{
        .it_value = .{ .sec = 0, .usec = 0 },
        .it_interval = .{ .sec = 0, .usec = 0 },
    };
    _ = setitimer(ITIMER_REAL, &timer, null);

    // Drain any remaining samples
    recordSample(vm, false);
}

// Initialize safepoint system
// This is called when the code heap is created
pub fn initSafepoints(vm: *vm_mod.FactorVM) !void {
    const code_heap = vm.code orelse return error.NoCodeHeap;

    // Safepoint page is already set to seg.start in code heap initialization
    // Just verify it's set
    if (code_heap.safepoint_page == 0) {
        return error.NoSafepointPage;
    }

    // Initially the page is unprotected (readable/writable)
    // It will be armed when needed (GC, interrupt, profiler)
    try disarmSafepoint(vm);
}

// Cleanup safepoint system
pub fn deinitSafepoints(vm: *vm_mod.FactorVM) void {
    // Best-effort cleanup: if mprotect fails during shutdown, nothing to do
    disarmSafepoint(vm) catch {};
}

const testing = std.testing;

// This test demonstrates how the safepoint system works
test "safepoint page protection" {
    // Create a VM
    var vm = try vm_mod.FactorVM.init(std.testing.allocator);
    defer vm.deinit();

    vm.vm_asm.ctx = try vm.newContext();
    vm.vm_asm.spare_ctx = try vm.newContext();

    // Create an executable segment for the safepoint page
    const page_size = segments.page_size;
    var seg = try segments.Segment.init(page_size + 64 * 1024, true);
    defer seg.deinit();

    // Create a CodeHeap with safepoint page at segment start
    const code_heap = try std.testing.allocator.create(vm_mod.CodeHeap);
    defer std.testing.allocator.destroy(code_heap);
    code_heap.* = .{
        .seg = undefined,
        .safepoint_page = seg.start,
        .code_start = seg.start + page_size,
        .code_size = 64 * 1024,
        .remembered_sets = write_barrier.CodeHeapRememberedSets.init(std.testing.allocator),
    };

    vm.code = code_heap;

    // Verify safepoint page is set
    try testing.expect(code_heap.safepoint_page != 0);

    // Initially the page should be unprotected (can be armed for safepoint)
    try disarmSafepoint(vm);

    // Arm the safepoint (protect the page)
    try armSafepoint(vm);

    // Check if an address on the safepoint page is detected
    const safepoint_addr = code_heap.safepoint_page + 100; // arbitrary offset in the page
    try testing.expect(isSafepoint(vm, safepoint_addr));

    // Check that an address NOT on the safepoint page is not detected
    const code_start = code_heap.safepoint_page + page_size;
    const code_addr = code_start + 100;
    try testing.expect(!isSafepoint(vm, code_addr));

    // Disarm the safepoint (unprotect the page)
    try disarmSafepoint(vm);
}

// Test profiling sample accumulation
test "profiling samples" {
    // Reset sample counters
    current_sample.reset();

    // Verify initial state
    try testing.expectEqual(@as(u64, 0), current_sample.sample_count.load(.monotonic));

    // Simulate recording samples
    _ = current_sample.sample_count.fetchAdd(5, .monotonic);
    _ = current_sample.gc_sample_count.fetchAdd(2, .monotonic);

    // Verify counters
    try testing.expectEqual(@as(u64, 5), current_sample.sample_count.load(.monotonic));
    try testing.expectEqual(@as(u64, 2), current_sample.gc_sample_count.load(.monotonic));

    // Reset
    current_sample.reset();
    try testing.expectEqual(@as(u64, 0), current_sample.sample_count.load(.monotonic));
}

// Test atomic flags
test "safepoint atomic flags" {
    // Initially false
    try testing.expect(!safepoint_fep_p.load(.monotonic));
    try testing.expect(!sampling_profiler_p.load(.monotonic));

    // Set flags
    safepoint_fep_p.store(true, .monotonic);
    sampling_profiler_p.store(true, .monotonic);

    // Verify
    try testing.expect(safepoint_fep_p.load(.monotonic));
    try testing.expect(sampling_profiler_p.load(.monotonic));

    // Clear flags
    safepoint_fep_p.store(false, .monotonic);
    sampling_profiler_p.store(false, .monotonic);

    // Verify
    try testing.expect(!safepoint_fep_p.load(.monotonic));
    try testing.expect(!sampling_profiler_p.load(.monotonic));
}
