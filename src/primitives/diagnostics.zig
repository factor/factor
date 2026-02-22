// primitives/diagnostics.zig - Die, GC, profiling, room, and diagnostic primitives

const std = @import("std");
const layouts = @import("../layouts.zig");
const math = @import("../fixnum.zig");
const objects = @import("../objects.zig");
const safepoints = @import("../safepoints.zig");
const slot_visitor = @import("../slot_visitor.zig");
const vm_mod = @import("../vm.zig");

const Cell = layouts.Cell;
const Fixnum = layouts.Fixnum;
const FactorVM = vm_mod.FactorVM;
const VMAssemblyFields = vm_mod.VMAssemblyFields;

// Sync context stack pointers from CPU registers.
// Factor JIT code uses R14 for datastack and R15 for retainstack on x86_64.
// Wrapper for VM's syncContextFromRegisters - kept for compatibility.
// The jit-save-context in JIT_PRIMITIVE template should save these before
// primitives run, but we call this as a safety measure in GC primitives.
fn syncContextFromRegisters(vm: *FactorVM) void {
    vm.syncContextFromRegisters();
}

// --- Die Primitive ---

pub export fn primitive_die(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    {
        const c = vm.vm_asm.ctx;
        // Print error from data stack - try TOS and TOS-1
        const ds = c.datastack;
        if (c.datastack_seg) |seg| {
            // Print TOS
            if (ds >= seg.start) {
                const tos = @as(*const layouts.Cell, @ptrFromInt(ds)).*;
                std.debug.print("[die] TOS=0x{x} tag={}\n", .{ tos, layouts.TAG(tos) });
                if (layouts.hasTag(tos, .tuple)) {
                    diePrintTuple(tos);
                    // If condition tuple, also decode inner error (slot[0])
                    dieDecodeConditionSlots(tos, vm);
                } else if (layouts.hasTag(tos, .array)) {
                    diePrintArray(tos);
                }
            }
            // Print TOS-1
            if (ds > seg.start + @sizeOf(layouts.Cell)) {
                const err_val = @as(*const layouts.Cell, @ptrFromInt(ds - @sizeOf(layouts.Cell))).*;
                std.debug.print("[die] TOS-1=0x{x} tag={}\n", .{ err_val, layouts.TAG(err_val) });
                if (layouts.hasTag(err_val, .tuple)) {
                    diePrintTuple(err_val);
                } else if (layouts.hasTag(err_val, .array)) {
                    diePrintArray(err_val);
                }
            }
        }
        // Print strings/words from retain stack for context
        if (c.retainstack_seg) |rseg| {
            const rs = c.retainstack;
            if (rs > rseg.start) {
                std.debug.print("[die] retain stack strings:\n", .{});
                var addr = rseg.start + @sizeOf(layouts.Cell);
                var ri: usize = 0;
                while (addr <= rs and ri < 16) : ({
                    addr += @sizeOf(layouts.Cell);
                    ri += 1;
                }) {
                    const val = @as(*const layouts.Cell, @ptrFromInt(addr)).*;
                    if (layouts.hasTag(val, .string)) {
                        std.debug.print("  r[{}] str: \"", .{ri});
                        diePrintString(val);
                        std.debug.print("\"\n", .{});
                    } else if (layouts.hasTag(val, .word)) {
                        std.debug.print("  r[{}] word: ", .{ri});
                        diePrintWordName(val);
                        std.debug.print("\n", .{});
                    }
                }
            }
        }
    }
    // Walk OBJ_GLOBAL hashtable to check key variable values
    dieInspectGlobal(vm, "os");
    dieInspectGlobal(vm, "cpu");
    dieInspectGlobal(vm, "startup-hooks");
    dieInspectGlobal(vm, "error");
    dieInspectGlobal(vm, "original-error");

    // Also dump ALL data stack entries with detail
    {
        const c = vm.vm_asm.ctx;
        if (c.datastack_seg) |seg| {
            const ds = c.datastack;
            var addr = seg.start + @sizeOf(layouts.Cell);
            var si: usize = 0;
            while (addr <= ds and si < 10) : ({
                addr += @sizeOf(layouts.Cell);
                si += 1;
            }) {
                const val = @as(*const layouts.Cell, @ptrFromInt(addr)).*;
                const tag = layouts.typeTag(val);
                std.debug.print("[die] ds[{}] = 0x{x} tag={}", .{ si, val, tag });
                if (tag == .string) {
                    std.debug.print(" \"", .{});
                    diePrintString(val);
                    std.debug.print("\"", .{});
                } else if (tag == .word) {
                    std.debug.print(" word=", .{});
                    diePrintWordName(val);
                } else if (val == layouts.false_object) {
                    std.debug.print(" (f)", .{});
                } else if (tag == .fixnum) {
                    std.debug.print(" fixnum={}", .{layouts.untagFixnum(val)});
                }
                std.debug.print("\n", .{});
            }
        }
    }

    vm.criticalError("The die word was called by the library.", 0);
}

