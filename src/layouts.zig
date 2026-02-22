// layouts.zig - Core type definitions for Factor VM
// Must be kept in sync with:
//   basis/bootstrap/layouts.factor
//   basis/vm/vm.factor

const std = @import("std");

pub const Cell = usize; // Equivalent to C++ cell (uintptr_t)
pub const Fixnum = isize; // Equivalent to C++ fixnum (intptr_t)

pub fn orderCell(context: Cell, item: Cell) std.math.Order {
    return std.math.order(context, item);
}

pub const data_alignment: Cell = 16;
pub const leaf_frame_size: Cell = 16;

pub const word_size: Cell = @bitSizeOf(Cell);

// Tag system - lower 4 bits
pub const tag_mask: Cell = 15;
pub const tag_bits: Cell = 4;

pub inline fn TAG(x: Cell) Cell {
    return x & tag_mask;
}

pub inline fn UNTAG(x: Cell) Cell {
    return x & ~tag_mask;
}

pub inline fn RETAG(x: Cell, new_tag: Cell) Cell {
    return UNTAG(x) | new_tag;
}

// Type tags - must match basis/bootstrap/layouts.factor
pub const TypeTag = enum(u4) {
    fixnum = 0,
    f = 1, // false/nil
    array = 2,
    float = 3,
    quotation = 4,
    bignum = 5,
    alien = 6,
    tuple = 7,
    wrapper = 8,
    byte_array = 9,
    callstack = 10,
    string = 11,
    word = 12,
    dll = 13,
};

pub inline fn hasTag(x: Cell, type_tag: TypeTag) bool {
    return TAG(x) == @intFromEnum(type_tag);
}

pub inline fn typeTag(x: Cell) TypeTag {
    return @enumFromInt(x & tag_mask);
}

pub fn retag(x: Cell, type_tag: TypeTag) Cell {
    return UNTAG(x) | @intFromEnum(type_tag);
}

pub const type_count: Cell = 14;

pub inline fn typeHasNoPointers(type_tag: TypeTag) bool {
    return switch (type_tag) {
        .bignum, .byte_array, .float, .callstack => true,
        else => false,
    };
}

// Floating point trap flags
pub const FPTrap = struct {
    pub const invalid_operation: Cell = 1 << 0;
    pub const overflow: Cell = 1 << 1;
    pub const underflow: Cell = 1 << 2;
    pub const zero_divide: Cell = 1 << 3;
    pub const inexact: Cell = 1 << 4;
};

// The 'f' (false) object - just the tag value
pub const false_object: Cell = @intFromEnum(TypeTag.f);

pub inline fn isImmediate(obj: Cell) bool {
    return TAG(obj) <= @intFromEnum(TypeTag.f);
}

// Fixnum operations
pub inline fn untagFixnum(tagged: Cell) Fixnum {
    std.debug.assert(hasTag(tagged, .fixnum));
    return @as(Fixnum, @bitCast(tagged)) >> @intCast(tag_bits);
}

// Same as untagFixnum but returns Cell (usize) - for use in sizes/indices.
// Returns 0 for invalid inputs during GC to avoid crashing on corrupted objects.
pub inline fn untagFixnumUnsigned(tagged: Cell) Cell {
    if (!hasTag(tagged, .fixnum)) {
        return 0;
    }
    return @bitCast(@as(Fixnum, @bitCast(tagged)) >> @intCast(tag_bits));
}

// Fast variant of untagFixnumUnsigned for hot paths outside GC.
// Debug-asserts the tag instead of a runtime branch.
pub inline fn untagFixnumFast(tagged: Cell) Cell {
    std.debug.assert(hasTag(tagged, .fixnum));
    return @bitCast(@as(Fixnum, @bitCast(tagged)) >> @intCast(tag_bits));
}

pub inline fn tagFixnum(untagged: Fixnum) Cell {
    return (@as(Cell, @bitCast(untagged << @intCast(tag_bits)))) | @intFromEnum(TypeTag.fixnum);
}

pub inline fn alignCell(a: Cell, b: Cell) Cell {
    return (a + (b - 1)) & ~(b - 1);
}

