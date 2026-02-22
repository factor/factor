// code_blocks.zig - Code block and code heap management
// Ported from vm/code_blocks.hpp, vm/code_heap.hpp
//
// Code blocks contain compiled Factor code (JIT output).
// Each code block has a header followed by machine code.

const std = @import("std");
const builtin = @import("builtin");

const alien = @import("primitives/alien.zig");
const icache = @import("icache.zig");
const layouts = @import("layouts.zig");
const trampolines = @import("trampolines.zig");

const Cell = layouts.Cell;

// GC info structure - stored at the end of each code block
// Must match basis/compiler/codegen/gc-maps/gc-maps.factor and vm/gc_info.hpp
pub const GcInfo = extern struct {
    gc_root_count: u32,
    derived_root_count: u32,
    return_address_count: u32,

    const Self = @This();

    pub fn callsiteBitmapSize(self: *const Self) u32 {
        return self.gc_root_count;
    }

    pub fn totalBitmapSize(self: *const Self) u32 {
        return self.return_address_count * self.callsiteBitmapSize();
    }

    pub fn totalBitmapBytes(self: *const Self) u32 {
        return (self.totalBitmapSize() + 7) / 8;
    }

    pub fn returnAddresses(self: *const Self) [*]const u32 {
        const ptr: [*]const u32 = @ptrCast(self);
        return ptr - self.return_address_count;
    }

    pub fn basePointerMap(self: *const Self) [*]const u32 {
        const ret_addrs = self.returnAddresses();
        return ret_addrs - (self.return_address_count * self.derived_root_count);
    }

    pub fn gcInfoBitmap(self: *const Self) [*]const u8 {
        const base_ptr_map = self.basePointerMap();
        const bytes: [*]const u8 = @ptrCast(base_ptr_map);
        return bytes - self.totalBitmapBytes();
    }

    pub fn callsiteGcRoots(self: *const Self, index: u32) u32 {
        return index * self.gc_root_count;
    }

    pub fn lookupBasePointer(self: *const Self, index: u32, derived_root: u32) u32 {
        const map = self.basePointerMap();
        return map[index * self.derived_root_count + derived_root];
    }

    pub fn returnAddressIndex(self: *const Self, return_address: u32) ?u32 {
        const ret_addrs = self.returnAddresses();
        for (0..self.return_address_count) |i| {
            if (return_address == ret_addrs[i]) {
                return @intCast(i);
            }
        }
        return null;
    }
};

pub fn isBitmapSet(bitmap: [*]const u8, index: u32) bool {
    const byte_index = index / 8;
    const bit_index: u3 = @intCast(index % 8);
    return (bitmap[byte_index] & (@as(u8, 1) << bit_index)) != 0;
}

// Code block types
pub const CodeBlockType = enum(u2) {
    unoptimized = 0, // Non-optimized (quick compile)
    optimized = 1, // Optimized by Factor compiler
    pic = 2, // Polymorphic inline cache
};

