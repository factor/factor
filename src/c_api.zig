// c_api.zig - C API functions exported for Factor compiled code
// These functions are called by Factor code via dlsym relocations
//
// Factor's compiled code expects these functions to be available at runtime.
// They're called via dlsym lookups from the code heap.

const std = @import("std");

const bignum = @import("bignum.zig");
const code_blocks = @import("code_blocks.zig");
const contexts = @import("contexts.zig");
const image = @import("image.zig");
const inline_cache = @import("inline_cache.zig");
const layouts = @import("layouts.zig");
const fixnum = @import("fixnum.zig");
const vm_mod = @import("vm.zig");

const Cell = layouts.Cell;
const Context = contexts.Context;
const FactorVM = vm_mod.FactorVM;
const Fixnum = layouts.Fixnum;
const VMAssemblyFields = vm_mod.VMAssemblyFields;

const PTHREAD_CANCEL_ASYNCHRONOUS = 0; // macOS value (2 is DEFERRED)

pub extern "c" fn pthread_setcanceltype(ty: c_int, old_ty: ?*c_int) c_int;

// Fixnum range (60 bits on 64-bit systems, accounting for 4-bit tag)
const fixnum_min: Fixnum = std.math.minInt(Fixnum) >> @intCast(layouts.tag_bits);
const fixnum_max: Fixnum = std.math.maxInt(Fixnum) >> @intCast(layouts.tag_bits);

// Force the linker to retain all exported functions that Factor resolves via dlsym.
// Without this, Release builds eliminate these "unused" functions via dead code elimination,
// causing dlsym failures at runtime. The exported symbol table is referenced from main.zig.

// Global VM pointer for C callbacks
var global_vm: ?*FactorVM = null;

// Global Io interface for file operations (set once in main)
pub var global_io: std.Io = undefined;
pub var global_io_initialized: bool = false;

// ============================================================================
// Stdin Handling (Unix)
// ============================================================================

/// Pipe for stdin data: stdin_thread reads from fd 0, writes to stdin_write; Factor reads from stdin_read
pub export var stdin_read: c_int = -1;
pub export var stdin_write: c_int = -1;

/// Pipe for control: Factor writes 'X' to control_write to request a read; stdin_thread reads from control_read
pub export var control_read: c_int = -1;
pub export var control_write: c_int = -1;

/// Pipe for size: stdin_thread writes byte count to size_write after reading; Factor reads from size_read
pub export var size_read: c_int = -1;
pub export var size_write: c_int = -1;

/// Whether the stdin thread has been initialized
pub export var stdin_thread_initialized_p: bool = false;

// Stdin thread handle
var stdin_thread: ?std.Thread = null;

// Native pthread handle for sending signals
var stdin_pthread: std.c.pthread_t = undefined;

const SpinMutex = @import("mutex.zig").SpinMutex;
var stdin_mutex: SpinMutex = .{};

// Flag to signal stdin thread to stop
var stdin_loop_running: std.atomic.Value(bool) = std.atomic.Value(bool).init(true);

