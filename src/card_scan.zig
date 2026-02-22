// card_scan.zig - Card scanning for generational GC
// Scans dirty cards in tenured/aging space to find cross-generational
// references. Also handles code heap root scanning, large object scanning,
// and aging space maintenance.
//
// Extracted from gc.zig to reduce file size.

const std = @import("std");

const code_blocks = @import("code_blocks.zig");
const code_heap_mod = @import("code_heap.zig");
const data_heap_mod = @import("data_heap.zig");
const gc_mod = @import("gc.zig");
const layouts = @import("layouts.zig");
const object_start_map = @import("object_start_map.zig");
const slot_visitor = @import("slot_visitor.zig");
const vm_mod = @import("vm.zig");
const write_barrier = @import("write_barrier.zig");

const Cell = layouts.Cell;
const CodeHeap = code_heap_mod.CodeHeap;
const GC = gc_mod.GarbageCollector;

// Scan cards in a generation for cross-generational references.
// Uses RELATIVE card/deck indices (matching C++ visit_cards), accessing
// the cards/decks arrays directly. This avoids the bug where absolute
// indices with cards_offset could address memory before the cards array
// when the generation start isn't deck-aligned.
pub fn scanCards(gc: *GC, tenured: *data_heap_mod.TenuredSpace, mask: u8, unmask: u8, destination: *slot_visitor.CopyingDestination, aging_start: Cell, aging_end: Cell) void {
    scanCardsGeneration(gc, tenured.start, tenured.end, &tenured.object_start, mask, unmask, destination, aging_start, aging_end);
}

