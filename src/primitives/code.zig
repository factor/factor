// primitives/code.zig - Code heap, quotation compilation, and method dispatch

const std = @import("std");
const code_blocks = @import("../code_blocks.zig");
const contexts = @import("../contexts.zig");
const jit_mod = @import("../jit.zig");
const layouts = @import("../layouts.zig");
const vm_mod = @import("../vm.zig");

const Cell = layouts.Cell;
const CodeBlock = code_blocks.CodeBlock;
const Fixnum = layouts.Fixnum;
const FactorVM = vm_mod.FactorVM;
const VMAssemblyFields = vm_mod.VMAssemblyFields;

// --- Code Heap Primitives ---

pub export fn primitive_modify_code_heap(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();

    const reset_inline_caches = vm.pop();
    const update_existing_words = vm.pop();
    var rooted_alist = vm.pop();
    vm.data_roots.append(vm.allocator, &rooted_alist) catch @panic("OOM");
    defer _ = vm.data_roots.pop();

    // Validate alist is an array
    if (!layouts.hasTag(rooted_alist, .array)) return;

    const count = blk: {
        const alist: *const layouts.Array = @ptrFromInt(layouts.UNTAG(rooted_alist));
        break :blk layouts.untagFixnumUnsigned(alist.capacity);
    };

    if (count == 0) return;

    // Process each (word, code) pair
    for (0..count) |i| {
        // CRITICAL: Re-derive alist from rooted_alist each iteration because
        // jitCompileQuotationWithOwner (called in previous iterations) can trigger GC
        // that moves the alist array. C++ does this via alist.untagged() data_root accessor.
        const alist_fresh: *const layouts.Array = @ptrFromInt(layouts.UNTAG(rooted_alist));
        var rooted_pair = alist_fresh.data()[i];
        vm.data_roots.append(vm.allocator, &rooted_pair) catch @panic("OOM");
        defer _ = vm.data_roots.pop();

        // Each element should be an array of [word, code]
        if (!layouts.hasTag(rooted_pair, .array)) {
            continue;
        }

        const pair: *const layouts.Array = @ptrFromInt(layouts.UNTAG(rooted_pair));
        if (layouts.untagFixnumUnsigned(pair.capacity) < 2) {
            continue;
        }

        var rooted_word = pair.data()[0];
        var rooted_code = pair.data()[1];
        vm.data_roots.ensureUnusedCapacity(vm.allocator, 2) catch @panic("OOM");
        vm.data_roots.appendAssumeCapacity(&rooted_word);
        defer _ = vm.data_roots.pop();
        vm.data_roots.appendAssumeCapacity(&rooted_code);
        defer _ = vm.data_roots.pop();

        // Validate word
        if (!layouts.hasTag(rooted_word, .word)) {
            continue;
        }

        // Handle based on code type
        const code_tag = layouts.typeTag(rooted_code);

        if (code_tag == .quotation or code_tag == .tuple) {
            // Quotation or tuple (curry/compose) case: JIT compile and update
            // word entry point. Matches C++ jit_compile_word which handles both
            // QUOTATION_TYPE and TUPLE_TYPE (see issue #2763).

            // C++ guard: Refuse to recompile lazy-jit-compile word more than once,
            // because quotation-compiled? depends on the identity of its code block.
            // Without this, recompiling lazy-jit-compile changes the sentinel
            // entry_point, causing all quotations with the OLD sentinel to appear
            // "compiled" (old_ep != new_ep), which creates infinite loops.
            const word_pre: *const layouts.Word = @ptrFromInt(layouts.UNTAG(rooted_word));
            if (word_pre.entry_point != 0 and
                rooted_word == vm.specialObject(.lazy_jit_compile_word))
            {
                continue;
            }

            // Compile the definition with the word as owner.
            // CRITICAL: relocate=false (matching C++ jit_compile_word in modify_code_heap).
            // Code blocks are added to uninitialized_blocks and initialized later by
            // updateCodeHeapWords, after ALL word entry_points have been set.
            // This ensures cross-references between words resolve correctly.
            const compiled = vm.jitCompileQuotationWithOwner(rooted_word, rooted_code, false);
            const word_after: *layouts.Word = @ptrFromInt(layouts.UNTAG(rooted_word));
            if (compiled) |cb| {
                word_after.entry_point = cb.entryPoint();
            } else {
                word_after.entry_point = vm.lazyJitCompileEntryPoint();
            }

            // Compile pic_def and pic_tail_def if present.
            // Matches C++ jit_compile_word which compiles these after setting entry_point.
            if (word_after.pic_def != layouts.false_object) {
                vm.jitCompileQuotation(word_after.pic_def, false);
            }
            if (word_after.pic_tail_def != layouts.false_object) {
                vm.jitCompileQuotation(word_after.pic_tail_def, false);
            }
        } else if (code_tag == .array) {
            // Array case: raw compiled code (optimized compilation)
            // Array contains: [parameters, literals, relocation, labels, code, frame_size]
            //
            // IMPORTANT: Following C++ two-phase approach:
            // Phase 1 (here): Allocate code block, copy machine code, apply labels, set entry_point
            // Phase 2 (in updateCodeHeapWords): Apply relocations after ALL entry_points are set
            // This is critical because code blocks may reference each other.
            const code_arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(rooted_code));
            const arr_cap = layouts.untagFixnumUnsigned(code_arr.capacity);

            if (arr_cap < 6) {
                continue;
            }

            const arr_data = code_arr.data();
            var parameters_cell = arr_data[0];
            var literals_cell = arr_data[1];
            var relocation_cell = arr_data[2];
            var labels_cell = arr_data[3];
            var code_bytes_cell = arr_data[4];
            const frame_size = layouts.untagFixnumUnsigned(arr_data[5]);

            vm.data_roots.ensureUnusedCapacity(vm.allocator, 5) catch @panic("OOM");
            vm.data_roots.appendAssumeCapacity(&parameters_cell);
            defer _ = vm.data_roots.pop();
            vm.data_roots.appendAssumeCapacity(&literals_cell);
            defer _ = vm.data_roots.pop();
            vm.data_roots.appendAssumeCapacity(&relocation_cell);
            defer _ = vm.data_roots.pop();
            vm.data_roots.appendAssumeCapacity(&labels_cell);
            defer _ = vm.data_roots.pop();
            vm.data_roots.appendAssumeCapacity(&code_bytes_cell);
            defer _ = vm.data_roots.pop();

            // Validate code_bytes is a byte-array
            if (!layouts.hasTag(code_bytes_cell, .byte_array)) {
                continue;
            }

            const code_bytes_pre: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(code_bytes_cell));
            const code_len = layouts.untagFixnumUnsigned(code_bytes_pre.capacity);

            // Allocate code block (triggers compaction if code heap is full)
            const header_size = @sizeOf(code_blocks.CodeBlock);
            const total_size = layouts.alignCell(header_size + code_len, layouts.data_alignment);

            const block = vm.allotCodeBlock(total_size);

            // Initialize the code block header (optimized type)
            block.initialize(.optimized, total_size, frame_size);
            block.owner = rooted_word;

            // Set relocation
            if (layouts.hasTag(relocation_cell, .byte_array)) {
                const reloc_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(relocation_cell));
                if (layouts.untagFixnumUnsigned(reloc_ba.capacity) > 0) {
                    block.relocation = relocation_cell;
                } else {
                    block.relocation = layouts.false_object;
                }
            } else {
                block.relocation = layouts.false_object;
            }

            // Set parameters
            if (layouts.hasTag(parameters_cell, .array)) {
                const params_arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(parameters_cell));
                if (layouts.untagFixnumUnsigned(params_arr.capacity) > 0) {
                    block.parameters = parameters_cell;
                } else {
                    block.parameters = layouts.false_object;
                }
            } else {
                block.parameters = layouts.false_object;
            }

            // Copy machine code (re-derive pointer after potential GC)
            const code_bytes: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(code_bytes_cell));
            const code_dest = block.codeStart();
            @memcpy(code_dest[0..code_len], code_bytes.data()[0..code_len]);

            // Apply labels fixups if present (these are block-internal, safe to do now)
            if (labels_cell != layouts.false_object and layouts.hasTag(labels_cell, .array)) {
                const labels_arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(labels_cell));
                const labels_data = labels_arr.data();
                const labels_cap = layouts.untagFixnumUnsigned(labels_arr.capacity);

                var j: usize = 0;
                while (j + 2 < labels_cap) : (j += 3) {
                    const rel_class_cell = labels_data[j];
                    const offset_cell = labels_data[j + 1];
                    const target_cell = labels_data[j + 2];

                    const rel_class: code_blocks.RelocationClass = @enumFromInt(@as(u4, @truncate(layouts.untagFixnumUnsigned(rel_class_cell))));
                    const offset: u24 = @truncate(layouts.untagFixnumUnsigned(offset_cell));
                    const target = layouts.untagFixnumUnsigned(target_cell);

                    const entry = code_blocks.RelocationEntry.init(.here, rel_class, offset);
                    var op = code_blocks.InstructionOperand.init(entry, block, 0);
                    const abs_value = target + block.entryPoint();
                    op.storeValue(@bitCast(abs_value));
                }
            }

            // CRITICAL: Add write barrier so GC will scan this code block's
            // relocation/parameters/owner fields during nursery collection.
            // Without this, if a subsequent iteration triggers GC (e.g., via
            // jitCompileQuotationWithOwner), the nursery byte arrays referenced
            // by relocation/parameters could be moved without updating these fields.
            // The GC's scanCodeBlock already handles uninitialized blocks correctly
            // (skips embedded literals, only visits header fields).
            // write_barrier already called by allotCodeBlock

            // DO NOT apply relocations here! Defer to updateCodeHeapWords.
            // Store the literals cell in uninitialized_blocks so updateCodeHeapWords
            // can initialize this block later, after all word entry_points are set.
            // This matches the C++ two-phase approach in add_code_block/update_code_heap_words.
            const code_heap = vm.code orelse continue;
            code_heap.putUninitializedBlock(vm.allocator, @intFromPtr(block), literals_cell) catch {
                // Fall back to immediate initialization if tracking fails
                vm.initializeCodeBlock(block, literals_cell);
            };

            // Set word entry point NOW (phase 1) so other blocks can reference it
            const word_after: *layouts.Word = @ptrFromInt(layouts.UNTAG(rooted_word));
            word_after.entry_point = block.entryPoint();
        } else {
            // Unknown code type - skip
        }
    }

    // If update_existing_words is true, we need to update all code blocks
    // to point to the new entry points. This is critical for existing call
    // sites to use the newly compiled code.
    if (update_existing_words != layouts.false_object) {
        updateCodeHeapWords(vm, reset_inline_caches != layouts.false_object);
    }
    if (update_existing_words == layouts.false_object) {
        // Fast path: just initialize uninitialized blocks without updating all word references
        if (vm.code) |code_heap| {
            var iter = code_heap.uninitialized_blocks.iterator();
            while (iter.next()) |entry| {
                const block: *code_blocks.CodeBlock = @ptrFromInt(entry.key_ptr.*);
                vm.initializeCodeBlock(block, entry.value_ptr.*);
            }
            code_heap.clearUninitializedBlocks();
        }
    }
}