// The stdin loop function that runs in a background thread.
fn stdinLoop() void {
    // Set up signal mask: block all signals except SIGUSR2, SIGTTIN, SIGTERM, SIGQUIT
    var mask: std.c.sigset_t = undefined;
    _ = std.c.sigfillset(&mask);
    _ = std.c.sigdelset(&mask, .USR2);
    _ = std.c.sigdelset(&mask, .TTIN);
    _ = std.c.sigdelset(&mask, .TERM);
    _ = std.c.sigdelset(&mask, .QUIT);
    var old_mask = std.posix.sigemptyset();
    _ = std.c.pthread_sigmask(std.c.SIG.SETMASK, &mask, &old_mask);

    // Enable async cancellation so pthread_cancel can interrupt blocking reads
    _ = std.c.pthread_setcancelstate(.ENABLE, null);
    _ = pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, null);

    var buf: [4096]u8 = undefined;

    while (stdin_loop_running.load(.acquire)) {
        // Wait for control signal ('X') from Factor
        var control_buf: [1]u8 = undefined;
        const ctrl_result = std.c.read(@intCast(control_read), &control_buf, control_buf.len);
        if (ctrl_result < 0) {
            if (std.c._errno().* == @intFromEnum(std.posix.E.INTR)) continue;
            break;
        }
        const ctrl_bytes: usize = @intCast(ctrl_result);

        if (ctrl_bytes == 0) break;
        if (control_buf[0] != 'X') break;

        // Read from actual stdin (fd 0)
        while (stdin_loop_running.load(.acquire)) {
            stdin_mutex.lock();
            stdin_mutex.unlock();

            const read_result = std.c.read(0, &buf, buf.len);
            if (read_result < 0) {
                if (std.c._errno().* == @intFromEnum(std.posix.E.INTR)) continue;
                stdin_loop_running.store(false, .release);
                break;
            }
            const bytes_read: usize = @intCast(read_result);

            // Write the byte count to size_write (as a native integer)
            var size_val: isize = @intCast(bytes_read);
            const size_bytes: [*]const u8 = @ptrCast(&size_val);
            if (std.c.write(@intCast(size_write), size_bytes, @sizeOf(isize)) < 0) {
                stdin_loop_running.store(false, .release);
                break;
            }

            // Write the data to stdin_write
            if (bytes_read > 0) {
                if (std.c.write(@intCast(stdin_write), buf[0..bytes_read].ptr, bytes_read) < 0) {
                    stdin_loop_running.store(false, .release);
                    break;
                }
            }

            break; // Go back to waiting for next control signal
        }
    }

    // Close our ends of the pipes
    _ = std.c.close(@intCast(stdin_write));
    _ = std.c.close(@intCast(control_read));
}

// Create a pipe with FD_CLOEXEC set on both ends (matching C++ safe_pipe)
fn safePipe() ?[2]c_int {
    var filedes: [2]c_int = undefined;

    if (std.c.pipe(&filedes) < 0) {
        return null;
    }

    const F_SETFD: c_int = 2;
    const FD_CLOEXEC: c_int = 1;

    if (std.c.fcntl(filedes[0], F_SETFD, FD_CLOEXEC) < 0) {
        _ = std.c.close(filedes[0]);
        _ = std.c.close(filedes[1]);
        return null;
    }

    if (std.c.fcntl(filedes[1], F_SETFD, FD_CLOEXEC) < 0) {
        _ = std.c.close(filedes[0]);
        _ = std.c.close(filedes[1]);
        return null;
    }

    return filedes;
}

/// Initialize stdin handling pipes
pub export fn open_console() callconv(.c) void {
    if (stdin_thread_initialized_p) return;

    const control_pipe = safePipe() orelse return;
    const size_pipe = safePipe() orelse {
        _ = std.c.close(control_pipe[0]);
        _ = std.c.close(control_pipe[1]);
        return;
    };
    const stdin_pipe = safePipe() orelse {
        _ = std.c.close(control_pipe[0]);
        _ = std.c.close(control_pipe[1]);
        _ = std.c.close(size_pipe[0]);
        _ = std.c.close(size_pipe[1]);
        return;
    };

    control_read = control_pipe[0];
    control_write = control_pipe[1];
    size_read = size_pipe[0];
    size_write = size_pipe[1];
    stdin_read = stdin_pipe[0];
    stdin_write = stdin_pipe[1];

    // Start the stdin thread
    stdin_loop_running.store(true, .release);
    const thread = std.Thread.spawn(.{}, stdinLoop, .{}) catch {
        _ = std.c.close(control_pipe[0]);
        _ = std.c.close(control_pipe[1]);
        _ = std.c.close(size_pipe[0]);
        _ = std.c.close(size_pipe[1]);
        _ = std.c.close(stdin_pipe[0]);
        _ = std.c.close(stdin_pipe[1]);
        control_read = -1;
        control_write = -1;
        size_read = -1;
        size_write = -1;
        stdin_read = -1;
        stdin_write = -1;
        return;
    };
    stdin_thread = thread;
    stdin_pthread = thread.getHandle();

    stdin_thread_initialized_p = true;
}