pub inline fn alignmentFor(a: Cell, b: Cell) Cell {
    return alignCell(a, b) - a;
}

// Object header format:
// bit 0      : free?
// bit 1      : forwarding pointer?
// if not forwarding:
//   bit 2..5    : tag
//   bit 6..end  : hashcode
// if forwarding:
//   bit 2..end  : forwarding pointer
pub const Object = extern struct {
    const Self = @This();

    header: Cell,

    pub inline fn isFree(self: *const Object) bool {
        return (self.header & 1) == 1;
    }

    pub inline fn getType(self: *const Object) TypeTag {
        return @enumFromInt(@as(u4, @truncate((self.header >> 2) & tag_mask)));
    }

    pub fn initialize(self: *Object, obj_type: TypeTag) void {
        self.header = @as(Cell, @intFromEnum(obj_type)) << 2;
    }

    pub fn hashcode(self: *const Object) Cell {
        return self.header >> 6;
    }

    pub fn setHashcode(self: *Object, hc: Cell) void {
        self.header = (self.header & 0x3f) | (hc << 6);
    }

    pub inline fn isForwardingPointer(self: *const Object) bool {
        return (self.header & 2) == 2;
    }

    pub inline fn forwardingPointer(self: *const Object) *Object {
        std.debug.assert(self.isForwardingPointer());
        std.debug.assert(UNTAG(self.header) != 0);
        return @ptrFromInt(UNTAG(self.header));
    }

    pub inline fn forwardTo(self: *Object, pointer: *Object) void {
        self.header = @intFromPtr(pointer) | 2;
    }

    pub fn slots(self: *const Object) [*]Cell {
        return @ptrCast(@constCast(self));
    }

    // Get pointer to data after the header (for variable-sized objects)
    pub fn dataPtr(self: *const Object, comptime T: type) [*]T {
        const base: [*]u8 = @ptrCast(@constCast(self));
        return @ptrCast(@alignCast(base + @sizeOf(Object)));
    }
};

// Array object - assembly code makes assumptions about layout
pub const Array = extern struct {
    header: Cell,
    capacity: Cell, // tagged

    pub const type_number = TypeTag.array;
    pub const element_size = @sizeOf(Cell);

    pub fn data(self: *const Array) [*]Cell {
        const base: [*]u8 = @ptrCast(@constCast(self));
        return @ptrCast(@alignCast(base + @sizeOf(Array)));
    }

    pub fn getCapacity(self: *const Array) Cell {
        return untagFixnumUnsigned(self.capacity);
    }
};

// Array helper functions - equivalent to vm/generic_arrays.hpp and vm/arrays.hpp

pub fn arrayCapacity(array: Cell) Cell {
    std.debug.assert(hasTag(array, .array));
    const arr: *const Array = @ptrFromInt(UNTAG(array));
    return arr.getCapacity();
}

pub fn arrayNth(array: Cell, index: Cell) Cell {
    std.debug.assert(hasTag(array, .array));
    const arr: *const Array = @ptrFromInt(UNTAG(array));
    const cap = arr.getCapacity();
    std.debug.assert(index < cap);
    return arr.data()[index];
}

// Note: caller must handle write barrier if needed
pub fn setArrayNth(array: Cell, index: Cell, value: Cell) void {
    std.debug.assert(hasTag(array, .array));
    const arr: *Array = @ptrFromInt(UNTAG(array));
    const cap = arr.getCapacity();
    std.debug.assert(index < cap);
    arr.data()[index] = value;
}

// Tuple layout - extends array with special fields
// The data after TupleLayout contains pairs of (superclass, hashcode) for each echelon
pub const TupleLayout = extern struct {
    header: Cell,
    capacity: Cell, // tagged
    klass: Cell, // tagged
    size: Cell, // tagged fixnum
    echelon: Cell, // tagged fixnum

    pub fn data(self: *const TupleLayout) [*]Cell {
        const base: [*]u8 = @ptrCast(@constCast(self));
        return @ptrCast(@alignCast(base + @sizeOf(TupleLayout)));
    }

    // C++ doesn't follow forwarding pointers here - the dispatch tables
    // and layouts are fixed up during image loading, and GC updates them
    pub fn nthSuperclass(self: *const TupleLayout, echelon_idx: Cell) Cell {
        return self.data()[echelon_idx * 2];
    }

    pub fn nthHashcode(self: *const TupleLayout, echelon_idx: Cell) Cell {
        // Hashcodes are tagged fixnums, no forwarding pointer needed
        return self.data()[echelon_idx * 2 + 1];
    }
};