// Update all code blocks to point to current word entry points
// This is equivalent to C++ VM's update_code_heap_words
pub fn updateCodeHeapWords(vm: *FactorVM, reset_inline_caches: bool) void {
    const code_heap = vm.code orelse return;

    // Pre-compilation pass: ensure all quotation literals in uninitialized
    // blocks have valid entry_points. Without this, applyRelocations sets
    // RT_ENTRY_POINT to lazy_jit_compile_ep, and updateWordReferences can
    // never fix it (loadCodeBlock follows the target to the lazy_jit_compile
    // code block, whose owner resolves back to lazy_jit_compile_ep).
    // This matches C++ behavior where jit_compile_quotation never fails
    // silently — sub-quotation entry_points are always valid before
    // code block initialization.
    preCompileQuotationLiterals(vm);

    // Capture a sorted snapshot of blocks AFTER pre-compilation
    const blocks = code_heap.all_blocks_sorted.items;
    if (blocks.len == 0) return;

    // Get PIC parameters from VM
    const max_pic_size = vm.max_pic_size;
    const lazy_jit_ep = vm.lazyJitCompileEntryPoint();

    // Collect PIC blocks to free (can't free during iteration since it modifies all_blocks)
    var pics_to_free = std.ArrayListUnmanaged(Cell){};
    defer pics_to_free.deinit(vm.allocator);
    pics_to_free.ensureUnusedCapacity(vm.allocator, blocks.len) catch @panic("OOM");

    for (blocks) |block_addr| {
        const block: *CodeBlock = @ptrFromInt(block_addr);

        // Check if this block needs initialization (deferred from primitive_modify_code_heap)
        if (code_heap.uninitialized_blocks.get(block_addr)) |literals_cell| {
            vm.initializeCodeBlock(block, literals_cell);
            continue;
        }

        // Free PIC blocks when resetting inline caches (matching C++ behavior).
        if (reset_inline_caches and block.blockType() == .pic) {
            pics_to_free.appendAssumeCapacity(block_addr);
            continue;
        }

        // Skip blocks that have no code pointer relocations (entry_point/pic)
        if (!code_heap.blockHasCodePointers(block)) continue;

        code_blocks.updateWordReferences(block, reset_inline_caches, max_pic_size, lazy_jit_ep);
    }

    // Batch free PIC blocks: O(N) instead of O(K*N)
    if (pics_to_free.items.len > 0) {
        for (pics_to_free.items) |pic_addr| {
            const block: *CodeBlock = @ptrFromInt(pic_addr);
            code_heap.freeBlockOnly(block);
        }
        code_heap.batchRemoveFromAllBlocks(pics_to_free.items);
    }

    // Clear uninitialized_blocks after processing
    code_heap.clearUninitializedBlocks();
}

