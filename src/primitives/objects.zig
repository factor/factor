// primitives/objects.zig - Object creation, slot access, arrays, strings, words

const std = @import("std");
const bignum = @import("../bignum.zig");
const code_blocks = @import("../code_blocks.zig");
const layouts = @import("../layouts.zig");
const math = @import("../fixnum.zig");
const objects = @import("../objects.zig");
const slot_visitor = @import("../slot_visitor.zig");
const vm_mod = @import("../vm.zig");
const diagnostics = @import("diagnostics.zig");

const Cell = layouts.Cell;
const CodeBlock = code_blocks.CodeBlock;
const Fixnum = layouts.Fixnum;
const FactorVM = vm_mod.FactorVM;
const VMAssemblyFields = vm_mod.VMAssemblyFields;

// Maximum array size (same as C++ array_size_max: 1 << (WORD_SIZE - TAG_BITS - 2))
const array_size_max: Cell = @as(Cell, 1) << (64 - layouts.tag_bits - 2);

// Validate and unbox an array size from a cell value.
// Like C++ unbox_array_size() which uses to_fixnum_strict() first.
// For bignums that don't fit in fixnum, throws out_of_fixnum_range.
// For values out of array size range, throws array_size.
fn unboxArraySize(vm: *FactorVM, obj: Cell) ?Cell {
    var n: Fixnum = undefined;

    // Handle different types like C++ to_fixnum_strict
    const tag = layouts.typeTag(obj);
    if (tag == .fixnum) {
        n = layouts.untagFixnum(obj);
    } else if (tag == .bignum) {
        // Try to convert bignum to fixnum
        const bn: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(obj));
        if (!bignum.fitsFixnum(bn)) {
            // Bignum too large for fixnum - throw out_of_fixnum_range
            vm.fixnumRangeError(obj);
        }
        n = bignum.toFixnum(bn);
    } else {
        // Other types can't be array sizes - throw type error (like C++ type_error)
        vm.fixnumRangeError(obj);
    }

    // Check array size bounds
    if (n >= 0 and @as(Cell, @intCast(n)) < array_size_max) {
        return @intCast(n);
    }
    vm.generalError(.array_size, obj, layouts.tagFixnum(@intCast(array_size_max)));
}

// --- Object Primitives ---

pub export fn primitive_clone(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    var obj = vm.peek();
    const tag = layouts.typeTag(obj);

    if (tag == .fixnum or obj == layouts.false_object) {
        return;
    }

    if (tag == .tuple) {
        const tuple: *const layouts.Tuple = @ptrFromInt(layouts.UNTAG(obj));
        std.debug.assert(tuple.header != tuple.layout);
        std.debug.assert(layouts.hasTag(tuple.layout, .array));
    }

    // Root the object - ensureNurserySpace can trigger GC which may move it
    vm.data_roots.append(vm.allocator, &obj) catch vm.memoryError();
    defer _ = vm.data_roots.pop();

    // Compute object size
    const size = slot_visitor.objectSize(layouts.UNTAG(obj));
    if (size == 0) return;

    // Ensure nursery space (may trigger GC, moving obj via data_root)
    if (!vm.ensureNurserySpace(size)) vm.memoryError();

    // After potential GC, re-derive source pointer from rooted obj
    const src_addr = layouts.UNTAG(obj);
    const src_ptr: [*]const u8 = @ptrFromInt(src_addr);

    // Allocate - guaranteed to succeed after ensureNurserySpace
    const dst_addr = vm.vm_asm.nursery.allocate(size);
    const dst_ptr: [*]u8 = @ptrFromInt(dst_addr);

    // Copy entire object
    @memcpy(dst_ptr[0..size], src_ptr[0..size]);

    // Reset hashcode (bits 6+ of header)
    const dst_obj: *layouts.Object = @ptrFromInt(dst_addr);
    dst_obj.header = dst_obj.header & 0x3F;

    vm.replace(dst_addr | @intFromEnum(tag));
}

