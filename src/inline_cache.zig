// inline_cache.zig - Polymorphic Inline Cache (PIC) implementation
// Ported from vm/inline_cache.hpp, vm/inline_cache.cpp
//
// PICs optimize method dispatch by caching recent class/method pairs
// at each call site. This avoids repeated method lookup for monomorphic
// and oligomorphic call sites.

const std = @import("std");
const builtin = @import("builtin");

const code_blocks = @import("code_blocks.zig");
const jit = @import("jit.zig");
const layouts = @import("layouts.zig");
const objects = @import("objects.zig");
const dispatch = @import("primitives/code.zig");
const vm_mod = @import("vm.zig");

const Cell = layouts.Cell;
const Fixnum = layouts.Fixnum;
const FactorVM = vm_mod.FactorVM;

// PIC type - determined by the types of objects being dispatched on
pub const PicType = enum {
    tag, // Dispatch on type tag (fixnum, string, array, etc.)
    tuple, // Dispatch on tuple layout
};

// Inline cache JIT - generates PIC code
pub const InlineCacheJit = struct {
    base_jit: jit.Jit,
    pic_type: PicType,

    const Self = @This();

    pub fn init(vm: *FactorVM, pic_type: PicType, generic_word: Cell) Self {
        return Self{
            .base_jit = jit.Jit.init(vm, generic_word),
            .pic_type = pic_type,
        };
    }

    pub fn registerRoot(self: *Self) void {
        self.base_jit.registerRoot();
    }

    pub fn deinit(self: *Self) void {
        self.base_jit.deinit();
    }

    pub fn emitCheckAndJump(self: *Self, ic_type: PicType, i: Cell, klass_in: Cell, method_in: Cell) !void {
        const vm = self.base_jit.vm;

        var klass = klass_in;
        var method = method_in;
        try vm.data_roots.ensureUnusedCapacity(vm.allocator, 2);
        vm.data_roots.appendAssumeCapacity(&klass);
        defer _ = vm.data_roots.pop();
        vm.data_roots.appendAssumeCapacity(&method);
        defer _ = vm.data_roots.pop();

        const check_template: jit.JitTemplate = if (layouts.hasTag(klass, .fixnum))
            .pic_check_tag
        else
            .pic_check_tuple;

        if (!(i == 0 and ic_type == .tag and klass == 0)) {
            try self.base_jit.emitWithLiteral(check_template, klass);
        }

        try self.base_jit.emitWithLiteral(.pic_hit, method);
    }

    pub fn emitMissHandler(self: *Self, generic_word: *Cell, methods: *Cell, index: Cell, cache_entries: *Cell, tail_call: bool) !void {
        try self.base_jit.emit(.prolog);

        try self.base_jit.push(generic_word.*);
        try self.base_jit.push(methods.*);
        try self.base_jit.push(layouts.tagFixnum(@intCast(index)));
        try self.base_jit.push(cache_entries.*);

        const vm = self.base_jit.vm;
        const miss_word = if (tail_call)
            vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.pic_miss_tail_word)]
        else
            vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.pic_miss_word)];

        _ = try self.base_jit.emitSubprimitive(miss_word, true, true);
    }

    pub fn emitInlineCache(
        self: *Self,
        index: Fixnum,
        generic_word_in: Cell,
        methods_in: Cell,
        cache_entries_in: Cell,
        tail_call: bool,
    ) !void {
        const vm = self.base_jit.vm;

        var generic_word = generic_word_in;
        var methods = methods_in;
        var cache_entries = cache_entries_in;
        try vm.data_roots.ensureUnusedCapacity(vm.allocator, 3);
        vm.data_roots.appendAssumeCapacity(&generic_word);
        defer _ = vm.data_roots.pop();
        vm.data_roots.appendAssumeCapacity(&methods);
        defer _ = vm.data_roots.pop();
        vm.data_roots.appendAssumeCapacity(&cache_entries);
        defer _ = vm.data_roots.pop();

        if (self.pic_type == .tag) {
            vm.dispatch_stats.pic_tag_count += 1;
        } else {
            vm.dispatch_stats.pic_tuple_count += 1;
        }

        const byte_offset: Fixnum = -index * @as(Fixnum, @sizeOf(Cell));
        try self.base_jit.emitWithLiteral(.pic_load, layouts.tagFixnum(byte_offset));

        switch (self.pic_type) {
            .tag => try self.base_jit.emit(.pic_tag),
            .tuple => try self.base_jit.emit(.pic_tuple),
        }

        if (cache_entries != layouts.false_object and
            layouts.hasTag(cache_entries, .array))
        {
            const entry_count = blk: {
                const entries: *const layouts.Array = @ptrFromInt(layouts.UNTAG(cache_entries));
                break :blk layouts.untagFixnumUnsigned(entries.capacity);
            };

            var i: Cell = 0;
            while (i + 1 < entry_count) : (i += 2) {
                const entries: *const layouts.Array = @ptrFromInt(layouts.UNTAG(cache_entries));
                const data = entries.data();
                const klass = data[i];
                const method = data[i + 1];

                // Validate method is word or quotation
                const mt = layouts.typeTag(method);
                std.debug.assert(mt == .word or mt == .quotation);

                try self.emitCheckAndJump(self.pic_type, i, klass, method);
            }
        }

        try self.emitMissHandler(&generic_word, &methods, @intCast(index), &cache_entries, tail_call);
    }
};