fn dieInspectGlobal(vm: *FactorVM, name: []const u8) void {
    const global_obj = vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.global)];
    if (global_obj == layouts.false_object or !layouts.hasTag(global_obj, .tuple)) {
        std.debug.print("[die] OBJ_GLOBAL is not a tuple (0x{x} tag={})\n", .{ global_obj, layouts.TAG(global_obj) });
        return;
    }
    // global-hashtable tuple: [header][layout][boxes=slot0]
    const global_addr = layouts.UNTAG(global_obj);
    const boxes = @as(*const layouts.Cell, @ptrFromInt(global_addr + 2 * @sizeOf(layouts.Cell))).*;
    if (boxes == layouts.false_object or !layouts.hasTag(boxes, .tuple)) {
        std.debug.print("[die] global.boxes is not a tuple (0x{x} tag={})\n", .{ boxes, layouts.TAG(boxes) });
        return;
    }
    // hashtable tuple: [header][layout][count=slot0][deleted=slot1][array=slot2]
    const ht_addr = layouts.UNTAG(boxes);
    const ht_array = @as(*const layouts.Cell, @ptrFromInt(ht_addr + 4 * @sizeOf(layouts.Cell))).*;
    if (ht_array == layouts.false_object or !layouts.hasTag(ht_array, .array)) {
        std.debug.print("[die] global.boxes.array is not an array (0x{x} tag={})\n", .{ ht_array, layouts.TAG(ht_array) });
        return;
    }
    // array: [header][capacity][data...]
    const arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(ht_array));
    const cap = layouts.untagFixnumUnsigned(arr.capacity);
    const data = arr.data();
    // Walk key-value pairs: data[0]=key0, data[1]=val0, data[2]=key1, ...
    var i: usize = 0;
    while (i + 1 < cap) : (i += 2) {
        const key = data[i];
        if (!layouts.hasTag(key, .word)) continue;
        const w: *const layouts.Word = @ptrFromInt(layouts.UNTAG(key));
        if (w.name == layouts.false_object or !layouts.hasTag(w.name, .string)) continue;
        const s: *const layouts.String = @ptrFromInt(layouts.UNTAG(w.name));
        const slen = layouts.untagFixnumUnsigned(s.length);
        if (slen != name.len) continue;
        const sd = s.data();
        var match = true;
        for (0..slen) |j| {
            if (@as(u8, @truncate(sd[j])) != name[j]) {
                match = false;
                break;
            }
        }
        if (!match) continue;
        // Found the word! data[i+1] is the global-box tuple
        const gbox = data[i + 1];
        std.debug.print("[die] global \"{s}\" found: gbox=0x{x} tag={}\n", .{ name, gbox, layouts.TAG(gbox) });
        if (layouts.hasTag(gbox, .tuple)) {
            // global-box tuple: [header][layout][value=slot0]
            const gbox_addr = layouts.UNTAG(gbox);
            const value = @as(*const layouts.Cell, @ptrFromInt(gbox_addr + 2 * @sizeOf(layouts.Cell))).*;
            std.debug.print("[die]   value=0x{x} tag={}", .{ value, layouts.TAG(value) });
            if (value == layouts.false_object) {
                std.debug.print(" (FALSE/f)\n", .{});
            } else if (layouts.hasTag(value, .word)) {
                std.debug.print(" word=", .{});
                diePrintWordName(value);
                std.debug.print("\n", .{});
            } else if (layouts.hasTag(value, .tuple)) {
                std.debug.print("\n", .{});
                diePrintTupleDeep(value, 0);
            } else if (layouts.hasTag(value, .string)) {
                std.debug.print(" str=\"", .{});
                diePrintString(value);
                std.debug.print("\"\n", .{});
            } else {
                std.debug.print("\n", .{});
            }
        }
        return;
    }
    std.debug.print("[die] global \"{s}\" NOT FOUND in hashtable\n", .{name});
}

fn diePrintArray(tagged_arr: layouts.Cell) void {
    const arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(tagged_arr));
    const cap = layouts.untagFixnumUnsigned(arr.capacity);
    std.debug.print("[die] error array cap={} addr=0x{x} [\n", .{ cap, layouts.UNTAG(tagged_arr) });
    if (cap > 100) {
        std.debug.print("  (suspicious capacity, skipping)\n", .{});
        return;
    }
    const data = arr.data();
    for (0..@min(cap, 15)) |i| {
        const val = data[i];
        std.debug.print("  [{:2}] 0x{x} tag={}\n", .{ i, val, layouts.TAG(val) });
    }
    std.debug.print("]\n", .{});
}

fn diePrintString(tagged_str: layouts.Cell) void {
    const s: *const layouts.String = @ptrFromInt(layouts.UNTAG(tagged_str));
    const len = layouts.untagFixnumUnsigned(s.length);
    const sd = s.data();
    for (0..@min(len, 60)) |j| {
        const ch = sd[j];
        if (ch >= 32 and ch < 127) std.debug.print("{c}", .{@as(u8, @truncate(ch))});
    }
}

fn diePrintWordName(tagged_word: layouts.Cell) void {
    const w: *const layouts.Word = @ptrFromInt(layouts.UNTAG(tagged_word));
    if (w.name != layouts.false_object and layouts.hasTag(w.name, .string)) {
        diePrintString(w.name);
    } else {
        std.debug.print("(unnamed 0x{x})", .{tagged_word});
    }
}