pub export fn primitive_wrapper(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( obj -- wrapper )
    // Matches C++ pattern: allot<wrapper> then peek (after allocation)
    const tagged = vm.allotObject(.wrapper, @sizeOf(layouts.Wrapper)) orelse vm.memoryError();

    // Peek AFTER allotObject (which may trigger GC and move stack values)
    const obj = vm.peek();

    const wrapper: *layouts.Wrapper = @ptrFromInt(layouts.UNTAG(tagged));
    wrapper.object = obj;
    vm.replace(tagged);
}

// --- Slot Access ---

pub export fn primitive_slot(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const ctx = vm_asm.ctx;
    // ( obj n -- value )
    const n = layouts.untagFixnum(ctx.pop());
    const obj = ctx.pop();
    const obj_ptr: *const layouts.Object = @ptrFromInt(layouts.UNTAG(obj));
    const slots = obj_ptr.slots();
    const value = slots[@intCast(n)];

    ctx.push(value);
}

pub export fn primitive_set_slot(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    // ( value obj n -- )
    const n = layouts.untagFixnum(ctx.pop());
    const obj = ctx.pop();
    const value = ctx.pop();
    const obj_ptr: *layouts.Object = @ptrFromInt(layouts.UNTAG(obj));
    const slots = obj_ptr.slots();
    const slot_ptr = &slots[@intCast(n)];
    slot_ptr.* = value;
    vm.writeBarrierKnownHeapWithValue(slot_ptr, value);
}

// --- Tuple Allocation ---

pub export fn primitive_tuple(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( layout -- tuple )
    // Use peek/replace pattern for GC safety - layout stays on stack during potential GC
    var layout_cell = vm.peek();

    // NOTE: tuple_layout objects have tag ARRAY (2), not TUPLE (7)!
    // This is because in Factor, tuple_layout extends array.
    vm.checkTag(layout_cell, .array);

    var layout: *const layouts.TupleLayout = @ptrFromInt(layouts.UNTAG(layout_cell));
    const num_slots = layouts.untagFixnumUnsigned(layout.size);
    const tuple_size = @sizeOf(layouts.Tuple) + num_slots * @sizeOf(Cell);

    // Allocate tuple (may trigger GC)
    const tagged = vm.allotObject(.tuple, tuple_size) orelse vm.memoryError();

    // Re-read layout from stack in case GC moved it
    layout_cell = vm.peek();
    layout = @ptrFromInt(layouts.UNTAG(layout_cell));

    const tuple: *layouts.Tuple = @ptrFromInt(layouts.UNTAG(tagged));
    tuple.layout = layout_cell;

    // Fill slots with f (false_object)
    @memset(tuple.data()[0..num_slots], layouts.false_object);

    std.debug.assert(tuple.header == (@as(Cell, @intFromEnum(layouts.TypeTag.tuple)) << 2));
    std.debug.assert(tuple.layout == layout_cell);

    vm.replace(tagged);
}

pub export fn primitive_tuple_boa(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    // ( slot-values... layout -- tuple )
    // Create a new tuple filling slots from the stack (BOA = By Order of Arguments)
    // Pop the layout and root it locally so we can bulk-copy the remaining
    // stack cells exactly like the C++ VM.
    var layout_cell = ctx.pop();

    // NOTE: tuple_layout objects have tag ARRAY (2), not TUPLE (7)!
    vm.checkTag(layout_cell, .array);

    vm.data_roots.append(vm.allocator, &layout_cell) catch vm.memoryError();
    defer _ = vm.data_roots.pop();

    const layout: *const layouts.TupleLayout = @ptrFromInt(layouts.UNTAG(layout_cell));
    const num_slots = layouts.untagFixnumUnsigned(layout.size);
    const tuple_size = @sizeOf(layouts.Tuple) + num_slots * @sizeOf(Cell);
    const slot_size = num_slots * @sizeOf(Cell);

    // Allocate tuple (may trigger GC which may move stack values)
    const tagged = vm.allotObject(.tuple, tuple_size) orelse {
        ctx.datastack -= slot_size;
        vm.memoryError();
    };

    const tuple: *layouts.Tuple = @ptrFromInt(layouts.UNTAG(tagged));
    tuple.layout = layout_cell;

    if (slot_size > 0) {
        const src_base = ctx.datastack - slot_size + @sizeOf(Cell);
        const src_data: [*]const Cell = @ptrFromInt(src_base);
        @memcpy(tuple.data()[0..num_slots], src_data[0..num_slots]);
    }

    // Pop slot values from stack. The layout was already popped above.
    ctx.datastack -= slot_size;

    std.debug.assert(tuple.header == (@as(Cell, @intFromEnum(layouts.TypeTag.tuple)) << 2));
    std.debug.assert(layouts.hasTag(tuple.layout, .array));

    vm.push(tagged);
}