/// Close stdin handling pipes and stop the thread
pub export fn close_console() callconv(.c) void {
    if (!stdin_thread_initialized_p) return;

    // Signal thread to stop
    stdin_loop_running.store(false, .release);

    // Close control_write to unblock the thread's read on control_read
    if (control_write >= 0) {
        _ = std.c.close(control_write);
        control_write = -1;
    }

    // Close stdin_write to unblock any read on stdin_read
    if (stdin_write >= 0) {
        _ = std.c.close(stdin_write);
        stdin_write = -1;
    }

    // Cancel the thread and wait for it to exit
    if (stdin_thread != null) {
        _ = std.c.pthread_cancel(stdin_pthread);
        _ = std.c.pthread_join(stdin_pthread, null);
        stdin_thread = null;
    }

    // Close remaining pipes
    if (stdin_read >= 0) _ = std.c.close(stdin_read);
    if (size_read >= 0) _ = std.c.close(size_read);
    if (size_write >= 0) _ = std.c.close(size_write);

    stdin_read = -1;
    stdin_write = -1;
    control_read = -1;
    size_read = -1;
    size_write = -1;
    stdin_thread_initialized_p = false;
}

/// Lock the console - used by FEP (debugger) to interrupt stdin reads
pub export fn lock_console() callconv(.c) void {
    if (!stdin_thread_initialized_p) return;
    stdin_mutex.lock();
    _ = std.c.pthread_kill(stdin_pthread, .USR2);
}

/// Unlock the console - allows stdin reads to resume
pub export fn unlock_console() callconv(.c) void {
    if (!stdin_thread_initialized_p) return;
    stdin_mutex.unlock();
}

pub fn setGlobalVM(vm: *FactorVM) void {
    global_vm = vm;
}

// ============================================================================
// Context Management
// ============================================================================

/// Called when entering Factor from C (callback entry point)
pub export fn begin_callback(vm_asm: *VMAssemblyFields, quot: Cell) callconv(.c) Cell {
    const parent = vm_asm.getVM();

    // Root the quotation against GC - initContext allocates, which can trigger GC
    var rooted_quot = quot;
    parent.data_roots.append(parent.allocator, &rooted_quot) catch @panic("OOM");
    defer _ = parent.data_roots.pop();

    // Reset the current context
    parent.vm_asm.ctx.reset();

    // CRITICAL: Always create a NEW spare context (like C++)
    parent.vm_asm.spare_ctx = parent.newContext() catch @panic("OOM");

    // Track callback
    parent.callback_ids.append(parent.allocator, @intCast(parent.callback_id)) catch @panic("OOM");
    parent.callback_id += 1;

    // Initialize context with alien for self-reference (like C++ init_context)
    parent.initContext(parent.vm_asm.ctx);

    return rooted_quot;
}

/// Called when returning from Factor to C (callback exit)
pub export fn end_callback(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const parent = vm_asm.getVM();

    // Pop callback id
    if (parent.callback_ids.items.len > 0) {
        _ = parent.callback_ids.pop();
    }

    // Delete current context and switch to spare
    parent.deleteContext();
}

/// Create a new context
pub export fn new_context(vm_asm: *VMAssemblyFields) callconv(.c) ?*Context {
    const parent = vm_asm.getVM();
    const ctx = parent.newContext() catch return null;
    parent.initContext(ctx);
    return ctx;
}

/// Delete the current context
pub export fn delete_context(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const parent = vm_asm.getVM();
    parent.deleteContext();
}

/// Reset the current context
pub export fn reset_context(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const parent = vm_asm.getVM();
    const ctx = parent.vm_asm.ctx;
    const arg1 = ctx.pop();
    const arg2 = ctx.pop();
    ctx.reset();
    ctx.push(arg2);
    ctx.push(arg1);
    parent.initContext(ctx);
}

// ============================================================================
// JIT and Compilation
// ============================================================================

/// Lazy JIT compile a quotation
pub export fn lazy_jit_compile(quot: Cell, vm_asm: *VMAssemblyFields) callconv(.c) Cell {
    const parent = vm_asm.getVM();
    const jit_mod = @import("jit.zig");
    return jit_mod.lazyJitCompile(parent, quot);
}

// ============================================================================
// Inline Cache
// ============================================================================

