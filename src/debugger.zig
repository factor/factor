// debugger.zig - Low-level debugger (Factor Error Protocol / factorbug)
// Extracted from vm.zig. Provides interactive debugging, stack printing,
// heap walking, and object inspection.

const std = @import("std");

const code_blocks = @import("code_blocks.zig");
const layouts = @import("layouts.zig");
const vm_mod = @import("vm.zig");

const Cell = layouts.Cell;
const FactorVM = vm_mod.FactorVM;

// --- Free functions (no VM needed) ---

fn factorbugUsage(advanced: bool) void {
    std.debug.print("Basic commands:\n", .{});
    std.debug.print("  q ^D             -- quit Factor\n", .{});
    std.debug.print("  c                -- continue executing Factor - NOT SAFE\n", .{});
    std.debug.print("  t                -- throw exception in Factor - NOT SAFE\n", .{});
    std.debug.print("  .s .r .c         -- print data, retain, call stacks\n", .{});
    if (advanced) {
        std.debug.print("  help             -- reprint this message\n", .{});
        std.debug.print("Advanced commands:\n", .{});
        std.debug.print("  e                -- dump environment\n", .{});
        std.debug.print("  d <addr> <count> -- dump memory\n", .{});
        std.debug.print("  u <addr>         -- dump object at tagged <addr>\n", .{});
        std.debug.print("  . <addr>         -- print object at tagged <addr>\n", .{});
        std.debug.print("  g                -- dump memory layout\n", .{});
        std.debug.print("  ds dr            -- dump data, retain stacks\n", .{});
        std.debug.print("  trim             -- toggle output trimming\n", .{});
        std.debug.print("  data             -- data heap dump\n", .{});
        std.debug.print("  words            -- words dump\n", .{});
        std.debug.print("  tuples           -- tuples dump\n", .{});
        std.debug.print("  edges            -- print all object-to-object references\n", .{});
        std.debug.print("  refs <addr>      -- find data heap references to object\n", .{});
        std.debug.print("  push <addr>      -- push object on data stack - NOT SAFE\n", .{});
        std.debug.print("  gc               -- trigger full GC - NOT SAFE\n", .{});
        std.debug.print("  compact-gc       -- trigger compacting GC - NOT SAFE\n", .{});
        std.debug.print("  code             -- code heap dump\n", .{});
        std.debug.print("  abort            -- call abort()\n", .{});
        std.debug.print("  breakpoint       -- trigger system breakpoint\n", .{});
    } else {
        std.debug.print("  help             -- full help, including advanced commands\n", .{});
    }
    std.debug.print("\n", .{});
}

fn printWord(word_ptr: *const layouts.Word) void {
    if (word_ptr.vocabulary != layouts.false_object and layouts.hasTag(word_ptr.vocabulary, .string)) {
        const vocab: *const layouts.String = @ptrFromInt(layouts.UNTAG(word_ptr.vocabulary));
        const vocab_len = layouts.untagFixnumUnsigned(vocab.length);
        const vocab_data = vocab.data();
        for (0..@min(vocab_len, 50)) |i| {
            const ch = vocab_data[i];
            if (ch >= 32 and ch < 127) {
                std.debug.print("{c}", .{@as(u8, @truncate(ch))});
            }
        }
        std.debug.print(":", .{});
    }
    if (word_ptr.name != layouts.false_object and layouts.hasTag(word_ptr.name, .string)) {
        const name: *const layouts.String = @ptrFromInt(layouts.UNTAG(word_ptr.name));
        const name_len = layouts.untagFixnumUnsigned(name.length);
        const name_data = name.data();
        for (0..@min(name_len, 50)) |i| {
            const ch = name_data[i];
            if (ch >= 32 and ch < 127) {
                std.debug.print("{c}", .{@as(u8, @truncate(ch))});
            }
        }
    } else {
        std.debug.print("#<not a string>", .{});
    }
}

fn dumpCell(addr: Cell) void {
    const val = @as(*const Cell, @ptrFromInt(addr)).*;
    std.debug.print("{x:016}: {x:016} tag {}\n", .{ addr, val, layouts.TAG(val) });
}