// --- Identity/Hash ---

pub export fn primitive_identity_hashcode(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const ctx = vm_asm.ctx;
    // ( obj -- hashcode )
    // C++: ctx->replace(tag_fixnum(obj->hashcode()));
    const obj = ctx.peek();
    if (layouts.isImmediate(obj)) {
        // Immediates - leave unchanged (value is its own hashcode)
        // But fixnums need to stay as-is
        return;
    }
    const obj_ptr: *const layouts.Object = @ptrFromInt(layouts.UNTAG(obj));
    const hc = obj_ptr.hashcode();
    ctx.replace(layouts.tagFixnum(@intCast(hc)));
}

pub export fn primitive_compute_identity_hashcode(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    // ( obj -- )
    // Compute and set identity hashcode (pops the object!)
    // C++: object* obj = untag<object>(ctx->pop());
    const obj = ctx.pop();
    if (!layouts.isImmediate(obj)) {
        const obj_addr = layouts.UNTAG(obj);
        const obj_ptr: *layouts.Object = @ptrFromInt(obj_addr);

        vm.object_counter += 1;
        if (vm.object_counter == 0) vm.object_counter += 1; // Avoid 0
        obj_ptr.setHashcode(obj_addr ^ vm.object_counter);
    }
}

pub export fn primitive_become(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( old-array new-array -- )
    // This is used by tools.deploy.shaker and tuple reshaping

    // Trigger minor GC first to ensure consistency
    diagnostics.primitive_minor_gc(vm_asm);

    // Pop arrays from stack
    const new_array = vm.pop();
    const old_array = vm.pop();

    // Type check: both must be arrays
    if (!layouts.hasTag(old_array, .array) or
        !layouts.hasTag(new_array, .array))
    {
        vm.criticalError("become: arguments must be arrays", 0);
        return;
    }

    const old_arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(old_array));
    const new_arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(new_array));

    const capacity = old_arr.getCapacity();

    // Arrays must have same capacity
    if (capacity != new_arr.getCapacity()) {
        vm.criticalError("become: arrays must have same capacity", 0);
        return;
    }

    // Build forwarding map from old objects to new objects
    const BecomeMap = std.AutoHashMap(Cell, Cell);
    var become_map = BecomeMap.init(vm.allocator);
    defer become_map.deinit();

    const old_data = old_arr.data();
    const new_data = new_arr.data();

    for (0..capacity) |i| {
        const old_ptr = old_data[i];
        const new_ptr = new_data[i];
        if (old_ptr != new_ptr) {
            // Map the untagged addresses
            const old_untagged = layouts.UNTAG(old_ptr);
            become_map.put(old_untagged, new_ptr) catch {
                vm.criticalError("become: failed to build forwarding map", 0);
                return;
            };
        }
    }

    // Define the visitor context for replacing references
    const BecomeVisitor = struct {
        map: *BecomeMap,

        fn visitSlot(slot: *Cell, ctx_ptr: *anyopaque) void {
            const self: *@This() = @ptrCast(@alignCast(ctx_ptr));
            const value = slot.*;

            if (!layouts.isImmediate(value)) {
                const untagged = layouts.UNTAG(value);
                if (self.map.get(untagged)) |new_value| {
                    slot.* = new_value;
                }
            }
        }
    };

    var visitor_ctx = BecomeVisitor{ .map = &become_map };

    // Visit all roots
    // 1. Special objects
    for (&vm.vm_asm.special_objects) |*slot| {
        BecomeVisitor.visitSlot(slot, @ptrCast(&visitor_ctx));
    }

    // 2. Data stack
    {
        const ctx = vm.vm_asm.ctx;
        if (ctx.datastack_seg) |seg| {
            var ptr = seg.start;
            while (ptr <= ctx.datastack) {
                const slot: *Cell = @ptrFromInt(ptr);
                BecomeVisitor.visitSlot(slot, @ptrCast(&visitor_ctx));
                ptr += @sizeOf(Cell);
            }
        }

        // 3. Retain stack
        if (ctx.retainstack_seg) |seg| {
            var ptr = seg.start;
            while (ptr <= ctx.retainstack) {
                const slot: *Cell = @ptrFromInt(ptr);
                BecomeVisitor.visitSlot(slot, @ptrCast(&visitor_ctx));
                ptr += @sizeOf(Cell);
            }
        }

        // 4. Context objects
        for (&ctx.context_objects) |*slot| {
            BecomeVisitor.visitSlot(slot, @ptrCast(&visitor_ctx));
        }
    }

    // 5. Data roots
    for (vm.data_roots.items) |root| {
        BecomeVisitor.visitSlot(root, @ptrCast(&visitor_ctx));
    }

    // 6. Callback stubs (owners are GC roots)
    if (vm.callbacks) |callback_heap| {
        const Ctx = struct {
            ctx: *BecomeVisitor,
            fn visit(slot: *Cell, c: @This()) void {
                BecomeVisitor.visitSlot(slot, @ptrCast(c.ctx));
            }
        };
        const ctx = Ctx{ .ctx = &visitor_ctx };
        callback_heap.iterateOwnersWithCtx(Ctx, Ctx.visit, ctx);
    }

    // 7. Uninitialized code blocks (literal arrays are roots)
    if (vm.code) |code| {
        var iter = code.uninitialized_blocks.iterator();
        while (iter.next()) |entry| {
            BecomeVisitor.visitSlot(entry.value_ptr, @ptrCast(&visitor_ctx));
        }
    }

    // 8. Active contexts
    for (vm.active_contexts.items) |ctx| {

        // Visit context stacks
        if (ctx.datastack_seg) |seg| {
            var ptr = seg.start;
            while (ptr <= ctx.datastack) {
                const slot: *Cell = @ptrFromInt(ptr);
                BecomeVisitor.visitSlot(slot, @ptrCast(&visitor_ctx));
                ptr += @sizeOf(Cell);
            }
        }

        if (ctx.retainstack_seg) |seg| {
            var ptr = seg.start;
            while (ptr <= ctx.retainstack) {
                const slot: *Cell = @ptrFromInt(ptr);
                BecomeVisitor.visitSlot(slot, @ptrCast(&visitor_ctx));
                ptr += @sizeOf(Cell);
            }
        }

        // Visit context objects
        for (&ctx.context_objects) |*slot| {
            BecomeVisitor.visitSlot(slot, @ptrCast(&visitor_ctx));
        }
    }

    // Visit all objects in the heap (tenured + aging). Nursery should be empty
    // after the minor GC above.
    if (vm.garbage_collector) |gc| {
        const data_heap = gc.heap;
        const was_gc_off = vm.gc_off;
        vm.gc_off = true;
        defer vm.gc_off = was_gc_off;

        // Aging space
        var aging_iter = slot_visitor.ObjectIterator.init(data_heap.aging.start, data_heap.aging.here);
        while (aging_iter.next()) |addr| {
            slot_visitor.visitObjectSlots(addr, BecomeVisitor.visitSlot, @ptrCast(&visitor_ctx));
        }

        // Tenured space
        var tenured_iter = slot_visitor.ObjectIterator.init(data_heap.tenured.start, data_heap.tenured.end);
        while (tenured_iter.next()) |addr| {
            slot_visitor.visitObjectSlots(addr, BecomeVisitor.visitSlot, @ptrCast(&visitor_ctx));
        }
    }

    // Visit all code blocks and update embedded literals
    if (vm.code) |code| {
        for (code.all_blocks_sorted.items) |addr| {
            const block: *CodeBlock = @ptrFromInt(addr);
            if (block.isFree()) continue;

            // Update header pointers
            BecomeVisitor.visitSlot(@ptrCast(&block.owner), @ptrCast(&visitor_ctx));
            BecomeVisitor.visitSlot(@ptrCast(&block.parameters), @ptrCast(&visitor_ctx));
            BecomeVisitor.visitSlot(@ptrCast(&block.relocation), @ptrCast(&visitor_ctx));

            // Update embedded literals (skip uninitialized blocks)
            if (!code.isUninitializedAddress(addr)) {
                if (block.relocation != layouts.false_object and
                    layouts.hasTag(block.relocation, .byte_array))
                {
                    const reloc_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(block.relocation));
                    const reloc_cap = layouts.untagFixnumUnsigned(reloc_ba.capacity);
                    if (reloc_cap > 0) {
                        const reloc_data = reloc_ba.data();
                        const reloc_count = reloc_cap / @sizeOf(code_blocks.RelocationEntry);
                        var param_index: Cell = 0;
                        var modified = false;
                        for (0..reloc_count) |i| {
                            const entry_ptr: *const code_blocks.RelocationEntry =
                                @ptrCast(@alignCast(reloc_data + i * @sizeOf(code_blocks.RelocationEntry)));
                            if (entry_ptr.getType() == .literal) {
                                var op = code_blocks.InstructionOperand.init(entry_ptr.*, block, param_index);
                                const value = op.loadValue();
                                const value_unsigned: Cell = @bitCast(value);
                                if (!layouts.isImmediate(value_unsigned)) {
                                    const untagged = layouts.UNTAG(value_unsigned);
                                    if (become_map.get(untagged)) |new_value| {
                                        op.storeValue(@bitCast(new_value));
                                        modified = true;
                                    }
                                }
                            }
                            param_index += entry_ptr.numberOfParameters();
                        }
                        if (modified) {
                            block.flushIcache();
                        }
                    }
                }
            }

            // Add to remembered set (may have introduced old->young refs)
            code.writeBarrier(block) catch @panic("OOM");
        }
    }

    // Mark all cards dirty since we may have introduced old->new references
    vm.markAllCards();
}