// Code block header structure
// Header bit layout:
//   bit 0:       free? (1 = free block)
//   bits 1-2:    type (CodeBlockType)
//   bits 3-23:   size / 8 (when not free)
//   bits 24-31:  stack_frame_size / 16 (when not free)
//
// When free:
//   bits 3-end:  size (not divided by 8)
pub const CodeBlock = extern struct {
    header: Cell,
    owner: Cell, // Tagged pointer: word, quotation, or f
    parameters: Cell, // Tagged array of call parameters
    relocation: Cell, // Tagged byte-array of relocation entries

    const Self = @This();

    pub inline fn isFree(self: *const Self) bool {
        return (self.header & 1) == 1;
    }

    pub fn blockType(self: *const Self) CodeBlockType {
        return @enumFromInt(@as(u2, @truncate((self.header >> 1) & 3)));
    }

    pub inline fn size(self: *const Self) Cell {
        if (self.isFree()) {
            return self.header & ~@as(Cell, 7);
        }
        return (self.header & 0xFFFFF8);
    }

    pub fn stackFrameSize(self: *const Self) Cell {
        if (self.isFree()) {
            return 0;
        }
        return (self.header >> 20) & 0xFF0;
    }

    pub fn stackFrameSizeForAddress(self: *const Self, addr: Cell) Cell {
        const natural_frame_size = self.stackFrameSize();

        // The first instruction in a code block is the prolog safepoint,
        // and a leaf procedure code block will record a frame size of zero.
        // If we're seeing a stack frame in either of these cases, it's a
        // fake "leaf frame" set up by the signal handler.
        if (natural_frame_size == 0 or addr == self.entryPoint()) {
            return Self.LEAF_FRAME_SIZE;
        }
        return natural_frame_size;
    }

    pub inline fn entryPoint(self: *const Self) Cell {
        std.debug.assert(!self.isFree());
        return @intFromPtr(self) + @sizeOf(Self);
    }

    pub fn codeStart(self: *const Self) [*]u8 {
        const base: [*]u8 = @ptrCast(@constCast(self));
        return base + @sizeOf(Self);
    }

    pub fn codeSize(self: *const Self) Cell {
        return self.size() - @sizeOf(Self);
    }

    pub fn initialize(self: *Self, block_type: CodeBlockType, total_size: Cell, frame_size: Cell) void {
        std.debug.assert(total_size >= @sizeOf(Self));
        std.debug.assert(total_size % 8 == 0);
        std.debug.assert(frame_size % 16 == 0);
        // Encode header
        const type_bits = @as(Cell, @intFromEnum(block_type)) << 1;
        const size_bits = total_size & 0xFFFFF8;
        const frame_bits = (frame_size & 0xFF0) << 20;
        self.header = type_bits | size_bits | frame_bits;
        self.owner = layouts.false_object;
        self.parameters = layouts.false_object;
        self.relocation = layouts.false_object;
    }

    pub fn setStackFrameSize(self: *Self, frame_size: Cell) void {
        std.debug.assert(self.size() < 0xFFFFFF);
        std.debug.assert(!self.isFree());
        std.debug.assert(frame_size % 16 == 0);
        std.debug.assert(frame_size <= 0xFF0);
        self.header = (self.header & 0xFFFFFF) | (frame_size << 20);
    }

    pub fn setType(self: *Self, block_type: CodeBlockType) void {
        self.header = (self.header & ~@as(Cell, 0x7)) | (@as(Cell, @intFromEnum(block_type)) << 1);
    }

    pub fn markFree(self: *Self, total_size: Cell) void {
        self.header = (total_size & ~@as(Cell, 7)) | 1;
    }

    pub fn flushIcache(self: *const Self) void {
        icache.flushICache(self.entryPoint(), self.codeSize());
    }

    pub fn isPic(self: *const Self) bool {
        return self.blockType() == .pic;
    }

    pub fn blockGcInfo(self: *const Self) ?*const GcInfo {
        if (self.isFree()) return null;
        const block_size = self.size();
        if (block_size < @sizeOf(GcInfo)) return null;

        const block_addr: [*]const u8 = @ptrCast(self);
        const gc_info_addr = block_addr + block_size - @sizeOf(GcInfo);
        return @ptrCast(@alignCast(gc_info_addr));
    }

    pub fn offset(self: *const Self, addr: Cell) Cell {
        return addr - self.entryPoint();
    }

    // LEAF_FRAME_SIZE = 16 (from layouts.hpp)
    pub const LEAF_FRAME_SIZE: Cell = 16;

    // Get the owner quotation for this code block
    // Matches C++ code_block::owner_quot():
    //   For non-optimized blocks owned by a word: return word->def (the quotation)
    //   For optimized blocks: return owner as-is (the word itself)
    pub fn ownerQuot(self: *const Self) Cell {
        if (self.blockType() != .optimized and layouts.hasTag(self.owner, .word)) {
            const word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(self.owner));
            return word.def;
        }
        return self.owner;
    }

    // Calculate scan value for single-stepper
    // Returns -1 for optimized code, or the quotation array index for unoptimized quotations
    pub fn scan(self: *const Self, vm: *@import("vm.zig").FactorVM, addr: Cell) Cell {
        // Only unoptimized code blocks support scanning
        if (self.blockType() != .unoptimized) {
            return layouts.tagFixnum(-1);
        }

        // Get the quotation - follow word->def if needed
        var ptr = self.owner;
        if (layouts.hasTag(ptr, .word)) {
            const word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(ptr));
            ptr = word.def;
        }

        // Must be a quotation
        if (!layouts.hasTag(ptr, .quotation)) {
            return layouts.tagFixnum(-1);
        }

        const ofs = self.offset(addr);
        return layouts.tagFixnum(quotCodeOffsetToScan(vm, ptr, ofs));
    }

    // Map a code offset to a quotation array index by replaying JIT compilation
    // Matches C++ factor_vm::quot_code_offset_to_scan
    fn quotCodeOffsetToScan(vm: *@import("vm.zig").FactorVM, quot_cell: Cell, offset_val: Cell) layouts.Fixnum {
        const jit_mod = @import("jit.zig");

        var compiler = jit_mod.QuotationJit.init(vm, quot_cell, false, false);
        defer compiler.deinit();
        compiler.initQuotation(quot_cell);
        compiler.jit.computePosition(offset_val);
        compiler.iterateQuotation() catch {
            return 0;
        };
        return compiler.jit.getPosition();
    }

    pub fn fromAddress(addr: Cell) *Self {
        return @ptrFromInt(addr);
    }
};

// Relocation types for code blocks - must match vm/instruction_operands.hpp
pub const RelocationType = enum(u4) {
    dlsym = 0, // External C symbol
    entry_point = 1, // Word/quotation entry point
    entry_point_pic = 2, // Word PIC entry point
    entry_point_pic_tail = 3, // Word tail-call PIC entry
    here = 4, // Current offset in code
    this = 5, // Current code block
    literal = 6, // Data heap literal
    untagged = 7, // Untagged fixnum literal
    megamorphic_cache_hits = 8, // Dispatch stats address
    vm = 9, // VM object pointer
    cards_offset = 10, // GC write barrier offset
    decks_offset = 11, // GC write barrier offset
    trampoline = 12, // Trampoline (ARM64 only)
    trampoline2 = 13, // Trampoline2 (ARM64 only)
    inline_cache_miss = 14, // Inline cache miss function
    safepoint = 15, // Safepoint page address
};

// Relocation class (how to patch)
// From C++: RC_ABSOLUTE_CELL=0, RC_ABSOLUTE=1, RC_RELATIVE=2,
// RC_RELATIVE_ARM_B=3, RC_RELATIVE_ARM_B_COND_LDR=4,
// RC_ABSOLUTE_ARM_LDUR=5, RC_ABSOLUTE_ARM_CMP=6,
// RC_ABSOLUTE_2=10, RC_ABSOLUTE_1=11
pub const RelocationClass = enum(u4) {
    absolute_cell = 0, // Full pointer
    absolute = 1, // 4-byte absolute
    relative = 2, // 4-byte relative (for CALL/JMP)
    relative_arm_b = 3, // ARM branch
    relative_arm_b_cond_ldr = 4, // ARM B.cond or LDR (literal)
    absolute_arm_ldur = 5, // ARM LDUR
    absolute_arm_cmp = 6, // ARM CMP
    _reserved7 = 7,
    _reserved8 = 8,
    _reserved9 = 9,
    absolute_2 = 10, // 2-byte absolute
    absolute_1 = 11, // 1-byte absolute
    _reserved12 = 12,
    _reserved13 = 13,
    _reserved14 = 14,
    _reserved15 = 15,
};