fn objectSizeForDebug(obj: *const layouts.Object, obj_type: layouts.TypeTag) Cell {
    const aligned = layouts.alignCell;
    const cell_size = @sizeOf(Cell);
    return switch (obj_type) {
        .array => blk: {
            const arr: *const layouts.Array = @ptrCast(obj);
            if (!layouts.hasTag(arr.capacity, .fixnum)) {
                break :blk layouts.data_alignment;
            }
            const cap = layouts.untagFixnumUnsigned(arr.capacity);
            break :blk aligned(@sizeOf(layouts.Array) + cap * cell_size, layouts.data_alignment);
        },
        .byte_array => blk: {
            const ba: *const layouts.ByteArray = @ptrCast(obj);
            if (!layouts.hasTag(ba.capacity, .fixnum)) {
                break :blk layouts.data_alignment;
            }
            const cap = layouts.untagFixnumUnsigned(ba.capacity);
            break :blk aligned(@sizeOf(layouts.ByteArray) + cap, layouts.data_alignment);
        },
        .string => blk: {
            const str: *const layouts.String = @ptrCast(obj);
            if (!layouts.hasTag(str.length, .fixnum)) {
                break :blk layouts.data_alignment;
            }
            const len = layouts.untagFixnumUnsigned(str.length);
            break :blk aligned(@sizeOf(layouts.String) + len, layouts.data_alignment);
        },
        .word => aligned(@sizeOf(layouts.Word), layouts.data_alignment),
        .quotation => aligned(@sizeOf(layouts.Quotation), layouts.data_alignment),
        .wrapper => aligned(@sizeOf(layouts.Wrapper), layouts.data_alignment),
        .float => aligned(@sizeOf(layouts.BoxedFloat), layouts.data_alignment),
        .tuple => blk: {
            const tuple: *const layouts.Tuple = @ptrCast(obj);
            if (layouts.hasTag(tuple.layout, .array)) {
                const layout_addr = layouts.UNTAG(tuple.layout);
                if (layout_addr == 0) break :blk aligned(@sizeOf(layouts.Tuple), layouts.data_alignment);
                const layout: *const layouts.TupleLayout = @ptrFromInt(layout_addr);
                if (!layouts.hasTag(layout.size, .fixnum)) {
                    break :blk aligned(@sizeOf(layouts.Tuple), layouts.data_alignment);
                }
                const slot_count = layouts.untagFixnumUnsigned(layout.size);
                break :blk aligned(@sizeOf(layouts.Tuple) + slot_count * cell_size, layouts.data_alignment);
            }
            break :blk aligned(@sizeOf(layouts.Tuple), layouts.data_alignment);
        },
        .alien => aligned(@sizeOf(layouts.Alien), layouts.data_alignment),
        .dll => aligned(@sizeOf(layouts.Dll), layouts.data_alignment),
        .callstack => blk: {
            const cs: *const layouts.Callstack = @ptrCast(obj);
            if (!layouts.hasTag(cs.length, .fixnum)) {
                break :blk layouts.data_alignment;
            }
            const len = layouts.untagFixnumUnsigned(cs.length);
            break :blk aligned(@sizeOf(layouts.Callstack) + len, layouts.data_alignment);
        },
        .bignum => blk: {
            const bn: *const layouts.Bignum = @ptrCast(obj);
            if (!layouts.hasTag(bn.capacity, .fixnum)) {
                break :blk layouts.data_alignment;
            }
            const cap = layouts.untagFixnumUnsigned(bn.capacity);
            break :blk aligned(@sizeOf(layouts.Bignum) + cap * cell_size, layouts.data_alignment);
        },
        else => layouts.data_alignment,
    };
}

fn printCodeBlockOwner(block: *const code_blocks.CodeBlock) void {
    const owner = block.owner;
    if (layouts.hasTag(owner, .word)) {
        const word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(owner));
        if (word.name != layouts.false_object and layouts.hasTag(word.name, .string)) {
            const str: *const layouts.String = @ptrFromInt(layouts.UNTAG(word.name));
            const len = layouts.untagFixnumUnsigned(str.length);
            const str_data = str.data();
            std.debug.print(" word: ", .{});
            for (0..@min(len, 60)) |j| {
                const ch = str_data[j];
                if (ch >= 32 and ch < 127) {
                    std.debug.print("{c}", .{@as(u8, @truncate(ch))});
                }
            }
        } else {
            std.debug.print(" word: (unnamed 0x{x})", .{owner});
        }
    } else if (layouts.hasTag(owner, .quotation)) {
        std.debug.print(" quotation 0x{x}", .{owner});
    } else {
        std.debug.print(" owner=0x{x} (tag={})", .{ owner, layouts.TAG(owner) });
    }
}

fn parseHexAddress(addr_str: []const u8) ?Cell {
    const trimmed = std.mem.trim(u8, addr_str, " \t");
    const hex_str = if (std.mem.startsWith(u8, trimmed, "0x") or std.mem.startsWith(u8, trimmed, "0X"))
        trimmed[2..]
    else
        trimmed;
    return std.fmt.parseInt(Cell, hex_str, 16) catch null;
}

// --- Functions that take a VM pointer ---

fn printFactorString(vm: *FactorVM, str: *const layouts.String) void {
    const len = layouts.untagFixnumUnsigned(str.length);
    const data = str.data();
    std.debug.print("\"", .{});
    const print_len = if (len > 100 and !vm.full_output) @as(usize, 100) else len;
    for (0..print_len) |i| {
        const ch = data[i];
        if (ch >= 32 and ch < 127) {
            std.debug.print("{c}", .{@as(u8, @truncate(ch))});
        } else {
            std.debug.print("\\x{x:02}", .{@as(u8, @truncate(ch))});
        }
    }
    if (print_len < len) std.debug.print("...", .{});
    std.debug.print("\"", .{});
}

