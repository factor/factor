// primitives/io.zig - File I/O and image saving primitives

const std = @import("std");
const bignum = @import("../bignum.zig");
const io_mod = @import("../io.zig");
const layouts = @import("../layouts.zig");
const math = @import("../fixnum.zig");
const vm_mod = @import("../vm.zig");

const Cell = layouts.Cell;
const Fixnum = layouts.Fixnum;
const FactorVM = vm_mod.FactorVM;
const VMAssemblyFields = vm_mod.VMAssemblyFields;

// --- I/O Helper Functions ---

fn allotAlien(vm: *FactorVM, address: Cell) Cell {
    return vm.allotAlien(layouts.false_object, address);
}

fn popFileHandle(vm: *FactorVM) ?*std.c.FILE {
    const alien_cell = vm.pop();
    vm.checkTag(alien_cell, .alien);
    const alien: *const layouts.Alien = @ptrFromInt(layouts.UNTAG(alien_cell));
    const addr = alien.address;
    return if (addr == 0) null else @ptrFromInt(addr);
}

fn peekFileHandle(vm: *FactorVM) ?*std.c.FILE {
    const alien_cell = vm.peek();
    vm.checkTag(alien_cell, .alien);
    const alien: *const layouts.Alien = @ptrFromInt(layouts.UNTAG(alien_cell));
    const addr = alien.address;
    return if (addr == 0) null else @ptrFromInt(addr);
}

// --- Image Saving ---

pub export fn primitive_save_image(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( path1 path2 then-die? -- )
    // path1: temporary path for saving
    // path2: final path to move to
    // then-die?: if true, exit after saving

    // Pop arguments from stack before doing anything that could modify the heap
    const then_die_val = vm.pop();
    const path2_val = vm.pop();
    const path1_val = vm.pop();

    // Convert to boolean
    const then_die = then_die_val != layouts.false_object;

    // Extract paths from byte arrays
    // Check that both are byte arrays
    if (!layouts.hasTag(path1_val, .byte_array)) {
        vm.typeError(.byte_array, path1_val);
    }
    if (!layouts.hasTag(path2_val, .byte_array)) {
        vm.typeError(.byte_array, path2_val);
    }

    const path1_ba: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(path1_val));
    const path2_ba: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(path2_val));

    // Get path data as slices
    const path1_len = layouts.untagFixnumUnsigned(path1_ba.capacity);
    const path2_len = layouts.untagFixnumUnsigned(path2_ba.capacity);

    const path1_data = path1_ba.data();
    const path2_data = path2_ba.data();

    // Copy paths to stack-allocated buffers BEFORE GC — compact_gc will move
    // the byte arrays, invalidating any pointers into them.
    var path1_buf: [4096]u8 = undefined;
    var path2_buf: [4096]u8 = undefined;

    var path1_end: usize = 0;
    while (path1_end < path1_len and path1_end < path1_buf.len - 1 and path1_data[path1_end] != 0) : (path1_end += 1) {
        path1_buf[path1_end] = path1_data[path1_end];
    }
    path1_buf[path1_end] = 0;

    var path2_end: usize = 0;
    while (path2_end < path2_len and path2_end < path2_buf.len - 1 and path2_data[path2_end] != 0) : (path2_end += 1) {
        path2_buf[path2_end] = path2_data[path2_end];
    }
    path2_buf[path2_end] = 0;

    const path1_slice: [:0]const u8 = path1_buf[0..path1_end :0];
    const path2_slice: [:0]const u8 = path2_buf[0..path2_end :0];

    // If then_die is true, clear volatile data that shouldn't be saved
    if (then_die) {
        // Strip out special_objects data which is set on startup anyway
        const objects_mod = @import("../objects.zig");
        for (0..objects_mod.special_object_count) |i| {
            if (!objects_mod.isSaveSpecial(i)) {
                vm.vm_asm.special_objects[i] = layouts.false_object;
            }
        }

        // Don't trace objects only reachable from context stacks so we don't
        // get volatile data saved in the image
        vm.clearActiveContexts();

        // Clear uninitialized code blocks
        if (vm.code) |code| {
            code.clearUninitializedBlocks();
        }

        // Clear callback heap allocator
        if (vm.callbacks) |cb| {
            cb.free_list.initialFreeList(0);
        }
    }

    // Trigger compact GC to minimize image size
    const diagnostics = @import("diagnostics.zig");
    diagnostics.primitive_compact_gc(vm_asm);

    // Save the image using the image module
    const image_mod = @import("../image.zig");
    const success = image_mod.saveImage(vm, path1_slice, path2_slice) catch {
        if (then_die) {
            std.process.exit(1);
        }
        // Throw ERROR_IO with errno
        const errno_val: Fixnum = @intCast(std.c._errno().*);
        vm.ioError(errno_val);
    };

    if (then_die) {
        std.process.exit(if (success) 0 else 1);
    }

    if (!success) {
        // Throw ERROR_IO with errno
        const errno_val: Fixnum = @intCast(std.c._errno().*);
        vm.ioError(errno_val);
    }
}

// --- File I/O Primitives ---

pub export fn primitive_fopen(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( path mode -- file )
    const mode_cell = vm.pop();
    const path_cell = vm.pop();

    // Extract byte array contents
    if (!layouts.hasTag(mode_cell, .byte_array) or
        !layouts.hasTag(path_cell, .byte_array))
    {
        vm.push(layouts.false_object);
        return;
    }

    const mode_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(mode_cell));
    const path_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(path_cell));

    const mode_data: [*:0]const u8 = @ptrCast(mode_ba.data());
    const path_data: [*:0]const u8 = @ptrCast(path_ba.data());

    // Open file with EINTR handling
    const file = io_mod.safeFopen(path_data, mode_data) catch {
        vm.push(layouts.false_object);
        return;
    };

    // Use allotAlien helper
    const file_ptr: usize = @intFromPtr(file);
    const result = allotAlien(vm, file_ptr);
    if (result == layouts.false_object) {
        io_mod.safeFclose(file) catch @panic("fclose failed");
    }
    vm.push(result);
}