// --- Array Primitives ---

pub export fn primitive_array(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( capacity fill -- array )
    // Matches C++ pattern: data_root<object> fill + allot_uninitialized_array
    var fill = vm.pop();
    const capacity_cell = vm.pop();

    const capacity = unboxArraySize(vm, capacity_cell) orelse return;

    // Root fill - allotUninitializedArray can trigger GC which may move heap objects
    vm.data_roots.append(vm.allocator, &fill) catch @panic("OOM");
    defer _ = vm.data_roots.pop();

    // Allocate array (may trigger GC). Use no-fill variant since we immediately
    // overwrite every element with fill below.
    const tagged = vm.allotUninitializedArrayNoFill(capacity) orelse vm.memoryError();

    // Fill with rooted fill value (may have been moved by GC)
    const arr: *layouts.Array = @ptrFromInt(layouts.UNTAG(tagged));
    @memset(arr.data()[0..capacity], fill);

    vm.push(tagged);
}

pub export fn primitive_resize_array(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( capacity array -- new-array )
    // Matches C++ pattern: data_root<array> a + reallot_array
    const arr = vm.pop();
    const capacity_cell = vm.pop();

    const new_capacity = unboxArraySize(vm, capacity_cell) orelse return;

    if (!layouts.hasTag(arr, .array)) {
        vm.push(layouts.false_object);
        return;
    }

    // reallotArray handles GC rooting internally
    if (vm.reallotArray(arr, new_capacity)) |new_arr| {
        vm.push(new_arr);
    } else {
        vm.push(layouts.false_object);
    }
}

