// float.zig - Boxed float helpers for the Factor VM.

const std = @import("std");
const layouts = @import("layouts.zig");
const vm_mod = @import("vm.zig");

const Cell = layouts.Cell;
const FactorVM = vm_mod.FactorVM;

// Allocate a boxed float via allotObject (handles nursery/tenured routing).
pub fn allocBoxedFloat(vm: *FactorVM, value: f64) !*layouts.BoxedFloat {
    const size = layouts.alignCell(@sizeOf(layouts.BoxedFloat), layouts.data_alignment);
    const tagged = vm.allotObject(.float, size) orelse return error.OutOfMemory;
    const boxed: *layouts.BoxedFloat = @ptrFromInt(layouts.UNTAG(tagged));
    boxed.n = value;
    return boxed;
}

// Untag a boxed float value.
pub fn untagFloat(cell: Cell) f64 {
    std.debug.assert(layouts.hasTag(cell, .float));
    const boxed: *const layouts.BoxedFloat = @ptrFromInt(layouts.UNTAG(cell));
    return boxed.n;
}