// Scan cards for a generation. Works with any generation (tenured or aging)
// that has an object_start map for finding objects at card boundaries.
pub fn scanCardsGeneration(
    gc: *GC,
    gen_start: Cell,
    gen_end: Cell,
    gen_object_start: *object_start_map.ObjectStartMap,
    mask: u8,
    unmask: u8,
    destination: *slot_visitor.CopyingDestination,
    aging_start: Cell,
    aging_end: Cell,
) void {
    // Access deck bytes using OFFSET-BASED indexing to match the JIT write
    // barrier (which computes: decks_offset + (addr >> deck_bits)).
    // Array-based indexing (decks[(addr-base) >> deck_bits]) disagrees with
    // offset-based when segment.start is not deck_size-aligned, because
    // (addr >> k) - (base >> k) != (addr - base) >> k in general.
    // Card access can remain array-based since base is always card_size-aligned
    // (page_size >= card_size).
    const heap_base = gc.heap.segment.start;
    const cards = gc.vm.cards_array orelse return;
    const decks_offset = gc.vm.vm_asm.decks_offset;

    // Align gen_start DOWN to absolute deck boundary
    const first_deck_addr = gen_start & ~@as(Cell, vm_mod.deck_size - 1);

    // Precise aging mode: during nursery tenured card scan, precisely track
    // which cards still contain aging references after copying nursery objects.
    // This prevents stale aging bits from accumulating over ~68K nursery GCs,
    // which otherwise cause the aging GC to scan thousands of cards that no
    // longer contain actual aging pointers.
    const precise_aging = aging_end != 0;

    // Track last scanned object position across consecutive cards.
    // Matches C++ visit_cards optimization: when scanning consecutive dirty
    // cards within a large object (e.g. a 600K-element array), reuse the
    // last object position instead of calling findObjectContainingCard
    // (which does a linear backward scan and is O(N) for large objects).
    var last_obj_start: Cell = 0;

    // Iterate decks by absolute address
    var deck_addr = first_deck_addr;
    while (deck_addr < gen_end) : (deck_addr += vm_mod.deck_size) {
        const abs_deck_idx = deck_addr >> @intCast(vm_mod.deck_bits);
        const deck_byte_ptr: *u8 = @ptrFromInt(decks_offset +% abs_deck_idx);
        if ((deck_byte_ptr.* & mask) == 0) {
            continue;
        }

        if (gc.current_event) |event| event.decks_scanned += 1;

        // Only clear the deck byte if the ENTIRE deck is within [gen_start, gen_end).
        // Boundary decks (partially outside the generation) must preserve
        // their byte for the adjacent generation's scan.
        const deck_fully_inside = (deck_addr >= gen_start and deck_addr + vm_mod.deck_size <= gen_end);
        const saved_deck = deck_byte_ptr.*;
        if (deck_fully_inside) {
            deck_byte_ptr.* &= ~unmask;
        }

        // Cards in this deck, clamped to generation range.
        const card_range_start = @max(deck_addr, gen_start);
        const card_range_end = @min(deck_addr + vm_mod.deck_size, gen_end);
        const first_card = (card_range_start - heap_base) / vm_mod.card_size;
        const last_card = (card_range_end - heap_base + vm_mod.card_size - 1) / vm_mod.card_size;

        var ci = first_card;
        while (ci < last_card) : (ci += 1) {
            if ((cards[ci] & mask) == 0) {
                continue;
            }
            if (gc.current_event) |event| event.cards_scanned += 1;
            const saved_card = cards[ci];

            // In non-precise mode, clear card mask bit before scanning.
            // In precise mode, we set the card byte after scanning based
            // on actual aging references found.
            if (!precise_aging) {
                cards[ci] &= ~unmask;
            }

            // Calculate card address range
            const card_start = heap_base + ci * vm_mod.card_size;
            const card_end = card_start + vm_mod.card_size;

            // Reuse last scanned object position if it extends into this card.
            // Matches C++ visit_card: if (!start || (start + obj->size()) < start_addr)
            //
            // OSM card index: must use (card_start - gen_start) / card_size, NOT
            // ci - gen_first_card. When gen_start is not card-aligned, the two
            // differ by 1, causing the OSM lookup to return the wrong object and
            // skip objects spanning the card boundary.
            const first_obj = if (last_obj_start != 0 and last_obj_start < card_start) blk: {
                // Use objectOrFreeSize which handles both live objects
                // and free blocks (matching C++ object::size()).
                const obj_size = gc_mod.objectOrFreeSize(last_obj_start);
                if (obj_size > 0 and last_obj_start + obj_size > card_start) {
                    break :blk last_obj_start;
                }
                const osm_card = if (card_start >= gen_start) (card_start - gen_start) / vm_mod.card_size else 0;
                break :blk gen_object_start.findObjectContainingCard(osm_card);
            } else blk: {
                const osm_card = if (card_start >= gen_start) (card_start - gen_start) / vm_mod.card_size else 0;
                break :blk gen_object_start.findObjectContainingCard(osm_card);
            };

            if (first_obj == null) {
                if (precise_aging) cards[ci] = 0;
                continue;
            }

            // Scan objects in this card, tracking the last object for reuse
            const result = scanObjectsInCard(first_obj.?, card_start, card_end, gen_end, destination, aging_start, aging_end);
            last_obj_start = result.last_obj;

            // If allocation failed during slot processing, restore the card
            // mark so the next GC cycle will re-process this card. Without
            // this, stale nursery/aging pointers survive with clean cards.
            if (destination.allocation_failed) {
                cards[ci] = saved_card;
                break;
            }

            // In precise mode, set card byte based on actual aging references
            if (precise_aging) {
                cards[ci] = if (result.has_aging_ref) write_barrier.card_points_to_aging else 0;
            }
        }

        // Restore deck byte if allocation failed during card processing
        if (destination.allocation_failed) {
            deck_byte_ptr.* = saved_deck;
            break;
        }
    }
}

const ScanResult = struct {
    last_obj: Cell,
    has_aging_ref: bool,
};