fn printNestedObj(vm: *FactorVM, obj: Cell, nesting: i32) void {
    if (nesting <= 0 and !vm.full_output) {
        std.debug.print(" ... ", .{});
        return;
    }

    const tag = layouts.TAG(obj);
    switch (@as(layouts.TypeTag, @enumFromInt(@as(u4, @truncate(tag))))) {
        .fixnum => {
            std.debug.print("{}", .{layouts.untagFixnum(obj)});
        },
        .float => {
            const float_ptr: *const layouts.BoxedFloat = @ptrFromInt(layouts.UNTAG(obj));
            std.debug.print("{d}", .{float_ptr.n});
        },
        .word => {
            const word_ptr: *const layouts.Word = @ptrFromInt(layouts.UNTAG(obj));
            printWord(word_ptr);
        },
        .string => {
            const str: *const layouts.String = @ptrFromInt(layouts.UNTAG(obj));
            printFactorString(vm, str);
        },
        .f => {
            std.debug.print("f", .{});
        },
        .array => {
            std.debug.print("{{", .{});
            const arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(obj));
            const arr_len = layouts.untagFixnumUnsigned(arr.capacity);
            const data = arr.data();
            const print_len = if (arr_len > 10 and !vm.full_output) @as(usize, 10) else arr_len;
            for (0..print_len) |i| {
                std.debug.print(" ", .{});
                printNestedObj(vm, data[i], nesting - 1);
            }
            if (print_len < arr_len) std.debug.print("...", .{});
            std.debug.print(" }}", .{});
        },
        .quotation => {
            std.debug.print("[", .{});
            const quot: *const layouts.Quotation = @ptrFromInt(layouts.UNTAG(obj));
            if (quot.array != layouts.false_object and layouts.hasTag(quot.array, .array)) {
                const arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(quot.array));
                const arr_len = layouts.untagFixnumUnsigned(arr.capacity);
                const data = arr.data();
                const print_len = if (arr_len > 10 and !vm.full_output) @as(usize, 10) else arr_len;
                for (0..print_len) |i| {
                    std.debug.print(" ", .{});
                    printNestedObj(vm, data[i], nesting - 1);
                }
                if (print_len < arr_len) std.debug.print("...", .{});
            }
            std.debug.print(" ]", .{});
        },
        .wrapper => {
            std.debug.print("W{{ ", .{});
            const wrapper: *const layouts.Wrapper = @ptrFromInt(layouts.UNTAG(obj));
            printNestedObj(vm, wrapper.object, nesting - 1);
            std.debug.print(" }}", .{});
        },
        .byte_array => {
            std.debug.print("B{{", .{});
            const ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(obj));
            const ba_len = layouts.untagFixnumUnsigned(ba.capacity);
            const data = ba.data();
            const print_len = if (ba_len > 16 and !vm.full_output) @as(usize, 16) else ba_len;
            for (0..print_len) |i| {
                std.debug.print(" {}", .{data[i]});
            }
            if (print_len < ba_len) std.debug.print("...", .{});
            std.debug.print(" }}", .{});
        },
        .tuple => {
            std.debug.print("T{{", .{});
            const tuple: *const layouts.Tuple = @ptrFromInt(layouts.UNTAG(obj));
            if (layouts.hasTag(tuple.layout, .array)) {
                const layout: *const layouts.TupleLayout = @ptrFromInt(layouts.UNTAG(tuple.layout));
                std.debug.print(" ", .{});
                printNestedObj(vm, layout.klass, nesting - 1);
                if (layouts.hasTag(layout.size, .fixnum)) {
                    const slot_count = layouts.untagFixnumUnsigned(layout.size);
                    const print_count = if (slot_count > 10 and !vm.full_output) @as(usize, 10) else slot_count;
                    const slots = tuple.data();
                    for (0..print_count) |i| {
                        std.debug.print(" ", .{});
                        printNestedObj(vm, slots[i], nesting - 1);
                    }
                    if (print_count < slot_count) std.debug.print("...", .{});
                }
            } else {
                std.debug.print(" ...", .{});
            }
            std.debug.print(" }}", .{});
        },
        .alien => {
            const alien: *const layouts.Alien = @ptrFromInt(layouts.UNTAG(obj));
            if (alien.expired != layouts.false_object) {
                std.debug.print("#<expired alien>", .{});
            } else if (alien.base != layouts.false_object) {
                std.debug.print("#<displaced alien {}+", .{alien.displacement});
                printNestedObj(vm, alien.base, nesting - 1);
                std.debug.print(">", .{});
            } else {
                std.debug.print("#<alien 0x{x}>", .{alien.address});
            }
        },
        else => {
            std.debug.print("#<{s} @ 0x{x}>", .{
                if (tag < layouts.type_count) @tagName(@as(layouts.TypeTag, @enumFromInt(@as(u4, @truncate(tag))))) else "unknown",
                obj,
            });
        },
    }
}

fn printObj(vm: *FactorVM, obj: Cell) void {
    printNestedObj(vm, obj, 10);
}

fn dumpMemory(from: Cell, to: Cell) void {
    const start = layouts.UNTAG(from);
    var addr = start;
    while (addr <= to) : (addr += @sizeOf(Cell)) {
        dumpCell(addr);
    }
}

fn printDatastack(vm: *FactorVM) void {
    const ctx = vm.vm_asm.ctx;
    const seg = ctx.datastack_seg orelse {
        std.debug.print("*** Datastack segment not initialized\n", .{});
        return;
    };
    std.debug.print("==== DATA STACK:\n", .{});
    var addr = seg.start;
    while (addr <= ctx.datastack) : (addr += @sizeOf(Cell)) {
        const val = @as(*const Cell, @ptrFromInt(addr)).*;
        printObj(vm, val);
        std.debug.print("\n", .{});
    }
}

fn printRetainstack(vm: *FactorVM) void {
    const ctx = vm.vm_asm.ctx;
    const seg = ctx.retainstack_seg orelse {
        std.debug.print("*** Retainstack segment not initialized\n", .{});
        return;
    };
    std.debug.print("==== RETAIN STACK:\n", .{});
    var addr = seg.start;
    while (addr <= ctx.retainstack) : (addr += @sizeOf(Cell)) {
        const val = @as(*const Cell, @ptrFromInt(addr)).*;
        printObj(vm, val);
        std.debug.print("\n", .{});
    }
}

fn dumpDatastackRaw(vm: *FactorVM) void {
    const ctx = vm.vm_asm.ctx;
    const seg = ctx.datastack_seg orelse {
        std.debug.print("*** Datastack segment not initialized\n", .{});
        return;
    };
    dumpMemory(seg.start, ctx.datastack);
}

fn dumpRetainstackRaw(vm: *FactorVM) void {
    const ctx = vm.vm_asm.ctx;
    const seg = ctx.retainstack_seg orelse {
        std.debug.print("*** Retainstack segment not initialized\n", .{});
        return;
    };
    dumpMemory(seg.start, ctx.retainstack);
}

