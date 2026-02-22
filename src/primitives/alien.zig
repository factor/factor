// alien.zig - FFI/Alien primitives for Factor VM
// Ported from vm/alien.cpp

const std = @import("std");

const bignum = @import("../bignum.zig");
const code_blocks = @import("../code_blocks.zig");
const float_mod = @import("../float.zig");
const layouts = @import("../layouts.zig");
const math_mod = @import("../fixnum.zig");
const vm_mod = @import("../vm.zig");

const Cell = layouts.Cell;
const Fixnum = layouts.Fixnum;
const FactorVM = vm_mod.FactorVM;
const VMAssemblyFields = vm_mod.VMAssemblyFields;

fn toFixnum(vm: *FactorVM, tagged: Cell) Fixnum {
    const tag = layouts.typeTag(tagged);
    if (tag == .fixnum) {
        return layouts.untagFixnum(tagged);
    } else if (tag == .bignum) {
        const bn: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(tagged));
        return bignum.toFixnum(bn);
    } else {
        vm.typeError(.fixnum, tagged);
    }
}

// Cached handle for dlopen(NULL) like C++ null_dll
pub var null_dll: ?*anyopaque = null;

pub fn initFfi() void {
    var rtld_mode: std.c.RTLD = .{};
    rtld_mode.LAZY = true;
    null_dll = std.c.dlopen(null, rtld_mode);
}

// --- Alien/FFI Primitives ---

// Get a pinned alien's address (alien with base == f)
fn pinnedAlienOffset(vm: *FactorVM, obj: Cell) ?[*]u8 {
    switch (@as(layouts.TypeTag, @enumFromInt(layouts.TAG(obj)))) {
        .alien => {
            const alien: *const layouts.Alien = @ptrFromInt(layouts.UNTAG(obj));
            if (alien.expired != layouts.false_object) {
                vm.expiredError(obj);
            }
            if (alien.base != layouts.false_object) {
                vm.typeError(.alien, obj);
            }
            return @ptrFromInt(alien.address);
        },
        .f => return null,
        else => {
            // C++ throws type_error(ALIEN_TYPE, obj) for non-alien, non-f values
            vm.typeError(.alien, obj);
        },
    }
}

pub export fn primitive_alien_address(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const obj = vm.peek();
    switch (@as(layouts.TypeTag, @enumFromInt(layouts.TAG(obj)))) {
        .alien => {
            const alien: *const layouts.Alien = @ptrFromInt(layouts.UNTAG(obj));
            if (alien.expired != layouts.false_object) {
                vm.expiredError(obj);
            }
            if (alien.base != layouts.false_object) {
                vm.generalError(.unused, layouts.tagFixnum(0), layouts.false_object);
            }
            vm.replace(math_mod.fromUnsignedCell(vm, alien.address));
        },
        .f => {
            vm.replace(layouts.tagFixnum(0));
        },
        else => {
            vm.typeError(.alien, obj);
        },
    }
}

pub export fn primitive_displaced_alien(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( displacement alien -- displaced-alien )
    const alien = vm.pop();
    const displacement_cell = vm.pop();

    const displacement: Cell = if (layouts.hasTag(displacement_cell, .fixnum))
        @bitCast(layouts.untagFixnum(displacement_cell))
    else
        0;

    // Validate alien type - must be byte_array, alien, or f (false)
    const tag = layouts.typeTag(alien);
    if (tag != .byte_array and
        tag != .alien and
        alien != layouts.false_object)
    {
        vm.typeError(.alien, alien);
    }

    // If displacement is 0, return original
    if (displacement == 0) {
        vm.push(alien);
        return;
    }

    // Root the alien before potential GC from allocation
    var rooted_alien = alien;
    vm.data_roots.append(vm.allocator, &rooted_alien) catch
        vm.memoryError();
    defer _ = vm.data_roots.pop();

    const tagged = vm.allotObject(.alien, @sizeOf(layouts.Alien)) orelse
        vm.memoryError();
    const new_alien: *layouts.Alien = @ptrFromInt(layouts.UNTAG(tagged));
    new_alien.expired = layouts.false_object;

    // Use rooted_alien which may have been updated by GC
    if (layouts.hasTag(rooted_alien, .alien)) {
        const src_alien: *const layouts.Alien = @ptrFromInt(layouts.UNTAG(rooted_alien));
        new_alien.base = src_alien.base;
        new_alien.displacement = src_alien.displacement + displacement;
    } else {
        new_alien.base = rooted_alien;
        new_alien.displacement = displacement;
    }

    new_alien.updateAddress();
    vm.push(tagged);
}