// Walk objects in a dirty card and visit their slots.
// Uses C++ visit_partial_objects approach: all pointer-bearing fields are
// contiguous after the header, so we use slotCountAndSize() + a single generic
// scan loop clipped to card boundaries. This eliminates the per-type switch
// for slot visiting.
//
// Optimization: slotCountAndSize() reads the header ONCE and returns both the
// slot count and object size in a single type switch, eliminating the previous
// triple header read (free check + slotCount + objectSizeFromHeader).
//
// When aging_end != 0 (precise mode), tracks whether any slot in the card
// points to the aging generation after copy. This allows the caller to
// precisely set the aging card bit instead of letting stale bits accumulate.
//
// Returns the address of the last object scanned and the aging ref flag.
fn scanObjectsInCard(first_obj: Cell, card_start: Cell, card_end: Cell, tenured_end: Cell, destination: *slot_visitor.CopyingDestination, aging_start: Cell, aging_end: Cell) ScanResult {
    var obj_addr = first_obj;
    var last_obj: Cell = first_obj;
    var has_aging_ref = false;

    while (obj_addr < card_end and obj_addr < tenured_end) {
        const header: Cell = @as(*const Cell, @ptrFromInt(obj_addr)).*;

        // Free block: header has low bit set, size in upper bits.
        // Track as last_obj for reuse across consecutive cards.
        if (header & 1 == 1) {
            const free_size = header & ~@as(Cell, 7);
            if (free_size == 0) break;
            last_obj = obj_addr;
            obj_addr += free_size;
            continue;
        }
        if (header == 0) break;

        // Combined slot count + object size from single header read.
        const info = slotCountAndSize(obj_addr);
        if (info.size == 0) break;

        // C++ visit_partial_objects: scan cells [obj+8 .. obj+8+slot_count*8),
        // clipped to [card_start, card_end). slot_count includes fixnum fields
        // (e.g. array capacity) which are harmless no-ops for visit_handle.
        if (info.slot_count > 0) {
            const slots_start = obj_addr + @sizeOf(Cell);
            const slots_end = slots_start + info.slot_count * @sizeOf(Cell);
            var ptr = @max(slots_start, card_start);
            const end = @min(slots_end, card_end);
            while (ptr < end) : (ptr += @sizeOf(Cell)) {
                const slot: *Cell = @ptrFromInt(ptr);
                const value = slot.*;
                if (!layouts.isImmediate(value)) {
                    const new_value = destination.copy(value);
                    if (new_value != value) slot.* = new_value;
                    // In precise mode, check if the (possibly updated) value
                    // points to aging. Short-circuit once found: skip the
                    // check for remaining slots since one aging ref is enough
                    // to set the card bit. This eliminates most overhead since
                    // cards with nursery refs typically have aging refs after copy.
                    if (!has_aging_ref and aging_end != 0) {
                        const untagged = layouts.UNTAG(new_value);
                        if (untagged >= aging_start and untagged < aging_end) {
                            has_aging_ref = true;
                        }
                    }
                }
            }
        }

        last_obj = obj_addr;
        obj_addr += info.size;
    }
    return .{ .last_obj = last_obj, .has_aging_ref = has_aging_ref };
}

const SlotCountAndSize = struct {
    slot_count: Cell,
    size: Cell,
};

// Combined slot count + object size from a single header read / type switch.
// Replaces separate slotCount() + objectSizeFromHeader() calls, eliminating
// two redundant header reads per object in the card scan hot path.
inline fn slotCountAndSize(obj_addr: Cell) SlotCountAndSize {
    const obj: *layouts.Object = @ptrFromInt(obj_addr);
    const t = obj.getType();
    return switch (t) {
        .array => blk: {
            const capacity = layouts.untagFixnumUnsigned(@as(*const layouts.Array, @ptrFromInt(obj_addr)).capacity);
            break :blk .{
                .slot_count = 1 + capacity,
                .size = layouts.alignCell(@sizeOf(layouts.Array) + capacity * @sizeOf(Cell), layouts.data_alignment),
            };
        },
        .tuple => blk: {
            const layout_addr = layouts.followForwardingPointers(@as(*const layouts.Tuple, @ptrFromInt(obj_addr)).layout);
            const layout: *layouts.TupleLayout = @ptrFromInt(layout_addr);
            const tuple_size = layouts.untagFixnumUnsigned(layout.size);
            break :blk .{
                .slot_count = 1 + tuple_size,
                .size = layouts.alignCell(@sizeOf(layouts.Tuple) + tuple_size * @sizeOf(Cell), layouts.data_alignment),
            };
        },
        .quotation => .{
            .slot_count = 3,
            .size = layouts.alignCell(@sizeOf(layouts.Quotation), layouts.data_alignment),
        },
        .word => .{
            .slot_count = 8,
            .size = layouts.alignCell(@sizeOf(layouts.Word), layouts.data_alignment),
        },
        .wrapper => .{
            .slot_count = 1,
            .size = layouts.alignCell(@sizeOf(layouts.Wrapper), layouts.data_alignment),
        },
        .string => blk: {
            const len = layouts.untagFixnumUnsigned(@as(*const layouts.String, @ptrFromInt(obj_addr)).length);
            break :blk .{
                .slot_count = 3,
                .size = layouts.alignCell(@sizeOf(layouts.String) + len, layouts.data_alignment),
            };
        },
        .alien => .{
            .slot_count = 2,
            .size = layouts.alignCell(@sizeOf(layouts.Alien), layouts.data_alignment),
        },
        .dll => .{
            .slot_count = 1,
            .size = layouts.alignCell(@sizeOf(layouts.Dll), layouts.data_alignment),
        },
        .bignum => blk: {
            const capacity = layouts.untagFixnumUnsigned(@as(*const layouts.Bignum, @ptrFromInt(obj_addr)).capacity);
            break :blk .{ .slot_count = 0, .size = layouts.alignCell(@sizeOf(layouts.Bignum) + capacity * @sizeOf(Cell), layouts.data_alignment) };
        },
        .byte_array => blk: {
            const capacity = layouts.untagFixnumUnsigned(@as(*const layouts.ByteArray, @ptrFromInt(obj_addr)).capacity);
            break :blk .{ .slot_count = 0, .size = layouts.alignCell(@sizeOf(layouts.ByteArray) + capacity, layouts.data_alignment) };
        },
        .callstack => blk: {
            const len = layouts.untagFixnumUnsigned(@as(*const layouts.Callstack, @ptrFromInt(obj_addr)).length);
            break :blk .{ .slot_count = 0, .size = layouts.alignCell(@sizeOf(layouts.Callstack) + len, layouts.data_alignment) };
        },
        .float => .{ .slot_count = 0, .size = layouts.alignCell(@sizeOf(layouts.BoxedFloat), layouts.data_alignment) },
        .fixnum, .f => .{ .slot_count = 0, .size = layouts.data_alignment },
    };
}