fn dieDecodeConditionSlots(tagged_tuple: layouts.Cell, vm: *FactorVM) void {
    // If this is a condition tuple, decode slot[0] (the inner error) recursively
    const tuple_addr = layouts.UNTAG(tagged_tuple);
    const raw_layout = @as(*const layouts.Cell, @ptrFromInt(tuple_addr + @sizeOf(layouts.Cell))).*;
    const layout_cell = layouts.followForwardingPointers(raw_layout);
    const layout_addr = layouts.UNTAG(layout_cell);
    if (layout_addr < 0x1000) return;
    // Check if this is a condition tuple (3 slots, klass=condition)
    const size_cell = @as(*const layouts.Cell, @ptrFromInt(layout_addr + 3 * @sizeOf(layouts.Cell))).*;
    if (!layouts.hasTag(size_cell, .fixnum)) return;
    const nslots = layouts.untagFixnumUnsigned(size_cell);
    if (nslots < 1) return;
    // Decode slot[0] - the inner error
    const inner_error = @as(*const layouts.Cell, @ptrFromInt(tuple_addr + 2 * @sizeOf(layouts.Cell))).*;
    std.debug.print("[die] === INNER ERROR (slot[0]) = 0x{x} tag={} ===\n", .{ inner_error, layouts.TAG(inner_error) });
    if (layouts.hasTag(inner_error, .tuple)) {
        diePrintTupleDeep(inner_error, 1);
    } else if (layouts.hasTag(inner_error, .array)) {
        diePrintArray(inner_error);
    } else if (layouts.hasTag(inner_error, .string)) {
        std.debug.print("  str=\"", .{});
        diePrintString(inner_error);
        std.debug.print("\"\n", .{});
    }
    // Decode continuation (slot[2]) for call stack
    if (nslots >= 3) {
        const cont = @as(*const layouts.Cell, @ptrFromInt(tuple_addr + 4 * @sizeOf(layouts.Cell))).*;
        if (layouts.hasTag(cont, .tuple)) {
            const cont_addr = layouts.UNTAG(cont);
            if (cont_addr >= 0x1000) {
                // continuation has 5 slots: data call retain name catch
                // slot[1] = callstack (tag=10)
                const call_slot = @as(*const layouts.Cell, @ptrFromInt(cont_addr + 3 * @sizeOf(layouts.Cell))).*;
                std.debug.print("[die] continuation call slot: 0x{x} tag={}\n", .{ call_slot, layouts.TAG(call_slot) });
                if (layouts.hasTag(call_slot, .callstack)) {
                    std.debug.print("[die] === ERROR CALL STACK ===\n", .{});
                    const cs_addr = layouts.UNTAG(call_slot);
                    // Callstack object: header, length, data[...]
                    const cs_len_cell = @as(*const layouts.Cell, @ptrFromInt(cs_addr + @sizeOf(layouts.Cell))).*;
                    std.debug.print("[die] cs_len_cell=0x{x} tag={}\n", .{ cs_len_cell, layouts.TAG(cs_len_cell) });
                    if (layouts.hasTag(cs_len_cell, .fixnum)) {
                        const cs_len = layouts.untagFixnumUnsigned(cs_len_cell);
                        std.debug.print("[die] callstack length={} bytes\n", .{cs_len});
                        // Print first few raw values for debugging
                        const data_start = cs_addr + 2 * @sizeOf(layouts.Cell);
                        std.debug.print("[die] callstack raw data:\n", .{});
                        for (0..@min(cs_len / @sizeOf(layouts.Cell), 16)) |ri| {
                            const rv = @as(*const layouts.Cell, @ptrFromInt(data_start + ri * @sizeOf(layouts.Cell))).*;
                            std.debug.print("  [{}] 0x{x}", .{ ri, rv });
                            if (vm.code) |ch| {
                                if (ch.codeBlockForAddress(rv)) |blk| {
                                    if (layouts.hasTag(blk.owner, .word)) {
                                        const bw: *const layouts.Word = @ptrFromInt(layouts.UNTAG(blk.owner));
                                        if (bw.name != layouts.false_object and layouts.hasTag(bw.name, .string)) {
                                            std.debug.print(" -> word: ", .{});
                                            diePrintString(bw.name);
                                        }
                                    } else if (layouts.hasTag(blk.owner, .quotation)) {
                                        std.debug.print(" -> quotation", .{});
                                    }
                                }
                            }
                            std.debug.print("\n", .{});
                        }
                        // Walk frames: each frame has return address at its base
                        var fa = data_start;
                        var fi: usize = 0;
                        while (fa < data_start + cs_len and fi < 16) : (fi += 1) {
                            const ret = @as(*const layouts.Cell, @ptrFromInt(fa)).*;
                            if (vm.code) |code_heap| {
                                if (code_heap.codeBlockForAddress(ret)) |block| {
                                    std.debug.print("  [{:2}] 0x{x}", .{ fi, ret });
                                    if (layouts.hasTag(block.owner, .word)) {
                                        const bw: *const layouts.Word = @ptrFromInt(layouts.UNTAG(block.owner));
                                        if (bw.name != layouts.false_object and layouts.hasTag(bw.name, .string)) {
                                            std.debug.print(" word: ", .{});
                                            const bs: *const layouts.String = @ptrFromInt(layouts.UNTAG(bw.name));
                                            const blen = layouts.untagFixnumUnsigned(bs.length);
                                            const bsd = bs.data();
                                            for (0..@min(blen, 40)) |j| {
                                                const ch = bsd[j];
                                                if (ch >= 32 and ch < 127) std.debug.print("{c}", .{@as(u8, @truncate(ch))});
                                            }
                                        }
                                    } else if (layouts.hasTag(block.owner, .quotation)) {
                                        std.debug.print(" quotation", .{});
                                    }
                                    std.debug.print("\n", .{});
                                    const frame_size = block.size();
                                    if (frame_size > 0 and frame_size < 0x10000) {
                                        fa += frame_size;
                                    } else break;
                                } else {
                                    // Not a known code block - skip 8 bytes
                                    fa += @sizeOf(layouts.Cell);
                                }
                            } else break;
                        }
                    }
                } else {
                    std.debug.print("[die] continuation call slot: 0x{x} tag={}\n", .{ call_slot, layouts.TAG(call_slot) });
                }
            }
        }
    }
}