// ARM instruction masks for relocation classes
pub const rel_arm_b_mask: u32 = 0x03ffffff;
pub const rel_arm_b_cond_ldr_mask: u32 = 0x00ffffe0;
pub const rel_arm_ldur_mask: u32 = 0x001ff000;
pub const rel_arm_cmp_mask: u32 = 0x003ffc00;

// Relocation entry
// C++ layout: (rel_type << 28) | (rel_class << 24) | offset
//   - Type: bits 28-31 (4 bits)
//   - Class: bits 24-27 (4 bits)
//   - Offset: bits 0-23 (24 bits)
pub const RelocationEntry = extern struct {
    value: u32,

    pub fn getType(self: RelocationEntry) RelocationType {
        return @enumFromInt(@as(u4, @truncate((self.value & 0xF0000000) >> 28)));
    }

    pub fn getClass(self: RelocationEntry) RelocationClass {
        return @enumFromInt(@as(u4, @truncate((self.value & 0x0F000000) >> 24)));
    }

    pub fn getOffset(self: RelocationEntry) u24 {
        return @truncate(self.value & 0x00FFFFFF);
    }

    pub fn init(rel_type: RelocationType, rel_class: RelocationClass, offset: u24) RelocationEntry {
        return RelocationEntry{
            .value = (@as(u32, @intFromEnum(rel_type)) << 28) |
                (@as(u32, @intFromEnum(rel_class)) << 24) |
                @as(u32, offset),
        };
    }

    // Get number of parameters consumed from literals/parameters array
    // This matches the C++ number_of_parameters() function
    pub fn numberOfParameters(self: RelocationEntry) u32 {
        return switch (self.getType()) {
            .vm => 1,
            .dlsym => 2,
            .entry_point, .entry_point_pic, .entry_point_pic_tail, .literal, .here, .untagged, .this, .megamorphic_cache_hits, .cards_offset, .decks_offset, .inline_cache_miss, .safepoint, .trampoline, .trampoline2 => 0,
        };
    }
};

pub const CodeBlockScanFlags = struct {
    has_literals: bool = false,
    has_code_ptrs: bool = false,
};

pub const LiteralRelocationSite = struct {
    rel: RelocationEntry,
    param_index: u32,
};

// Scan relocation entries once to determine if a code block contains
// embedded literals or code pointers.
pub fn scanRelocationFlags(block: *const CodeBlock) CodeBlockScanFlags {
    var flags = CodeBlockScanFlags{};

    if (block.relocation == layouts.false_object) return flags;
    if (!layouts.hasTag(block.relocation, .byte_array)) return flags;

    const reloc_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(block.relocation));
    const reloc_cap = layouts.untagFixnumUnsigned(reloc_ba.capacity);
    if (reloc_cap == 0) return flags;

    const reloc_data = reloc_ba.data();
    const reloc_count = reloc_cap / @sizeOf(RelocationEntry);

    for (0..reloc_count) |i| {
        const entry_ptr: *const RelocationEntry = @ptrCast(@alignCast(reloc_data + i * @sizeOf(RelocationEntry)));
        switch (entry_ptr.getType()) {
            .literal => flags.has_literals = true,
            .entry_point, .entry_point_pic, .entry_point_pic_tail => flags.has_code_ptrs = true,
            else => {},
        }
        if (flags.has_literals and flags.has_code_ptrs) break;
    }

    return flags;
}

pub fn collectLiteralRelocationSites(
    block: *const CodeBlock,
    out: *std.ArrayListUnmanaged(LiteralRelocationSite),
    allocator: std.mem.Allocator,
) !void {
    out.clearRetainingCapacity();

    if (block.relocation == layouts.false_object) return;
    if (!layouts.hasTag(block.relocation, .byte_array)) return;

    const reloc_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(block.relocation));
    const reloc_cap = layouts.untagFixnumUnsigned(reloc_ba.capacity);
    if (reloc_cap == 0) return;

    const reloc_data = reloc_ba.data();
    const reloc_count = reloc_cap / @sizeOf(RelocationEntry);

    var literal_count: usize = 0;
    for (0..reloc_count) |i| {
        const entry_ptr: *const RelocationEntry = @ptrCast(@alignCast(reloc_data + i * @sizeOf(RelocationEntry)));
        if (entry_ptr.getType() == .literal) literal_count += 1;
    }
    if (literal_count == 0) return;

    try out.ensureTotalCapacity(allocator, literal_count);

    var param_index: u32 = 0;
    for (0..reloc_count) |i| {
        const entry_ptr: *const RelocationEntry = @ptrCast(@alignCast(reloc_data + i * @sizeOf(RelocationEntry)));
        const entry = entry_ptr.*;
        const rel_type = entry.getType();

        if (rel_type == .literal) {
            out.appendAssumeCapacity(.{
                .rel = entry,
                .param_index = param_index,
            });
        }

        switch (rel_type) {
            .vm => param_index += 1,
            .dlsym => param_index += 2,
            else => {},
        }
    }
}