// --- Byte Array Primitives ---

pub export fn primitive_byte_array(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( size -- byte-array )
    const size_cell = vm.pop();
    const size = unboxArraySize(vm, size_cell) orelse return;

    const result = vm.allotByteArray(size);
    vm.push(result);
}

pub export fn primitive_uninitialized_byte_array(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( size -- byte-array )
    const size_cell = vm.pop();
    const size = unboxArraySize(vm, size_cell) orelse return;

    const header_size = @sizeOf(layouts.ByteArray);
    const total_size = layouts.alignCell(header_size + size, layouts.data_alignment);

    // Use allotObject which routes large objects to tenured space
    const tagged = vm.allotObject(.byte_array, total_size) orelse vm.memoryError();
    const ba: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(tagged));
    ba.capacity = layouts.tagFixnum(@intCast(size));
    // Don't initialize data - left uninitialized for performance
    vm.push(tagged);
}

pub export fn primitive_resize_byte_array(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( n byte-array -- new-byte-array )
    // Matches C++ pattern: data_root<byte_array> + reallot_array
    var ba_cell = vm.pop();
    const size_cell = vm.pop();

    if (!layouts.hasTag(ba_cell, .byte_array)) {
        vm.push(layouts.false_object);
        return;
    }
    const new_size = unboxArraySize(vm, size_cell) orelse return;

    const old_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(ba_cell));
    const old_size = layouts.untagFixnumUnsigned(old_ba.capacity);

    if (new_size == old_size) {
        vm.push(ba_cell);
        return;
    }

    // In-place shrink for nursery objects (matches C++ reallot_array_in_place_p)
    if (new_size <= old_size and vm.vm_asm.nursery.contains(@ptrFromInt(layouts.UNTAG(ba_cell)))) {
        const ba_mut: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(ba_cell));
        ba_mut.capacity = layouts.tagFixnum(@as(Fixnum, @intCast(new_size)));
        vm.push(ba_cell);
        return;
    }

    // Root old byte array - allocation can trigger GC
    vm.data_roots.append(vm.allocator, &ba_cell) catch vm.memoryError();
    defer _ = vm.data_roots.pop();

    const header_size = @sizeOf(layouts.ByteArray);
    const total_size = layouts.alignCell(header_size + new_size, layouts.data_alignment);

    // Use allotObject which routes large objects to tenured space
    const tagged = vm.allotObject(.byte_array, total_size) orelse vm.memoryError();
    const addr = layouts.UNTAG(tagged);

    const new_ba: *layouts.ByteArray = @ptrFromInt(addr);
    new_ba.capacity = layouts.tagFixnum(@intCast(new_size));

    // Re-derive old pointer from rooted cell (allotObject may trigger GC)
    const old_ba_after_gc: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(ba_cell));
    const copy_size = @min(old_size, new_size);
    @memcpy(new_ba.data()[0..copy_size], old_ba_after_gc.data()[0..copy_size]);

    if (new_size > old_size) {
        @memset(new_ba.data()[old_size..new_size], 0);
    }

    vm.push(tagged);
}