/// Handle inline cache miss
pub export fn inline_cache_miss(return_address: Cell, vm_asm: *VMAssemblyFields) callconv(.c) Cell {
    const parent = vm_asm.getVM();
    return inline_cache.inlineCacheMiss(parent, return_address);
}

// ============================================================================
// Math Operations (overflow handling)
// ============================================================================

/// Handle fixnum addition overflow - promote to bignum.
pub export fn overflow_fixnum_add(x: Fixnum, y: Fixnum, vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ux = x >> @intCast(layouts.tag_bits);
    const uy = y >> @intCast(layouts.tag_bits);
    const sum = ux + uy;
    const bn = fixnum.toBignum(vm, sum) catch
        @panic("overflow_fixnum_add: out of memory");
    vm.replace(layouts.tagBignum(bn));
}

/// Handle fixnum subtraction overflow - promote to bignum.
pub export fn overflow_fixnum_subtract(x: Fixnum, y: Fixnum, vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ux = x >> @intCast(layouts.tag_bits);
    const uy = y >> @intCast(layouts.tag_bits);
    const diff = ux - uy;
    const bn = fixnum.toBignum(vm, diff) catch
        @panic("overflow_fixnum_subtract: out of memory");
    vm.replace(layouts.tagBignum(bn));
}

/// Handle fixnum multiplication overflow - promote to bignum.
pub export fn overflow_fixnum_multiply(x: Fixnum, y: Fixnum, vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const bx = fixnum.toBignum(vm, x) catch
        @panic("overflow_fixnum_multiply: out of memory");
    var bx_cell: Cell = layouts.tagBignum(bx);
    vm.data_roots.append(vm.allocator, &bx_cell) catch
        @panic("overflow_fixnum_multiply: out of memory");
    defer _ = vm.data_roots.pop();

    const by = fixnum.toBignum(vm, y) catch
        @panic("overflow_fixnum_multiply: out of memory");
    var by_cell: Cell = layouts.tagBignum(by);
    vm.data_roots.append(vm.allocator, &by_cell) catch
        @panic("overflow_fixnum_multiply: out of memory");
    defer _ = vm.data_roots.pop();

    const bx_ptr: *const layouts.Bignum = @ptrFromInt(layouts.UNTAG(bx_cell));
    const by_ptr: *const layouts.Bignum = @ptrFromInt(layouts.UNTAG(by_cell));
    const result = bignum.multiply(vm, bx_ptr, by_ptr) catch
        @panic("overflow_fixnum_multiply: out of memory");
    vm.replace(layouts.tagBignum(result));
}

// ============================================================================
// Integer Conversion
// ============================================================================

/// Convert signed cell to Factor integer
pub export fn from_signed_cell(integer: Fixnum, vm_asm: *VMAssemblyFields) callconv(.c) Cell {
    if (integer >= fixnum_min and integer <= fixnum_max) {
        return layouts.tagFixnum(integer);
    }
    const vm = vm_asm.getVM();
    const bn = fixnum.toBignum(vm, integer) catch
        @panic("from_signed_cell: out of memory");
    return layouts.tagBignum(bn);
}

/// Convert unsigned cell to Factor integer
pub export fn from_unsigned_cell(integer: Cell, vm_asm: *VMAssemblyFields) callconv(.c) Cell {
    if (integer <= @as(Cell, @intCast(fixnum_max))) {
        return layouts.tagFixnum(@intCast(integer));
    }
    const vm = vm_asm.getVM();
    const signed_val: Fixnum = @bitCast(integer);
    if (signed_val >= 0) {
        const bn = fixnum.toBignum(vm, signed_val) catch
            @panic("from_unsigned_cell: out of memory");
        return layouts.tagBignum(bn);
    }
    // Value has high bit set (> i64 max). Need a 2-digit bignum.
    const bn = bignum.allocBignum(vm, 2, false) catch
        @panic("from_unsigned_cell: out of memory");
    bn.setDigit(0, integer & bignum.DIGIT_MASK);
    bn.setDigit(1, integer >> bignum.DIGIT_BITS);
    return layouts.tagBignum(bn);
}