// Instruction operand - handles reading/writing instruction operands
pub const InstructionOperand = struct {
    rel: RelocationEntry,
    compiled: *CodeBlock,
    index: Cell, // Index into parameters array (for external relocations)
    pointer: Cell, // Pointer to instruction location

    const Self = @This();

    pub fn init(rel: RelocationEntry, compiled: *CodeBlock, index: Cell) Self {
        return Self{
            .rel = rel,
            .compiled = compiled,
            .index = index,
            .pointer = compiled.entryPoint() + rel.getOffset(),
        };
    }

    // Load a value from a bitfield of an ARM instruction
    // Extracts bits [msb:lsb] and applies scaling (left shift)
    fn loadValueMasked(self: *const Self, msb: u5, lsb: u5, scaling: u5) i64 {
        const ptr: *align(1) const i32 = @ptrFromInt(self.pointer - @sizeOf(u32));
        const value = ptr.*;

        // Extract bits by shifting left to clear high bits, then right to position
        const shifted = value << (31 - msb);
        const extracted: i32 = shifted >> (31 - msb + lsb);

        // Apply scaling (left shift) and convert to i64
        return @as(i64, extracted) << scaling;
    }

    // Load the current value from the instruction
    // Note: x86 instruction operands are NOT aligned, so we use align(1) pointers
    pub fn loadValue(self: *const Self) i64 {
        return switch (self.rel.getClass()) {
            .absolute_cell => @bitCast(@as(*align(1) const Cell, @ptrFromInt(self.pointer - @sizeOf(Cell))).*),
            .absolute => @as(*align(1) const u32, @ptrFromInt(self.pointer - @sizeOf(u32))).*,
            .absolute_2 => @as(*align(1) const u16, @ptrFromInt(self.pointer - @sizeOf(u16))).*,
            .absolute_1 => @as(*const u8, @ptrFromInt(self.pointer - @sizeOf(u8))).*, // u8 always aligned
            .relative => blk: {
                const offset: i32 = @as(*align(1) const i32, @ptrFromInt(self.pointer - @sizeOf(i32))).*;
                break :blk @as(i64, offset) + @as(i64, @bitCast(self.pointer));
            },
            .relative_arm_b => blk: {
                const masked = self.loadValueMasked(25, 0, 2);
                break :blk masked + @as(i64, @bitCast(self.pointer)) - 4;
            },
            .relative_arm_b_cond_ldr => blk: {
                const masked = self.loadValueMasked(23, 5, 2);
                break :blk masked + @as(i64, @bitCast(self.pointer)) - 4;
            },
            .absolute_arm_ldur => self.loadValueMasked(20, 12, 0),
            .absolute_arm_cmp => self.loadValueMasked(21, 10, 0),
            ._reserved7, ._reserved8, ._reserved9, ._reserved12, ._reserved13, ._reserved14, ._reserved15 => {
                std.debug.print("[RELOC] FATAL: invalid relocation class {} in entry raw=0x{x} pointer=0x{x}\n", .{
                    @intFromEnum(self.rel.getClass()), self.rel.value, self.pointer,
                });
                unreachable;
            },
        };
    }

    // Load the current value from the instruction, using an explicit base
    // address for relative relocations. This is needed during code heap
    // compaction: instruction encodings still reference the OLD code base.
    pub fn loadValueRelative(self: *const Self, relative_to: Cell) i64 {
        return switch (self.rel.getClass()) {
            .absolute_cell => @bitCast(@as(*align(1) const Cell, @ptrFromInt(self.pointer - @sizeOf(Cell))).*),
            .absolute => @as(*align(1) const u32, @ptrFromInt(self.pointer - @sizeOf(u32))).*,
            .absolute_2 => @as(*align(1) const u16, @ptrFromInt(self.pointer - @sizeOf(u16))).*,
            .absolute_1 => @as(*const u8, @ptrFromInt(self.pointer - @sizeOf(u8))).*, // u8 always aligned
            .relative => blk: {
                const offset: i32 = @as(*align(1) const i32, @ptrFromInt(self.pointer - @sizeOf(i32))).*;
                break :blk @as(i64, offset) + @as(i64, @bitCast(relative_to));
            },
            .relative_arm_b => blk: {
                const masked = self.loadValueMasked(25, 0, 2);
                break :blk masked + @as(i64, @bitCast(relative_to)) - 4;
            },
            .relative_arm_b_cond_ldr => blk: {
                const masked = self.loadValueMasked(23, 5, 2);
                break :blk masked + @as(i64, @bitCast(relative_to)) - 4;
            },
            .absolute_arm_ldur => self.loadValueMasked(20, 12, 0),
            .absolute_arm_cmp => self.loadValueMasked(21, 10, 0),
            ._reserved7, ._reserved8, ._reserved9, ._reserved12, ._reserved13, ._reserved14, ._reserved15 => {
                std.debug.print("[RELOC] FATAL: invalid relocation class {} in entry raw=0x{x} relative_to=0x{x}\n", .{
                    @intFromEnum(self.rel.getClass()), self.rel.value, relative_to,
                });
                unreachable;
            },
        };
    }

    // Store a value into a bitfield of an ARM instruction
    // Inserts value into bits specified by mask, at position lsb, with scaling (right shift)
    fn storeValueMasked(self: *Self, value: i64, mask: u32, lsb: u5, scaling: u5) void {
        const ptr: *align(1) u32 = @ptrFromInt(self.pointer - @sizeOf(u32));
        const old = ptr.*;

        // Right shift to remove scaling, then position at lsb, then apply mask
        const shifted_value: u32 = @truncate(@as(u64, @bitCast(value >> scaling)));
        const positioned = (shifted_value << lsb) & mask;

        // Clear masked bits in original, then OR in new value
        ptr.* = (old & ~mask) | positioned;
    }

    // Store a value to the instruction operand
    // Note: x86 instruction operands are NOT aligned, so we use align(1) pointers
    pub fn storeValue(self: *Self, absolute_value: i64) void {
        const relative_value = absolute_value - @as(i64, @bitCast(self.pointer));

        switch (self.rel.getClass()) {
            .absolute_cell => {
                const ptr: *align(1) Cell = @ptrFromInt(self.pointer - @sizeOf(Cell));
                ptr.* = @bitCast(absolute_value);
            },
            .absolute => {
                const ptr: *align(1) u32 = @ptrFromInt(self.pointer - @sizeOf(u32));
                ptr.* = @truncate(@as(u64, @bitCast(absolute_value)));
            },
            .absolute_2 => {
                const ptr: *align(1) u16 = @ptrFromInt(self.pointer - @sizeOf(u16));
                ptr.* = @truncate(@as(u64, @bitCast(absolute_value)));
            },
            .absolute_1 => {
                const ptr: *u8 = @ptrFromInt(self.pointer - @sizeOf(u8)); // u8 always aligned
                ptr.* = @truncate(@as(u64, @bitCast(absolute_value)));
            },
            .relative => {
                const ptr: *align(1) i32 = @ptrFromInt(self.pointer - @sizeOf(i32));
                ptr.* = @truncate(relative_value);
            },
            .relative_arm_b => {
                // Adjust relative value for ARM B/BL (add 4 to compensate for PC offset)
                const adjusted = relative_value + 4;

                // Assert range and alignment (matching C++ FACTOR_ASSERT)
                std.debug.assert(adjusted < 0x8000000);
                std.debug.assert(adjusted >= -0x8000000);
                std.debug.assert((adjusted & 3) == 0);

                self.storeValueMasked(adjusted, rel_arm_b_mask, 0, 2);
            },
            .relative_arm_b_cond_ldr => {
                // Adjust relative value for ARM B.cond/LDR (add 4 to compensate for PC offset)
                const adjusted = relative_value + 4;

                // Assert range and alignment
                std.debug.assert(adjusted < 0x2000000);
                std.debug.assert(adjusted >= -0x2000000);
                std.debug.assert((adjusted & 3) == 0);

                self.storeValueMasked(adjusted, rel_arm_b_cond_ldr_mask, 5, 2);
            },
            .absolute_arm_ldur => {
                // LDUR offset is signed 9-bit [-256, 255]
                std.debug.assert(absolute_value >= -256);
                std.debug.assert(absolute_value <= 255);

                self.storeValueMasked(absolute_value, rel_arm_ldur_mask, 12, 0);
            },
            .absolute_arm_cmp => {
                // CMP immediate is unsigned 12-bit [0, 4095]
                std.debug.assert(absolute_value >= 0);
                std.debug.assert(absolute_value <= 4095);

                self.storeValueMasked(absolute_value, rel_arm_cmp_mask, 10, 0);
            },
            ._reserved7, ._reserved8, ._reserved9, ._reserved12, ._reserved13, ._reserved14, ._reserved15 => {
                std.debug.print("[RELOC] FATAL: invalid relocation class {} in storeValue, entry raw=0x{x} pointer=0x{x}\n", .{
                    @intFromEnum(self.rel.getClass()), self.rel.value, self.pointer,
                });
                unreachable;
            },
        }
    }

    // Load the code block that this operand points to.
    // Matches C++: (code_block*)(load_value() - sizeof(code_block))
    pub inline fn loadCodeBlock(self: *const Self) ?*CodeBlock {
        const value = self.loadValue();
        if (value == 0) return null;
        const unsigned_value: Cell = @bitCast(value);
        return @ptrFromInt(unsigned_value - @sizeOf(CodeBlock));
    }
};