// Bignum - import from bignum.zig which has the full implementation
const bignum = @import("bignum.zig");
pub const Bignum = bignum.Bignum;

// Byte array
pub const ByteArray = extern struct {
    header: Cell,
    capacity: Cell, // tagged

    pub const type_number = TypeTag.byte_array;
    pub const element_size: Cell = 1;

    pub fn data(self: *const ByteArray) [*]u8 {
        const base: [*]u8 = @ptrCast(@constCast(self));
        return base + @sizeOf(ByteArray);
    }
};

// String object - assembly code makes assumptions about layout
pub const String = extern struct {
    header: Cell,
    length: Cell, // tagged num of chars
    aux: Cell, // tagged (auxiliary byte_array for high Unicode, or f)
    hashcode_field: Cell, // tagged (cached string hash)

    pub const type_number = TypeTag.string;

    pub fn data(self: *const String) [*]u8 {
        const base: [*]u8 = @ptrCast(@constCast(self));
        return base + @sizeOf(String);
    }

    pub fn getLength(self: *const String) usize {
        return untagFixnumUnsigned(self.length);
    }
};

// Word object - assembly code makes assumptions about layout
// See: basis/bootstrap/images/images.factor
//      basis/compiler/constants/constants.factor
//      basis/bootstrap/primitives.factor
pub const Word = extern struct {
    header: Cell,
    hashcode_field: Cell, // TAGGED hashcode
    name: Cell, // TAGGED word name
    vocabulary: Cell, // TAGGED word vocabulary
    def: Cell, // TAGGED definition
    props: Cell, // TAGGED property assoc
    pic_def: Cell, // TAGGED alternative entry point for direct non-tail calls
    pic_tail_def: Cell, // TAGGED alternative entry point for direct tail calls
    subprimitive: Cell, // TAGGED machine code for sub-primitive
    entry_point: Cell, // UNTAGGED entry point: jump here to execute word

    pub const type_number = TypeTag.word;

    // code_block follows this struct
};

// Wrapper object
pub const Wrapper = extern struct {
    header: Cell,
    object: Cell, // TAGGED

    pub const type_number = TypeTag.wrapper;
};

// Boxed float - assembly code makes assumptions about layout
pub const BoxedFloat = extern struct {
    header: Cell,
    n: f64,

    pub const type_number = TypeTag.float;
};

// Quotation object - assembly code makes assumptions about layout
// See: basis/bootstrap/images/images.factor
//      basis/compiler/constants/constants.factor
//      core/bootstrap/primitives.factor
pub const Quotation = extern struct {
    header: Cell,
    array: Cell, // tagged
    cached_effect: Cell, // tagged
    cache_counter: Cell, // tagged
    entry_point: Cell, // UNTAGGED entry point; jump here to call quotation

    pub const type_number = TypeTag.quotation;

    // code_block follows after entry_point
};

// Alien object - foreign pointer wrapper
pub const Alien = extern struct {
    header: Cell,
    base: Cell, // tagged
    expired: Cell, // tagged
    displacement: Cell, // untagged
    address: Cell, // untagged

    pub const type_number = TypeTag.alien;

    pub fn updateAddress(self: *Alien) void {
        if (self.base == false_object) {
            self.address = self.displacement;
        } else {
            self.address = UNTAG(self.base) + @sizeOf(ByteArray) + self.displacement;
        }
    }
};

// DLL object - dynamic library handle
pub const Dll = extern struct {
    header: Cell,
    path: Cell, // tagged byte array holding a C string
    handle: ?*anyopaque, // OS-specific handle

    pub const type_number = TypeTag.dll;
};