// Scan code heap for nursery/aging references using the remembered set.
// Only code blocks that had their literals modified (via write barrier)
// are scanned. This matches C++ visit_code_heap_roots.
pub const CodeRootScanMode = enum { nursery, aging, both };

pub fn scanCodeHeapRoots(gc: *GC, destination: *slot_visitor.CopyingDestination, mode: CodeRootScanMode) void {
    const code = gc.vm.code orelse return;
    if (!code.remembered_sets.hasAny()) return;
    const has_uninitialized = code.uninitialized_blocks.count() != 0;
    const nursery_set: ?*const std.DynamicBitSet = if (code.remembered_sets.points_to_nursery) |*set| set else null;
    const aging_set: ?*const std.DynamicBitSet = if (code.remembered_sets.points_to_aging) |*set| set else null;

    // Iterate dirty block list: O(m) where m = dirty count, vs O(N) bitset scan.
    // Entries are validated against the active bitset and then filtered by isFree().
    const scanDirtyBlocks = struct {
        fn scan(
            gc2: *GC,
            code2: *CodeHeap,
            indices: []const usize,
            active_set: ?*const std.DynamicBitSet,
            dest: *slot_visitor.CopyingDestination,
            has_uninit: bool,
        ) void {
            for (indices) |index| {
                if (active_set) |set| {
                    if (!set.isSet(index)) continue;
                }
                const addr: Cell = code2.code_start + @as(Cell, @intCast(index)) * layouts.data_alignment;
                const block: *code_blocks.CodeBlock = @ptrFromInt(addr);
                if (!block.isFree()) {
                    scanCodeBlock(code2, has_uninit, gc2, block, dest);
                }
            }
        }
    }.scan;

    switch (mode) {
        .nursery => {
            if (code.remembered_sets.nursery_has_any) {
                scanDirtyBlocks(gc, code, code.remembered_sets.nurseryDirtyBlocks(), nursery_set, destination, has_uninitialized);
            }
        },
        .aging => {
            if (code.remembered_sets.aging_has_any) {
                scanDirtyBlocks(gc, code, code.remembered_sets.agingDirtyBlocks(), aging_set, destination, has_uninitialized);
            }
        },
        .both => {
            // Scan nursery first.
            if (code.remembered_sets.nursery_has_any) {
                scanDirtyBlocks(gc, code, code.remembered_sets.nurseryDirtyBlocks(), nursery_set, destination, has_uninitialized);
            }

            // Then scan aging, skipping blocks already present in nursery set.
            // Uses nursery bitset for O(1) cross-check per block.
            if (code.remembered_sets.aging_has_any) {
                for (code.remembered_sets.agingDirtyBlocks()) |index| {
                    if (aging_set) |set| {
                        if (!set.isSet(index)) continue;
                    }
                    if (nursery_set) |set| {
                        if (set.isSet(index)) continue;
                    }
                    const addr: Cell = code.code_start + @as(Cell, @intCast(index)) * layouts.data_alignment;
                    const block: *code_blocks.CodeBlock = @ptrFromInt(addr);
                    if (!block.isFree()) {
                        scanCodeBlock(code, has_uninitialized, gc, block, destination);
                    }
                }
            }
        },
    }
}