// Relocation context - provides values for relocation resolution
pub const RelocationContext = struct {
    vm_ptr: Cell,
    cards_offset: Cell,
    decks_offset: Cell,
    megamorphic_cache_hits_ptr: Cell,
    inline_cache_miss_ptr: Cell,
    safepoint_page: Cell,

    // PIC configuration
    max_pic_size: Cell,
    lazy_jit_compile_ep: Cell,

    // Get literal from literals array at given index
    literals: ?*const layouts.Array,
    parameters: ?*const layouts.Array,
};

fn requireLiterals(ctx: *const RelocationContext, literal_index: *Cell) Cell {
    const lits = ctx.literals.?;
    std.debug.assert(literal_index.* < layouts.untagFixnumUnsigned(lits.capacity));
    const lit = lits.data()[literal_index.*];
    literal_index.* += 1;
    return lit;
}

fn requireParameters(ctx: *const RelocationContext, param_index: Cell, needed: Cell) *const layouts.Array {
    const params = ctx.parameters.?;
    std.debug.assert(param_index + (needed - 1) < layouts.untagFixnumUnsigned(params.capacity));
    return params;
}

// Apply all relocations to a code block
pub fn applyRelocations(block: *CodeBlock, ctx: *const RelocationContext) void {
    if (block.relocation == layouts.false_object) return;
    if (!layouts.hasTag(block.relocation, .byte_array)) return;

    const reloc_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(block.relocation));
    const reloc_data = reloc_ba.data();
    const reloc_count = layouts.untagFixnumUnsigned(reloc_ba.capacity) / @sizeOf(RelocationEntry);

    var literal_index: Cell = 0;
    var param_index: Cell = 0;

    for (0..reloc_count) |i| {
        const entry_ptr: *const RelocationEntry = @ptrCast(@alignCast(reloc_data + i * @sizeOf(RelocationEntry)));
        var op = InstructionOperand.init(entry_ptr.*, block, param_index);

        const value: i64 = switch (entry_ptr.getType()) {
            .literal => @bitCast(requireLiterals(ctx, &literal_index)),
            .entry_point => blk: {
                const lit = requireLiterals(ctx, &literal_index);
                const tag = layouts.typeTag(lit);
                std.debug.assert(tag == .word or tag == .quotation);
                const ep = computeEntryPoint(lit);
                if (comptime builtin.mode == .Debug) {
                    if (tag == .quotation and (ep == ctx.lazy_jit_compile_ep or ep == 0)) {
                        std.debug.print("[STALE RELOC] block=0x{x} owner=0x{x} quot=0x{x} ep=0x{x} lazy_ep=0x{x}\n", .{
                            @intFromPtr(block), block.owner, lit, ep, ctx.lazy_jit_compile_ep,
                        });
                    }
                }
                break :blk @bitCast(ep);
            },
            .entry_point_pic => blk: {
                const lit = requireLiterals(ctx, &literal_index);
                std.debug.assert(layouts.hasTag(lit, .word));
                break :blk @bitCast(computeEntryPointPicAddress(lit, ctx.max_pic_size, ctx.lazy_jit_compile_ep));
            },
            .entry_point_pic_tail => blk: {
                const lit = requireLiterals(ctx, &literal_index);
                std.debug.assert(layouts.hasTag(lit, .word));
                break :blk @bitCast(computeEntryPointPicTailAddress(lit, ctx.max_pic_size, ctx.lazy_jit_compile_ep));
            },
            .here => blk: {
                const lit = requireLiterals(ctx, &literal_index);
                std.debug.assert(layouts.hasTag(lit, .fixnum));
                const offset = layouts.untagFixnum(lit);
                if (offset >= 0) {
                    break :blk @as(i64, @bitCast(block.entryPoint() + entry_ptr.getOffset())) + offset;
                }
                // Negative: entry_point - n (where n < 0, so this adds |n|)
                // Intentionally omits reloc_offset, matching C++ compute_here_address
                break :blk @as(i64, @bitCast(block.entryPoint())) - offset;
            },
            .this => @bitCast(block.entryPoint()),
            .untagged => blk: {
                const lit = requireLiterals(ctx, &literal_index);
                std.debug.assert(layouts.hasTag(lit, .fixnum));
                break :blk layouts.untagFixnum(lit);
            },
            .dlsym => @bitCast(computeDlsymAddress(requireParameters(ctx, param_index, 2), param_index)),
            .vm => blk: {
                const offset_cell = requireParameters(ctx, param_index, 1).data()[param_index];
                std.debug.assert(layouts.hasTag(offset_cell, .fixnum));
                break :blk @as(i64, @bitCast(ctx.vm_ptr)) + layouts.untagFixnum(offset_cell);
            },
            .cards_offset => @bitCast(ctx.cards_offset),
            .decks_offset => @bitCast(ctx.decks_offset),
            .megamorphic_cache_hits => @bitCast(ctx.megamorphic_cache_hits_ptr),
            .inline_cache_miss => @bitCast(ctx.inline_cache_miss_ptr),
            .safepoint => @bitCast(ctx.safepoint_page),
            .trampoline => if (builtin.cpu.arch == .aarch64)
                @as(i64, @bitCast(@intFromPtr(&trampolines.trampoline)))
            else
                unreachable,
            .trampoline2 => if (builtin.cpu.arch == .aarch64)
                @as(i64, @bitCast(@intFromPtr(&trampolines.trampoline2)))
            else
                unreachable,
        };

        op.storeValue(value);
        param_index += entry_ptr.numberOfParameters();
    }
}