// Pre-compile quotation literals in uninitialized code blocks.
// Only scans literals referenced by entry-point relocation slots, instead of
// walking every literal cell in every block.
fn preCompileQuotationLiterals(vm: *FactorVM) void {
    const code_heap = vm.code orelse return;
    if (code_heap.uninitialized_blocks.count() == 0) return;

    const lazy_ep = vm.lazyJitCompileEntryPoint();

    // Collect uncompiled quotation literals first (can't compile while iterating
    // uninitialized_blocks because compilation may trigger GC/compaction).
    var to_compile = std.ArrayListUnmanaged(Cell){};
    defer to_compile.deinit(vm.allocator);

    var iter = code_heap.uninitialized_blocks.iterator();
    while (iter.next()) |entry| {
        const block_addr = entry.key_ptr.*;
        const literals_cell = entry.value_ptr.*;
        if (literals_cell == layouts.false_object) continue;
        if (!layouts.hasTag(literals_cell, .array)) continue;

        const block: *const CodeBlock = @ptrFromInt(block_addr);
        if (block.relocation == layouts.false_object) continue;
        if (!layouts.hasTag(block.relocation, .byte_array)) continue;

        const lit_arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(literals_cell));
        const lit_data = lit_arr.data();
        const lit_cap = layouts.untagFixnumUnsigned(lit_arr.capacity);

        const reloc_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(block.relocation));
        const reloc_data = reloc_ba.data();
        const reloc_count = layouts.untagFixnumUnsigned(reloc_ba.capacity) / @sizeOf(code_blocks.RelocationEntry);

        var literal_index: usize = 0;
        for (0..reloc_count) |i| {
            const entry_ptr: *const code_blocks.RelocationEntry =
                @ptrCast(@alignCast(reloc_data + i * @sizeOf(code_blocks.RelocationEntry)));
            const rel_type = entry_ptr.getType();

            switch (rel_type) {
                .entry_point => {
                    if (literal_index >= lit_cap) break;
                    const lit = lit_data[literal_index];
                    literal_index += 1;

                    if (!layouts.hasTag(lit, .quotation)) continue;
                    const q: *const layouts.Quotation = @ptrFromInt(layouts.UNTAG(lit));
                    if (q.entry_point == 0 or q.entry_point == lazy_ep) {
                        to_compile.append(vm.allocator, lit) catch continue;
                    }
                },
                .entry_point_pic, .entry_point_pic_tail, .literal, .here, .untagged => {
                    literal_index += 1;
                },
                else => {},
            }
        }
    }

    if (to_compile.items.len > 0) {
        // Root all quotation cells to protect from GC during compilation.
        vm.data_roots.ensureUnusedCapacity(vm.allocator, to_compile.items.len) catch @panic("OOM");
        for (to_compile.items) |*cell_ptr| {
            vm.data_roots.appendAssumeCapacity(cell_ptr);
        }
        defer {
            // Pop all roots we added
            var k: usize = 0;
            while (k < to_compile.items.len) : (k += 1) {
                _ = vm.data_roots.pop();
            }
        }

        for (to_compile.items) |quot_cell| {
            // Re-check entry_point (may have been compiled as a dependency)
            if (layouts.hasTag(quot_cell, .quotation)) {
                const q: *const layouts.Quotation = @ptrFromInt(layouts.UNTAG(quot_cell));
                if (q.entry_point == 0 or q.entry_point == lazy_ep) {
                    vm.jitCompileQuotation(quot_cell, true);
                }
            }
        }
    }
}

