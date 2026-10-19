const std = @import("std");
const builtin = @import("builtin");
const layouts = @import("layouts.zig");
const vm_mod = @import("vm.zig");
const jit = @import("jit.zig");
const blocks = @import("code_blocks.zig");
const heap_mod = @import("data_heap.zig");
const gc = @import("gc.zig");
const Cell = layouts.Cell;

fn symbol(vm: *vm_mod.FactorVM, name: [:0]const u8) Cell {
    const result = vm.allotByteArray(name.len + 1);
    @memcpy(layouts.untag(layouts.ByteArray, result).data()[0 .. name.len + 1], name.ptr[0 .. name.len + 1]);
    return result;
}

fn template(vm: *vm_mod.FactorVM, pairs: usize, third_field: bool) !Cell {
    try vm.data_roots.ensureUnusedCapacity(vm.allocator, 4);
    var params = vm.allotArray(2 * pairs, layouts.false_object).?;
    vm.data_roots.appendAssumeCapacity(&params);
    defer _ = vm.data_roots.pop();
    for (0..pairs) |i| {
        const value = symbol(vm, "puts");
        layouts.untag(layouts.Array, params).data()[2 * i] = value;
    }
    var rels = vm.allotByteArray((pairs + 1) * 4);
    vm.data_roots.appendAssumeCapacity(&rels);
    defer _ = vm.data_roots.pop();
    for (0..pairs + 1) |i| {
        const entry = blocks.RelocationEntry.init(.dlsym, .absolute_cell, @intCast((i + 1) * @sizeOf(Cell)));
        std.mem.writeInt(u32, layouts.untag(layouts.ByteArray, rels).data()[4 * i ..][0..4], entry.value, builtin.cpu.arch.endian());
    }
    var bytes = vm.allotByteArray((pairs + 1) * @sizeOf(Cell) + 16);
    vm.data_roots.appendAssumeCapacity(&bytes);
    defer _ = vm.data_roots.pop();
    @memset(layouts.untag(layouts.ByteArray, bytes).data()[(pairs + 1) * @sizeOf(Cell) ..][0..16], 0xa5);
    const result = vm.allotArray(if (third_field) 3 else 2, layouts.false_object).?;
    const data = layouts.untag(layouts.Array, result).data();
    data[0] = rels;
    data[1] = bytes;
    if (third_field) data[2] = params;
    return result;
}

fn runCase(third_field: bool, pairs: usize, collect: bool) !void {
    const allocator = std.testing.allocator;
    const vm = try vm_mod.FactorVM.init(allocator);
    vm.vm_asm.ctx = try vm.newContext();
    vm.vm_asm.spare_ctx = try vm.newContext();
    const heap = try heap_mod.DataHeap.init(allocator, 8192, 8192, 32768);
    vm.setDataHeap(heap);
    var collector = gc.GarbageCollector.init(allocator, vm, heap);
    vm.gc = &collector;
    defer {
        vm.gc = null;
        collector.deinit();
        vm.deinit();
        heap.deinit();
    }
    var compiler = jit.Jit.init(vm, layouts.false_object);
    compiler.registerRoot();
    defer compiler.deinit();
    var first = try template(vm, 0, false);
    vm.data_roots.appendAssumeCapacity(&first);
    defer _ = vm.data_roots.pop();
    var dynamic_symbol = symbol(vm, "strlen");
    vm.data_roots.appendAssumeCapacity(&dynamic_symbol);
    defer _ = vm.data_roots.pop();
    try compiler.parameter(dynamic_symbol);
    try compiler.parameter(layouts.false_object);
    try compiler.emitRaw(first);
    try std.testing.expectEqual(@as(Cell, 2), compiler.parameters.count);

    const next = try template(vm, pairs, third_field);
    try compiler.parameter(dynamic_symbol);
    try compiler.parameter(layouts.false_object);
    const collections_before = heap.nursery_collections;
    if (collect) {
        const available = vm.vm_asm.nursery.end - vm.vm_asm.nursery.here;
        _ = vm.allotByteArray(available - @sizeOf(layouts.ByteArray) - layouts.data_alignment);
    }
    // Only emitRaw's root retains next while parameter-table growth collects.
    try compiler.emitRaw(next);
    try std.testing.expectEqual(@as(Cell, 4 + 2 * pairs), compiler.parameters.count);
    try std.testing.expectEqual((pairs + 2) * @sizeOf(Cell) + 32, compiler.code.items.len);
    for (compiler.code.items[compiler.code.items.len - 16 ..]) |byte| try std.testing.expectEqual(@as(u8, 0xa5), byte);
    if (collect) try std.testing.expect(heap.nursery_collections > collections_before);
    try compiler.parameter(dynamic_symbol);
    try compiler.parameter(layouts.false_object);
    try compiler.emitRaw(first);
    try std.testing.expectEqual(@as(Cell, 6 + 2 * pairs), compiler.parameters.count);

    // Use the production relocation walker on an actual allocated code-block
    // layout; synthetic pointer slots deliberately are never executed.
    var memory: [4096]u8 align(layouts.data_alignment) = @splat(0);
    const block: *blocks.CodeBlock = @ptrCast(&memory);
    block.initialize(.unoptimized, memory.len, 0);
    const rels = vm.allotByteArray(compiler.relocation.items.len);
    @memcpy(layouts.untag(layouts.ByteArray, rels).data()[0..compiler.relocation.items.len], compiler.relocation.items);
    block.parameters = compiler.parameters.elements;
    block.relocation = rels;
    @memcpy(memory[@sizeOf(blocks.CodeBlock)..][0..compiler.code.items.len], compiler.code.items);
    const context: blocks.RelocationContext = .{
        .vm_ptr = @intFromPtr(vm), .cards_offset = 0, .decks_offset = 0,
        .megamorphic_cache_hits_ptr = 0, .inline_cache_miss_ptr = 0,
        .safepoint_page = 0, .max_pic_size = 0, .lazy_jit_compile_ep = 0,
        .literals = null, .parameters = layouts.untag(layouts.Array, block.parameters),
    };
    blocks.applyRelocations(block, &context);
    for (0..pairs + 3) |i| {
        const entry = blocks.RelocationEntry{ .value = std.mem.readInt(u32, layouts.untag(layouts.ByteArray, rels).data()[4 * i ..][0..4], builtin.cpu.arch.endian()) };
        const op = blocks.InstructionOperand.init(entry, block, 2 * i);
        const expected = blocks.computeDlsymAddressForOperand(context.parameters.?, 2 * i, &op);
        try std.testing.expectEqual(expected, @as(Cell, @bitCast(op.loadValue())));
        if (i >= 2 and i < pairs + 2) {
            const value = context.parameters.?.data()[2 * i];
            try std.testing.expectEqualSlices(u8, "puts\x00", layouts.untag(layouts.ByteArray, value).data()[0..5]);
            try std.testing.expectEqual(layouts.false_object, context.parameters.?.data()[2 * i + 1]);
        }
    }
}

test "JIT special templates preserve old and optional static parameter relocation order across GC" {
    try runCase(false, 0, false);
    try runCase(true, 0, false);
    try runCase(true, 1, false);
    try runCase(true, 32, true);
}