// --- String Primitives ---

pub export fn primitive_string(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( length fill -- string )
    const fill_cell = vm.pop();
    const length_cell = vm.pop();

    const length = unboxArraySize(vm, length_cell) orelse return;
    const fill = layouts.untagFixnumUnsigned(fill_cell);

    // Use allotObject which routes large objects to tenured space
    const string_size = layouts.alignCell(@sizeOf(layouts.String) + length, layouts.data_alignment);

    var tagged = vm.allotObject(.string, string_size) orelse vm.memoryError();

    const str: *layouts.String = @ptrFromInt(layouts.UNTAG(tagged));
    str.length = layouts.tagFixnum(@intCast(length));
    str.hashcode_field = layouts.false_object;
    str.aux = layouts.false_object;

    if (fill <= 0x7f) {
        @memset(str.data()[0..length], @truncate(fill));
    } else {
        // Non-ASCII - allocate aux array. Root the string first since
        // the aux allocation can trigger GC which may move the string.
        vm.data_roots.append(vm.allocator, &tagged) catch vm.memoryError();
        defer _ = vm.data_roots.pop();

        const aux_capacity = length * 2;
        const aux_size = layouts.alignCell(@sizeOf(layouts.ByteArray) + aux_capacity, layouts.data_alignment);
        if (vm.allotObject(.byte_array, aux_size)) |aux_tagged| {
            // Re-derive str pointer - GC may have moved the string
            const str2: *layouts.String = @ptrFromInt(layouts.UNTAG(tagged));
            const aux: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(aux_tagged));
            aux.capacity = layouts.tagFixnum(@intCast(aux_capacity));
            str2.aux = aux_tagged;

            const lo_fill: u8 = @truncate((fill & 0x7f) | 0x80);
            @memset(str2.data()[0..length], lo_fill);

            const hi_fill: u16 = @truncate((fill >> 7) ^ 0x1);
            const aux_data: [*]u16 = @ptrCast(@alignCast(aux.data()));
            @memset(aux_data[0..length], hi_fill);
        } else {
            const str2: *layouts.String = @ptrFromInt(layouts.UNTAG(tagged));
            @memset(str2.data()[0..length], @truncate(fill & 0x7f));
        }
    }

    vm.push(tagged);
}