// Handle inline cache miss
pub fn inlineCacheMiss(vm: *FactorVM, return_address: Cell) Cell {
    // Protect return address across GC/compaction
    var return_root = vm_mod.CodeRoot.init(return_address, vm);
    return_root.register();
    defer return_root.deinit();

    const tail_call_p = CallSitePatcher.isTailCallSite(return_root.value);

    const ctx = vm.vm_asm.ctx;

    // Pop parameters from the data stack (pushed by the miss handler in JIT code)
    var cache_entries = ctx.pop();
    const index_tagged = ctx.pop();
    var methods = ctx.pop();
    var generic_word = ctx.pop();

    // Register heap pointers as GC roots — batch capacity for all 4 roots
    vm.data_roots.ensureUnusedCapacity(vm.allocator, 4) catch @panic("OOM");
    vm.data_roots.appendAssumeCapacity(&cache_entries);
    defer _ = vm.data_roots.pop();
    vm.data_roots.appendAssumeCapacity(&methods);
    defer _ = vm.data_roots.pop();
    vm.data_roots.appendAssumeCapacity(&generic_word);
    defer _ = vm.data_roots.pop();

    if (comptime builtin.mode == .Debug) {
        std.debug.assert(layouts.hasTag(index_tagged, .fixnum));
        std.debug.assert(layouts.hasTag(generic_word, .word));
    }

    const index: Fixnum = layouts.untagFixnum(index_tagged);

    const obj_addr = ctx.datastack -% @as(Cell, @intCast(index * @as(Fixnum, @sizeOf(Cell))));

    var obj: Cell = @as(*const Cell, @ptrFromInt(obj_addr)).*;
    vm.data_roots.appendAssumeCapacity(&obj);
    defer _ = vm.data_roots.pop();

    // Determine current PIC size
    var pic_size: Cell = 0;
    if (cache_entries != layouts.false_object and layouts.hasTag(cache_entries, .array)) {
        const entries: *const layouts.Array = @ptrFromInt(layouts.UNTAG(cache_entries));
        pic_size = layouts.untagFixnumUnsigned(entries.capacity) / 2;
    }

    updatePicTransitions(vm, pic_size);

    // Default to generic word's entry point
    const generic: *const layouts.Word = @ptrFromInt(layouts.UNTAG(generic_word));
    var xt: Cell = generic.entry_point;

    if (pic_size < vm.max_pic_size) {
        if (comptime builtin.mode == .Debug) {
            std.debug.assert(layouts.TAG(obj) < layouts.type_count);
        }

        const klass = dispatch.objectClass(obj);
        const method = dispatch.lookupMethod(obj, methods);

        if (method != layouts.false_object) {
            if (comptime builtin.mode == .Debug) {
                const method_tag = layouts.typeTag(method);
                std.debug.assert(method_tag == .word or method_tag == .quotation);
            }

            const maybe_new_entries = addInlineCacheEntry(vm, cache_entries, klass, method);

            if (maybe_new_entries) |new_entries_value| {
                var new_cache_entries: Cell = new_entries_value;
                vm.data_roots.append(vm.allocator, &new_cache_entries) catch @panic("OOM");
                defer _ = vm.data_roots.pop();

                const new_xt = generateInlineCache(vm, index, generic_word, methods, new_cache_entries, tail_call_p);
                if (new_xt != 0) {
                    xt = new_xt;
                }
            }
        }
    }

    // Patch the call site
    if (return_root.valid and return_root.value != 0 and xt != 0) {
        if (comptime builtin.mode == .Debug) {
            std.debug.assert(CallSitePatcher.isValidCallSite(return_root.value));
        }
        deallocateInlineCache(vm, return_root.value);
        CallSitePatcher.setCallTarget(return_root.value, xt);
    }

    return xt;
}