// Scan all code blocks (used when growing the data heap).
pub fn scanAllCodeBlocksForCopy(gc: *GC, destination: *slot_visitor.CopyingDestination) void {
    const code = gc.vm.code orelse return;
    const has_uninitialized = code.uninitialized_blocks.count() != 0;
    for (code.all_blocks_sorted.items) |block_addr| {
        const block: *code_blocks.CodeBlock = @ptrFromInt(block_addr);
        if (!block.isFree()) {
            scanCodeBlock(code, has_uninitialized, gc, block, destination);
        }
    }
}

// Scan a code block for heap references
fn scanCodeBlock(code: *CodeHeap, has_uninitialized: bool, gc: *GC, block: *code_blocks.CodeBlock, destination: *slot_visitor.CopyingDestination) void {
    if (gc.current_event) |event| event.code_blocks_scanned += 1;
    visitSlot(@ptrCast(&block.owner), destination);

    // Visit parameters array
    visitSlot(@ptrCast(&block.parameters), destination);

    // Visit relocation table
    visitSlot(@ptrCast(&block.relocation), destination);

    if (!code.blockHasLiterals(block)) return;
    const is_uninitialized = has_uninitialized and code.isBlockUninitialized(block);
    const literal_sites = code.literalSitesForBlock(block);

    // Scan embedded literals in the code
    scanEmbeddedLiterals(block, destination, is_uninitialized, literal_sites);
}

// Visit a single slot, copying the object if needed (inlined from gc.zig visitSlot)
inline fn visitSlot(slot: *Cell, destination: *slot_visitor.CopyingDestination) void {
    const value = slot.*;
    if (layouts.isImmediate(value)) return;
    const new_value = destination.copy(value);
    if (new_value != value) slot.* = new_value;
}

// Scan embedded literals in a code block
// This is critical for GC correctness: code blocks contain literal references
// to heap objects embedded in the machine code via relocation entries.
// When GC moves these objects, the embedded literals must be updated.
fn scanEmbeddedLiterals(
    block: *code_blocks.CodeBlock,
    destination: *slot_visitor.CopyingDestination,
    is_uninitialized: bool,
    literal_sites: ?[]const code_blocks.LiteralRelocationSite,
) void {
    if (is_uninitialized) return;

    if (literal_sites) |sites| {
        if (sites.len == 0) return;
        var modified = false;
        for (sites) |site| {
            var op = code_blocks.InstructionOperand.init(site.rel, block, @as(Cell, site.param_index));
            const value = op.loadValue();
            const value_unsigned: Cell = @bitCast(value);
            if (!layouts.isImmediate(value_unsigned)) {
                const new_value = destination.copy(value_unsigned);
                if (new_value != value_unsigned) {
                    op.storeValue(@bitCast(new_value));
                    modified = true;
                }
            }
        }
        if (modified) block.flushIcache();
        return;
    }

    // Get relocation table
    if (block.relocation == layouts.false_object) return;
    if (!layouts.hasTag(block.relocation, .byte_array)) return;

    const reloc_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(block.relocation));
    const reloc_cap = layouts.untagFixnumUnsigned(reloc_ba.capacity);
    if (reloc_cap == 0) return;

    const reloc_data = reloc_ba.data();
    const reloc_count = reloc_cap / @sizeOf(code_blocks.RelocationEntry);

    var modified = false;
    var param_index: Cell = 0;

    for (0..reloc_count) |i| {
        const entry_ptr: *const code_blocks.RelocationEntry = @ptrCast(@alignCast(reloc_data + i * @sizeOf(code_blocks.RelocationEntry)));
        const entry = entry_ptr.*;
        const rel_type = entry.getType();

        if (rel_type == .literal) {
            var op = code_blocks.InstructionOperand.init(entry, block, param_index);
            const value = op.loadValue();
            const value_unsigned: Cell = @bitCast(value);

            if (!layouts.isImmediate(value_unsigned)) {
                const new_value = destination.copy(value_unsigned);
                if (new_value != value_unsigned) {
                    op.storeValue(@bitCast(new_value));
                    modified = true;
                }
            }
        }
        switch (rel_type) {
            .vm => param_index += 1,
            .dlsym => param_index += 2,
            else => {},
        }
    }

    // Flush instruction cache if we modified any literals
    if (modified) {
        block.flushIcache();
    }
}
