// primitives/contexts.zig - Context, stack, and special object primitives

const std = @import("std");
const layouts = @import("../layouts.zig");
const math = @import("../fixnum.zig");
const vm_mod = @import("../vm.zig");

const Cell = layouts.Cell;
const Fixnum = layouts.Fixnum;
const FactorVM = vm_mod.FactorVM;
const VMAssemblyFields = vm_mod.VMAssemblyFields;

// --- Special Objects ---

pub export fn primitive_special_object(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const ctx = vm_asm.ctx;
    // ( n -- value )
    const n = layouts.untagFixnum(ctx.peek());
    const value = vm_asm.special_objects[@intCast(n)];
    ctx.replace(value);
}

pub export fn primitive_set_special_object(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const ctx = vm_asm.ctx;
    // ( value n -- )
    const n = layouts.untagFixnum(ctx.pop());
    const value = ctx.pop();
    vm_asm.special_objects[@intCast(n)] = value;
}

// --- Context Primitives ---

pub export fn primitive_context_object(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const ctx = vm_asm.ctx;
    // ( n -- value )
    // NOTE: C++ VM uses peek/replace:
    // fixnum n = untag_fixnum(ctx->peek());
    // ctx->replace(ctx->context_objects[n]);
    const n = layouts.untagFixnum(ctx.peek());
    ctx.replace(ctx.context_objects[@intCast(n)]);
}

pub export fn primitive_set_context_object(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const ctx = vm_asm.ctx;
    // ( value n -- )
    const n = layouts.untagFixnum(ctx.pop());
    const value = ctx.pop();
    ctx.context_objects[@intCast(n)] = value;
}

pub export fn primitive_context_object_for(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( n context -- obj )
    // C++ reference: vm/contexts.cpp:187-191
    const ctx_cell = vm.pop();
    const index = layouts.untagFixnum(vm.pop());

    const ctx = vm.getContextFromAlien(ctx_cell);
    if (ctx == null) {
        vm.push(layouts.false_object);
        return;
    }

    vm.push(ctx.?.context_objects[@intCast(index)]);
}

// Helper: convert stack to array - allocates in nursery
fn stackToArray(vm: *FactorVM, bottom: Cell, top: Cell) Cell {
    // Calculate depth in cells
    const depth_bytes: i64 = @as(i64, @intCast(top)) - @as(i64, @intCast(bottom)) + @sizeOf(Cell);
    if (depth_bytes < 0) {
        return layouts.false_object;
    }

    const depth_cells: Cell = @intCast(@divExact(@as(u64, @intCast(depth_bytes)), @sizeOf(Cell)));

    // Allocate array, triggering GC if needed
    const array_size = @sizeOf(layouts.Array) + depth_cells * @sizeOf(Cell);
    const tagged = vm.allotObject(.array, array_size) orelse {
        vm.memoryError();
    };
    const arr: *layouts.Array = @ptrFromInt(layouts.UNTAG(tagged));

    arr.capacity = layouts.tagFixnum(@intCast(depth_cells));

    // Copy stack data to array
    const src: [*]const Cell = @ptrFromInt(bottom);
    const dest = arr.data();
    @memcpy(dest[0..depth_cells], src[0..depth_cells]);

    return tagged;
}

pub export fn primitive_datastack_for(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( context -- array )
    const ctx_cell = vm.pop();

    const other_ctx = vm.getContextFromAlien(ctx_cell);
    if (other_ctx == null) {
        vm.push(layouts.false_object);
        return;
    }

    const ctx = other_ctx.?;
    if (ctx.datastack_seg == null) {
        vm.push(layouts.false_object);
        return;
    }

    const bottom = ctx.datastack_seg.?.start;
    const top = ctx.datastack;
    const arr = stackToArray(vm, bottom, top);
    vm.push(arr);
}

pub export fn primitive_retainstack_for(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( context -- array )
    const ctx_cell = vm.peek();

    const other_ctx = vm.getContextFromAlien(ctx_cell);
    if (other_ctx == null) {
        vm.replace(layouts.false_object);
        return;
    }

    const ctx = other_ctx.?;
    if (ctx.retainstack_seg == null) {
        vm.replace(layouts.false_object);
        return;
    }

    const bottom = ctx.retainstack_seg.?.start;
    const top = ctx.retainstack;
    const arr = stackToArray(vm, bottom, top);
    vm.replace(arr);
}