fn diePrintTupleDeep(tagged_tuple: layouts.Cell, depth: u32) void {
    if (depth > 3) return;
    const tuple_addr = layouts.UNTAG(tagged_tuple);
    if (tuple_addr < 0x1000) return;
    const raw_layout = @as(*const layouts.Cell, @ptrFromInt(tuple_addr + @sizeOf(layouts.Cell))).*;
    const layout_cell = layouts.followForwardingPointers(raw_layout);
    const layout_addr = layouts.UNTAG(layout_cell);
    if (layout_addr < 0x1000) {
        std.debug.print("[die:d{}] layout too low: 0x{x}\n", .{ depth, layout_addr });
        return;
    }
    const klass = @as(*const layouts.Cell, @ptrFromInt(layout_addr + 2 * @sizeOf(layouts.Cell))).*;
    const size_cell = @as(*const layouts.Cell, @ptrFromInt(layout_addr + 3 * @sizeOf(layouts.Cell))).*;
    std.debug.print("[die:d{}] class=", .{depth});
    if (layouts.hasTag(klass, .word)) {
        diePrintWordName(klass);
    } else {
        std.debug.print("0x{x}(tag={})", .{ klass, layouts.TAG(klass) });
    }
    if (!layouts.hasTag(size_cell, .fixnum)) {
        std.debug.print(" size=INVALID(0x{x})\n", .{size_cell});
        return;
    }
    const nslots = layouts.untagFixnumUnsigned(size_cell);
    std.debug.print(" slots={}\n", .{nslots});
    for (0..@min(nslots, 10)) |si| {
        const slot = @as(*const layouts.Cell, @ptrFromInt(tuple_addr + (2 + si) * @sizeOf(layouts.Cell))).*;
        std.debug.print("[die:d{}]   [{:2}] 0x{x} tag={}", .{ depth, si, slot, layouts.TAG(slot) });
        if (layouts.hasTag(slot, .word)) {
            std.debug.print(" word=", .{});
            diePrintWordName(slot);
        } else if (layouts.hasTag(slot, .string)) {
            std.debug.print(" str=\"", .{});
            diePrintString(slot);
            std.debug.print("\"", .{});
        } else if (slot == layouts.false_object) {
            std.debug.print(" (f)", .{});
        } else if (layouts.hasTag(slot, .fixnum)) {
            std.debug.print(" fixnum={}", .{layouts.untagFixnum(slot)});
        } else if (layouts.hasTag(slot, .tuple)) {
            std.debug.print(" -> ", .{});
            // Print class name of nested tuple
            const naddr = layouts.UNTAG(slot);
            if (naddr >= 0x1000) {
                const nraw = @as(*const layouts.Cell, @ptrFromInt(naddr + @sizeOf(layouts.Cell))).*;
                const nlayout = layouts.followForwardingPointers(nraw);
                const nladdr = layouts.UNTAG(nlayout);
                if (nladdr >= 0x1000) {
                    const nk = @as(*const layouts.Cell, @ptrFromInt(nladdr + 2 * @sizeOf(layouts.Cell))).*;
                    if (layouts.hasTag(nk, .word)) {
                        diePrintWordName(nk);
                    }
                }
            }
        } else if (layouts.hasTag(slot, .array)) {
            const arr2: *const layouts.Array = @ptrFromInt(layouts.UNTAG(slot));
            const cap2 = layouts.untagFixnumUnsigned(arr2.capacity);
            std.debug.print(" array[{}]", .{cap2});
        }
        std.debug.print("\n", .{});
    }
    // Recursively decode slot[0] if it's also a tuple
    if (nslots > 0) {
        const slot0 = @as(*const layouts.Cell, @ptrFromInt(tuple_addr + 2 * @sizeOf(layouts.Cell))).*;
        if (layouts.hasTag(slot0, .tuple)) {
            diePrintTupleDeep(slot0, depth + 1);
        }
    }
}