// Get the actual owner of a code block
// Cold generic word call sites point to quotations that call inline-cache-miss
// This function extracts the actual word from such quotations
fn codeBlockOwner(block: *const CodeBlock) Cell {
    const owner = block.owner;

    // If not a quotation, return as-is
    if (!layouts.hasTag(owner, .quotation)) {
        return owner;
    }

    // For quotations used in PIC, extract the wrapped word
    const quot: *const layouts.Quotation = @ptrFromInt(layouts.UNTAG(owner));
    if (quot.array == layouts.false_object) {
        return owner;
    }

    const arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(quot.array));
    const capacity = layouts.untagFixnumUnsigned(arr.capacity);

    // PIC quotations have 5 elements
    if (capacity != 5) {
        return owner;
    }

    // Extract word from wrapper at index 0
    const elem0 = arr.data()[0];
    if (layouts.hasTag(elem0, .wrapper)) {
        const wrapper: *const layouts.Wrapper = @ptrFromInt(layouts.UNTAG(elem0));
        return wrapper.object;
    }

    return owner;
}

// Compute entry point for a word or quotation.
// Matches C++ compute_entry_point_address.
inline fn computeEntryPoint(obj: Cell) Cell {
    const tag = layouts.typeTag(obj);
    if (tag == .word) {
        const word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(obj));
        return word.entry_point;
    } else if (tag == .quotation) {
        const quot: *const layouts.Quotation = @ptrFromInt(layouts.UNTAG(obj));
        return quot.entry_point;
    }
    unreachable;
}

// Check if a quotation is compiled (has valid entry_point)
// Matches C++ quotation_compiled_p: entry_point != 0 && entry_point != lazy_jit_compile_entry_point()
fn isQuotationCompiled(quot: *const layouts.Quotation, lazy_jit_ep: Cell) bool {
    return quot.entry_point != 0 and quot.entry_point != lazy_jit_ep;
}