pub export fn primitive_code_blocks(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( -- array )
    // Returns an array describing all code blocks in the code heap
    // Each code block contributes 6 elements to the result array:
    //   owner, parameters, relocation, type, size, entry_point

    // For stub: return an empty array placeholder
    // Real implementation would:
    // 1. Iterate through all code blocks
    // 2. For each block, push: owner, parameters, relocation, type (fixnum), size (fixnum), entry_point
    // 3. Convert vector to array and return
    vm.push(layouts.false_object);
}

pub export fn primitive_strip_stack_traces(_: *VMAssemblyFields) callconv(.c) void {
    // ( -- )
    // Strips debug information from all code blocks by setting owner to false
    // Used to reduce memory usage after compilation

    // For stub: just return
    // Real implementation would:
    // Iterate through all code blocks and set block->owner = false_object
}

// --- Single-stepper Primitives ---

pub export fn primitive_innermost_stack_frame_executing(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( callstack -- quotation )
    // Returns the quotation being executed in the innermost stack frame
    const cs_cell = vm.peek();

    vm.checkTag(cs_cell, .callstack);

    const callstack: *const layouts.Callstack = @ptrFromInt(layouts.UNTAG(cs_cell));
    const code = vm.code orelse @panic("no code heap");

    // Get the top frame
    const frame = callstack.top();
    const addr_ptr: *const Cell = @ptrFromInt(frame + contexts.FRAME_RETURN_ADDRESS);
    const addr = addr_ptr.*;

    // Find the code block for this address
    const block = code.codeBlockForAddress(addr) orelse {
        vm.replace(layouts.false_object);
        return;
    };

    // Replace with the owner quotation
    vm.replace(block.ownerQuot());
}

