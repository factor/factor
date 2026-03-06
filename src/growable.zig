// growable.zig - Growable array and byte array data structures
// Ported from vm/arrays.hpp, vm/arrays.cpp, vm/byte_arrays.hpp, vm/byte_arrays.cpp
//
// These helper structures are used by VM internals for building arrays incrementally.
// They automatically grow the backing array as needed and can be trimmed to exact size.

const std = @import("std");
const layouts = @import("layouts.zig");
const vm_mod = @import("vm.zig");
const Cell = layouts.Cell;

/// Growable array for building arrays incrementally
/// Equivalent to C++ growable_array
pub const GrowableArray = struct {
    const Self = @This();

    // Current number of elements
    count: Cell,
    // Tagged pointer to backing array
    elements: Cell,
    // Parent VM for allocations
    vm: *vm_mod.FactorVM,

    /// Initialize a new growable array with given capacity
    /// Allocates memory via VM nursery
    pub fn init(parent_vm: *vm_mod.FactorVM, initial_capacity: Cell) ?GrowableArray {
        const arr = parent_vm.allotUninitializedArray(initial_capacity) orelse return null;

        return GrowableArray{
            .count = 0,
            .elements = arr,
            .vm = parent_vm,
        };
    }

    /// Get the current capacity of the backing array
    pub fn capacity(self: *const GrowableArray) Cell {
        const array: *layouts.Array = @ptrFromInt(layouts.UNTAG(self.elements));
        return array.getCapacity();
    }

    /// Grow the backing array to accommodate at least count elements
    /// Allocates memory
    pub fn reallotArray(self: *GrowableArray, new_count: Cell) bool {
        const new_elements = self.vm.reallotArray(self.elements, new_count) orelse return false;
        self.elements = new_elements;
        return true;
    }

    /// Add a single element to the array
    /// Grows the array if necessary (doubles capacity)
    /// Allocates memory
    pub fn add(self: *GrowableArray, elt: Cell) bool {
        // Root elt to protect from GC during reallotArray (matches C++ data_root<object> elt)
        var elt_root = elt;
        self.vm.data_roots.append(self.vm.allocator, &elt_root) catch return false;
        defer _ = self.vm.data_roots.pop();

        if (self.count == self.capacity()) {
            if (!self.reallotArray(2 * self.count)) {
                return false;
            }
        }

        const array: *layouts.Array = @ptrFromInt(layouts.UNTAG(self.elements));
        const data = array.data();
        data[self.count] = elt_root;

        // Write barrier: only needed for pointer stores.
        self.vm.writeBarrierKnownHeapWithValue(&data[self.count], elt_root);

        self.count += 1;
        return true;
    }

    /// Append all elements from another array
    /// Grows the array if necessary (doubles capacity)
    /// Allocates memory
    pub fn append(self: *GrowableArray, elts: Cell) bool {
        std.debug.assert(layouts.hasTag(elts, .array));

        // Root elts to protect from GC during reallotArray (matches C++ data_root<array> elts)
        var elts_root = elts;
        self.vm.data_roots.append(self.vm.allocator, &elts_root) catch return false;
        defer _ = self.vm.data_roots.pop();

        const source_capacity = blk: {
            const source_array: *layouts.Array = @ptrFromInt(layouts.UNTAG(elts_root));
            break :blk source_array.getCapacity();
        };

        if (self.count + source_capacity > self.capacity()) {
            if (!self.reallotArray(2 * (self.count + source_capacity))) {
                return false;
            }
        }

        if (source_capacity == 0) {
            return true;
        }

        // Re-derive both arrays after potential GC from reallotArray
        const dest_array: *layouts.Array = @ptrFromInt(layouts.UNTAG(self.elements));
        const dest_data = dest_array.data();
        const source_array: *layouts.Array = @ptrFromInt(layouts.UNTAG(elts_root));
        const source_data = source_array.data();

        const dst_start: usize = @intCast(self.count);
        const src_len: usize = @intCast(source_capacity);
        @memcpy(dest_data[dst_start .. dst_start + src_len], source_data[0..src_len]);

        // One range barrier is cheaper than per-slot barriers for bulk append.
        // Skip it when the appended slice contains only immediates.
        var has_heap_refs = false;
        for (source_data[0..src_len]) |value| {
            if (!layouts.isImmediate(value)) {
                has_heap_refs = true;
                break;
            }
        }
        if (has_heap_refs) {
            const slot_start_addr = @intFromPtr(&dest_data[dst_start]);
            const slot_bytes = source_capacity * @sizeOf(Cell);
            self.vm.writeBarrierRange(slot_start_addr, slot_bytes);
        }
        self.count += source_capacity;

        return true;
    }

    /// Trim the backing array to exact size (count elements)
    /// Allocates memory
    pub fn trim(self: *GrowableArray) bool {
        return self.reallotArray(self.count);
    }

    /// Get the tagged backing array
    pub fn toArray(self: *const GrowableArray) Cell {
        return self.elements;
    }
};