// Helper to pop alien pointer with offset
// Stack effect: ( alien offset -- )
// Returns a valid pointer or raises a Factor-level memory error (never returns null).
fn alienPointer(vm: *FactorVM) [*]u8 {
    const offset_cell = vm.pop();
    const offset: Fixnum = if (layouts.hasTag(offset_cell, .fixnum))
        layouts.untagFixnum(offset_cell)
    else
        @call(.never_inline, toFixnum, .{ vm, offset_cell });
    const obj = vm.pop();
    if (vm.alienOffset(obj)) |ptr| {
        // Wrapping add handles negative offsets correctly (C equivalent: ptr + offset)
        const addr = @intFromPtr(ptr) +% @as(usize, @bitCast(offset));
        return @ptrFromInt(addr);
    }
    vm.generalError(.memory, layouts.tagFixnum(0), layouts.false_object);
}

pub export fn primitive_alien_signed_1(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const typed_ptr: *const i8 = @ptrCast(@alignCast(ptr));
    vm.push(layouts.tagFixnum(@intCast(typed_ptr.*)));
}

pub export fn primitive_set_alien_signed_1(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const value_cell = vm.pop();
    const typed_ptr: *i8 = @ptrCast(@alignCast(ptr));
    typed_ptr.* = @truncate(toFixnum(vm, value_cell));
}

pub export fn primitive_alien_signed_2(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const typed_ptr: *align(1) const i16 = @ptrCast(ptr);
    vm.push(layouts.tagFixnum(@intCast(typed_ptr.*)));
}

pub export fn primitive_set_alien_signed_2(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const value_cell = vm.pop();
    const typed_ptr: *align(1) i16 = @ptrCast(ptr);
    typed_ptr.* = @truncate(toFixnum(vm, value_cell));
}

pub export fn primitive_alien_signed_4(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const typed_ptr: *align(1) const i32 = @ptrCast(ptr);
    vm.push(layouts.tagFixnum(@intCast(typed_ptr.*)));
}

pub export fn primitive_set_alien_signed_4(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const value_cell = vm.pop();
    const typed_ptr: *align(1) i32 = @ptrCast(ptr);
    typed_ptr.* = @truncate(toFixnum(vm, value_cell));
}

pub export fn primitive_alien_signed_8(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const typed_ptr: *align(1) const i64 = @ptrCast(ptr);
    vm.push(math_mod.fromSignedCell(vm, typed_ptr.*));
}

pub export fn primitive_set_alien_signed_8(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const value_cell = vm.pop();
    const typed_ptr: *align(1) i64 = @ptrCast(ptr);
    typed_ptr.* = @intCast(toFixnum(vm, value_cell));
}

pub export fn primitive_alien_unsigned_1(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const typed_ptr: *const u8 = @ptrCast(@alignCast(ptr));
    vm.push(layouts.tagFixnum(@intCast(typed_ptr.*)));
}

pub export fn primitive_set_alien_unsigned_1(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const value_cell = vm.pop();
    const typed_ptr: *u8 = @ptrCast(@alignCast(ptr));
    typed_ptr.* = @truncate(@as(u64, @bitCast(toFixnum(vm, value_cell))));
}

pub export fn primitive_alien_unsigned_2(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const typed_ptr: *align(1) const u16 = @ptrCast(ptr);
    vm.push(layouts.tagFixnum(@intCast(typed_ptr.*)));
}

pub export fn primitive_set_alien_unsigned_2(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const value_cell = vm.pop();
    const typed_ptr: *align(1) u16 = @ptrCast(ptr);
    typed_ptr.* = @truncate(@as(u64, @bitCast(toFixnum(vm, value_cell))));
}

pub export fn primitive_alien_unsigned_4(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const typed_ptr: *align(1) const u32 = @ptrCast(ptr);
    vm.push(layouts.tagFixnum(@intCast(typed_ptr.*)));
}

pub export fn primitive_set_alien_unsigned_4(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const value_cell = vm.pop();
    const typed_ptr: *align(1) u32 = @ptrCast(ptr);
    typed_ptr.* = @truncate(@as(u64, @bitCast(toFixnum(vm, value_cell))));
}

pub export fn primitive_alien_unsigned_8(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const typed_ptr: *align(1) const u64 = @ptrCast(ptr);
    vm.push(math_mod.fromUnsignedCell(vm, typed_ptr.*));
}

pub export fn primitive_set_alien_unsigned_8(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const value_cell = vm.pop();
    const typed_ptr: *align(1) u64 = @ptrCast(ptr);
    typed_ptr.* = @bitCast(toFixnum(vm, value_cell));
}