fn printCallstack(vm: *FactorVM) void {
    const ctx = vm.vm_asm.ctx;
    std.debug.print("==== CALL STACK:\n", .{});
    std.debug.print("  callstack_top=0x{x}, callstack_bottom=0x{x}\n", .{ ctx.callstack_top, ctx.callstack_bottom });
    if (ctx.callstack_top < ctx.callstack_bottom) {
        const size = ctx.callstack_bottom - ctx.callstack_top;
        std.debug.print("  size={} bytes\n", .{size});
        var frame_addr = ctx.callstack_top;
        var i: usize = 0;
        while (frame_addr < ctx.callstack_bottom and i < 30) : (i += 1) {
            const ret_addr = @as(*const Cell, @ptrFromInt(frame_addr)).*;
            std.debug.print("    [{:2}] 0x{x}", .{ i, ret_addr });
            if (vm.code) |code_heap| {
                if (code_heap.codeBlockForAddress(ret_addr)) |block| {
                    printCodeBlockOwner(block);
                    const frame_size = block.stackFrameSizeForAddress(ret_addr);
                    if (frame_size == 0) {
                        frame_addr += @sizeOf(Cell);
                    } else {
                        frame_addr += frame_size;
                    }
                } else {
                    std.debug.print(" (no code block)", .{});
                    frame_addr += @sizeOf(Cell);
                }
            } else {
                frame_addr += @sizeOf(Cell);
            }
            std.debug.print("\n", .{});
        }
    }
}

fn printDatastackStderr(vm: *FactorVM) void {
    const ctx = vm.vm_asm.ctx;
    const seg = ctx.datastack_seg orelse {
        std.debug.print("No datastack segment\n", .{});
        return;
    };
    const depth = ctx.datastackDepth();
    std.debug.print("--- Data stack (depth {}):\n", .{depth});
    var addr = seg.start;
    var i: usize = 0;
    while (addr <= ctx.datastack and i < 50) : ({
        addr += @sizeOf(Cell);
        i += 1;
    }) {
        const val = @as(*const Cell, @ptrFromInt(addr)).*;
        const tag = layouts.TAG(val);
        std.debug.print("  [{:2}] 0x{x:016} tag={} ({s})\n", .{
            i,
            val,
            tag,
            if (tag < layouts.type_count) @tagName(@as(layouts.TypeTag, @enumFromInt(@as(u4, @truncate(tag))))) else "invalid",
        });
        if (tag == @intFromEnum(layouts.TypeTag.alien)) {
            const alien: *const layouts.Alien = @ptrFromInt(layouts.UNTAG(val));
            std.debug.print("       -> alien.base=0x{x} disp=0x{x} addr=0x{x} expired=0x{x}\n", .{
                alien.base,
                alien.displacement,
                alien.address,
                alien.expired,
            });
        }
    }
}

fn printRetainstackStderr(vm: *FactorVM) void {
    const ctx = vm.vm_asm.ctx;
    const seg = ctx.retainstack_seg orelse {
        std.debug.print("No retainstack segment\n", .{});
        return;
    };
    const depth = ctx.retainstackDepth();
    std.debug.print("--- Retain stack (depth {}):\n", .{depth});
    var addr = seg.start;
    var i: usize = 0;
    while (addr <= ctx.retainstack and i < 30) : ({
        addr += @sizeOf(Cell);
        i += 1;
    }) {
        const val = @as(*const Cell, @ptrFromInt(addr)).*;
        const tag = layouts.TAG(val);
        std.debug.print("  [{:2}] 0x{x:016} tag={} ({s})\n", .{
            i,
            val,
            tag,
            if (tag < layouts.type_count) @tagName(@as(layouts.TypeTag, @enumFromInt(@as(u4, @truncate(tag))))) else "invalid",
        });
    }
}

fn printCallstackStderr(vm: *FactorVM) void {
    const ctx = vm.vm_asm.ctx;
    std.debug.print("--- Call stack:\n", .{});
    std.debug.print("  callstack_top=0x{x}, callstack_bottom=0x{x}\n", .{ ctx.callstack_top, ctx.callstack_bottom });
    if (ctx.callstack_top < ctx.callstack_bottom) {
        const size = ctx.callstack_bottom - ctx.callstack_top;
        std.debug.print("  size={} bytes\n", .{size});
        var frame_addr = ctx.callstack_top;
        var i: usize = 0;
        while (frame_addr < ctx.callstack_bottom and i < 30) : (i += 1) {
            const ret_addr = @as(*const Cell, @ptrFromInt(frame_addr)).*;
            std.debug.print("    [{:2}] 0x{x}", .{ i, ret_addr });
            if (vm.code) |code_heap| {
                if (code_heap.codeBlockForAddress(ret_addr)) |block| {
                    printCodeBlockOwner(block);
                    const frame_size = block.stackFrameSizeForAddress(ret_addr);
                    if (frame_size == 0) {
                        frame_addr += @sizeOf(Cell);
                    } else {
                        frame_addr += frame_size;
                    }
                } else {
                    std.debug.print(" (no code block)", .{});
                    frame_addr += @sizeOf(Cell);
                }
            } else {
                frame_addr += @sizeOf(Cell);
            }
            std.debug.print("\n", .{});
        }
    }
}

fn dumpEnvironment(vm: *FactorVM) void {
    std.debug.print("--- Special objects:\n", .{});
    for (vm.vm_asm.special_objects, 0..) |obj, i| {
        if (obj != layouts.false_object) {
            std.debug.print("  [{:3}] 0x{x:016}\n", .{ i, obj });
        }
    }
}