pub export fn primitive_check_datastack(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( saved-datastack in out -- ? )
    // Check if datastack matches expected state for call(
    // This validates that the preserved portion of the stack hasn't changed
    const out = layouts.untagFixnum(vm.pop());
    const in = layouts.untagFixnum(vm.pop());
    const height = out - in;
    const saved_datastack = vm.pop();

    {
        const ctx = vm.vm_asm.ctx;
        if (ctx.datastack_seg) |seg| {
            // Check that the saved datastack is an array
            if (!layouts.hasTag(saved_datastack, .array)) {
                vm.push(layouts.false_object);
                return;
            }

            const saved_height: Fixnum = @intCast(layouts.arrayCapacity(saved_datastack));
            // Handle case where datastack might have underflowed
            const current_height: Fixnum = if (ctx.datastack >= seg.start)
                @intCast((ctx.datastack - seg.start + @sizeOf(Cell)) / @sizeOf(Cell))
            else
                0;

            // Verify current height matches expected height after effect
            if (current_height - height != saved_height) {
                vm.push(layouts.false_object);
                return;
            }

            // Compare bottom portion of stack element-by-element
            // We check saved_height - in elements (the preserved portion)
            const ds_bot: [*]Cell = @ptrFromInt(seg.start);
            const preserved_count: Cell = @intCast(saved_height - in);

            for (0..preserved_count) |i| {
                if (ds_bot[i] != layouts.arrayNth(saved_datastack, i)) {
                    vm.push(layouts.false_object);
                    return;
                }
            }

            // All checks passed
            vm.push(vm.tagBoolean(true));
        } else {
            vm.push(layouts.false_object);
        }
    }
}

pub export fn primitive_load_locals(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( n -- )
    // Load n values from datastack to local stack (retain stack)
    const count = layouts.untagFixnum(vm.pop());
    {
        const ctx = vm.vm_asm.ctx;
        // Bulk copy from datastack to retainstack, matching C++ implementation
        // C++: memcpy((cell*)(ctx->retainstack + sizeof(cell)),
        //            (cell*)(ctx->datastack - sizeof(cell) * (count - 1)),
        //            sizeof(cell) * count);
        const cell_size = @sizeOf(Cell);
        const count_unsigned: Cell = @intCast(count);
        const src_addr = ctx.datastack - cell_size * (count_unsigned - 1);
        const dst_addr = ctx.retainstack + cell_size;
        const byte_count = cell_size * count_unsigned;

        const src_ptr: [*]const u8 = @ptrFromInt(src_addr);
        const dst_ptr: [*]u8 = @ptrFromInt(dst_addr);

        @memcpy(dst_ptr[0..byte_count], src_ptr[0..byte_count]);

        ctx.datastack -= cell_size * count_unsigned;
        ctx.retainstack += cell_size * count_unsigned;
    }
}

// Helper: copy array contents to a stack segment, returns new stack top
fn array_to_stack(arr: *const layouts.Array, bottom: Cell) Cell {
    const capacity = layouts.untagFixnumUnsigned(arr.capacity);
    const depth = capacity * @sizeOf(Cell);
    const data = arr.data();

    // Copy array data to stack segment (matches C++ memcpy)
    const dest: [*]Cell = @ptrFromInt(bottom);
    @memcpy(dest[0..capacity], data[0..capacity]);

    // Return pointer to top of stack (last element)
    return bottom + depth - @sizeOf(Cell);
}

pub export fn primitive_set_datastack(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( array -- )
    // Set the datastack to the contents of the array
    const arr_cell = vm.pop();
    {
        const ctx = vm.vm_asm.ctx;
        if (layouts.hasTag(arr_cell, .array)) {
            const arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(arr_cell));
            if (ctx.datastack_seg) |seg| {
                ctx.datastack = array_to_stack(arr, seg.start);
            }
        }
    }
}

pub export fn primitive_set_retainstack(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( array -- )
    // Set the retainstack to the contents of the array
    const arr_cell = vm.pop();
    {
        const ctx = vm.vm_asm.ctx;
        if (layouts.hasTag(arr_cell, .array)) {
            const arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(arr_cell));
            if (ctx.retainstack_seg) |seg| {
                ctx.retainstack = array_to_stack(arr, seg.start);
            }
        }
    }
}