fn updatePicTransitions(vm: *FactorVM, pic_size: Cell) void {
    if (pic_size == vm.max_pic_size) {
        vm.dispatch_stats.pic_to_mega_transitions += 1;
    } else if (pic_size == 0) {
        vm.dispatch_stats.cold_call_to_ic_transitions += 1;
    } else if (pic_size == 1) {
        vm.dispatch_stats.ic_to_pic_transitions += 1;
    }
}

fn deallocateInlineCache(vm: *FactorVM, return_address: Cell) void {
    const old_entry_point = if (comptime builtin.mode == .Debug) blk: {
        break :blk CallSitePatcher.getCallTarget(return_address);
    } else blk: {
        break :blk CallSitePatcher.getCallTargetUnchecked(return_address);
    };
    if (old_entry_point == 0) return;

    const old_block_addr = old_entry_point - @sizeOf(code_blocks.CodeBlock);
    const old_block: *code_blocks.CodeBlock = @ptrFromInt(old_block_addr);

    if (old_block.isPic()) {
        if (vm.code) |code_heap| {
            code_heap.free(old_block);
        }
    }
}

// Add an entry to the cache - implementation that allocates in the VM heap
pub fn addInlineCacheEntry(vm: *FactorVM, cache_entries: Cell, klass: Cell, method: Cell) ?Cell {
    var klass_copy = klass;
    var method_copy = method;
    var entries_copy = cache_entries;

    vm.data_roots.ensureUnusedCapacity(vm.allocator, 3) catch return null;
    vm.data_roots.appendAssumeCapacity(&klass_copy);
    defer _ = vm.data_roots.pop();
    vm.data_roots.appendAssumeCapacity(&method_copy);
    defer _ = vm.data_roots.pop();
    vm.data_roots.appendAssumeCapacity(&entries_copy);
    defer _ = vm.data_roots.pop();

    if (entries_copy == layouts.false_object) {
        const new_array_cell = vm.allotUninitializedArrayNoFill(2) orelse return null;
        const new_array: *layouts.Array = @ptrFromInt(layouts.UNTAG(new_array_cell));
        const arr_data = new_array.data();
        arr_data[0] = klass_copy;
        arr_data[1] = method_copy;
        return new_array_cell;
    }

    std.debug.assert(layouts.hasTag(entries_copy, .array));

    const old_entries: *const layouts.Array = @ptrFromInt(layouts.UNTAG(entries_copy));
    const old_size = layouts.untagFixnumUnsigned(old_entries.capacity);
    const new_size = old_size + 2;

    const new_array_cell = vm.allotUninitializedArrayNoFill(new_size) orelse return null;
    const new_array: *layouts.Array = @ptrFromInt(layouts.UNTAG(new_array_cell));
    const new_data = new_array.data();
    const old_entries_updated: *const layouts.Array = @ptrFromInt(layouts.UNTAG(entries_copy));
    const old_data = old_entries_updated.data();

    @memcpy(new_data[0..old_size], old_data[0..old_size]);

    new_data[old_size] = klass_copy;
    new_data[old_size + 1] = method_copy;

    return new_array_cell;
}

fn generateInlineCache(vm: *FactorVM, index: Fixnum, generic_word_in: Cell, methods_in: Cell, cache_entries_in: Cell, tail_call_p: bool) Cell {
    var generic_word = generic_word_in;
    var methods = methods_in;
    var cache_entries = cache_entries_in;
    vm.data_roots.ensureUnusedCapacity(vm.allocator, 3) catch return 0;
    vm.data_roots.appendAssumeCapacity(&generic_word);
    defer _ = vm.data_roots.pop();
    vm.data_roots.appendAssumeCapacity(&methods);
    defer _ = vm.data_roots.pop();
    vm.data_roots.appendAssumeCapacity(&cache_entries);
    defer _ = vm.data_roots.pop();

    const ic_type = determineInlineCacheType(cache_entries);
    var ic_jit = InlineCacheJit.init(vm, ic_type, generic_word);
    ic_jit.registerRoot();
    ic_jit.base_jit.owner = generic_word;
    defer ic_jit.deinit();

    ic_jit.emitInlineCache(index, generic_word, methods, cache_entries, tail_call_p) catch {
        return 0;
    };

    const code_block = ic_jit.base_jit.toCodeBlock(.pic, jit.JIT_FRAME_SIZE) catch {
        return 0;
    };

    if (code_block) |block| {
        vm.initializeCodeBlockFromMap(block);
        return block.entryPoint();
    }

    return 0;
}