pub export fn primitive_innermost_stack_frame_scan(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( callstack -- n )
    // Returns the scan offset for single-stepping in the innermost frame
    const cs_cell = vm.peek();

    vm.checkTag(cs_cell, .callstack);

    const callstack: *const layouts.Callstack = @ptrFromInt(layouts.UNTAG(cs_cell));
    const code = vm.code orelse @panic("no code heap");

    // Get the top frame
    const frame = callstack.top();
    const addr_ptr: *const Cell = @ptrFromInt(frame + contexts.FRAME_RETURN_ADDRESS);
    const addr = addr_ptr.*;

    // Find the code block for this address
    const block = code.codeBlockForAddress(addr) orelse {
        vm.replace(layouts.false_object);
        return;
    };

    // Replace with the scan value
    vm.replace(block.scan(vm, addr));
}

pub export fn primitive_set_innermost_stack_frame_quotation(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( quot callstack -- )
    // Patches the innermost frame to execute a different quotation
    // Used by the single-stepper to modify execution flow
    const cs_cell = vm.pop();
    const quot_cell = vm.pop();

    vm.checkTag(cs_cell, .callstack);
    vm.checkTag(quot_cell, .quotation);

    const callstack: *const layouts.Callstack = @ptrFromInt(layouts.UNTAG(cs_cell));
    const quot: *const layouts.Quotation = @ptrFromInt(layouts.UNTAG(quot_cell));
    const code = vm.code orelse return;

    // Get the innermost frame
    const inner = callstack.top() + contexts.FRAME_RETURN_ADDRESS;
    const addr_ptr: *Cell = @ptrFromInt(inner);
    const addr = addr_ptr.*;

    // Find the code block for the current address
    const block = code.codeBlockForAddress(addr) orelse return;

    // Calculate the offset within the current code block
    const offset_val = block.offset(addr);

    // Patch the return address to point to the new quotation at the same offset
    addr_ptr.* = quot.entry_point + offset_val;
}