/// Convert signed 64-bit to Factor integer
pub export fn from_signed_8(n: i64, vm_asm: *VMAssemblyFields) callconv(.c) Cell {
    return from_signed_cell(@intCast(n), vm_asm);
}

/// Convert unsigned 64-bit to Factor integer
pub export fn from_unsigned_8(n: u64, vm_asm: *VMAssemblyFields) callconv(.c) Cell {
    return from_unsigned_cell(n, vm_asm);
}

/// Convert signed 32-bit to Factor integer
pub export fn from_signed_4(n: i32, vm_asm: *VMAssemblyFields) callconv(.c) Cell {
    return from_signed_cell(n, vm_asm);
}

/// Convert unsigned 32-bit to Factor integer
pub export fn from_unsigned_4(n: u32, vm_asm: *VMAssemblyFields) callconv(.c) Cell {
    return from_unsigned_cell(n, vm_asm);
}

// ============================================================================
// Utility Functions
// ============================================================================

extern "c" fn __error() *c_int;

/// Get errno
pub export fn err_no() callconv(.c) c_int {
    return __error().*;
}

/// Set errno
pub export fn set_err_no(err: c_int) callconv(.c) void {
    __error().* = err;
}

/// memcpy wrapper - used by set-callstack inline code
pub export fn factor_memcpy(dst: ?*anyopaque, src: ?*const anyopaque, len: usize) callconv(.c) ?*anyopaque {
    const d_ptr = dst orelse return dst;
    const s_ptr = src orelse return dst;
    const d: [*]u8 = @ptrCast(d_ptr);
    const s: [*]const u8 = @ptrCast(s_ptr);
    @memcpy(d[0..len], s[0..len]);
    return d_ptr;
}

// ============================================================================
// GC Functions
// ============================================================================

/// Trigger minor GC
pub export fn minor_gc(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const parent = vm_asm.getVM();
    parent.minorGc();
}

/// Trigger full GC
pub export fn full_gc(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const parent = vm_asm.getVM();
    parent.fullGc();
}

// ============================================================================
// Undefined Symbol Handler
// ============================================================================

/// Called when Factor code tries to call an FFI function that wasn't found.
/// Uses the return address to find which symbol was being called by looking
/// up the code block and scanning its relocation table for RT_DLSYM entries.
pub export fn undefined_symbol() callconv(.c) void {
    const vm = global_vm orelse {
        std.debug.print("\nFATAL: undefined_symbol called with no global VM\n", .{});
        std.process.abort();
    };

    const ctx = vm.vm_asm.ctx;

    const frame = ctx.callstack_top;
    const return_address: Cell = @as(*const Cell, @ptrFromInt(frame)).*;

    // Find the code block and relocation entry
    var symbol: Cell = layouts.false_object;
    var library: Cell = layouts.false_object;

    if (vm.code) |code| {
        if (code.codeBlockForAddress(return_address)) |block| {
            const dlsym_result = findDlsymRelocation(block, return_address);
            symbol = dlsym_result.symbol;
            library = dlsym_result.library;
        }
    }

    if (symbol == layouts.false_object) {
        std.debug.print("\nFATAL: Cannot find RT_DLSYM at return address 0x{x}\n", .{return_address});
        std.debug.print("Entering low-level debugger (factorbug)...\n", .{});
        vm.factorbug();
        std.process.abort();
    }

    // Print what symbol is missing
    std.debug.print("\nUndefined symbol at 0x{x}: ", .{return_address});
    if (layouts.hasTag(symbol, .byte_array)) {
        const ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(symbol));
        const cap = layouts.untagFixnum(ba.capacity);
        if (cap > 0 and cap < 256) {
            const name = ba.data()[0..@intCast(cap)];
            std.debug.print("{s}\n", .{name});
        } else {
            std.debug.print("(capacity={d})\n", .{cap});
        }
    } else {
        std.debug.print("(symbol=0x{x})\n", .{symbol});
    }

    // Raise a Factor-level error that can be caught
    vm.generalError(.undefined_symbol, symbol, library);
}

// Result of finding RT_DLSYM relocation
const DlsymResult = struct {
    symbol: Cell,
    library: Cell,
};