pub export fn primitive_resize_string(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( n string -- newstring )
    // Matches C++ pattern: data_root<string> + allot
    var str_cell = vm.pop();
    const length_cell = vm.pop();

    if (!layouts.hasTag(str_cell, .string)) {
        vm.typeError(.string, str_cell);
    }

    const new_length = unboxArraySize(vm, length_cell) orelse return;

    var old_str: *const layouts.String = @ptrFromInt(layouts.UNTAG(str_cell));
    const old_length = layouts.untagFixnumUnsigned(old_str.length);

    if (new_length == old_length) {
        vm.push(str_cell);
        return;
    }

    // Root old string - allocation can trigger GC
    vm.data_roots.append(vm.allocator, &str_cell) catch vm.memoryError();
    defer _ = vm.data_roots.pop();

    // Use allotObject which routes large objects to tenured space
    const has_aux = old_str.aux != layouts.false_object and layouts.hasTag(old_str.aux, .byte_array);
    const string_size = layouts.alignCell(@sizeOf(layouts.String) + new_length, layouts.data_alignment);

    var tagged = vm.allotObject(.string, string_size) orelse vm.memoryError();

    // Re-derive old_str from rooted str_cell (allotObject may trigger GC)
    old_str = @ptrFromInt(layouts.UNTAG(str_cell));

    var new_str: *layouts.String = @ptrFromInt(layouts.UNTAG(tagged));
    new_str.length = layouts.tagFixnum(@intCast(new_length));
    new_str.hashcode_field = layouts.false_object;

    const copy_length = @min(old_length, new_length);
    @memcpy(new_str.data()[0..copy_length], old_str.data()[0..copy_length]);

    if (new_length > old_length) {
        @memset(new_str.data()[old_length..new_length], 0);
    }

    // Handle auxiliary byte_array for Unicode strings
    if (has_aux) {
        // Root the new string before second allocation
        vm.data_roots.append(vm.allocator, &tagged) catch vm.memoryError();
        defer _ = vm.data_roots.pop();

        const aux_capacity = new_length * 2;
        const aux_size = layouts.alignCell(@sizeOf(layouts.ByteArray) + aux_capacity, layouts.data_alignment);
        if (vm.allotObject(.byte_array, aux_size)) |aux_tagged| {
            const aux_addr = layouts.UNTAG(aux_tagged);
            const new_aux: *layouts.ByteArray = @ptrFromInt(aux_addr);
            new_aux.capacity = layouts.tagFixnum(@intCast(aux_capacity));

            // Re-derive pointers after GC (allotObject may trigger GC)
            const old_str2: *const layouts.String = @ptrFromInt(layouts.UNTAG(str_cell));
            const old_aux: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(old_str2.aux));
            const aux_copy_length = @min(copy_length * 2, aux_capacity);
            @memcpy(new_aux.data()[0..aux_copy_length], old_aux.data()[0..aux_copy_length]);

            if (aux_capacity > copy_length * 2) {
                @memset(new_aux.data()[copy_length * 2 .. aux_capacity], 0);
            }

            // Re-derive new_str from rooted tagged (GC may have moved it)
            new_str = @ptrFromInt(layouts.UNTAG(tagged));
            new_str.aux = aux_tagged;
        } else {
            new_str = @ptrFromInt(layouts.UNTAG(tagged));
            new_str.aux = layouts.false_object;
        }
    } else {
        new_str.aux = layouts.false_object;
    }

    vm.push(tagged);
}