// --- Quotation Primitives ---

pub export fn primitive_quotation_compiled_p(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( quot -- ? )
    const quot_cell = vm.pop();
    if (!layouts.hasTag(quot_cell, .quotation)) {
        vm.push(layouts.false_object);
        return;
    }
    const quot: *const layouts.Quotation = @ptrFromInt(layouts.UNTAG(quot_cell));
    // Quotation is compiled if entry_point is non-zero and not lazy_jit_compile stub
    // Matches C++ quotation_compiled_p: entry_point != 0 && entry_point != lazy_jit_compile_entry_point()
    const compiled = jit_mod.isQuotationCompiled(vm, quot);
    vm.push(vm.tagBoolean(compiled));
}

pub export fn primitive_jit_compile(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( quot -- )
    // Matches C++ primitive_jit_compile: jit_compile_quotation(ctx->pop(), true)
    const quot_cell = vm.pop();
    vm.jitCompileQuotation(quot_cell, true);
}

pub export fn primitive_array_to_quotation(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( array -- quotation )
    // NOTE: C++ VM uses peek/replace:
    // quotation* quot = allot<quotation>(sizeof(quotation));
    // quot->array = ctx->peek();
    // quot->cached_effect = false_object;
    // quot->cache_counter = false_object;
    // quot->entry_point = lazy_jit_compile_entry_point();
    // ctx->replace(tag<quotation>(quot));

    const tagged = vm.allotObject(.quotation, @sizeOf(layouts.Quotation)) orelse {
        vm.memoryError();
        return;
    };

    // Peek AFTER allotObject - arr may have been moved by GC
    const arr = vm.peek();

    const quot: *layouts.Quotation = @ptrFromInt(layouts.UNTAG(tagged));
    quot.array = arr;
    quot.cached_effect = layouts.false_object;
    quot.cache_counter = layouts.false_object;
    quot.entry_point = vm.lazyJitCompileEntryPoint();
    vm.replace(tagged);
}

// --- Word Primitives ---

pub export fn primitive_word_optimized_p(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( word -- ? )
    const word_cell = vm.peek();
    vm.checkTag(word_cell, .word);
    const word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(word_cell));
    // Code block is located just before the entry point
    const block: *const code_blocks.CodeBlock = @ptrFromInt(word.entry_point - @sizeOf(code_blocks.CodeBlock));
    vm.replace(vm.tagBoolean(block.blockType() == .optimized));
}

// --- Dispatch Primitives ---

pub export fn primitive_lookup_method(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const ctx = vm_asm.ctx;
    // ( object methods -- method )
    const methods = ctx.pop();
    const object = ctx.pop();
    const method = lookupMethod(object, methods);
    ctx.push(method);
}

