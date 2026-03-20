const std = @import("std");
const builtin = @import("builtin");

const code_blocks = @import("code_blocks.zig");
const free_list = @import("free_list.zig");
const icache = @import("icache.zig");
const layouts = @import("layouts.zig");
const objects = @import("objects.zig");
const segments = @import("segments.zig");

const Cell = layouts.Cell;

fn returnTakesParam() bool {
    return builtin.cpu.arch == .x86_64 or builtin.cpu.arch == .x86;
}

pub const CallbackHeap = struct {
    segment: ?*segments.Segment,
    free_list: free_list.FreeListAllocator,
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, size: Cell) !Self {
        const seg = try allocator.create(segments.Segment);
        errdefer allocator.destroy(seg);

        seg.* = try segments.Segment.init(size, true);
        errdefer seg.deinit();

        return Self{
            .segment = seg,
            .free_list = .init(allocator, seg.start, seg.size),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.free_list.deinit();
        if (self.segment) |seg| {
            seg.deinit();
            self.allocator.destroy(seg);
            self.segment = null;
        }
    }

    pub fn add(self: *Self, owner: Cell, return_rewind: Cell, vm_ptr: Cell, vm: *const @import("vm.zig").FactorVM) ?*code_blocks.CodeBlock {
        const special_objects = &vm.vm_asm.special_objects;
        const callback_stub = special_objects[@intFromEnum(objects.SpecialObject.callback_stub)];
        if (callback_stub == layouts.false_object) return null;

        std.debug.assert(layouts.hasTag(callback_stub, .array));
        const stub_array: *const layouts.Array = @ptrFromInt(layouts.UNTAG(callback_stub));
        std.debug.assert(layouts.untagFixnumUnsigned(stub_array.capacity) >= 2);

        const insns_cell = stub_array.data()[1];
        std.debug.assert(layouts.hasTag(insns_cell, .byte_array));
        const insns: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(insns_cell));
        const code_size = layouts.untagFixnumUnsigned(insns.capacity);

        const total_size = layouts.alignCell(@sizeOf(code_blocks.CodeBlock) + code_size, layouts.data_alignment);
        const addr = self.free_list.allocate(total_size) orelse return null;
        const stub: *code_blocks.CodeBlock = @ptrFromInt(addr);

        // low 3 bits are clear (not free, type bits 0).
        stub.header = total_size & ~@as(Cell, 7);
        stub.owner = owner;
        stub.parameters = layouts.false_object;
        stub.relocation = layouts.false_object;

        const dest: [*]u8 = @ptrFromInt(stub.entryPoint());
        const src = insns.data();
        @memcpy(dest[0..code_size], src[0..code_size]);

        storeCallbackOperand(stub, special_objects, 0, vm_ptr);

        if (builtin.cpu.arch == .aarch64) {
            const trampolines = @import("trampolines.zig");
            const c_api = @import("c_api.zig");
            if (vm.code) |code| {
                storeCallbackOperand(stub, special_objects, 1, code.safepoint_page);
            }
            storeCallbackOperand(stub, special_objects, 2, @intFromPtr(&trampolines.trampoline));
            storeCallbackOperand(stub, special_objects, 3, @intFromPtr(&trampolines.trampoline2));
            storeCallbackOperand(stub, special_objects, 4, @intFromPtr(&c_api.inline_cache_miss));
            storeCallbackOperand(stub, special_objects, 5, @intFromPtr(&vm.dispatch_stats.megamorphic_cache_hits));
        } else {
            storeCallbackOperand(stub, special_objects, 2, vm_ptr);
        }

        if (returnTakesParam()) {
            storeCallbackOperand(stub, special_objects, 3, return_rewind);
        }

        self.update(stub, vm);

        return stub;
    }

    pub fn update(_: *Self, stub: *code_blocks.CodeBlock, vm: *const @import("vm.zig").FactorVM) void {
        if (stub.owner == layouts.false_object) return;
        if (!layouts.hasTag(stub.owner, .word)) return;

        const word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(stub.owner));
        const special_objects = &vm.vm_asm.special_objects;

        if (builtin.cpu.arch == .aarch64) {
            storeCallbackOperand(stub, special_objects, 6, word.entry_point);
        } else {
            storeCallbackOperand(stub, special_objects, 1, word.entry_point);
        }

        icache.flushICache(stub.entryPoint(), stub.codeSize());
    }

    pub fn free(self: *Self, stub: *code_blocks.CodeBlock) void {
        const size = stub.size();
        stub.markFree(size);
        self.free_list.free(@intFromPtr(stub), size);
    }

    pub fn room(self: *const Self) AllocatorRoom {
        return AllocatorRoom{
            .size = self.segment.?.size,
            .occupied_space = self.free_list.allocatedBytes(),
            .total_free = self.free_list.freeBytes(),
            .contiguous_free = self.free_list.largestFreeBlock(),
            .free_block_count = self.free_list.freeBlockCount(),
        };
    }

    pub fn iterateOwners(self: *Self, visitor: fn (*Cell) void) void {
        const seg = self.segment orelse return;

        var current = seg.start;
        while (current < seg.end) {
            const block: *code_blocks.CodeBlock = @ptrFromInt(current);
            const block_size = block.size();

            if (block_size == 0) break; // End of used space

            if (!block.isFree()) {
                visitor(&block.owner);
            }

            current += block_size;
        }
    }

    pub fn iterateOwnersWithCtx(self: *Self, comptime T: type, visitor: fn (*Cell, T) void, ctx: T) void {
        const seg = self.segment orelse return;

        var current = seg.start;
        while (current < seg.end) {
            const block: *code_blocks.CodeBlock = @ptrFromInt(current);
            const block_size = block.size();

            if (block_size == 0) break; // End of used space

            if (!block.isFree()) {
                visitor(&block.owner, ctx);
            }

            current += block_size;
        }
    }
};