pub export fn primitive_set_string_nth_fast(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( ch n string -- )
    const str_cell = vm.pop();
    const n = layouts.untagFixnum(vm.pop());
    const value = layouts.untagFixnum(vm.pop());

    if (!layouts.hasTag(str_cell, .string)) {
        return;
    }

    const str: *layouts.String = @ptrFromInt(layouts.UNTAG(str_cell));
    const data = str.data();
    const index: usize = @intCast(n);

    // Set the byte directly - Factor code handles Unicode encoding
    // For ASCII: value is the character directly
    // For non-ASCII: value is (char & 0x7f) | 0x80 (set by Factor's set-string-nth-slow)
    const unsigned_value: Cell = @bitCast(value);
    data[index] = @truncate(unsigned_value);
}

// --- Word Primitives ---

pub export fn primitive_word(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( name vocabulary hashcode -- word )
    // Matches C++ pattern: data_root for name/vocab then allot<word>
    var hashcode = vm.pop();
    var vocab = vm.pop();
    var name = vm.pop();

    // Root all three - name and vocab are heap strings, allocation can trigger GC
    vm.data_roots.ensureUnusedCapacity(vm.allocator, 3) catch @panic("OOM");
    vm.data_roots.appendAssumeCapacity(&name);
    defer _ = vm.data_roots.pop();
    vm.data_roots.appendAssumeCapacity(&vocab);
    defer _ = vm.data_roots.pop();
    vm.data_roots.appendAssumeCapacity(&hashcode);
    defer _ = vm.data_roots.pop();

    var word_cell = vm.allotObject(.word, @sizeOf(layouts.Word)) orelse vm.memoryError();
    const word: *layouts.Word = @ptrFromInt(layouts.UNTAG(word_cell));
    word.hashcode_field = hashcode;
    word.name = name;
    word.vocabulary = vocab;
    word.def = vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.undefined)];
    word.props = layouts.false_object;
    word.pic_def = layouts.false_object;
    word.pic_tail_def = layouts.false_object;
    word.subprimitive = layouts.false_object;
    word.entry_point = 0;

    // JIT compile the word's def quotation (matches C++ allot_word behavior).
    vm.data_roots.append(vm.allocator, &word_cell) catch vm.memoryError();
    defer _ = vm.data_roots.pop();

    const def = word.def;
    const compiled = vm.jitCompileQuotationWithOwner(word_cell, def, true);
    const w: *layouts.Word = @ptrFromInt(layouts.UNTAG(word_cell));
    if (compiled) |cb| {
        w.entry_point = cb.entryPoint();
    }

    vm.push(word_cell);
}

pub export fn primitive_word_code(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( word -- start end )
    const word_cell = vm.peek();

    if (!layouts.hasTag(word_cell, .word)) {
        vm.typeError(.word, word_cell);
    }

    const word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(word_cell));
    const entry = word.entry_point;
    vm.replace(math.fromUnsignedCell(vm, entry));

    // Compute end address: code_block_addr + code_block.size()
    if (entry >= @sizeOf(CodeBlock)) {
        const block: *const CodeBlock = @ptrFromInt(entry - @sizeOf(CodeBlock));
        if (!block.isFree()) {
            vm.push(math.fromUnsignedCell(vm, @intFromPtr(block) + block.size()));
            return;
        }
    }
    vm.push(math.fromUnsignedCell(vm, entry));
}

pub export fn primitive_quotation_code(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( quotation -- start end )
    const quot_cell = vm.peek();

    if (!layouts.hasTag(quot_cell, .quotation)) {
        vm.typeError(.quotation, quot_cell);
    }

    const quot: *const layouts.Quotation = @ptrFromInt(layouts.UNTAG(quot_cell));
    const entry = quot.entry_point;
    vm.replace(math.fromUnsignedCell(vm, entry));

    // Compute end address: code_block_addr + code_block.size()
    if (entry >= @sizeOf(CodeBlock)) {
        const block: *const CodeBlock = @ptrFromInt(entry - @sizeOf(CodeBlock));
        if (!block.isFree()) {
            vm.push(math.fromUnsignedCell(vm, @intFromPtr(block) + block.size()));
            return;
        }
    }
    vm.push(math.fromUnsignedCell(vm, entry));
}