fn dumpMemoryLayout(vm: *FactorVM) void {
    std.debug.print("--- Memory layout:\n", .{});
    if (vm.data) |data_ptr| {
        std.debug.print("  Tenured: 0x{x} - 0x{x}\n", .{ data_ptr.tenured.start, data_ptr.tenured.start + data_ptr.tenured.size });
        std.debug.print("  Aging: 0x{x} - 0x{x}\n", .{ data_ptr.aging.start, data_ptr.aging.end });
    }
    if (vm.code) |code_ptr| {
        if (code_ptr.seg) |seg| {
            std.debug.print("  Code heap: 0x{x} - 0x{x}\n", .{ seg.start, seg.end });
        }
    }
    std.debug.print("  Nursery: 0x{x} - 0x{x} (here=0x{x})\n", .{
        vm.vm_asm.nursery.start,
        vm.vm_asm.nursery.end,
        vm.vm_asm.nursery.here,
    });
}

fn parseAndDumpMemory(args: []const u8) void {
    const trimmed = std.mem.trim(u8, args, " \t");
    var iter = std.mem.splitScalar(u8, trimmed, ' ');
    const addr_str = iter.next() orelse {
        std.debug.print("Usage: d <addr> <count>\n", .{});
        return;
    };
    const count_str = iter.next() orelse {
        std.debug.print("Usage: d <addr> <count>\n", .{});
        return;
    };
    const addr = parseHexAddress(addr_str) orelse {
        std.debug.print("Invalid address: {s}\n", .{addr_str});
        return;
    };
    const count = std.fmt.parseInt(usize, count_str, 10) catch {
        std.debug.print("Invalid count: {s}\n", .{count_str});
        return;
    };
    const end_addr = addr + count * @sizeOf(Cell);
    dumpMemory(addr, end_addr);
}

fn parseAndDumpObject(vm: *FactorVM, args: []const u8) void {
    const addr = parseHexAddress(args) orelse {
        std.debug.print("Invalid address: {s}\n", .{args});
        return;
    };
    dumpObject(vm, addr);
}

fn parseAndPrintObject(vm: *FactorVM, args: []const u8) void {
    const addr = parseHexAddress(args) orelse {
        std.debug.print("Invalid address: {s}\n", .{args});
        return;
    };
    printObj(vm, addr);
    std.debug.print("\n", .{});
}

fn parseAndFindRefs(vm: *FactorVM, args: []const u8) void {
    const addr = parseHexAddress(args) orelse {
        std.debug.print("Invalid address: {s}\n", .{args});
        return;
    };
    findRefs(vm, addr);
}

fn parseAndPush(vm: *FactorVM, args: []const u8) void {
    const addr = parseHexAddress(args) orelse {
        std.debug.print("Invalid address: {s}\n", .{args});
        return;
    };
    const ctx = vm.vm_asm.ctx;
    ctx.datastack += @sizeOf(Cell);
    @as(*Cell, @ptrFromInt(ctx.datastack)).* = addr;
    std.debug.print("Pushed 0x{x}\n", .{addr});
}

fn dumpObject(vm: *FactorVM, tagged_addr: Cell) void {
    const tag = layouts.TAG(tagged_addr);
    const untagged = layouts.UNTAG(tagged_addr);
    std.debug.print("Object at 0x{x} (tag={}, {s}):\n", .{
        tagged_addr,
        tag,
        if (tag < layouts.type_count) @tagName(@as(layouts.TypeTag, @enumFromInt(@as(u4, @truncate(tag))))) else "unknown",
    });

    switch (@as(layouts.TypeTag, @enumFromInt(@as(u4, @truncate(tag))))) {
        .fixnum => {
            std.debug.print("  fixnum: {}\n", .{layouts.untagFixnum(tagged_addr)});
        },
        .array => {
            const arr: *const layouts.Array = @ptrFromInt(untagged);
            const len = layouts.untagFixnumUnsigned(arr.capacity);
            std.debug.print("  capacity: {}\n", .{len});
            const data = arr.data();
            for (0..@min(len, 20)) |i| {
                std.debug.print("  [{:3}] ", .{i});
                printObj(vm, data[i]);
                std.debug.print("\n", .{});
            }
            if (len > 20) std.debug.print("  ... ({} more elements)\n", .{len - 20});
        },
        .string => {
            const str: *const layouts.String = @ptrFromInt(untagged);
            const len = layouts.untagFixnumUnsigned(str.length);
            std.debug.print("  length: {}\n", .{len});
            std.debug.print("  value: ", .{});
            printFactorString(vm, str);
            std.debug.print("\n", .{});
        },
        .word => {
            const word: *const layouts.Word = @ptrFromInt(untagged);
            std.debug.print("  name: ", .{});
            printWord(word);
            std.debug.print("\n", .{});
            std.debug.print("  hashcode: 0x{x}\n", .{word.hashcode_field});
            std.debug.print("  def: 0x{x}\n", .{word.def});
            std.debug.print("  props: 0x{x}\n", .{word.props});
            std.debug.print("  pic_def: 0x{x}\n", .{word.pic_def});
            std.debug.print("  pic_tail_def: 0x{x}\n", .{word.pic_tail_def});
            std.debug.print("  subprimitive: 0x{x}\n", .{word.subprimitive});
            std.debug.print("  entry_point: 0x{x}\n", .{word.entry_point});
        },
        .quotation => {
            const quot: *const layouts.Quotation = @ptrFromInt(untagged);
            std.debug.print("  array: 0x{x}\n", .{quot.array});
            std.debug.print("  cached_effect: 0x{x}\n", .{quot.cached_effect});
            std.debug.print("  cache_counter: 0x{x}\n", .{quot.cache_counter});
            std.debug.print("  entry_point: 0x{x}\n", .{quot.entry_point});
            if (quot.array != layouts.false_object and layouts.hasTag(quot.array, .array)) {
                std.debug.print("  contents: ", .{});
                printObj(vm, tagged_addr);
                std.debug.print("\n", .{});
            }
        },
        .byte_array => {
            const ba: *const layouts.ByteArray = @ptrFromInt(untagged);
            const len = layouts.untagFixnumUnsigned(ba.capacity);
            std.debug.print("  capacity: {}\n", .{len});
            const data = ba.data();
            std.debug.print("  first 32 bytes: ", .{});
            for (0..@min(len, 32)) |i| {
                std.debug.print("{x:02} ", .{data[i]});
            }
            std.debug.print("\n", .{});
        },
        .tuple => {
            const tuple: *const layouts.Tuple = @ptrFromInt(untagged);
            std.debug.print("  layout: 0x{x}\n", .{tuple.layout});
            if (layouts.hasTag(tuple.layout, .tuple)) {
                const layout: *const layouts.TupleLayout = @ptrFromInt(layouts.UNTAG(tuple.layout));
                const size = layouts.untagFixnumUnsigned(layout.size);
                std.debug.print("  size: {}\n", .{size});
                const slots = tuple.data();
                for (0..@min(size, 20)) |i| {
                    std.debug.print("  [{:2}] ", .{i});
                    printObj(vm, slots[i]);
                    std.debug.print("\n", .{});
                }
            } else {
                std.debug.print("  (layout tag: {})\n", .{layouts.TAG(tuple.layout)});
            }
        },
        .wrapper => {
            const wrapper: *const layouts.Wrapper = @ptrFromInt(untagged);
            std.debug.print("  wrapped: 0x{x}\n", .{wrapper.object});
            std.debug.print("  value: ", .{});
            printObj(vm, wrapper.object);
            std.debug.print("\n", .{});
        },
        .f => {
            std.debug.print("  (false singleton)\n", .{});
        },
        else => {
            std.debug.print("  raw cells:\n", .{});
            for (0..8) |i| {
                const ptr = untagged + i * @sizeOf(Cell);
                const val = @as(*const Cell, @ptrFromInt(ptr)).*;
                std.debug.print("    [{:2}] 0x{x}\n", .{ i, val });
            }
        },
    }
}