pub export fn primitive_fclose(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( file -- )
    const file = popFileHandle(vm) orelse return;
    io_mod.safeFclose(file) catch {
        // Error during close - Factor code should check errno if needed
    };
}

pub export fn primitive_fflush(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( file -- )
    const file = popFileHandle(vm) orelse return;
    io_mod.safeFflush(file) catch {
        // Error during flush
    };
}

pub export fn primitive_fgetc(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( file -- ch/f )
    const file = peekFileHandle(vm) orelse {
        vm.replace(layouts.false_object);
        return;
    };

    const c = io_mod.safeFgetc(file) catch {
        const errno_val: Fixnum = @intCast(std.c._errno().*);
        vm.ioError(errno_val);
    };

    const EOF: i32 = -1;
    if (c == EOF) {
        // EOF reached - clear the EOF indicator so subsequent reads can work
        io_mod.safeClearerr(file);
        vm.replace(layouts.false_object);
    } else {
        vm.replace(layouts.tagFixnum(@intCast(c)));
    }
}

pub export fn primitive_fputc(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( ch file -- )
    const file = popFileHandle(vm) orelse return;
    const ch = layouts.untagFixnum(vm.pop());
    io_mod.safeFputc(@intCast(ch), file) catch {
        const errno_val: Fixnum = @intCast(std.c._errno().*);
        vm.ioError(errno_val);
    };
}

pub export fn primitive_fread(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( n buf alien -- count )
    const file = popFileHandle(vm) orelse {
        vm.push(layouts.tagFixnum(0));
        return;
    };

    const buf_cell = vm.pop();
    const size_cell = vm.pop();

    const size = layouts.untagFixnum(size_cell);
    if (size <= 0) {
        vm.push(layouts.tagFixnum(0));
        return;
    }

    // Get buffer address from alien or byte_array
    const buf_tag = layouts.typeTag(buf_cell);
    var buffer: *anyopaque = undefined;

    if (buf_tag == .alien) {
        const alien: *const layouts.Alien = @ptrFromInt(layouts.UNTAG(buf_cell));
        // Use alien.address which is the precomputed untagged address
        const buf_addr = alien.address;
        if (buf_addr == 0) {
            vm.push(layouts.tagFixnum(0));
            return;
        }
        buffer = @ptrFromInt(buf_addr);
    } else if (buf_tag == .byte_array) {
        const byte_array: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(buf_cell));
        buffer = @constCast(byte_array.data());
    } else {
        vm.push(layouts.tagFixnum(0));
        return;
    }

    const bytes_read = io_mod.safeFread(buffer, 1, @intCast(size), file) catch {
        // Clear EOF indicator after error so file can be reused
        io_mod.safeClearerr(file);
        vm.push(layouts.tagFixnum(0));
        return;
    };

    // If we read less than requested, we may have hit EOF - clear the indicator
    if (bytes_read < @as(usize, @intCast(size))) {
        io_mod.safeClearerr(file);
    }

    vm.push(math.fromUnsignedCell(vm, bytes_read));
}

pub export fn primitive_fwrite(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( buf length file -- )
    const file = popFileHandle(vm) orelse return;
    const length_cell = vm.pop();
    const buf_cell = vm.pop();

    const length = layouts.untagFixnum(length_cell);
    if (length <= 0) return;

    // Get buffer address from alien or byte_array
    const buf_tag = layouts.typeTag(buf_cell);
    var buffer: *const anyopaque = undefined;

    if (buf_tag == .alien) {
        const alien: *const layouts.Alien = @ptrFromInt(layouts.UNTAG(buf_cell));
        const buf_addr = alien.address;
        if (buf_addr == 0) return;
        buffer = @ptrFromInt(buf_addr);
    } else if (buf_tag == .byte_array) {
        const byte_array: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(buf_cell));
        buffer = byte_array.data();
    } else {
        return;
    }

    _ = io_mod.safeFwrite(buffer, 1, @intCast(length), file) catch return;
}

pub export fn primitive_ftell(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( file -- offset )
    const file = peekFileHandle(vm) orelse {
        vm.replace(layouts.tagFixnum(0));
        return;
    };

    const offset = io_mod.safeFtell(file) catch {
        vm.replace(layouts.tagFixnum(0));
        return;
    };

    vm.replace(math.fromSignedCell(vm, offset));
}

pub export fn primitive_fseek(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( offset whence file -- )
    const file = popFileHandle(vm) orelse return;
    const whence = layouts.untagFixnum(vm.pop());
    const offset = math.toSignedCell(vm, vm.pop());

    io_mod.safeFseek(file, offset, @intCast(whence)) catch {
        const errno_val: Fixnum = @intCast(std.c._errno().*);
        vm.ioError(errno_val);
    };
}

pub export fn primitive_existsp(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( path -- ? )
    const path_cell = vm.pop();

    if (!layouts.hasTag(path_cell, .byte_array)) {
        vm.push(layouts.false_object);
        return;
    }

    const path_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(path_cell));
    const path_data: [*:0]const u8 = @ptrCast(path_ba.data());

    // Use std.c.stat extern to check if file exists (posix.stat doesn't exist in std)
    const S = struct {
        extern "c" fn stat(path: [*:0]const u8, buf: *anyopaque) c_int;
    };
    var stat_buf: [256]u8 = undefined; // Buffer for stat struct
    const result = S.stat(path_data, &stat_buf);

    vm.push(vm.tagBoolean(result >= 0));
}