// Callstack object
pub const Callstack = extern struct {
    header: Cell,
    length: Cell, // tagged

    pub const type_number = TypeTag.callstack;

    pub fn frameTopAt(self: *const Callstack, offset: Cell) Cell {
        return @intFromPtr(self) + @sizeOf(Callstack) + offset;
    }

    pub fn top(self: *const Callstack) Cell {
        return @intFromPtr(self) + @sizeOf(Callstack);
    }

    pub fn bottom(self: *const Callstack) Cell {
        return @intFromPtr(self) + @sizeOf(Callstack) + untagFixnum(self.length);
    }

    pub fn data(self: *const Callstack) [*]const Cell {
        const base: [*]const u8 = @ptrCast(self);
        return @ptrCast(@alignCast(base + @sizeOf(Callstack)));
    }
};

// Tuple object
pub const Tuple = extern struct {
    header: Cell,
    layout: Cell, // tagged layout

    pub const type_number = TypeTag.tuple;

    pub fn data(self: *const Tuple) [*]Cell {
        const base: [*]u8 = @ptrCast(@constCast(self));
        return @ptrCast(@alignCast(base + @sizeOf(Tuple)));
    }

    pub fn getLayout(self: *const Tuple) *const TupleLayout {
        // Follow forwarding pointers - layout may have moved during GC
        const layout_addr = followForwardingPointers(self.layout);
        return @ptrFromInt(layout_addr);
    }
};

// Size calculation utilities
pub fn arraySize(comptime ArrayType: type, capacity: Cell) Cell {
    return @sizeOf(ArrayType) + capacity * ArrayType.element_size;
}

pub fn stringSize(size: Cell) Cell {
    return @sizeOf(String) + size;
}

pub fn tupleCapacity(layout: *const TupleLayout) Cell {
    return untagFixnumUnsigned(layout.size);
}

pub fn tupleSize(layout: *const TupleLayout) Cell {
    return @sizeOf(Tuple) + tupleCapacity(layout) * @sizeOf(Cell);
}

pub fn stringCapacity(str: *const String) Cell {
    return untagFixnum(str.length);
}

// Get the number of slots (cells) in an object that should be scanned by GC
// This is the count of cell-sized fields after the header
// Based on vm/slot_visitor.hpp slot_count()
pub fn slotCount(obj: Cell) Cell {
    if (isImmediate(obj)) return 0;

    const object_ptr: *const Object = @ptrFromInt(UNTAG(obj));
    if (object_ptr.isFree()) return 0;

    const obj_type = object_ptr.getType();

    return switch (obj_type) {
        .array => {
            const arr: *const Array = @ptrCast(object_ptr);
            return 1 + arr.getCapacity();
        },

        .tuple => {
            const t: *const Tuple = @ptrCast(object_ptr);
            const layout_cell = t.layout;
            // NOTE: TupleLayout has array tag (2), not tuple tag (7)!
            if (hasTag(layout_cell, .array)) {
                const layout: *const TupleLayout = @ptrFromInt(UNTAG(layout_cell));
                return 1 + tupleCapacity(layout);
            }
            return 1; // Just the layout field if we can't read it
        },

        // Objects that don't refer to other objects
        .float, .bignum, .byte_array, .callstack => 0,

        // Quotation: array, cached_effect, cache_counter (3 fields after header)
        .quotation => 3,

        // Alien: base, expired (2 fields after header, not counting displacement/address)
        .alien => 2,

        // Wrapper: object (1 field after header)
        .wrapper => 1,

        // String: length, aux, hashcode_field (3 fields after header)
        .string => 3,

        // Word: hashcode_field, name, vocabulary, def, props, pic_def, pic_tail_def, subprimitive (8 fields after header)
        .word => 8,

        // DLL: path (1 field after header, handle is not a Factor object)
        .dll => 1,

        // Fixnum and f are immediates, shouldn't reach here
        .fixnum, .f => 0,
    };
}