/// Growable byte array for building byte arrays incrementally
/// Equivalent to C++ growable_byte_array
pub const GrowableByteArray = struct {
    const Self = @This();

    // Current number of bytes
    count: Cell,
    // Tagged pointer to backing byte array
    elements: Cell,
    // Parent VM for allocations
    vm: *vm_mod.FactorVM,

    /// Initialize a new growable byte array with given capacity
    /// Allocates memory via VM nursery
    pub fn init(parent_vm: *vm_mod.FactorVM, initial_capacity: Cell) GrowableByteArray {
        const arr = parent_vm.allotByteArray(initial_capacity);
        return GrowableByteArray{
            .count = 0,
            .elements = arr,
            .vm = parent_vm,
        };
    }

    /// Get the current capacity of the backing byte array
    pub fn capacity(self: *const GrowableByteArray) Cell {
        const byte_array: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(self.elements));
        return layouts.untagFixnumUnsigned(byte_array.capacity);
    }

    /// Grow the backing byte array to accommodate at least count bytes
    /// Allocates memory
    pub fn reallotArray(self: *GrowableByteArray, new_count: Cell) bool {
        std.debug.assert(layouts.hasTag(self.elements, .byte_array));

        const old_ba: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(self.elements));
        const old_capacity = layouts.untagFixnumUnsigned(old_ba.capacity);

        if (new_count == old_capacity) return true;

        // In-place shrink for nursery objects (matches C++ reallot_array_in_place_p)
        if (new_count <= old_capacity and self.vm.vm_asm.nursery.contains(@ptrFromInt(layouts.UNTAG(self.elements)))) {
            const ba_mut: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(self.elements));
            ba_mut.capacity = layouts.tagFixnum(@as(layouts.Fixnum, @intCast(new_count)));
            return true;
        }

        // Root old elements so GC can update self.elements if it moves
        self.vm.data_roots.append(self.vm.allocator, &self.elements) catch return false;
        defer _ = self.vm.data_roots.pop();

        // Allocate new byte array - may trigger GC, moving self.elements
        const new_elements = self.vm.allotByteArray(new_count);
        const new_ba: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(new_elements));

        // Re-derive old_ba from self.elements (updated by GC if moved)
        const old_ba_after: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(self.elements));

        // Copy existing data
        const to_copy = @min(old_capacity, new_count);
        @memcpy(new_ba.data()[0..to_copy], old_ba_after.data()[0..to_copy]);

        self.elements = new_elements;
        return true;
    }

    /// Reserve space for len more bytes, growing if necessary (doubles capacity)
    /// Allocates memory
    pub fn growBytes(self: *GrowableByteArray, len: Cell) bool {
        const new_count = self.count + len;
        if (new_count >= self.capacity()) {
            if (!self.reallotArray(2 * new_count)) {
                return false;
            }
        }
        self.count = new_count;
        return true;
    }

    /// Append raw bytes to the byte array
    /// Grows the array if necessary (doubles capacity)
    /// Allocates memory
    pub fn appendBytes(self: *GrowableByteArray, elts: [*]const u8, len: Cell) bool {
        const old_count = self.count;
        if (!self.growBytes(len)) {
            return false;
        }

        const byte_array: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(self.elements));
        const data = byte_array.data();
        @memcpy(data[old_count .. old_count + len], elts[0..len]);
        return true;
    }

    /// Append another byte array
    /// Grows the array if necessary (doubles capacity)
    /// Allocates memory
    pub fn appendByteArray(self: *GrowableByteArray, byte_array_tagged: Cell) bool {
        std.debug.assert(layouts.hasTag(byte_array_tagged, .byte_array));

        var source_root = byte_array_tagged;
        const len = blk: {
            const ba: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(byte_array_tagged));
            break :blk layouts.untagFixnumUnsigned(ba.capacity);
        };
        const new_size = self.count + len;

        if (new_size >= self.capacity()) {
            self.vm.data_roots.append(self.vm.allocator, &source_root) catch return false;
            defer _ = self.vm.data_roots.pop();

            if (!self.reallotArray(2 * new_size)) {
                return false;
            }
        }

        const dest_ba: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(self.elements));
        const source_ba: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(source_root));
        @memcpy(dest_ba.data()[self.count .. self.count + len], source_ba.data()[0..len]);
        self.count += len;
        return true;
    }

    /// Trim the backing byte array to exact size (count bytes)
    /// Allocates memory
    pub fn trim(self: *GrowableByteArray) bool {
        return self.reallotArray(self.count);
    }

    /// Get the tagged backing byte array
    pub fn toByteArray(self: *const GrowableByteArray) Cell {
        return self.elements;
    }
};