fn dumpDataHeap(vm: *FactorVM) void {
    std.debug.print("--- Data heap dump:\n", .{});
    const data_ptr = vm.data orelse {
        std.debug.print("  (data heap not initialized)\n", .{});
        return;
    };
    const tenured_start = data_ptr.tenured.start;
    const tenured_end = data_ptr.tenured.end;
    var addr = tenured_start;
    var obj_count: usize = 0;
    while (addr < tenured_end) {
        const obj: *const layouts.Object = @ptrFromInt(addr);
        if ((obj.header & 3) != 0) break;
        const obj_type = obj.getType();
        obj_count += 1;
        std.debug.print("{x:0>16} ", .{addr});
        printObj(vm, addr | @intFromEnum(obj_type));
        std.debug.print("\n", .{});
        const size = objectSizeForDebug(obj, obj_type);
        if (size == 0) {
            addr += layouts.data_alignment;
            continue;
        }
        addr += size;
    }
    std.debug.print("  (dumped {} objects)\n", .{obj_count});
}

fn dumpWords(vm: *FactorVM) void {
    std.debug.print("--- Words dump:\n", .{});
    const data_ptr = vm.data orelse {
        std.debug.print("  (data heap not initialized)\n", .{});
        return;
    };
    const tenured_start = data_ptr.tenured.start;
    const tenured_end = data_ptr.tenured.end;
    std.debug.print("  Scanning tenured: 0x{x} - 0x{x}\n", .{ tenured_start, tenured_end });
    var addr = tenured_start;
    var word_count: usize = 0;
    var obj_count: usize = 0;
    while (addr < tenured_end) {
        const obj: *const layouts.Object = @ptrFromInt(addr);
        if ((obj.header & 3) != 0) {
            std.debug.print("  ERROR: Invalid header at 0x{x}: 0x{x} (bits 0-1 not zero)\n", .{ addr, obj.header });
            std.debug.print("  Stopping iteration - likely misaligned due to previous size error\n", .{});
            break;
        }
        obj_count += 1;
        const obj_type = obj.getType();
        if (obj_count <= 50) {
            const raw_size = objectSizeForDebug(obj, obj_type);
            if (obj_type == .array) {
                const arr: *const layouts.Array = @ptrFromInt(addr);
                std.debug.print("  [obj#{} at 0x{x}: type=array, header=0x{x}, cap_raw=0x{x}, size={}]\n", .{
                    obj_count, addr, obj.header, arr.capacity, raw_size,
                });
            } else if (obj_type == .string) {
                const str: *const layouts.String = @ptrFromInt(addr);
                std.debug.print("  [obj#{} at 0x{x}: type=string, header=0x{x}, len_raw=0x{x}, size={}]\n", .{
                    obj_count, addr, obj.header, str.length, raw_size,
                });
            } else if (obj_type == .byte_array) {
                const ba: *const layouts.ByteArray = @ptrFromInt(addr);
                std.debug.print("  [obj#{} at 0x{x}: type=byte_array, header=0x{x}, cap_raw=0x{x}, size={}]\n", .{
                    obj_count, addr, obj.header, ba.capacity, raw_size,
                });
            } else if (obj_type == .bignum) {
                const bn: *const layouts.Bignum = @ptrFromInt(addr);
                std.debug.print("  [obj#{} at 0x{x}: type=bignum, header=0x{x}, cap_raw=0x{x}, size={}]\n", .{
                    obj_count, addr, obj.header, bn.capacity, raw_size,
                });
            } else {
                std.debug.print("  [obj#{} at 0x{x}: type={t}, header=0x{x}, size={}]\n", .{
                    obj_count, addr, obj_type, obj.header, raw_size,
                });
            }
        }
        if (obj_type == .word) {
            word_count += 1;
            const word: *const layouts.Word = @ptrFromInt(addr);
            std.debug.print("{x:0>16} ", .{addr});
            printWord(word);
            std.debug.print("\n", .{});
        }
        const raw_size = objectSizeForDebug(obj, obj_type);
        const size = layouts.alignCell(raw_size, layouts.data_alignment);
        if (size == 0) {
            addr += layouts.data_alignment;
            continue;
        }
        addr += size;
    }
    std.debug.print("  (scanned {} objects, found {} words)\n", .{ obj_count, word_count });
}