// Like slot_count, but takes an untagged object address (reads type from header).
// Use this when iterating objects in a heap region where addresses are not tagged.
pub fn slotCountFromAddress(obj_addr: Cell) Cell {
    if (obj_addr < 0x1000) return 0;

    const object_ptr: *const Object = @ptrFromInt(obj_addr);
    if (object_ptr.isFree()) return 0;

    const obj_type = object_ptr.getType();

    return switch (obj_type) {
        .array => {
            const arr: *const Array = @ptrCast(object_ptr);
            return 1 + arr.getCapacity();
        },
        .tuple => {
            const t: *const Tuple = @ptrCast(object_ptr);
            const layout_cell = t.layout;
            // NOTE: TupleLayout has array tag (2), not tuple tag (7)!
            if (hasTag(layout_cell, .array)) {
                const layout_addr = followForwardingPointers(layout_cell);
                const layout: *const TupleLayout = @ptrFromInt(layout_addr);
                return 1 + tupleCapacity(layout);
            }
            return 1;
        },
        .float, .bignum, .byte_array, .callstack => 0,
        .quotation => 3,
        .alien => 2,
        .wrapper => 1,
        .string => 3,
        .word => 8,
        .dll => 1,
        .fixnum, .f => 0,
    };
}

// NOTE: For array reallocation, use FactorVM.reallotArray()
// Array reallocation requires VM context for proper allocation and GC coordination.
// See vm.zig FactorVM.reallotArray() for the implementation.
//
// The function signature in vm.zig is:
//   pub fn reallotArray(self: *FactorVM, old_array: Cell, new_capacity: Cell) ?Cell

// Follow forwarding pointer chain to find the actual object location.
// This is critical during GC when objects may have been moved.
// Equivalent to C++ fixup.translate_data().
pub inline fn followForwardingPointers(addr: Cell) Cell {
    var current = UNTAG(addr);

    // Safety check: don't dereference null/invalid pointers
    if (current < 0x1000) {
        return current;
    }

    var obj: *Object = @ptrFromInt(current);

    // Follow forwarding pointer chain (bounded to detect corruption)
    const max_hops = 16;
    var hops: u32 = 0;
    while (obj.isForwardingPointer()) : (hops += 1) {
        if (hops >= max_hops) break;
        obj = obj.forwardingPointer();
        current = @intFromPtr(obj);
    }

    return current;
}

// Tagged pointer utilities
pub fn tag(comptime T: type, value: *T) Cell {
    std.debug.assert(@intFromPtr(value) % data_alignment == 0);
    return @intFromPtr(value) | @intFromEnum(T.type_number);
}

pub fn untag(comptime T: type, value: Cell) *T {
    std.debug.assert(UNTAG(value) != 0);
    std.debug.assert(UNTAG(value) % data_alignment == 0);
    return @ptrFromInt(UNTAG(value));
}

// Specific tag functions for common types
pub fn tagBignum(bn: *Bignum) Cell {
    std.debug.assert(@intFromPtr(bn) % data_alignment == 0);
    return @intFromPtr(bn) | @intFromEnum(TypeTag.bignum);
}

pub fn tagFloat(boxed: *BoxedFloat) Cell {
    std.debug.assert(@intFromPtr(boxed) % data_alignment == 0);
    return @intFromPtr(boxed) | @intFromEnum(TypeTag.float);
}

// Verify struct layouts at compile time
comptime {
    // Ensure Object is the correct size
    std.debug.assert(@sizeOf(Object) == @sizeOf(Cell));

    // Ensure Array fields are in correct order
    std.debug.assert(@offsetOf(Array, "header") == 0);
    std.debug.assert(@offsetOf(Array, "capacity") == @sizeOf(Cell));

    // Ensure Word fields are in correct order (critical for assembly)
    std.debug.assert(@offsetOf(Word, "header") == 0 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Word, "hashcode_field") == 1 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Word, "name") == 2 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Word, "vocabulary") == 3 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Word, "def") == 4 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Word, "props") == 5 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Word, "pic_def") == 6 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Word, "pic_tail_def") == 7 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Word, "subprimitive") == 8 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Word, "entry_point") == 9 * @sizeOf(Cell));

    // Ensure Quotation fields are in correct order (critical for assembly)
    std.debug.assert(@offsetOf(Quotation, "header") == 0 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Quotation, "array") == 1 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Quotation, "cached_effect") == 2 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Quotation, "cache_counter") == 3 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Quotation, "entry_point") == 4 * @sizeOf(Cell));
}