// For tuples, returns the layout; for other types, returns the tagged fixnum of the tag.
// No forwarding pointer following needed outside of GC since all references are
// updated after collection completes.
pub inline fn objectClass(object: Cell) Cell {
    const tag = layouts.typeTag(object);
    if (tag == .tuple) {
        const tuple: *const layouts.Tuple = @ptrFromInt(layouts.UNTAG(object));
        return tuple.layout;
    }
    return layouts.tagFixnum(@as(Fixnum, @intCast(@intFromEnum(tag))));
}

// C++: ((klass >> TAG_BITS) & capacity) << 1
inline fn methodCacheHashcode(klass: Cell, cache_arr: *const layouts.Array) Cell {
    const capacity = layouts.untagFixnumFast(cache_arr.capacity);
    // capacity >> 1 gives number of pairs, - 1 for mask
    const mask = (capacity >> 1) - 1;
    // Shift klass right by tag bits, mask, then shift left for pair indexing
    return ((klass >> layouts.tag_bits) & mask) << 1;
}

inline fn updateMethodCache(vm: *FactorVM, cache: Cell, klass: Cell, method: Cell) void {
    const cache_arr: *layouts.Array = @ptrFromInt(layouts.UNTAG(cache));
    const hashcode = methodCacheHashcode(klass, cache_arr);
    const data = cache_arr.data();
    data[hashcode] = klass;
    data[hashcode + 1] = method;

    // method_cache_hashcode() always returns an even index, so this pair
    // occupies a single card/deck-aligned 2-cell slot. Mark once.
    const slot0 = &data[hashcode];
    const slot1 = &data[hashcode + 1];
    std.debug.assert((@intFromPtr(slot0) >> vm_mod.card_bits) == (@intFromPtr(slot1) >> vm_mod.card_bits));
    vm.writeBarrierKnownHeap(slot0);
}

pub export fn primitive_mega_cache_miss(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    // ( methods index cache -- method )
    // Matches C++ factor_vm::primitive_mega_cache_miss()
    vm.dispatch_stats.megamorphic_cache_misses += 1;

    const cache = ctx.pop();
    const index_cell = ctx.pop();
    const methods = ctx.pop();

    const index = layouts.untagFixnum(index_cell);

    const stack_addr = ctx.datastack -% (@as(Cell, @intCast(index)) * @sizeOf(Cell));
    const object = @as(*const Cell, @ptrFromInt(stack_addr)).*;

    const klass = objectClass(object);
    const method = lookupMethod(object, methods);

    updateMethodCache(vm, cache, klass, method);

    ctx.push(method);
}

inline fn searchLookupAlist(table: Cell, klass: Cell) Cell {
    const elements: *const layouts.Array = @ptrFromInt(layouts.UNTAG(table));
    const cap: isize = layouts.untagFixnum(elements.capacity);
    const data = elements.data();

    var index: isize = cap - 2;
    while (index >= 0) : (index -= 2) {
        if (data[@intCast(index)] == klass) {
            return data[@intCast(index + 1)];
        }
    }
    return layouts.false_object;
}

inline fn searchLookupHash(table: Cell, klass: Cell, hashcode: Cell) Cell {
    const buckets: *const layouts.Array = @ptrFromInt(layouts.UNTAG(table));

    std.debug.assert(layouts.hasTag(buckets.capacity, .fixnum));

    const cap: Cell = @intCast(layouts.untagFixnum(buckets.capacity));
    const bucket_idx = hashcode & (cap - 1);
    const bucket = buckets.data()[bucket_idx];

    if (layouts.hasTag(bucket, .array)) {
        return searchLookupAlist(bucket, klass);
    }
    return bucket;
}