fn storeCallbackOperand(stub: *code_blocks.CodeBlock, special_objects: *const [objects.special_object_count]Cell, index: usize, value: Cell) void {
    const callback_stub = special_objects[@intFromEnum(objects.SpecialObject.callback_stub)];
    if (callback_stub == layouts.false_object) return;

    const stub_array: *const layouts.Array = @ptrFromInt(layouts.UNTAG(callback_stub));
    const reloc_cell = stub_array.data()[0];
    if (!layouts.hasTag(reloc_cell, .byte_array)) return;

    const reloc_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(reloc_cell));
    const reloc_data = reloc_ba.data();
    const reloc_count = layouts.untagFixnumUnsigned(reloc_ba.capacity) / @sizeOf(code_blocks.RelocationEntry);

    std.debug.assert(index < reloc_count);

    const entry_ptr: *const code_blocks.RelocationEntry = @ptrCast(@alignCast(reloc_data + index * @sizeOf(code_blocks.RelocationEntry)));
    const entry = entry_ptr.*;

    const pointer = stub.entryPoint() + entry.getOffset();

    switch (entry.getClass()) {
        .absolute_cell => {
            const ptr: [*]u8 = @ptrFromInt(pointer - @sizeOf(Cell));
            std.mem.writeInt(Cell, ptr[0..@sizeOf(Cell)], value, .little);
        },
        .absolute => {
            const ptr: [*]u8 = @ptrFromInt(pointer - @sizeOf(u32));
            std.mem.writeInt(u32, ptr[0..@sizeOf(u32)], @truncate(value), .little);
        },
        .absolute_2 => {
            const ptr: [*]u8 = @ptrFromInt(pointer - @sizeOf(u16));
            std.mem.writeInt(u16, ptr[0..@sizeOf(u16)], @truncate(value), .little);
        },
        .absolute_1 => {
            const ptr: [*]u8 = @ptrFromInt(pointer - @sizeOf(u8));
            ptr[0] = @truncate(value);
        },
        .relative => {
            const ptr: [*]u8 = @ptrFromInt(pointer - @sizeOf(i32));
            const rel_value: i32 = @truncate(@as(i64, @bitCast(value)) - @as(i64, @bitCast(pointer)));
            std.mem.writeInt(i32, ptr[0..@sizeOf(i32)], rel_value, .little);
        },
        .relative_arm_b,
        .relative_arm_b_cond_ldr,
        .absolute_arm_ldur,
        .absolute_arm_cmp,
        ._reserved7,
        ._reserved8,
        ._reserved9,
        ._reserved12,
        ._reserved13,
        ._reserved14,
        ._reserved15,
        => unreachable,
    }
}

pub const AllocatorRoom = struct {
    size: Cell,
    occupied_space: Cell,
    total_free: Cell,
    contiguous_free: Cell,
    free_block_count: Cell,
};

test "callback heap basic" {
    var heap = try CallbackHeap.init(std.testing.allocator, 64 * 1024);
    defer heap.deinit();

    const room_info = heap.room();
    try std.testing.expect(room_info.size == 64 * 1024);
}