fn diePrintTuple(tagged_tuple: layouts.Cell) void {
    const tuple_addr = layouts.UNTAG(tagged_tuple);
    const raw_layout = @as(*const layouts.Cell, @ptrFromInt(tuple_addr + @sizeOf(layouts.Cell))).*;
    // Follow forwarding pointers on layout
    const layout_cell = layouts.followForwardingPointers(raw_layout);
    std.debug.print("[die] layout raw=0x{x} followed=0x{x} tag={}\n", .{ raw_layout, layout_cell, layouts.TAG(layout_cell) });

    if (layouts.hasTag(layout_cell, .tuple)) {
        const layout_addr = layouts.UNTAG(layout_cell);
        // TupleLayout: header, capacity, klass, size, echelon
        const klass = @as(*const layouts.Cell, @ptrFromInt(layout_addr + 2 * @sizeOf(layouts.Cell))).*;
        const size_cell = @as(*const layouts.Cell, @ptrFromInt(layout_addr + 3 * @sizeOf(layouts.Cell))).*;
        const tuple_size = layouts.untagFixnumUnsigned(size_cell);
        std.debug.print("[die] class=0x{x} tag={}", .{ klass, layouts.TAG(klass) });
        if (layouts.hasTag(klass, .word)) {
            std.debug.print(" name=", .{});
            diePrintWordName(klass);
        }
        std.debug.print("\n[die] {} slots:\n", .{tuple_size});
        for (0..@min(tuple_size, 10)) |si| {
            const slot = @as(*const layouts.Cell, @ptrFromInt(tuple_addr + (2 + si) * @sizeOf(layouts.Cell))).*;
            std.debug.print("  [{:2}] 0x{x} tag={}", .{ si, slot, layouts.TAG(slot) });
            if (layouts.hasTag(slot, .word)) {
                std.debug.print(" word=", .{});
                diePrintWordName(slot);
            } else if (layouts.hasTag(slot, .string)) {
                std.debug.print(" str=\"", .{});
                diePrintString(slot);
                std.debug.print("\"", .{});
            } else if (layouts.hasTag(slot, .tuple)) {
                // Recursively print nested tuple class name
                const nested_layout_raw = @as(*const layouts.Cell, @ptrFromInt(layouts.UNTAG(slot) + @sizeOf(layouts.Cell))).*;
                const nested_layout = layouts.followForwardingPointers(nested_layout_raw);
                if (layouts.hasTag(nested_layout, .tuple)) {
                    const nl_addr = layouts.UNTAG(nested_layout);
                    const nklass = @as(*const layouts.Cell, @ptrFromInt(nl_addr + 2 * @sizeOf(layouts.Cell))).*;
                    if (layouts.hasTag(nklass, .word)) {
                        std.debug.print(" tuple=", .{});
                        diePrintWordName(nklass);
                    }
                }
            }
            std.debug.print("\n", .{});
        }
    } else {
        // Layout tag is wrong - try to read the layout address as if it were a tuple layout anyway
        const forced_addr = layouts.UNTAG(layout_cell);
        if (forced_addr > 0x1000) {
            // Read memory at layout address: header, capacity, klass, size, echelon
            const mem0 = @as(*const layouts.Cell, @ptrFromInt(forced_addr)).*;
            const mem1 = @as(*const layouts.Cell, @ptrFromInt(forced_addr + 8)).*;
            const mem2 = @as(*const layouts.Cell, @ptrFromInt(forced_addr + 16)).*;
            const mem3 = @as(*const layouts.Cell, @ptrFromInt(forced_addr + 24)).*;
            const mem4 = @as(*const layouts.Cell, @ptrFromInt(forced_addr + 32)).*;
            std.debug.print("[die] layout@0x{x}: hdr=0x{x} cap=0x{x} klass=0x{x}(tag={}) size=0x{x} ech=0x{x}\n", .{
                forced_addr, mem0, mem1, mem2, layouts.TAG(mem2), mem3, mem4,
            });
            if (layouts.hasTag(mem2, .word) and mem2 > 0x1000) {
                std.debug.print("[die] klass word=", .{});
                diePrintWordName(mem2);
                std.debug.print("\n", .{});
            }
            // Also try interpreting size as tuple slot count
            if (layouts.hasTag(mem3, .fixnum)) {
                const nslots = layouts.untagFixnumUnsigned(mem3);
                std.debug.print("[die] {} slots (raw):\n", .{nslots});
                for (0..@min(nslots, 8)) |si| {
                    const slot = @as(*const layouts.Cell, @ptrFromInt(tuple_addr + (2 + si) * @sizeOf(layouts.Cell))).*;
                    std.debug.print("  [{:2}] 0x{x} tag={}\n", .{ si, slot, layouts.TAG(slot) });
                }
            }
        } else {
            std.debug.print("[die] layout address too low: 0x{x}\n", .{forced_addr});
        }
    }
}

// --- GC Primitives ---

pub export fn primitive_minor_gc(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();

    // CRITICAL FIX: Sync context stack pointers from CPU registers before GC.
    syncContextFromRegisters(vm);

    if (vm.garbage_collector) |gc| {
        vm.current_gc_p = true;
        gc.collect(.collect_nursery);
        vm.current_gc_p = false;
    }
}

pub export fn primitive_full_gc(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    syncContextFromRegisters(vm);
    if (vm.garbage_collector) |gc_inst| {
        vm.current_gc_p = true;
        gc_inst.collect(.collect_full);
        vm.current_gc_p = false;
    }
}