fn dumpTuples(vm: *FactorVM) void {
    std.debug.print("--- Tuples dump:\n", .{});
    const data_ptr = vm.data orelse {
        std.debug.print("  (data heap not initialized)\n", .{});
        return;
    };
    const tenured_start = data_ptr.tenured.start;
    const tenured_end = data_ptr.tenured.end;
    var addr = tenured_start;
    var tuple_count: usize = 0;
    while (addr < tenured_end) {
        const obj: *const layouts.Object = @ptrFromInt(addr);
        if ((obj.header & 3) != 0) break;
        const obj_type = obj.getType();
        if (obj_type == .tuple) {
            tuple_count += 1;
            std.debug.print("{x:0>16} ", .{addr});
            printObj(vm, addr | @intFromEnum(layouts.TypeTag.tuple));
            std.debug.print("\n", .{});
        }
        const size = objectSizeForDebug(obj, obj_type);
        if (size == 0) {
            addr += layouts.data_alignment;
            continue;
        }
        addr += size;
    }
    std.debug.print("  (found {} tuples)\n", .{tuple_count});
}

fn findRefs(vm: *FactorVM, target: Cell) void {
    std.debug.print("--- Finding references to 0x{x}:\n", .{target});
    const data_ptr = vm.data orelse {
        std.debug.print("  (data heap not initialized)\n", .{});
        return;
    };
    var ref_count: usize = 0;
    const tenured_start = data_ptr.tenured.start;
    const tenured_end = data_ptr.tenured.end;
    var addr = tenured_start;
    while (addr < tenured_end and ref_count < 50) {
        const val = @as(*const Cell, @ptrFromInt(addr)).*;
        if (val == target) {
            std.debug.print("  Found at 0x{x} (tenured)\n", .{addr});
            ref_count += 1;
        }
        addr += @sizeOf(Cell);
    }
    addr = data_ptr.nursery.start;
    while (addr < data_ptr.nursery.here and ref_count < 50) {
        const val = @as(*const Cell, @ptrFromInt(addr)).*;
        if (val == target) {
            std.debug.print("  Found at 0x{x} (nursery)\n", .{addr});
            ref_count += 1;
        }
        addr += @sizeOf(Cell);
    }
    for (vm.vm_asm.special_objects, 0..) |obj, i| {
        if (obj == target) {
            std.debug.print("  Found in special_objects[{}]\n", .{i});
            ref_count += 1;
        }
    }
    std.debug.print("  (found {} references)\n", .{ref_count});
}

fn objectSizeTagged(tagged: Cell) Cell {
    const tag = layouts.typeTag(tagged);
    if (tag == .fixnum or tag == .f) {
        return 0;
    }
    const addr = layouts.UNTAG(tagged);
    const obj: *const layouts.Object = @ptrFromInt(addr);
    const obj_type = obj.getType();
    return objectSizeForDebug(obj, obj_type);
}

fn dumpCodeHeap(vm: *FactorVM) void {
    const code_ptr = vm.code orelse {
        std.debug.print("(code heap not initialized)\n", .{});
        return;
    };

    const start = code_ptr.code_start;
    const end = start + code_ptr.code_size;

    if (start == 0 or code_ptr.code_size == 0) {
        std.debug.print("0 bytes used by relocation tables\n", .{});
        std.debug.print("0 bytes used by parameter tables\n", .{});
        return;
    }

    var reloc_size: Cell = 0;
    var parameter_size: Cell = 0;
    var scan = start;

    while (scan < end) {
        const block: *const code_blocks.CodeBlock = @ptrFromInt(scan);
        const block_size = block.size();

        if (block_size == 0) {
            std.debug.print("ERROR: zero-size block at 0x{x}\n", .{scan});
            break;
        }

        if (!block.isFree()) {
            if (block.relocation != layouts.false_object) {
                reloc_size += objectSizeTagged(block.relocation);
            }
            if (block.parameters != layouts.false_object) {
                parameter_size += objectSizeTagged(block.parameters);
            }

            const status: []const u8 = "allocated";
            std.debug.print("{x} {x} {s} stack frame {}\n", .{
                scan,
                block_size,
                status,
                block.stackFrameSize(),
            });
        }

        scan += block_size;
    }

    std.debug.print("{} bytes used by relocation tables\n", .{reloc_size});
    std.debug.print("{} bytes used by parameter tables\n", .{parameter_size});
}

// --- Public entry points (called from FactorVM methods) ---

