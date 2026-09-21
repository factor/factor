const std = @import("std");
const builtin = @import("builtin");

const code_blocks = @import("code_blocks.zig");
const free_list = @import("free_list.zig");
const icache = @import("icache.zig");
const jit_protect = @import("jit_protect.zig");
const layouts = @import("layouts.zig");
const objects = @import("objects.zig");
const segments = @import("segments.zig");

const Cell = layouts.Cell;

pub export fn arm64_variadic_callbacks_supported() callconv(.c) bool {
    return builtin.cpu.arch == .aarch64;
}

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

    // Callback addresses escape to native code, so live stubs cannot move.
    // Rebuild only the free lists when mixed template sizes exhaust a bucket.
    // The caller must hold a writable JIT scope while updating free headers.
    fn coalesceFreeBlocks(self: *Self, requested_size: Cell) void {
        self.free_list.reset();
        var scan = self.free_list.start;
        while (scan < self.free_list.end) {
            const block: *free_list.FreeBlock = @ptrFromInt(scan);
            var size = block.size();
            if (block.isFree()) {
                var next = scan + size;
                while (next < self.free_list.end) {
                    const following: *const free_list.FreeBlock = @ptrFromInt(next);
                    if (!following.isFree()) break;
                    const following_size = following.size();
                    size += following_size;
                    next += following_size;
                }
                // Zig's small buckets are exact-fit: even a merged 512-byte
                // block cannot satisfy a 128-byte request. Split small spans
                // for this retry; the allocator already splits large spans.
                var remainder = size;
                var address = scan;
                if (size <= free_list.free_list_count * free_list.block_granularity) {
                    while (remainder >= requested_size) {
                        self.free_list.addFreeBlock(address, requested_size);
                        address += requested_size;
                        remainder -= requested_size;
                    }
                }
                self.free_list.addFreeBlock(address, remainder);
            }
            scan += size;
        }
    }

    fn allocateStub(self: *Self, size: Cell) ?Cell {
        return self.free_list.allocate(size) orelse retry: {
            self.coalesceFreeBlocks(size);
            break :retry self.free_list.allocate(size);
        };
    }

    pub fn add(self: *Self, owner: Cell, return_rewind: Cell, vm_ptr: Cell, vm: *const @import("vm.zig").FactorVM) ?*code_blocks.CodeBlock {
        var jit_scope = jit_protect.Scope.init();
        defer jit_scope.deinit();

        const special_objects = &vm.vm_asm.special_objects;
        const callback_stub = special_objects[@intFromEnum(objects.SpecialObject.callback_stub)];
        if (callback_stub == layouts.false_object) return null;

        std.debug.assert(layouts.hasTag(callback_stub, .array));
        var stub_array: *const layouts.Array = @ptrFromInt(layouts.UNTAG(callback_stub));
        std.debug.assert(layouts.untagFixnumUnsigned(stub_array.capacity) >= 2);

        const variadic = builtin.cpu.arch == .aarch64 and return_rewind == std.math.maxInt(Cell);
        if (variadic) {
            if (layouts.untagFixnumUnsigned(stub_array.capacity) < 3) {
                @constCast(vm).generalError(.ffi, layouts.false_object, layouts.false_object);
            }
            stub_array = @ptrFromInt(layouts.UNTAG(stub_array.data()[2]));
        }

        const insns_cell = stub_array.data()[1];
        std.debug.assert(layouts.hasTag(insns_cell, .byte_array));
        const insns: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(insns_cell));
        const code_size = layouts.untagFixnumUnsigned(insns.capacity);

        const total_size = layouts.alignCell(@sizeOf(code_blocks.CodeBlock) + code_size, layouts.data_alignment);
        const addr = self.allocateStub(total_size) orelse return null;
        const stub: *code_blocks.CodeBlock = @ptrFromInt(addr);

        // low 3 bits are clear (not free, type bits 0).
        stub.header = total_size & ~@as(Cell, 7);
        stub.owner = owner;
        // Callback GC visits only owner, so keep template selection immediate.
        stub.parameters = if (variadic) layouts.tagFixnum(1) else layouts.false_object;
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
        var jit_scope = jit_protect.Scope.init();
        defer jit_scope.deinit();

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
        var jit_scope = jit_protect.Scope.init();
        defer jit_scope.deinit();

        const size = stub.size();
        stub.markFree(size);
        self.free_list.free(@intFromPtr(stub), size);
    }

    /// Reset the callback heap to a single empty free block. Used by
    /// (save-image)/save-image-and-exit to drop volatile callback stubs before
    /// saving. initialFreeList writes a FreeBlock header into the heap, which
    /// is MAP_JIT (W^X) on arm64 — must be made writable first, or the write
    /// SIGBUSes at the heap base. Mirrors the scope discipline of the other
    /// JIT-touching methods here.
    pub fn clearFreeList(self: *Self) void {
        var jit_scope = jit_protect.Scope.init();
        defer jit_scope.deinit();

        self.free_list.initialFreeList(0);
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

    var stub_array: *const layouts.Array = @ptrFromInt(layouts.UNTAG(callback_stub));
    if (stub.parameters == layouts.tagFixnum(1)) {
        stub_array = @ptrFromInt(layouts.UNTAG(stub_array.data()[2]));
    }
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

test "callback heap retries mixed sizes across pinned blocks" {
    // Test the allocation path on every architecture, independently of the
    // ARM64-only variadic ABI. Use ordinary memory rather than executable code.
    var storage: [2048]u8 align(layouts.data_alignment) = undefined;
    var heap = CallbackHeap{
        .segment = null,
        .allocator = std.testing.allocator,
        .free_list = .init(std.testing.allocator, @intFromPtr(&storage), storage.len),
    };
    defer heap.deinit();
    var scope = jit_protect.Scope.init();
    defer scope.deinit();

    const pinned = heap.allocateStub(256).?;
    const pinned_header: *Cell = @ptrFromInt(pinned);
    pinned_header.* = 256;
    const pinned_bytes: [*]u8 = @ptrFromInt(pinned + @sizeOf(Cell));
    @memset(pinned_bytes[0 .. 256 - @sizeOf(Cell)], 0x5a);

    var stubs: [16]Cell = undefined;
    for (0..6) |round| {
        const size: Cell = if (round % 2 == 0) 128 else 256;
        var count: usize = 0;
        while (heap.allocateStub(size)) |address| {
            try std.testing.expect(count < stubs.len);
            const header: *Cell = @ptrFromInt(address);
            header.* = size;
            stubs[count] = address;
            count += 1;
        }
        try std.testing.expectEqual((storage.len - 256) / size, count);
        try std.testing.expectEqual(@as(Cell, 0), heap.free_list.freeBytes());
        for (stubs[0..count]) |address| heap.free(@ptrFromInt(address));
        try std.testing.expectEqual(@as(Cell, storage.len - 256), heap.free_list.freeBytes());
        try std.testing.expectEqual(@as(Cell, 256), pinned_header.*);
        for (pinned_bytes[0 .. 256 - @sizeOf(Cell)]) |byte| try std.testing.expectEqual(@as(u8, 0x5a), byte);
    }
    heap.free(@ptrFromInt(pinned));
    try std.testing.expectEqual(@as(Cell, storage.len), heap.free_list.freeBytes());
    // Once the last pinned block is gone the whole region is reusable.
    try std.testing.expectEqual(@intFromPtr(&storage), heap.allocateStub(storage.len).?);
}

test "callback heap alternates template sizes without moving live stubs" {
    if (builtin.cpu.arch != .aarch64) return error.SkipZigTest;

    // Synthetic templates exercise add/free and template selection without
    // executing native code. No relocation table is needed for these stubs.
    const OrdinaryCode = extern struct {
        header: layouts.ByteArray,
        bytes: [128 - @sizeOf(code_blocks.CodeBlock)]u8,
    };
    const VariadicCode = extern struct {
        header: layouts.ByteArray,
        bytes: [256 - @sizeOf(code_blocks.CodeBlock)]u8,
    };
    var ordinary: OrdinaryCode align(16) = .{
        .header = .{ .header = 0, .capacity = layouts.tagFixnum(128 - @sizeOf(code_blocks.CodeBlock)) },
        .bytes = @splat(0x35),
    };
    var variadic: VariadicCode align(16) = .{
        .header = .{ .header = 0, .capacity = layouts.tagFixnum(256 - @sizeOf(code_blocks.CodeBlock)) },
        .bytes = @splat(0x79),
    };
    var variadic_template: extern struct { header: layouts.Array, items: [2]Cell } align(16) = .{
        .header = .{ .header = 0, .capacity = layouts.tagFixnum(2) },
        .items = .{ layouts.false_object, layouts.retag(@intFromPtr(&variadic), .byte_array) },
    };
    var templates: extern struct { header: layouts.Array, items: [3]Cell } align(16) = .{
        .header = .{ .header = 0, .capacity = layouts.tagFixnum(3) },
        .items = .{ layouts.false_object, layouts.retag(@intFromPtr(&ordinary), .byte_array), layouts.retag(@intFromPtr(&variadic_template), .array) },
    };
    // add only reads this special object and code when owner is false.
    var vm: @import("vm.zig").FactorVM = undefined;
    vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.callback_stub)] = layouts.retag(@intFromPtr(&templates), .array);
    vm.code = null;

    var heap = try CallbackHeap.init(std.testing.allocator, 16 * 1024);
    defer heap.deinit();
    // Pin a larger stub so the free spans on either side are multiples of
    // both sizes; otherwise unmergeable 128-byte tails are legitimate.
    const pinned = heap.add(layouts.false_object, std.math.maxInt(Cell), 0, &vm).?;
    const pinned_entry = pinned.entryPoint();
    var stubs: [128]*code_blocks.CodeBlock = undefined;

    for (0..6) |round| {
        const is_variadic = round % 2 == 1;
        const rewind: Cell = if (is_variadic) std.math.maxInt(Cell) else 0;
        const size: Cell = if (is_variadic) 256 else 128;
        var count: usize = 0;
        while (heap.add(layouts.false_object, rewind, 0, &vm)) |stub| {
            try std.testing.expect(count < stubs.len);
            stubs[count] = stub;
            count += 1;
            try std.testing.expectEqual(size, stub.size());
            try std.testing.expectEqual(if (is_variadic) layouts.tagFixnum(1) else layouts.false_object, stub.parameters);
        }
        // A failure is legitimate only when less than one stub is free.
        try std.testing.expectEqual((16 * 1024 - 256) / size, count);
        try std.testing.expect(heap.room().total_free < size);
        for (stubs[0..count]) |stub| heap.free(stub);
        try std.testing.expectEqual(@as(Cell, 256), heap.room().occupied_space);
        try std.testing.expectEqual(pinned_entry, pinned.entryPoint());
        const bytes: [*]const u8 = @ptrFromInt(pinned_entry);
        try std.testing.expectEqualSlices(u8, &variadic.bytes, bytes[0..variadic.bytes.len]);
    }
    heap.free(pinned);
    try std.testing.expectEqual(@as(Cell, 16 * 1024), heap.room().total_free);
}