pub export fn primitive_compact_gc(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // CRITICAL FIX: Sync context stack pointers from CPU registers before GC.
    syncContextFromRegisters(vm);

    // Compact GC
    if (vm.garbage_collector) |gc| {
        vm.current_gc_p = true;
        gc.collect(.collect_compact);
        vm.current_gc_p = false;
    }
}

// --- GC Events ---

pub export fn primitive_enable_gc_events(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( -- )
    if (vm.gc_events == null) {
        const list = vm.allocator.create(std.ArrayListUnmanaged(vm_mod.GCEvent)) catch return;
        list.* = .{};
        vm.gc_events = list;
    }
}

pub export fn primitive_disable_gc_events(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const growable = @import("../growable.zig");
    // ( -- array/f )
    // Disable GC event tracking and return collected events as an array.
    // Each event is returned as a byte-array containing the event struct.
    //
    // Matches C++ primitive_disable_gc_events which uses growable_array
    // for incremental allocation. The previous Zig version tried to
    // pre-allocate all space in one nursery chunk, which failed when
    // there were thousands of GC events (total size > nursery).
    if (vm.gc_events) |event_list| {
        // CRITICAL: Set gc_events to null BEFORE iterating.
        // This prevents GC (triggered by allocations below) from
        // recording more events into the list while we read it.
        vm.gc_events = null;

        const event_count = event_list.items.len;

        if (event_count == 0) {
            event_list.deinit(vm.allocator);
            vm.allocator.destroy(event_list);
            vm.push(layouts.false_object);
            return;
        }

        // Use GrowableArray for incremental allocation (like C++ growable_array).
        // Each add() can trigger GC if the nursery fills up.
        var result = growable.GrowableArray.init(vm, @min(event_count, 1024)) orelse {
            event_list.deinit(vm.allocator);
            vm.allocator.destroy(event_list);
            vm.memoryError();
        };

        // Root result.elements so GC can update it when the backing
        // array moves between generations.
        vm.data_roots.append(vm.allocator, &result.elements) catch {
            event_list.deinit(vm.allocator);
            vm.allocator.destroy(event_list);
            vm.memoryError();
        };
        defer _ = vm.data_roots.pop();

        // Convert each event to a byte-array and add to result.
        // Matches C++: byte_array_from_value(&event) + result.add().
        const event_size = @sizeOf(vm_mod.GCEvent);
        for (event_list.items) |event| {
            const ba_tagged = vm.allotByteArray(event_size);
            const ba: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(ba_tagged));
            const event_bytes: [*]const u8 = @ptrCast(&event);
            @memcpy(ba.data()[0..event_size], event_bytes[0..event_size]);

            if (!result.add(ba_tagged)) {
                event_list.deinit(vm.allocator);
                vm.allocator.destroy(event_list);
                vm.memoryError();
            }
        }

        event_list.deinit(vm.allocator);
        vm.allocator.destroy(event_list);

        _ = result.trim();
        vm.push(result.elements);
    } else {
        // GC events were not enabled
        vm.push(layouts.false_object);
    }
}

// --- Room Info Primitives ---

pub export fn primitive_data_room(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( -- byte-array )
    // Return data heap statistics as a byte array
    // Structure matches data_heap_room from C++ VM
    const gc_instance = vm.garbage_collector orelse {
        vm.push(layouts.false_object);
        return;
    };

    const data = gc_instance.heap;

    // data_heap_room structure has 15 cells:
    // nursery_size, nursery_occupied, nursery_free,
    // aging_size, aging_occupied, aging_free,
    // tenured_size, tenured_occupied, tenured_total_free,
    // tenured_contiguous_free, tenured_free_block_count,
    // cards, decks, mark_stack
    const room_size = 15 * @sizeOf(Cell);
    const header_size = @sizeOf(layouts.ByteArray);
    const total_size = header_size + room_size;

    const tagged = vm.allotObject(.byte_array, total_size) orelse {
        vm.memoryError();
    };
    const ba: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(tagged));
    ba.capacity = layouts.tagFixnum(@intCast(room_size));

    const room_data: [*]Cell = @ptrCast(@alignCast(ba.data()));
    const nurs = &vm.vm_asm.nursery;

    room_data[0] = nurs.size;
    room_data[1] = nurs.size - nurs.freeBytes();
    room_data[2] = nurs.freeBytes();

    room_data[3] = data.aging.size;
    room_data[4] = data.aging.usedBytes();
    room_data[5] = data.aging.freeBytes();

    room_data[6] = data.tenured.size;
    room_data[7] = data.tenured.size - data.tenured.free_list.free_space;
    room_data[8] = data.tenured.free_list.free_space;
    room_data[9] = data.tenured.free_list.largestFreeBlock();
    room_data[10] = data.tenured.free_list.free_block_count;

    const cards_count = (data.segment.size + vm_mod.card_size - 1) / vm_mod.card_size;
    const decks_count = (data.segment.size + vm_mod.deck_size - 1) / vm_mod.deck_size;
    room_data[11] = cards_count;
    room_data[12] = decks_count;

    room_data[13] = vm.mark_stack.capacity() * @sizeOf(Cell);
    room_data[14] = 0; // Reserved for future use

    vm.push(tagged);
}
pub export fn primitive_code_room(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( -- byte-array )
    // Return code heap statistics as a byte array
    // Structure matches allocator_room from C++ VM
    const code_heap = vm.code orelse {
        vm.push(layouts.false_object);
        return;
    };

    // allocator_room structure has 5 cells:
    // size, occupied_space, total_free, contiguous_free, free_block_count
    const room_size = 5 * @sizeOf(Cell);
    const header_size = @sizeOf(layouts.ByteArray);
    const total_size = header_size + room_size;

    const tagged = vm.allotObject(.byte_array, total_size) orelse {
        vm.memoryError();
    };
    const ba: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(tagged));
    ba.capacity = layouts.tagFixnum(@intCast(room_size));

    const room_data: [*]Cell = @ptrCast(@alignCast(ba.data()));

    if (code_heap.free_list) |alloc| {
        room_data[0] = alloc.size;
        room_data[1] = alloc.size - alloc.free_space;
        room_data[2] = alloc.free_space;
        room_data[3] = alloc.largestFreeBlock();
        room_data[4] = alloc.free_block_count;
    } else {
        room_data[0] = 0;
        room_data[1] = 0;
        room_data[2] = 0;
        room_data[3] = 0;
        room_data[4] = 0;
    }

    vm.push(tagged);
}