// Megamorphic cache operations
pub const MegamorphicCache = struct {
    pub fn hashcode(klass: Cell, capacity_mask: Cell) Cell {
        return ((klass >> layouts.tag_bits) & capacity_mask) << 1;
    }

    pub fn lookup(cache: *const layouts.Array, klass: Cell) ?Cell {
        const capacity = layouts.untagFixnumFast(cache.capacity);
        if (capacity == 0) return null;

        const capacity_mask = (capacity >> 1) - 1;
        const slot = hashcode(klass, capacity_mask);
        std.debug.assert(slot < capacity);

        const data = cache.data();
        if (data[slot] == klass) {
            return data[slot + 1];
        }

        return null;
    }

    pub fn update(cache: *layouts.Array, klass: Cell, method: Cell) void {
        const capacity = layouts.untagFixnumFast(cache.capacity);
        if (capacity == 0) return;

        const capacity_mask = (capacity >> 1) - 1;
        const slot = hashcode(klass, capacity_mask);
        std.debug.assert(slot < capacity);

        const arr_data = cache.data();
        arr_data[slot] = klass;
        arr_data[slot + 1] = method;
    }
};

// Call site patching for x86-64
pub const CallSitePatcher = struct {
    const call_opcode: u8 = 0xe8;
    const jmp_opcode: u8 = 0xe9;

    fn callSiteOpcode(return_address: Cell) u8 {
        const opcode_ptr: *const u8 = @ptrFromInt(return_address - 5);
        return opcode_ptr.*;
    }

    fn isValidCallSite(return_address: Cell) bool {
        const opcode = callSiteOpcode(return_address);
        return opcode == call_opcode or opcode == jmp_opcode;
    }

    pub fn getCallTarget(return_address: Cell) Cell {
        if (!isValidCallSite(return_address)) {
            return 0;
        }

        return getCallTargetUnchecked(return_address);
    }

    pub inline fn getCallTargetUnchecked(return_address: Cell) Cell {
        const offset_ptr: *align(1) const i32 = @ptrFromInt(return_address - 4);
        const offset: i64 = offset_ptr.*;
        return @intCast(@as(i64, @intCast(return_address)) + offset);
    }

    pub fn setCallTarget(return_address: Cell, target: Cell) void {
        const offset: i32 = @truncate(@as(i64, @intCast(target)) - @as(i64, @intCast(return_address)));
        const offset_ptr: *align(1) i32 = @ptrFromInt(return_address - 4);
        offset_ptr.* = offset;
    }

    pub fn isTailCallSite(return_address: Cell) bool {
        return callSiteOpcode(return_address) == jmp_opcode;
    }
};

pub fn determineInlineCacheType(cache_entries: Cell) PicType {
    if (cache_entries == layouts.false_object) {
        return .tag;
    }

    std.debug.assert(layouts.hasTag(cache_entries, .array));

    const entries: *const layouts.Array = @ptrFromInt(layouts.UNTAG(cache_entries));
    const entry_count = layouts.untagFixnumUnsigned(entries.capacity);
    const data = entries.data();

    var i: Cell = 0;
    while (i < entry_count) : (i += 2) {
        const klass = data[i];
        if (layouts.hasTag(klass, .array)) {
            return .tuple;
        }
    }

    return .tag;
}

// Tests
test "object class" {
    const fixnum = layouts.tagFixnum(42);
    const fixnum_class = dispatch.objectClass(fixnum);
    try std.testing.expectEqual(layouts.tagFixnum(0), fixnum_class);
}

test "megamorphic cache hashcode" {
    const klass = layouts.tagFixnum(5);
    const capacity_mask: Cell = 14;
    const slot = MegamorphicCache.hashcode(klass, capacity_mask);
    try std.testing.expect(slot < 16);
    try std.testing.expect(slot % 2 == 0);
}

test "call site patcher" {
    _ = CallSitePatcher.isTailCallSite;
    _ = CallSitePatcher.getCallTarget;
    _ = CallSitePatcher.setCallTarget;
}
