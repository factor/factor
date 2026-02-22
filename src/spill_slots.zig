// spill_slots.zig - Shared spill-slot traversal for callstack GC roots
//
// Handles the derived-pointer protocol:
// 1) subtract base pointers from derived pointers
// 2) visit GC roots selected by the callsite bitmap
// 3) add base pointers back to derived pointers

const code_blocks = @import("code_blocks.zig");
const layouts = @import("layouts.zig");

const Cell = layouts.Cell;

pub inline fn visit(
    comptime Ctx: type,
    stack_pointer: [*]Cell,
    gc_info: *const code_blocks.GcInfo,
    callsite: u32,
    ctx: Ctx,
    comptime visitSlotFn: fn (*Cell, Ctx) void,
) void {
    const bitmap = gc_info.gcInfoBitmap();

    var spill_slot: u32 = 0;
    while (spill_slot < gc_info.derived_root_count) : (spill_slot += 1) {
        const base_pointer = gc_info.lookupBasePointer(callsite, spill_slot);
        if (base_pointer != @as(u32, 0xFFFFFFFF)) {
            stack_pointer[spill_slot] -%= stack_pointer[base_pointer];
        }
    }

    const callsite_roots = gc_info.callsiteGcRoots(callsite);
    spill_slot = 0;
    while (spill_slot < gc_info.gc_root_count) : (spill_slot += 1) {
        if (code_blocks.isBitmapSet(bitmap, callsite_roots + spill_slot)) {
            visitSlotFn(&stack_pointer[spill_slot], ctx);
        }
    }

    spill_slot = 0;
    while (spill_slot < gc_info.derived_root_count) : (spill_slot += 1) {
        const base_pointer = gc_info.lookupBasePointer(callsite, spill_slot);
        if (base_pointer != @as(u32, 0xFFFFFFFF)) {
            stack_pointer[spill_slot] +%= stack_pointer[base_pointer];
        }
    }
}