pub export fn primitive_callback_room(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( -- byte-array )
    // Return callback heap statistics as a byte array
    // Structure matches allocator_room from C++ VM
    const callback_heap = vm.callbacks orelse {
        vm.push(layouts.false_object);
        return;
    };

    // allocator_room structure has 5 cells:
    // size, occupied_space, total_free, contiguous_free, free_block_count
    const room_size = 5 * @sizeOf(Cell);
    const header_size = @sizeOf(layouts.ByteArray);
    const total_size = header_size + room_size;

    const tagged = vm.allotObject(.byte_array, total_size) orelse {
        vm.memoryError();
    };
    const ba: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(tagged));
    ba.capacity = layouts.tagFixnum(@intCast(room_size));

    const room_data: [*]Cell = @ptrCast(@alignCast(ba.data()));

    room_data[0] = callback_heap.free_list.size;
    room_data[1] = callback_heap.free_list.size - callback_heap.free_list.free_space;
    room_data[2] = callback_heap.free_list.free_space;
    room_data[3] = callback_heap.free_list.largestFreeBlock();
    room_data[4] = callback_heap.free_list.free_block_count;

    vm.push(tagged);
}

// --- All Instances ---

pub export fn primitive_all_instances(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( -- array )
    // Returns an array of all objects in the data heap.
    // Mirrors C++ factor_vm::instances(TYPE_COUNT):
    //   1. Full GC to empty nursery/aging into tenured
    //   2. Iterate tenured + large objects, collecting tagged pointers
    //   3. Build a Factor array from collected pointers

    // Full GC empties nursery and aging, promoting all live objects to tenured
    syncContextFromRegisters(vm);
    if (vm.garbage_collector) |gc| {
        vm.current_gc_p = true;
        gc.collect(.collect_full);
        vm.current_gc_p = false;
    }

    const heap = vm.data orelse {
        vm.push(layouts.false_object);
        return;
    };

    // Prevent GC during iteration (matches C++ gc_off = true in each_object)
    const was_gc_off = vm.gc_off;
    vm.gc_off = true;

    // Count objects in tenured space.
    // Matches C++ each_object(tenured, ...) which never breaks on header==0
    // and reads free block sizes from the header (header & ~7).
    const free_list = @import("../free_list.zig");
    var count: usize = 0;
    var scan = heap.tenured.start;
    const tenured_end = heap.tenured.end;
    while (scan < tenured_end) {
        const header: Cell = @as(*const Cell, @ptrFromInt(scan)).*;
        if (header & 1 == 1) {
            // Free block - size is always encoded in header
            const size = header & ~@as(Cell, 7);
            if (size == 0) break; // Invalid free block
            scan += size;
        } else {
            const size = free_list.objectSizeFromHeader(scan);
            if (size == 0) break;
            count += 1;
            scan += size;
        }
    }

    // Restore gc_off for allocation
    vm.gc_off = was_gc_off;

    // Allocate array — nursery is empty after full GC so this should not
    // trigger another GC for reasonably-sized heaps.
    const array_tagged = vm.allotUninitializedArray(count) orelse {
        vm.memoryError();
    };
    const array: *layouts.Array = @ptrFromInt(layouts.UNTAG(array_tagged));
    const data = array.data();

    // Fill array with tagged object pointers from tenured space
    var idx: usize = 0;
    scan = heap.tenured.start;
    while (scan < tenured_end and idx < count) {
        const header: Cell = @as(*const Cell, @ptrFromInt(scan)).*;
        if (header & 1 == 1) {
            // Free block - size is always encoded in header
            const size = header & ~@as(Cell, 7);
            if (size == 0) break; // Invalid free block
            scan += size;
        } else {
            const size = free_list.objectSizeFromHeader(scan);
            if (size == 0) break;
            // Tag the object: address | type_tag (like C++ tag_dynamic)
            const type_tag = @as(Cell, @truncate((header >> 2) & layouts.tag_mask));
            data[idx] = scan | type_tag;
            idx += 1;
            scan += size;
        }
    }

    // Adjust capacity if we got fewer objects
    if (idx < count) {
        array.capacity = layouts.tagFixnum(@as(Fixnum, @intCast(idx)));
    }

    vm.push(array_tagged);
}