// Compute entry point for PIC address (non-tail call)
// Uses word's pic_def if it's a compiled quotation, otherwise falls back to word's entry_point
// Matches C++ compute_entry_point_pic_address
fn computeEntryPointPicAddress(word_cell: Cell, max_pic_size: Cell, lazy_jit_ep: Cell) Cell {
    std.debug.assert(layouts.hasTag(word_cell, .word));

    const word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(word_cell));
    const pic_def = word.pic_def;

    // If pic_def is false/null or max_pic_size is 0, use word's entry_point
    if (pic_def == layouts.false_object or max_pic_size == 0) {
        return word.entry_point;
    }

    // Check if pic_def is a compiled quotation
    if (layouts.hasTag(pic_def, .quotation)) {
        const quot: *const layouts.Quotation = @ptrFromInt(layouts.UNTAG(pic_def));
        if (isQuotationCompiled(quot, lazy_jit_ep)) {
            return quot.entry_point;
        }
    }

    // Fallback to word's entry_point
    return word.entry_point;
}

// Compute entry point for PIC tail address (tail call)
// Uses word's pic_tail_def if it's a compiled quotation, otherwise falls back to word's entry_point
// Matches C++ compute_entry_point_pic_tail_address
fn computeEntryPointPicTailAddress(word_cell: Cell, max_pic_size: Cell, lazy_jit_ep: Cell) Cell {
    std.debug.assert(layouts.hasTag(word_cell, .word));

    const word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(word_cell));
    const pic_tail_def = word.pic_tail_def;

    // If pic_tail_def is false/null or max_pic_size is 0, use word's entry_point
    if (pic_tail_def == layouts.false_object or max_pic_size == 0) {
        return word.entry_point;
    }

    // Check if pic_tail_def is a compiled quotation
    if (layouts.hasTag(pic_tail_def, .quotation)) {
        const quot: *const layouts.Quotation = @ptrFromInt(layouts.UNTAG(pic_tail_def));
        if (isQuotationCompiled(quot, lazy_jit_ep)) {
            return quot.entry_point;
        }
    }

    // Fallback to word's entry_point
    return word.entry_point;
}

// Compute dlsym address - looks up an external library symbol
// Parameters array contains: [symbol_name (byte_array), dll (dll object or f)]
// Returns the symbol address or undefined_symbol handler if not found
// Look up internal VM symbols by name. The runtime @intFromPtr references
// prevent Zig's DCE from stripping exported functions in Release builds.
fn lookupInternalSymbol(name: [*:0]const u8) ?usize {
    const c = @import("c_api.zig");
    const eql = struct {
        fn f(a: [*:0]const u8, b: [*:0]const u8) bool {
            return std.mem.orderZ(u8, a, b) == .eq;
        }
    }.f;
    if (eql(name, "begin_callback")) return @intFromPtr(&c.begin_callback);
    if (eql(name, "end_callback")) return @intFromPtr(&c.end_callback);
    if (eql(name, "new_context")) return @intFromPtr(&c.new_context);
    if (eql(name, "delete_context")) return @intFromPtr(&c.delete_context);
    if (eql(name, "reset_context")) return @intFromPtr(&c.reset_context);
    if (eql(name, "lazy_jit_compile")) return @intFromPtr(&c.lazy_jit_compile);
    if (eql(name, "inline_cache_miss")) return @intFromPtr(&c.inline_cache_miss);
    if (eql(name, "overflow_fixnum_add")) return @intFromPtr(&c.overflow_fixnum_add);
    if (eql(name, "overflow_fixnum_subtract")) return @intFromPtr(&c.overflow_fixnum_subtract);
    if (eql(name, "overflow_fixnum_multiply")) return @intFromPtr(&c.overflow_fixnum_multiply);
    if (eql(name, "from_signed_cell")) return @intFromPtr(&c.from_signed_cell);
    if (eql(name, "from_unsigned_cell")) return @intFromPtr(&c.from_unsigned_cell);
    if (eql(name, "from_signed_8")) return @intFromPtr(&c.from_signed_8);
    if (eql(name, "from_unsigned_8")) return @intFromPtr(&c.from_unsigned_8);
    if (eql(name, "from_signed_4")) return @intFromPtr(&c.from_signed_4);
    if (eql(name, "from_unsigned_4")) return @intFromPtr(&c.from_unsigned_4);
    if (eql(name, "err_no")) return @intFromPtr(&c.err_no);
    if (eql(name, "set_err_no")) return @intFromPtr(&c.set_err_no);
    if (eql(name, "factor_memcpy")) return @intFromPtr(&c.factor_memcpy);
    if (eql(name, "minor_gc")) return @intFromPtr(&c.minor_gc);
    if (eql(name, "full_gc")) return @intFromPtr(&c.full_gc);
    if (eql(name, "undefined_symbol")) return @intFromPtr(&c.undefined_symbol);
    return null;
}

pub fn computeDlsymAddress(parameters: *const layouts.Array, index: Cell) Cell {
    const symbol = parameters.data()[index];
    const library = parameters.data()[index + 1];

    const c_api = @import("c_api.zig");
    const undef_addr = @intFromPtr(&c_api.undefined_symbol);

    std.debug.assert(layouts.hasTag(symbol, .byte_array));

    const symbol_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(symbol));
    const name_ptr: [*:0]const u8 = @ptrCast(symbol_ba.data());

    var handle: ?*anyopaque = null;
    if (library != layouts.false_object) {
        std.debug.assert(layouts.hasTag(library, .dll));
        const dll: *const layouts.Dll = @ptrFromInt(layouts.UNTAG(library));
        if (dll.handle == null) return undef_addr;
        handle = dll.handle;
    } else {
        // Null dll — look up in main executable.
        // Check internal table first (also prevents DCE of exported fns).
        if (lookupInternalSymbol(name_ptr)) |addr| return addr;

        handle = alien.null_dll;
    }

    const sym_addr = std.c.dlsym(handle, name_ptr);
    if (sym_addr) |addr| {
        return @intFromPtr(addr);
    }

    return undef_addr;
}