pub fn factorbug(vm: *FactorVM) void {
    if (vm.fep_disabled) {
        std.debug.print("Low level debugger disabled\n", .{});
        std.process.exit(1);
    }

    vm.fep_p = true;

    std.debug.print("Starting low level debugger...\n", .{});

    const c_api = @import("c_api.zig");
    c_api.lock_console();

    const signals = @import("signals.zig");
    signals.ignoreCtrlC();

    const stdin_fd = 0;
    if (std.c.isatty(stdin_fd) == 0) {
        std.debug.print("(stdin is not a terminal - printing stacks and exiting)\n", .{});
        printDatastack(vm);
        printRetainstack(vm);
        printCallstack(vm);
        std.process.exit(1);
    }

    if (!vm.fep_help_was_shown) {
        factorbugUsage(false);
        vm.fep_help_was_shown = true;
    }

    var seen_command = false;
    while (true) {
        std.debug.print("> ", .{});

        var buf: [1024]u8 = undefined;
        const read_result = std.c.read(stdin_fd, &buf, buf.len);
        if (read_result < 0) {
            if (!seen_command) {
                vm.fep_disabled = true;
                printDatastack(vm);
                printRetainstack(vm);
                printCallstack(vm);
            }
            std.process.exit(1);
        }
        const bytes_read: usize = @intCast(read_result);

        if (bytes_read == 0) {
            if (!seen_command) {
                vm.fep_disabled = true;
                printDatastack(vm);
                printRetainstack(vm);
                printCallstack(vm);
            }
            std.process.exit(1);
        }

        const line = buf[0..bytes_read];
        const cmd = std.mem.trim(u8, line, " \t\r\n");
        if (cmd.len == 0) continue;

        seen_command = true;

        if (std.mem.eql(u8, cmd, "q")) {
            std.process.exit(1);
        } else if (std.mem.eql(u8, cmd, "c")) {
            c_api.unlock_console();
            signals.handleCtrlC();
            vm.fep_p = false;
            return;
        } else if (std.mem.eql(u8, cmd, "t")) {
            c_api.unlock_console();
            signals.handleCtrlC();
            vm.fep_p = false;
            vm.generalError(.interrupt, layouts.false_object, layouts.false_object);
        } else if (std.mem.eql(u8, cmd, ".s")) {
            printDatastack(vm);
        } else if (std.mem.eql(u8, cmd, ".r")) {
            printRetainstack(vm);
        } else if (std.mem.eql(u8, cmd, ".c")) {
            printCallstack(vm);
        } else if (std.mem.eql(u8, cmd, "ds")) {
            dumpDatastackRaw(vm);
        } else if (std.mem.eql(u8, cmd, "dr")) {
            dumpRetainstackRaw(vm);
        } else if (std.mem.eql(u8, cmd, "e")) {
            dumpEnvironment(vm);
        } else if (std.mem.eql(u8, cmd, "g")) {
            dumpMemoryLayout(vm);
        } else if (std.mem.eql(u8, cmd, "help")) {
            factorbugUsage(true);
        } else if (std.mem.eql(u8, cmd, "trim")) {
            vm.full_output = !vm.full_output;
            std.debug.print("Output trimming: {s}\n", .{if (vm.full_output) "disabled" else "enabled"});
        } else if (std.mem.eql(u8, cmd, "data")) {
            dumpDataHeap(vm);
        } else if (std.mem.eql(u8, cmd, "words")) {
            dumpWords(vm);
        } else if (std.mem.eql(u8, cmd, "tuples")) {
            dumpTuples(vm);
        } else if (std.mem.eql(u8, cmd, "code")) {
            dumpCodeHeap(vm);
        } else if (std.mem.eql(u8, cmd, "gc")) {
            if (vm.garbage_collector) |gc_inst| {
                std.debug.print("Running full GC...\n", .{});
                gc_inst.collectFull(false);
                std.debug.print("GC complete.\n", .{});
            } else {
                std.debug.print("GC not available.\n", .{});
            }
        } else if (std.mem.eql(u8, cmd, "compact-gc")) {
            if (vm.garbage_collector) |gc_inst| {
                std.debug.print("Running compacting GC...\n", .{});
                gc_inst.collectFull(true);
                std.debug.print("Compacting GC complete.\n", .{});
            } else {
                std.debug.print("GC not available.\n", .{});
            }
        } else if (std.mem.eql(u8, cmd, "abort")) {
            std.debug.panic("User requested abort", .{});
        } else if (std.mem.eql(u8, cmd, "breakpoint")) {
            const arch = @import("builtin").cpu.arch;
            if (arch == .x86_64 or arch == .x86) {
                asm volatile ("ud2");
            } else if (arch == .aarch64) {
                asm volatile ("udf #0");
            } else {
                const ptr: *volatile u8 = @ptrFromInt(0);
                _ = ptr.*;
            }
        } else if (std.mem.startsWith(u8, cmd, "d ")) {
            parseAndDumpMemory(cmd[2..]);
        } else if (std.mem.startsWith(u8, cmd, "u ")) {
            parseAndDumpObject(vm, cmd[2..]);
        } else if (std.mem.startsWith(u8, cmd, ". ")) {
            parseAndPrintObject(vm, cmd[2..]);
        } else if (std.mem.startsWith(u8, cmd, "refs ")) {
            parseAndFindRefs(vm, cmd[5..]);
        } else if (std.mem.startsWith(u8, cmd, "push ")) {
            parseAndPush(vm, cmd[5..]);
        } else {
            std.debug.print("unknown command: '{s}'\n", .{cmd});
        }
    }
}

pub fn criticalError(vm: *FactorVM, msg: []const u8, tagged: Cell) void {
    std.debug.print("You have triggered a bug in Factor. Please report.\n", .{});
    std.debug.print("critical_error: {s}: 0x{x}\n", .{ msg, tagged });
    factorbug(vm);
}