// Find the RT_DLSYM relocation at or near the given return address
fn findDlsymRelocation(block: *code_blocks.CodeBlock, return_address: Cell) DlsymResult {
    var result = DlsymResult{
        .symbol = layouts.false_object,
        .library = layouts.false_object,
    };

    const reloc_cell = block.relocation;
    if (reloc_cell == 0 or reloc_cell == layouts.false_object) return result;
    if (!layouts.hasTag(reloc_cell, .byte_array)) return result;

    const reloc_array: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(reloc_cell));
    const capacity = layouts.untagFixnumUnsigned(reloc_array.capacity);
    const entry_count = capacity / @sizeOf(code_blocks.RelocationEntry);

    // Get parameters array
    const params_cell = block.parameters;
    if (params_cell == 0 or params_cell == layouts.false_object) return result;
    if (!layouts.hasTag(params_cell, .array)) return result;
    const params: *layouts.Array = @ptrFromInt(layouts.UNTAG(params_cell));
    const params_capacity = layouts.untagFixnumUnsigned(params.capacity);

    const entry_point = block.entryPoint();
    const entries: [*]const code_blocks.RelocationEntry = @ptrCast(@alignCast(reloc_array.data()));

    // Scan relocations looking for RT_DLSYM entries near return_address
    var best_offset: Cell = 0;
    var best_param_index: Cell = 0;
    var found = false;

    var param_index: Cell = 0;
    for (0..entry_count) |i| {
        const entry = entries[i];
        const rel_type = entry.getType();
        const offset = entry.getOffset();
        const param_count = entry.numberOfParameters();

        if (rel_type == .dlsym) {
            const pointer = entry_point + offset;
            if (pointer < return_address and offset > best_offset) {
                best_offset = offset;
                best_param_index = param_index;
                found = true;
            }
        }

        param_index += param_count;
    }

    if (!found) return result;

    // Parameters for RT_DLSYM are at [param_index] = symbol, [param_index+1] = library
    if (best_param_index + 1 >= params_capacity) return result;

    const params_data = params.data();
    result.symbol = params_data[best_param_index];
    result.library = params_data[best_param_index + 1];

    return result;
}

// Find the RT_DLSYM relocation at or near the given return address and extract symbol name
fn findDlsymSymbolName(block: *code_blocks.CodeBlock, return_address: usize) ?[]const u8 {
    const reloc_cell = block.relocation;
    if (reloc_cell == 0 or reloc_cell == layouts.false_object) return null;
    if (!layouts.hasTag(reloc_cell, .byte_array)) return null;

    const reloc_array: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(reloc_cell));
    const capacity = layouts.untagFixnumUnsigned(reloc_array.capacity);
    const entry_count = capacity / @sizeOf(code_blocks.RelocationEntry);

    const params_cell = block.parameters;
    if (params_cell == 0 or params_cell == layouts.false_object) return null;
    if (!layouts.hasTag(params_cell, .array)) return null;
    const params: *layouts.Array = @ptrFromInt(layouts.UNTAG(params_cell));
    const params_capacity = layouts.untagFixnumUnsigned(params.capacity);

    const entry_point = block.entryPoint();
    const entries: [*]const code_blocks.RelocationEntry = @ptrCast(@alignCast(reloc_array.data()));

    var best_offset: Cell = 0;
    var best_param_index: Cell = 0;
    var found = false;

    var param_index: Cell = 0;
    for (0..entry_count) |i| {
        const entry = entries[i];
        const rel_type = entry.getType();
        const offset = entry.getOffset();
        const param_count = entry.numberOfParameters();

        if (rel_type == .dlsym) {
            const pointer = entry_point + offset;
            if (pointer < return_address and offset > best_offset) {
                best_offset = offset;
                best_param_index = param_index;
                found = true;
            }
        }

        param_index += param_count;
    }

    if (!found) return null;
    if (best_param_index + 1 >= params_capacity) return null;

    const symbol_alien = params.data()[best_param_index];
    const symbol_name = image.extractSymbolName(symbol_alien);
    if (symbol_name.len > 0) {
        return symbol_name;
    }

    return null;
}

// Tests