pub export fn primitive_alien_float(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const typed_ptr: *align(1) const f32 = @ptrCast(ptr);
    const boxed = float_mod.allocBoxedFloat(vm, @floatCast(typed_ptr.*)) catch
        vm.memoryError();
    vm.push(@intFromPtr(boxed) | @intFromEnum(layouts.TypeTag.float));
}

pub export fn primitive_set_alien_float(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const value_cell = vm.pop();
    const typed_ptr: *align(1) f32 = @ptrCast(ptr);
    if (layouts.hasTag(value_cell, .float)) {
        const boxed: *const layouts.BoxedFloat = @ptrFromInt(layouts.UNTAG(value_cell));
        typed_ptr.* = @floatCast(boxed.n);
    }
}

pub export fn primitive_alien_double(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const typed_ptr: *align(1) const f64 = @ptrCast(ptr);
    const boxed = float_mod.allocBoxedFloat(vm, typed_ptr.*) catch
        vm.memoryError();
    vm.push(@intFromPtr(boxed) | @intFromEnum(layouts.TypeTag.float));
}

pub export fn primitive_set_alien_double(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const value_cell = vm.pop();
    const typed_ptr: *align(1) f64 = @ptrCast(ptr);
    if (layouts.hasTag(value_cell, .float)) {
        const boxed: *const layouts.BoxedFloat = @ptrFromInt(layouts.UNTAG(value_cell));
        typed_ptr.* = boxed.n;
    }
}

pub export fn primitive_alien_cell(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const typed_ptr: *align(1) const Cell = @ptrCast(ptr);
    const value = typed_ptr.*;

    // NULL pointer maps to f (false_object), matching C++ allot_alien(false_object, 0)
    if (value == 0) {
        vm.push(layouts.false_object);
        return;
    }

    const tagged = vm.allotObject(.alien, @sizeOf(layouts.Alien)) orelse
        vm.memoryError();
    const alien: *layouts.Alien = @ptrFromInt(layouts.UNTAG(tagged));
    alien.base = layouts.false_object;
    alien.expired = layouts.false_object;
    alien.displacement = value;
    alien.address = value;
    vm.push(tagged);
}

pub export fn primitive_set_alien_cell(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ptr = alienPointer(vm);
    const value_cell = vm.pop();
    const typed_ptr: *align(1) Cell = @ptrCast(ptr);
    if (pinnedAlienOffset(vm, value_cell)) |alien_ptr| {
        typed_ptr.* = @intFromPtr(alien_ptr);
    } else {
        typed_ptr.* = 0;
    }
}

// Signed/unsigned cell primitives — read/write cell-sized integers (not alien pointers).
// On 64-bit, cell == 8 bytes, so these are equivalent to signed/unsigned 8.
pub const primitive_alien_signed_cell = primitive_alien_signed_8;
pub const primitive_set_alien_signed_cell = primitive_set_alien_signed_8;
pub const primitive_alien_unsigned_cell = primitive_alien_unsigned_8;
pub const primitive_set_alien_unsigned_cell = primitive_set_alien_unsigned_8;

comptime {
    @export(&primitive_alien_signed_8, .{ .name = "primitive_alien_signed_cell", .linkage = .strong });
    @export(&primitive_set_alien_signed_8, .{ .name = "primitive_set_alien_signed_cell", .linkage = .strong });
    @export(&primitive_alien_unsigned_8, .{ .name = "primitive_alien_unsigned_cell", .linkage = .strong });
    @export(&primitive_set_alien_unsigned_8, .{ .name = "primitive_set_alien_unsigned_cell", .linkage = .strong });
}

// DLL primitives using direct C library calls (matches C++ VM behavior)
pub export fn primitive_dlopen(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const path_cell = vm.pop();

    vm.checkTag(path_cell, .byte_array);

    const path_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(path_cell));
    const capacity = layouts.untagFixnumUnsigned(path_ba.capacity);
    const path_data = path_ba.data();

    var path_buf: [1024]u8 = undefined;
    if (capacity >= path_buf.len) {
        vm.push(layouts.false_object);
        return;
    }
    @memcpy(path_buf[0..capacity], path_data[0..capacity]);
    path_buf[capacity] = 0;

    var rtld_mode: std.c.RTLD = .{};
    rtld_mode.LAZY = true;
    rtld_mode.GLOBAL = true;
    const handle = std.c.dlopen(@ptrCast(&path_buf), rtld_mode);

    const tagged = vm.allotObject(.dll, @sizeOf(layouts.Dll)) orelse {
        if (handle) |h| _ = std.c.dlclose(h);
        vm.memoryError();
    };
    const dll: *layouts.Dll = @ptrFromInt(layouts.UNTAG(tagged));
    dll.path = path_cell;
    dll.handle = handle;
    vm.push(tagged);
}