// Update word references in a code block (after word redefinition).
// Matches C++ factor_vm::update_word_references.
pub fn updateWordReferences(block: *CodeBlock, reset_inline_caches: bool, max_pic_size: Cell, lazy_jit_ep: Cell) void {
    if (block.relocation == layouts.false_object) return;
    if (!layouts.hasTag(block.relocation, .byte_array)) return;

    const reloc_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(block.relocation));
    const reloc_cap = layouts.untagFixnumUnsigned(reloc_ba.capacity);
    if (reloc_cap == 0) return;

    const reloc_data = reloc_ba.data();
    const reloc_count = reloc_cap / @sizeOf(RelocationEntry);

    var literal_index: Cell = 0;
    var modified = false;

    for (0..reloc_count) |i| {
        const entry_ptr: *const RelocationEntry = @ptrCast(@alignCast(reloc_data + i * @sizeOf(RelocationEntry)));
        const rel_type = entry_ptr.getType();

        switch (rel_type) {
            .entry_point => {
                var op = InstructionOperand.init(entry_ptr.*, block, literal_index);
                if (op.loadCodeBlock()) |dest| {
                    const owner = dest.owner;
                    if (owner != layouts.false_object) {
                        const new_ep = computeEntryPoint(owner);
                        if (comptime builtin.mode == .Debug) {
                            if (new_ep == lazy_jit_ep) {
                                const S = struct {
                                    var count: u64 = 0;
                                };
                                S.count += 1;
                                if (S.count <= 5) {
                                    std.debug.print("[updateWordRefs STUCK] #{} block=0x{x} block_owner=0x{x} dest_owner=0x{x} tag={}\n", .{
                                        S.count, @intFromPtr(block), block.owner, owner, @intFromEnum(layouts.typeTag(owner)),
                                    });
                                }
                            }
                        }
                        const new_ep_value: i64 = @bitCast(new_ep);
                        if (op.loadValue() != new_ep_value) {
                            op.storeValue(new_ep_value);
                            modified = true;
                        }
                    }
                }
                literal_index += 1;
            },
            .entry_point_pic => {
                var op = InstructionOperand.init(entry_ptr.*, block, literal_index);
                if (op.loadCodeBlock()) |dest| {
                    if (reset_inline_caches or !dest.isPic()) {
                        const owner = codeBlockOwner(dest);
                        if (owner != layouts.false_object) {
                            const new_ep_value: i64 = @bitCast(computeEntryPointPicAddress(owner, max_pic_size, lazy_jit_ep));
                            if (op.loadValue() != new_ep_value) {
                                op.storeValue(new_ep_value);
                                modified = true;
                            }
                        }
                    }
                }
                literal_index += 1;
            },
            .entry_point_pic_tail => {
                var op = InstructionOperand.init(entry_ptr.*, block, literal_index);
                if (op.loadCodeBlock()) |dest| {
                    if (reset_inline_caches or !dest.isPic()) {
                        const owner = codeBlockOwner(dest);
                        if (owner != layouts.false_object) {
                            const new_ep_value: i64 = @bitCast(computeEntryPointPicTailAddress(owner, max_pic_size, lazy_jit_ep));
                            if (op.loadValue() != new_ep_value) {
                                op.storeValue(new_ep_value);
                                modified = true;
                            }
                        }
                    }
                }
                literal_index += 1;
            },
            .literal, .here, .untagged => literal_index += 1,
            else => {},
        }
    }

    // Flush only when at least one relocation target changed.
    if (modified) {
        block.flushIcache();
    }
}

// Compile-time verification
comptime {
    // Verify CodeBlock size
    std.debug.assert(@sizeOf(CodeBlock) == 4 * @sizeOf(Cell));

    // Verify field order
    std.debug.assert(@offsetOf(CodeBlock, "header") == 0);
    std.debug.assert(@offsetOf(CodeBlock, "owner") == @sizeOf(Cell));
    std.debug.assert(@offsetOf(CodeBlock, "parameters") == 2 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(CodeBlock, "relocation") == 3 * @sizeOf(Cell));
}

// Tests
test "code block header encoding" {
    var block: CodeBlock = undefined;
    block.initialize(.unoptimized, 64, 32);

    try std.testing.expect(!block.isFree());
    try std.testing.expectEqual(CodeBlockType.unoptimized, block.blockType());
    try std.testing.expectEqual(@as(Cell, 64), block.size());
    try std.testing.expectEqual(@as(Cell, 32), block.stackFrameSize());
}

test "code block free marking" {
    var block: CodeBlock = undefined;
    block.initialize(.optimized, 128, 16);

    try std.testing.expect(!block.isFree());

    block.markFree(128);
    try std.testing.expect(block.isFree());
    try std.testing.expectEqual(@as(Cell, 128), block.size());
}

test "relocation entry" {
    const entry = RelocationEntry.init(.entry_point, .relative, 0x1234);

    try std.testing.expectEqual(RelocationType.entry_point, entry.getType());
    try std.testing.expectEqual(RelocationClass.relative, entry.getClass());
    try std.testing.expectEqual(@as(u24, 0x1234), entry.getOffset());
}