// Matches C++ lookup_tuple_method: no runtime tag checks, just untag directly.
inline fn lookupTupleMethod(obj: Cell, methods: Cell) Cell {
    const tuple: *const layouts.Tuple = @ptrFromInt(layouts.UNTAG(obj));

    std.debug.assert(layouts.hasTag(tuple.layout, .array));

    const layout: *const layouts.TupleLayout = @ptrFromInt(layouts.UNTAG(tuple.layout));
    const echelons: *const layouts.Array = @ptrFromInt(layouts.UNTAG(methods));

    std.debug.assert(layouts.hasTag(echelons.capacity, .fixnum));
    std.debug.assert(layouts.hasTag(layout.echelon, .fixnum));

    const echelons_cap = layouts.untagFixnum(echelons.capacity);
    const echelons_data = echelons.data();

    var echelon: isize = @min(layouts.untagFixnum(layout.echelon), echelons_cap - 1);

    while (echelon >= 0) {
        const echelon_idx: usize = @intCast(echelon);
        const echelon_methods = echelons_data[echelon_idx];

        if (layouts.hasTag(echelon_methods, .word)) {
            return echelon_methods;
        } else if (echelon_methods != layouts.false_object) {
            const klass = layout.nthSuperclass(echelon_idx);
            const hashcode_raw = layout.nthHashcode(echelon_idx);

            std.debug.assert(layouts.hasTag(hashcode_raw, .fixnum));

            const hashcode: Cell = @bitCast(layouts.untagFixnum(hashcode_raw));
            const result = searchLookupHash(echelon_methods, klass, hashcode);
            if (result != layouts.false_object) {
                return result;
            }
        }

        echelon -= 1;
    }

    // C++ calls critical_error here, but it requires VM access.
    // This path should never be reached with valid data.
    if (comptime std.debug.runtime_safety) unreachable;
    return layouts.false_object;
}

// Matches C++ lookup_method: array_nth(methods, tag) with FACTOR_ASSERT only.
pub inline fn lookupMethod(object: Cell, methods: Cell) Cell {
    const methods_arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(methods));
    const tag: Cell = layouts.TAG(object);

    std.debug.assert(tag < layouts.untagFixnumFast(methods_arr.capacity));

    const method = methods_arr.data()[tag];

    if (tag == @intFromEnum(layouts.TypeTag.tuple)) {
        if (layouts.hasTag(method, .array)) {
            return lookupTupleMethod(object, method);
        }
    }

    return method;
}

// --- Callstack Primitives ---

// Used by callstack_for to skip the primitive's own frame and its caller
fn secondFromTopStackFrame(vm: *FactorVM, ctx: *const contexts.Context) Cell {
    var frame_top = ctx.callstack_top;
    const bottom = ctx.callstack_bottom;

    // Skip 2 frames using frame_predecessor
    const code = vm.code orelse {
        // No code heap - fall back to returning original top
        return frame_top;
    };

    for (0..2) |_| {
        const pred = code.framePredecessor(frame_top);

        if (pred >= bottom) {
            // Reached bottom of callstack
            return frame_top;
        }
        frame_top = pred;
    }

    return frame_top;
}

pub export fn primitive_callstack_for(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( context -- callstack )
    const ctx_cell = vm.peek();

    const other_ctx = vm.getContextFromAlien(ctx_cell);
    if (other_ctx == null) {
        vm.replace(layouts.false_object);
        return;
    }

    const ctx = other_ctx.?;

    // Use second_from_top_stack_frame() like C++ does.
    // This skips 2 frames from the top because the 'callstack' primitive frame
    // and its caller frame should not be included - otherwise set-callstack
    // would loop forever.
    const top = secondFromTopStackFrame(vm, ctx);
    const bottom = ctx.callstack_bottom;

    // Match C++: size = max(0, bottom - top). The second_from_top_stack_frame
    // already skipped the primitive frame and its caller, so bottom - top gives
    // the correct callstack size to capture.
    const size: Cell = if (bottom > top) bottom - top else 0;

    // Allocate callstack object, triggering GC if needed
    const callstack_size = @sizeOf(layouts.Callstack) + size;
    const tagged = vm.allotObject(.callstack, callstack_size) orelse {
        vm.memoryError();
        return;
    };
    const callstack: *layouts.Callstack = @ptrFromInt(layouts.UNTAG(tagged));
    callstack.length = layouts.tagFixnum(@intCast(size));

    if (size > 0) {
        const src: [*]const u8 = @ptrFromInt(top);
        const dest: [*]u8 = @ptrFromInt(callstack.top());
        @memcpy(dest[0..size], src[0..size]);
    }

    vm.replace(tagged);
}