pub export fn primitive_dlsym(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const library_cell = vm.pop();
    const name_cell = vm.peek();

    vm.checkTag(name_cell, .byte_array);

    const name_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(name_cell));
    const name_len = layouts.untagFixnumUnsigned(name_ba.capacity);
    const name_data = name_ba.data();

    var name_buf: [256]u8 = undefined;
    if (name_len >= name_buf.len) {
        vm.replace(layouts.false_object);
        return;
    }
    @memcpy(name_buf[0..name_len], name_data[0..name_len]);
    name_buf[name_len] = 0;

    const sym_addr: ?*anyopaque = blk: {
        if (library_cell == layouts.false_object) {
            break :blk std.c.dlsym(null_dll, @ptrCast(&name_buf));
        }
        vm.checkTag(library_cell, .dll);
        const dll: *const layouts.Dll = @ptrFromInt(layouts.UNTAG(library_cell));
        if (dll.handle == null) break :blk null;
        break :blk std.c.dlsym(dll.handle, @ptrCast(&name_buf));
    };

    if (sym_addr) |addr| {
        const tagged = vm.allotObject(.alien, @sizeOf(layouts.Alien)) orelse
            vm.memoryError();
        const alien: *layouts.Alien = @ptrFromInt(layouts.UNTAG(tagged));
        alien.base = layouts.false_object;
        alien.expired = layouts.false_object;
        const addr_val = @intFromPtr(addr);
        alien.displacement = addr_val;
        alien.address = addr_val;
        vm.replace(tagged);
    } else {
        vm.replace(layouts.false_object);
    }
}

pub export fn primitive_dlclose(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const dll_cell = vm.pop();

    vm.checkTag(dll_cell, .dll);

    const dll: *layouts.Dll = @ptrFromInt(layouts.UNTAG(dll_cell));
    if (dll.handle) |handle| {
        _ = std.c.dlclose(handle);
        dll.handle = null;
    }
}

pub export fn primitive_dll_validp(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const library = vm.peek();

    const objects = @import("../objects.zig");
    const canonical_true = vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.canonical_true)];

    if (library == layouts.false_object) {
        vm.replace(canonical_true);
        return;
    }

    vm.checkTag(library, .dll);

    const dll: *const layouts.Dll = @ptrFromInt(layouts.UNTAG(library));
    vm.replace(if (dll.handle != null) canonical_true else layouts.false_object);
}

pub export fn primitive_current_callback(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    if (vm.callback_ids.items.len > 0) {
        vm.push(layouts.tagFixnum(vm.callback_ids.items[vm.callback_ids.items.len - 1]));
    } else {
        vm.push(layouts.tagFixnum(0));
    }
}

pub export fn primitive_callback(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( word return-rewind -- alien )
    const return_rewind_cell = vm.pop();
    const word_cell = vm.pop();

    const return_rewind: Cell = layouts.untagFixnumUnsigned(return_rewind_cell);

    const callback_heap = vm.callbacks orelse {
        vm.generalError(.callback_space_overflow, layouts.false_object, layouts.false_object);
    };

    const vm_ptr: Cell = @intFromPtr(&vm.vm_asm);

    const stub = callback_heap.add(word_cell, return_rewind, vm_ptr, vm) orelse {
        vm.generalError(.callback_space_overflow, layouts.false_object, layouts.false_object);
    };

    const func = stub.entryPoint();

    const tagged = vm.allotObject(.alien, @sizeOf(layouts.Alien)) orelse
        vm.memoryError();
    const alien: *layouts.Alien = @ptrFromInt(layouts.UNTAG(tagged));
    alien.base = layouts.false_object;
    alien.expired = layouts.false_object;
    alien.displacement = func;
    alien.address = func;
    vm.push(tagged);
}

pub export fn primitive_free_callback(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const alien_cell = vm.pop();

    if (vm.alienOffset(alien_cell)) |entry_point| {
        const entry_addr: usize = @intFromPtr(entry_point);
        const code_block_addr = entry_addr - @sizeOf(code_blocks.CodeBlock);
        const stub: *code_blocks.CodeBlock = @ptrFromInt(code_block_addr);

        if (vm.callbacks) |callback_heap| {
            callback_heap.free(stub);
        }
    }
}