// --- Dispatch Statistics ---

pub export fn primitive_reset_dispatch_stats(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // Reset all dispatch statistics
    vm.dispatch_stats.megamorphic_cache_hits = 0;
    vm.dispatch_stats.megamorphic_cache_misses = 0;
    vm.dispatch_stats.cold_call_to_ic_transitions = 0;
    vm.dispatch_stats.ic_to_pic_transitions = 0;
    vm.dispatch_stats.pic_to_mega_transitions = 0;
    vm.dispatch_stats.pic_tag_count = 0;
    vm.dispatch_stats.pic_tuple_count = 0;
}

pub export fn primitive_dispatch_stats(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( -- byte-array )
    // Returns a byte array containing the dispatch_statistics struct,
    // matching C++ byte_array_from_value(&dispatch_stats).
    const stats_size = @sizeOf(vm_mod.DispatchStatistics);
    const ba_size = @sizeOf(layouts.ByteArray) + stats_size;

    const tagged = vm.allotObject(.byte_array, ba_size) orelse {
        vm.memoryError();
    };
    const ba: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(tagged));
    ba.capacity = layouts.tagFixnum(@intCast(stats_size));

    const ba_data = ba.data();
    const stats_bytes: [*]const u8 = @ptrCast(&vm.dispatch_stats);
    @memcpy(ba_data[0..stats_size], stats_bytes[0..stats_size]);

    vm.push(tagged);
}

// --- Profiling Primitives ---

pub export fn primitive_set_profiling(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const rate = vm.pop();
    const rate_fixnum = layouts.untagFixnum(rate);
    const running = safepoints.sampling_profiler_p.load(.monotonic);

    if (rate_fixnum > 0 and !running) {
        safepoints.startSamplingProfiler(vm, @intCast(rate_fixnum)) catch return;
    } else if (rate_fixnum == 0 and running) {
        safepoints.endSamplingProfiler(vm);
    }
}

pub export fn primitive_get_samples(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();

    // If profiler is still running or no samples collected, return false
    if (safepoints.sampling_profiler_p.load(.monotonic) or vm.profiling_samples.items.len == 0) {
        vm.push(layouts.false_object);
        return;
    }

    const samples = vm.profiling_samples.items;
    const num_samples = samples.len;

    // Allocate outer array to hold all sample tuples
    var samples_array = vm.allotUninitializedArray(num_samples) orelse {
        vm.push(layouts.false_object);
        return;
    };

    // Root samples_array since inner allocations can trigger GC
    vm.data_roots.append(vm.allocator, &samples_array) catch {
        vm.push(layouts.false_object);
        return;
    };
    defer _ = vm.data_roots.pop();

    // Get the callstacks growable array
    var callstacks_cell = vm.specialObject(.sample_callstacks);
    vm.data_roots.append(vm.allocator, &callstacks_cell) catch {
        vm.push(layouts.false_object);
        return;
    };
    defer _ = vm.data_roots.pop();

    for (samples, 0..) |sample, i| {
        // Allocate 7-element tuple for this sample
        var sample_arr = vm.allotUninitializedArray(7) orelse {
            vm.push(layouts.false_object);
            return;
        };

        // Root sample_arr for the callstack array allocation below
        vm.data_roots.append(vm.allocator, &sample_arr) catch {
            vm.push(layouts.false_object);
            return;
        };
        defer _ = vm.data_roots.pop();

        // Fill in the counts
        var sa: *layouts.Array = @ptrFromInt(layouts.UNTAG(sample_arr));
        sa.data()[0] = layouts.tagFixnum(@intCast(sample.sample_count));
        sa.data()[1] = layouts.tagFixnum(@intCast(sample.gc_sample_count));
        sa.data()[2] = layouts.tagFixnum(@intCast(sample.jit_sample_count));
        sa.data()[3] = layouts.tagFixnum(@intCast(sample.foreign_sample_count));
        sa.data()[4] = layouts.tagFixnum(@intCast(sample.foreign_thread_sample_count));
        sa.data()[5] = sample.thread;

        // Build callstack sub-array from the growable array indices
        const cs_size = sample.callstack_end - sample.callstack_begin;
        const cs_arr = vm.allotUninitializedArray(cs_size) orelse {
            vm.push(layouts.false_object);
            return;
        };

        // Fill callstack array from the heap growable array
        const cs: *layouts.Array = @ptrFromInt(layouts.UNTAG(cs_arr));
        for (0..cs_size) |j| {
            cs.data()[j] = safepoints.sampleCallstacksNth(callstacks_cell, sample.callstack_begin + j);
        }

        // Re-derive sample_arr after potential GC from cs_arr allocation
        sa = @ptrFromInt(layouts.UNTAG(sample_arr));
        sa.data()[6] = cs_arr;

        // Store in outer array (re-derive after potential GC)
        const outer: *layouts.Array = @ptrFromInt(layouts.UNTAG(samples_array));
        outer.data()[i] = sample_arr;
    }

    vm.push(samples_array);
}
