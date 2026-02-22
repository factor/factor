// jit.zig - JIT compiler for Factor quotations
// Ported from vm/jit.hpp, vm/jit.cpp
//
// The JIT compiler uses a template-based approach where pre-assembled
// machine code snippets are concatenated together to produce compiled code.
// Templates are stored in special_objects and defined in Factor bootstrap code.

const std = @import("std");

const code_blocks = @import("code_blocks.zig");
const cpu = @import("cpu.zig");
const growable = @import("growable.zig");
const layouts = @import("layouts.zig");
const objects = @import("objects.zig");
const vm_mod = @import("vm.zig");

const Cell = layouts.Cell;
const Fixnum = layouts.Fixnum;
const FactorVM = vm_mod.FactorVM;

fn removeRoot(vm: *FactorVM, target: *Cell) void {
    // Roots are pushed in order; the target should be at the end.
    // Pop from the end (O(1)) instead of linear search + orderedRemove (O(n)).
    if (vm.data_roots.items.len > 0 and vm.data_roots.items[vm.data_roots.items.len - 1] == target) {
        _ = vm.data_roots.pop();
        return;
    }
    // Fallback: linear search for out-of-order removal
    for (vm.data_roots.items, 0..) |root, idx| {
        if (root == target) {
            _ = vm.data_roots.orderedRemove(idx);
            return;
        }
    }
}

// JIT template indices (stored in special_objects)
pub const JitTemplate = enum(u32) {
    // Basic templates
    prolog = @intFromEnum(objects.SpecialObject.jit_prolog),
    primitive_word = @intFromEnum(objects.SpecialObject.jit_primitive_word),
    primitive = @intFromEnum(objects.SpecialObject.jit_primitive),
    word_jump = @intFromEnum(objects.SpecialObject.jit_word_jump),
    word_call = @intFromEnum(objects.SpecialObject.jit_word_call),
    if_word = @intFromEnum(objects.SpecialObject.jit_if_word),
    jit_if = @intFromEnum(objects.SpecialObject.jit_if),
    safepoint = @intFromEnum(objects.SpecialObject.jit_safepoint),
    epilog = @intFromEnum(objects.SpecialObject.jit_epilog),
    return_template = @intFromEnum(objects.SpecialObject.jit_return),
    push_literal = @intFromEnum(objects.SpecialObject.jit_push_literal),
    dip_word = @intFromEnum(objects.SpecialObject.jit_dip_word),
    dip = @intFromEnum(objects.SpecialObject.jit_dip),
    two_dip_word = @intFromEnum(objects.SpecialObject.jit_2dip_word),
    two_dip = @intFromEnum(objects.SpecialObject.jit_2dip),
    three_dip_word = @intFromEnum(objects.SpecialObject.jit_3dip_word),
    three_dip = @intFromEnum(objects.SpecialObject.jit_3dip),
    execute = @intFromEnum(objects.SpecialObject.jit_execute),
    declare_word = @intFromEnum(objects.SpecialObject.jit_declare_word),

    // PIC templates
    pic_load = @intFromEnum(objects.SpecialObject.pic_load),
    pic_tag = @intFromEnum(objects.SpecialObject.pic_tag),
    pic_tuple = @intFromEnum(objects.SpecialObject.pic_tuple),
    pic_check_tag = @intFromEnum(objects.SpecialObject.pic_check_tag),
    pic_check_tuple = @intFromEnum(objects.SpecialObject.pic_check_tuple),
    pic_hit = @intFromEnum(objects.SpecialObject.pic_hit),
    pic_miss_word = @intFromEnum(objects.SpecialObject.pic_miss_word),
    pic_miss_tail_word = @intFromEnum(objects.SpecialObject.pic_miss_tail_word),

    // Megamorphic templates
    mega_lookup = @intFromEnum(objects.SpecialObject.mega_lookup),
    mega_lookup_word = @intFromEnum(objects.SpecialObject.mega_lookup_word),
    mega_miss_word = @intFromEnum(objects.SpecialObject.mega_miss_word),
};

// =============================================================================
// Label and Forward Reference System
// =============================================================================

// Position is -1 if not yet defined (forward reference)
pub const Label = struct {
    position: i64,

    pub fn init() Label {
        return .{ .position = -1 };
    }

    pub fn isDefined(self: *const Label) bool {
        return self.position >= 0;
    }

    pub fn define(self: *Label, pos: usize) void {
        self.position = @intCast(pos);
    }

    pub fn getPosition(self: *const Label) ?usize {
        if (self.isDefined()) {
            return @intCast(self.position);
        }
        return null;
    }
};

pub const ForwardReference = struct {
    label_id: usize, // Index into label array
    patch_offset: usize, // Offset in code buffer where to patch
    relocation_class: code_blocks.RelocationClass, // Type of relocation

    pub fn init(label_id: usize, patch_offset: usize, rel_class: code_blocks.RelocationClass) ForwardReference {
        return .{
            .label_id = label_id,
            .patch_offset = patch_offset,
            .relocation_class = rel_class,
        };
    }
};

pub const LabelManager = struct {
    labels: std.ArrayList(Label),
    forward_refs: std.ArrayList(ForwardReference),
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .labels = .{},
            .forward_refs = .{},
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.labels.deinit(self.allocator);
        self.forward_refs.deinit(self.allocator);
    }

    pub fn clear(self: *Self) void {
        self.labels.clearRetainingCapacity();
        self.forward_refs.clearRetainingCapacity();
    }

    pub fn makeLabel(self: *Self) !usize {
        const label_id = self.labels.items.len;
        try self.labels.append(self.allocator, Label.init());
        return label_id;
    }

    pub fn defineLabel(self: *Self, label_id: usize, position: usize) !void {
        if (label_id >= self.labels.items.len) {
            return error.InvalidLabelId;
        }
        self.labels.items[label_id].define(position);
    }

    pub fn isLabelDefined(self: *const Self, label_id: usize) bool {
        if (label_id >= self.labels.items.len) {
            return false;
        }
        return self.labels.items[label_id].isDefined();
    }

    // Get label position (null if undefined)
    pub fn getLabelPosition(self: *const Self, label_id: usize) ?usize {
        if (label_id >= self.labels.items.len) {
            return null;
        }
        return self.labels.items[label_id].getPosition();
    }

    // Add a forward reference
    pub fn addForwardRef(self: *Self, label_id: usize, patch_offset: usize, rel_class: code_blocks.RelocationClass) !void {
        if (label_id >= self.labels.items.len) {
            return error.InvalidLabelId;
        }
        try self.forward_refs.append(
            self.allocator,
            ForwardReference.init(label_id, patch_offset, rel_class),
        );
    }

    // Returns the fixup data as an array of [relocation_class, offset, target] triples
    pub fn fixupLabels(self: *Self, code_buffer: []u8) !std.ArrayList(Cell) {
        var fixups = std.ArrayList(Cell){};
        errdefer fixups.deinit(self.allocator);

        try fixups.ensureUnusedCapacity(self.allocator, self.forward_refs.items.len * 3);

        for (self.forward_refs.items) |fwd_ref| {
            const label_id = fwd_ref.label_id;

            if (label_id >= self.labels.items.len) {
                return error.InvalidLabelId;
            }

            const label = self.labels.items[label_id];
            if (!label.isDefined()) {
                return error.UndefinedLabel;
            }

            const target_pos = label.getPosition() orelse return error.UndefinedLabel;

            // Patch the code directly for relative jumps/calls
            try patchRelativeJump(code_buffer, fwd_ref.patch_offset, target_pos);

            // Record fixup for code block metadata (Factor format: class, offset, target)
            fixups.appendAssumeCapacity(layouts.tagFixnum(@as(Fixnum, @intCast(@intFromEnum(fwd_ref.relocation_class)))));
            fixups.appendAssumeCapacity(layouts.tagFixnum(@as(Fixnum, @intCast(fwd_ref.patch_offset))));
            fixups.appendAssumeCapacity(layouts.tagFixnum(@as(Fixnum, @intCast(target_pos))));
        }

        return fixups;
    }
};

fn patchRelativeJump(code_buffer: []u8, patch_offset: usize, target_pos: usize) !void {
    const arch = cpu.Arch.current();

    switch (arch) {
        .x86, .x86_64 => {
            // x86_64: relative offset is 4 bytes after the opcode
            // Jump/call format: [opcode] [4-byte rel offset]
            // The offset is calculated from the end of the instruction
            const insn_end = patch_offset + 5; // opcode (1 byte) + offset (4 bytes)
            const rel_offset: i32 = @intCast(@as(i64, @intCast(target_pos)) - @as(i64, @intCast(insn_end)));

            if (patch_offset + 5 > code_buffer.len) {
                return error.PatchOffsetOutOfBounds;
            }

            // Write the offset in little-endian format
            std.mem.writeInt(i32, code_buffer[patch_offset + 1 ..][0..4], rel_offset, .little);
        },
        .aarch64 => {
            // ARM64: branch offset is encoded in the instruction
            // B/BL format: [6-bit opcode][26-bit signed offset]
            // Offset is in instructions (4-byte aligned), so divide by 4
            const insn_pos = patch_offset;
            const offset_in_bytes: i32 = @intCast(@as(i64, @intCast(target_pos)) - @as(i64, @intCast(insn_pos)));
            const offset_in_insns: i32 = @divExact(offset_in_bytes, 4);

            if (patch_offset + 4 > code_buffer.len) {
                return error.PatchOffsetOutOfBounds;
            }

            // Read existing instruction
            const insn_ptr: *u32 = @ptrCast(@alignCast(&code_buffer[patch_offset]));
            var insn = std.mem.readInt(u32, @as(*[4]u8, @ptrCast(insn_ptr)), .little);

            // Clear old offset bits (lower 26 bits) and set new offset
            const imm26: u32 = @bitCast(offset_in_insns & 0x03ffffff);
            insn = (insn & 0xfc000000) | imm26;

            // Write back
            std.mem.writeInt(u32, @as(*[4]u8, @ptrCast(insn_ptr)), insn, .little);
        },
        .unsupported => return error.UnsupportedArchitecture,
    }
}

// Base JIT compiler
pub const Jit = struct {
    vm: *FactorVM,
    owner: Cell, // Tagged pointer to word or quotation
    code: std.ArrayList(u8),
    relocation: std.ArrayList(u8),
    parameters: growable.GrowableArray,
    literals: growable.GrowableArray,
    label_manager: LabelManager,

    // For offset computation (debugging/source mapping)
    computing_offset_p: bool,
    position: i64,
    offset: u64,

    const Self = @This();

    pub fn init(vm: *FactorVM, owner: Cell) Self {
        // Increment current_jit_count (matches C++ jit::jit constructor)
        std.debug.assert(vm.current_jit_count >= 0);
        vm.current_jit_count += 1;

        // Pre-ensure nursery space for BOTH GrowableArray backing arrays.
        // Without this, the second allotUninitializedArray could trigger GC,
        // moving the first array before it can be rooted (the struct is
        // returned by value, so registerRoot() happens only after init).
        // In C++, data_root<array> in growable_array ctor roots each array
        // immediately after allocation; Zig can't do RAII, so we pre-reserve.
        const array_size = layouts.alignCell(
            layouts.arraySize(layouts.Array, 10),
            layouts.data_alignment,
        );
        _ = vm.ensureNurserySpace(array_size * 2);

        const parameters = growable.GrowableArray.init(vm, 10) orelse {
            @panic("JIT.init: failed to allocate parameters growable array");
        };
        const literals = growable.GrowableArray.init(vm, 10) orelse {
            @panic("JIT.init: failed to allocate literals growable array");
        };

        // NOTE: We do NOT register the owner as a GC root here because in Zig,
        // returning Self by value copies the struct. The caller MUST call
        // registerRoot() after the struct is in its final location.
        return Self{
            .vm = vm,
            .owner = owner,
            .code = .{},
            .relocation = .{},
            .parameters = parameters,
            .literals = literals,
            .label_manager = LabelManager.init(vm.allocator),
            .computing_offset_p = false,
            .position = 0,
            .offset = 0,
        };
    }

    /// Register the owner as a GC root. MUST be called after init() when the
    /// struct is in its final location (not before return-by-value copy).
    pub fn registerRoot(self: *Self) void {
        self.vm.data_roots.ensureUnusedCapacity(self.vm.allocator, 3) catch @panic("JIT registerRoot: OOM");
        self.vm.data_roots.appendAssumeCapacity(&self.owner);
        self.vm.data_roots.appendAssumeCapacity(&self.literals.elements);
        self.vm.data_roots.appendAssumeCapacity(&self.parameters.elements);
    }

    pub fn deinit(self: *Self) void {
        // Unregister roots (matches C++ data_root<T> destructors)
        removeRoot(self.vm, &self.owner);
        removeRoot(self.vm, &self.literals.elements);
        removeRoot(self.vm, &self.parameters.elements);

        self.code.deinit(self.vm.allocator);
        self.relocation.deinit(self.vm.allocator);
        self.label_manager.deinit();

        // Decrement current_jit_count (matches C++ jit::~jit destructor)
        std.debug.assert(self.vm.current_jit_count >= 1);
        self.vm.current_jit_count -= 1;
    }

    // Get a template from special_objects by enum
    fn getTemplate(self: *const Self, template: JitTemplate) ?*const layouts.Array {
        const template_cell = self.vm.vm_asm.special_objects[@intFromEnum(template)];
        return getArrayFromCell(template_cell);
    }

    // Get a template array from a cell value
    fn getArrayFromCell(template_cell: Cell) ?*const layouts.Array {
        if (template_cell == layouts.false_object) {
            return null;
        }
        std.debug.assert(layouts.hasTag(template_cell, .array));
        return @as(*const layouts.Array, @ptrFromInt(layouts.UNTAG(template_cell)));
    }

    // Emit a template by enum (append its relocation info and machine code)
    pub fn emit(self: *Self, template: JitTemplate) !void {
        var template_cell = self.vm.vm_asm.special_objects[@intFromEnum(template)];
        try self.vm.data_roots.append(self.vm.allocator, &template_cell);
        defer _ = self.vm.data_roots.pop();

        if (getArrayFromCell(template_cell) == null) return;

        try self.emitTemplateCell(template_cell);
    }

    // Emit a raw template array (2-element: {reloc, code})
    pub fn emitRaw(self: *Self, template_cell: Cell) !void {
        try self.emitTemplateCell(template_cell);
    }

    // Emit a template cell (2-element array: { relocation-info, machine-code })
    fn emitTemplateCell(self: *Self, template_cell_: Cell) !void {
        var template_cell = template_cell_;
        try self.vm.data_roots.append(self.vm.allocator, &template_cell);
        defer _ = self.vm.data_roots.pop();

        const tmpl = getArrayFromCell(template_cell) orelse return;
        if (layouts.untagFixnumUnsigned(tmpl.capacity) < 2) return;

        const data = tmpl.data();

        // Emit relocation info
        try self.emitRelocation(data[0]);

        // Re-derive template after relocation in case GC moved it
        const tmpl_after = getArrayFromCell(template_cell) orelse return;
        if (layouts.untagFixnumUnsigned(tmpl_after.capacity) < 2) return;
        const data_after = tmpl_after.data();
        const code_cell = data_after[1];

        // Handle offset computation for source mapping (matches C++)
        if (self.computing_offset_p) {
            if (code_cell != layouts.false_object and
                layouts.hasTag(code_cell, .byte_array))
            {
                const ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(code_cell));
                const size = layouts.untagFixnumUnsigned(ba.capacity);

                if (self.offset == 0) {
                    self.position -= 1;
                    self.computing_offset_p = false;
                } else if (self.offset < size) {
                    self.position += 1;
                    self.computing_offset_p = false;
                } else {
                    self.offset -= size;
                }
            }
        }

        // Emit machine code
        try self.emitCode(code_cell);
    }

    // Matches C++ jit::emit_with_literal in vm/jit.cpp
    pub fn emitWithLiteral(self: *Self, template: JitTemplate, lit: Cell) !void {
        // Protect literal from GC during allocation (matches C++ data_root<object> argument)
        var lit_copy = lit;
        try self.vm.data_roots.append(self.vm.allocator, &lit_copy);
        defer _ = self.vm.data_roots.pop();

        try self.literal(lit_copy);
        try self.emit(template);
    }

    // Matches C++ jit::emit_with_parameter in vm/jit.cpp
    pub fn emitWithParameter(self: *Self, template: JitTemplate, param: Cell) !void {
        // Protect parameter from GC during allocation (matches C++ data_root<object> argument)
        var param_copy = param;
        try self.vm.data_roots.append(self.vm.allocator, &param_copy);
        defer _ = self.vm.data_roots.pop();

        try self.parameter(param_copy);
        try self.emit(template);
    }

    // Push a literal onto the data stack (emits code to push at runtime)
    // This is different from literal() which just adds to the literals array
    pub fn push(self: *Self, value: Cell) !void {
        try self.emitWithLiteral(.push_literal, value);
    }

    // Add a literal for relocation
    pub fn literal(self: *Self, value: Cell) !void {
        if (!self.literals.add(value)) {
            return error.OutOfMemory;
        }
    }

    // Add a parameter for relocation
    pub fn parameter(self: *Self, value: Cell) !void {
        if (!self.parameters.add(value)) {
            return error.OutOfMemory;
        }
    }

    // Append values from a Factor array to parameters
    pub fn appendParameters(self: *Self, arr_cell: Cell) !void {
        var root = arr_cell;
        try self.vm.data_roots.append(self.vm.allocator, &root);
        defer _ = self.vm.data_roots.pop();

        if (root == layouts.false_object) return;
        std.debug.assert(layouts.hasTag(root, .array));
        if (!self.parameters.append(root)) {
            return error.OutOfMemory;
        }
    }

    // Append values from a Factor array to literals
    pub fn appendLiterals(self: *Self, arr_cell: Cell) !void {
        var root = arr_cell;
        try self.vm.data_roots.append(self.vm.allocator, &root);
        defer _ = self.vm.data_roots.pop();

        if (root == layouts.false_object) return;
        std.debug.assert(layouts.hasTag(root, .array));
        if (!self.literals.append(root)) {
            return error.OutOfMemory;
        }
    }

    // Emit a subprimitive (word with subprimitive slot containing template)
    // The subprimitive slot contains a 5-element array:
    //   [0] = parameters array
    //   [1] = literals array
    //   [2] = main code template
    //   [3] = call continuation (for non-tail calls)
    //   [4] = tail continuation (for tail calls)
    // Returns true if this was a tail call (no further code needed)
    pub fn emitSubprimitive(self: *Self, word_cell: Cell, tail_call_p: bool, stack_frame_p: bool) !bool {
        // Root the word (matches C++ data_root<word>)
        var word_root = word_cell;
        try self.vm.data_roots.append(self.vm.allocator, &word_root);
        defer _ = self.vm.data_roots.pop();

        std.debug.assert(layouts.hasTag(word_root, .word));
        const word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(word_root));

        // Root the subprimitive template array (matches C++ data_root<array>)
        var subprim_root = word.subprimitive;
        try self.vm.data_roots.append(self.vm.allocator, &subprim_root);
        defer _ = self.vm.data_roots.pop();

        if (subprim_root == layouts.false_object) return false;
        std.debug.assert(layouts.hasTag(subprim_root, .array));
        const code_template: *const layouts.Array = @ptrFromInt(layouts.UNTAG(subprim_root));
        const cap = layouts.untagFixnumUnsigned(code_template.capacity);

        if (cap < 3) {
            return false;
        }

        // Append parameters from template[0]
        {
            const tmpl: *const layouts.Array = @ptrFromInt(layouts.UNTAG(subprim_root));
            const data = tmpl.data();
            if (data[0] != layouts.false_object and
                layouts.hasTag(data[0], .array))
            {
                try self.appendParameters(data[0]);
            }
        }

        // Append literals from template[1]
        {
            const tmpl: *const layouts.Array = @ptrFromInt(layouts.UNTAG(subprim_root));
            const data = tmpl.data();
            if (data[1] != layouts.false_object and
                layouts.hasTag(data[1], .array))
            {
                try self.appendLiterals(data[1]);
            }
        }

        // Emit main code from template[2]
        {
            const tmpl: *const layouts.Array = @ptrFromInt(layouts.UNTAG(subprim_root));
            const data = tmpl.data();
            try self.emitRaw(data[2]);
        }

        // If template has 5 elements, emit continuation code
        if (cap == 5) {
            if (tail_call_p) {
                // Emit epilog before tail continuation if stack frame exists
                if (stack_frame_p) {
                    try self.emit(.epilog);
                }
                // Emit tail continuation from template[4]
                const tmpl: *const layouts.Array = @ptrFromInt(layouts.UNTAG(subprim_root));
                const data = tmpl.data();
                try self.emitRaw(data[4]);
                return true;
            } else {
                // Emit call continuation from template[3]
                const tmpl: *const layouts.Array = @ptrFromInt(layouts.UNTAG(subprim_root));
                const data = tmpl.data();
                try self.emitRaw(data[3]);
            }
        }
        return false;
    }

    // Emit relocation entries
    fn emitRelocation(self: *Self, reloc_cell: Cell) !void {
        // No GC root needed: appendSlice uses system allocator, not Factor heap
        if (reloc_cell == layouts.false_object) return;
        std.debug.assert(layouts.hasTag(reloc_cell, .byte_array));

        const ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(reloc_cell));
        const reloc_data = ba.data();
        const reloc_size = layouts.untagFixnumUnsigned(ba.capacity);

        // Each relocation entry is 4 bytes
        const entry_count = reloc_size / @sizeOf(code_blocks.RelocationEntry);
        const current_offset = self.code.items.len;

        // Adjust relocation offsets and append
        for (0..entry_count) |i| {
            const entry_bytes = reloc_data[i * 4 .. (i + 1) * 4];
            var entry: code_blocks.RelocationEntry = @bitCast(entry_bytes[0..4].*);

            // Adjust offset to account for code already emitted
            const new_offset = entry.getOffset() + @as(u24, @intCast(current_offset));
            entry = code_blocks.RelocationEntry.init(
                entry.getType(),
                entry.getClass(),
                new_offset,
            );

            const entry_u32: u32 = @bitCast(entry);
            try self.relocation.appendSlice(self.vm.allocator, std.mem.asBytes(&entry_u32));
        }
    }

    // Emit machine code
    fn emitCode(self: *Self, code_cell: Cell) !void {
        // No GC root needed: appendSlice uses system allocator, not Factor heap
        if (code_cell == layouts.false_object) return;
        std.debug.assert(layouts.hasTag(code_cell, .byte_array));

        const ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(code_cell));
        const code_data = ba.data();
        const code_size = layouts.untagFixnumUnsigned(ba.capacity);

        try self.code.appendSlice(self.vm.allocator, code_data[0..code_size]);
    }

    pub fn codeSize(self: *const Self) usize {
        return self.code.items.len;
    }

    // Set position for source mapping
    pub fn setPosition(self: *Self, pos: i64) void {
        if (self.computing_offset_p) {
            self.position = pos;
        }
    }

    // Get current position
    pub fn getPosition(self: *const Self) i64 {
        return self.position;
    }

    // Compute position from code offset (for debugging)
    pub fn computePosition(self: *Self, offset_: u64) void {
        self.computing_offset_p = true;
        self.position = 0;
        self.offset = offset_;
    }

    // =============================================================================
    // Label manipulation methods
    // =============================================================================

    pub fn makeLabel(self: *Self) !usize {
        return try self.label_manager.makeLabel();
    }

    pub fn defineLabel(self: *Self, label_id: usize) !void {
        const current_pos = self.code.items.len;
        try self.label_manager.defineLabel(label_id, current_pos);
    }

    // Emit a jump to a label (forward or backward)
    pub fn emitJumpToLabel(self: *Self, label_id: usize, rel_class: code_blocks.RelocationClass) !void {
        const current_pos = self.code.items.len;

        if (self.label_manager.isLabelDefined(label_id)) {
            // Backward jump - label is already defined
            const target_pos = self.label_manager.getLabelPosition(label_id) orelse return error.UndefinedLabel;
            try self.emitJumpDirect(target_pos);
        } else {
            // Forward jump - emit placeholder and record fixup
            const patch_offset = current_pos;
            try self.emitJumpPlaceholder();
            try self.label_manager.addForwardRef(label_id, patch_offset, rel_class);
        }
    }

    // Emit a call to a label (forward or backward)
    pub fn emitCallToLabel(self: *Self, label_id: usize, rel_class: code_blocks.RelocationClass) !void {
        const current_pos = self.code.items.len;

        if (self.label_manager.isLabelDefined(label_id)) {
            // Backward call - label is already defined
            const target_pos = self.label_manager.getLabelPosition(label_id) orelse return error.UndefinedLabel;
            try self.emitCallDirect(target_pos);
        } else {
            // Forward call - emit placeholder and record fixup
            const patch_offset = current_pos;
            try self.emitCallPlaceholder();
            try self.label_manager.addForwardRef(label_id, patch_offset, rel_class);
        }
    }

    fn emitJumpDirect(self: *Self, target_pos: usize) !void {
        const current_pos = self.code.items.len;
        const arch = cpu.Arch.current();

        switch (arch) {
            .x86_64 => {
                const insn_end = current_pos + 5; // JMP is 5 bytes
                const rel_offset: i32 = @intCast(@as(i64, @intCast(target_pos)) - @as(i64, @intCast(insn_end)));
                try cpu.X86Instruction.encodeJump(self.vm.allocator, &self.code, rel_offset);
            },
            .aarch64 => {
                const offset_in_bytes: i32 = @intCast(@as(i64, @intCast(target_pos)) - @as(i64, @intCast(current_pos)));
                try cpu.ARM64Instruction.encodeJump(self.vm.allocator, &self.code, offset_in_bytes);
            },
            .unsupported => return error.UnsupportedArchitecture,
        }
    }

    fn emitCallDirect(self: *Self, target_pos: usize) !void {
        const current_pos = self.code.items.len;
        const arch = cpu.Arch.current();

        switch (arch) {
            .x86_64 => {
                const insn_end = current_pos + 5; // CALL is 5 bytes
                const rel_offset: i32 = @intCast(@as(i64, @intCast(target_pos)) - @as(i64, @intCast(insn_end)));
                try cpu.X86Instruction.encodeCall(self.vm.allocator, &self.code, rel_offset);
            },
            .aarch64 => {
                const offset_in_bytes: i32 = @intCast(@as(i64, @intCast(target_pos)) - @as(i64, @intCast(current_pos)));
                try cpu.ARM64Instruction.encodeCall(self.vm.allocator, &self.code, offset_in_bytes);
            },
            .unsupported => return error.UnsupportedArchitecture,
        }
    }

    fn emitJumpPlaceholder(self: *Self) !void {
        const arch = cpu.Arch.current();

        switch (arch) {
            .x86_64 => {
                // JMP rel32: E9 [4-byte offset]
                try self.code.append(self.vm.allocator, cpu.X86Instruction.JMP_OPCODE);
                try self.code.appendSlice(self.vm.allocator, &[_]u8{ 0, 0, 0, 0 }); // Placeholder offset
            },
            .aarch64 => {
                // B #0 (branch to self, will be patched)
                const insn: u32 = (0b0 << 31) | (0b00101 << 26) | 0; // B with offset 0
                var bytes: [4]u8 = undefined;
                std.mem.writeInt(u32, &bytes, insn, .little);
                try self.code.appendSlice(self.vm.allocator, &bytes);
            },
            .unsupported => return error.UnsupportedArchitecture,
        }
    }

    fn emitCallPlaceholder(self: *Self) !void {
        const arch = cpu.Arch.current();

        switch (arch) {
            .x86_64 => {
                // CALL rel32: E8 [4-byte offset]
                try self.code.append(self.vm.allocator, cpu.X86Instruction.CALL_OPCODE);
                try self.code.appendSlice(self.vm.allocator, &[_]u8{ 0, 0, 0, 0 }); // Placeholder offset
            },
            .aarch64 => {
                // BL #0 (branch with link to self, will be patched)
                const insn: u32 = (0b1 << 31) | (0b00101 << 26) | 0; // BL with offset 0
                var bytes: [4]u8 = undefined;
                std.mem.writeInt(u32, &bytes, insn, .little);
                try self.code.appendSlice(self.vm.allocator, &bytes);
            },
            .unsupported => return error.UnsupportedArchitecture,
        }
    }

    pub fn fixupLabels(self: *Self) !std.ArrayList(Cell) {
        return try self.label_manager.fixupLabels(self.code.items);
    }

    // Compile to a code block
    // frame_size: Stack frame size (must be multiple of 16, max 0xFF0)
    pub fn toCodeBlock(self: *Self, block_type: code_blocks.CodeBlockType, frame_size: Cell) !?*code_blocks.CodeBlock {
        // Add GC info padding (dummy for non-optimizing compiler)
        const alignment = layouts.data_alignment;
        const padding = layouts.alignCell(self.code.items.len + 4, alignment) - self.code.items.len - 4;
        for (0..padding) |_| {
            try self.code.append(self.vm.allocator, 0);
        }
        // Append dummy GC info (4 bytes of zeros)
        try self.code.appendSlice(self.vm.allocator, &[_]u8{ 0, 0, 0, 0 });

        // Trim parameter/literal arrays to exact size (matches C++)
        if (!self.parameters.trim()) @panic("OOM trimming parameters");
        if (!self.literals.trim()) @panic("OOM trimming literals");

        // Calculate total size needed
        const header_size = @sizeOf(code_blocks.CodeBlock);
        const code_size = self.code.items.len;
        const total_size = layouts.alignCell(header_size + code_size, alignment);

        // Allocate from code heap, triggering compaction if full
        const block = self.vm.allotCodeBlock(total_size);

        // Initialize the code block header
        block.initialize(block_type, total_size, frame_size);
        block.owner = self.owner;

        // validateFreeList checkpoints removed (root cause: non-contiguous heap fixed)

        // CRITICAL: Allocate all nursery objects FIRST, rooting them to protect from GC.
        // Then store them into the code block only after all allocations are complete.
        // This prevents stale pointers if GC moves objects during allocation.

        // Allocate relocation byte array (rooted)
        var reloc_cell: Cell = layouts.false_object;
        if (self.relocation.items.len > 0) {
            reloc_cell = self.vm.allotByteArray(self.relocation.items.len);
            if (reloc_cell == layouts.false_object) @panic("OOM allocating relocation byte array");
            const reloc_ba: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(reloc_cell));
            @memcpy(reloc_ba.data()[0..self.relocation.items.len], self.relocation.items);
        }
        // Root reloc_cell to protect from GC during subsequent allocations
        try self.vm.data_roots.append(self.vm.allocator, &reloc_cell);
        defer _ = self.vm.data_roots.pop();

        const params_cell = self.parameters.toArray();
        const literals_cell = self.literals.toArray();

        // NOW store into code block - all allocations complete, values are final
        block.relocation = reloc_cell;
        block.parameters = params_cell;

        // Copy machine code
        const code_dest = block.codeStart();
        @memcpy(code_dest[0..code_size], self.code.items);

        // Defer initialization: add to uninitialized_blocks (matching C++ add_code_block).
        // The caller (jitCompileQuotationWithOwner, inline cache, etc.) decides whether
        // to initialize immediately (relocate=true) or defer to updateCodeHeapWords.
        if (self.vm.code) |ch| {
            ch.putUninitializedBlock(self.vm.allocator, @intFromPtr(block), literals_cell) catch {
                // Fallback: initialize immediately if map insertion fails
                self.vm.initializeCodeBlock(@ptrCast(block), literals_cell);
            };
        } else {
            self.vm.initializeCodeBlock(@ptrCast(block), literals_cell);
        }

        return block;
    }
};

// Stack frame size constants
pub const JIT_FRAME_SIZE: Cell = 32; // Standard JIT frame size
pub const SIGNAL_HANDLER_STACK_FRAME_SIZE: Cell = 192; // Signal handler frame size

// Quotation-specific JIT compiler
// This implements the non-optimizing compiler that compiles quotations by
// concatenating pre-assembled machine code chunks from subprimitive templates.
pub const QuotationJit = struct {
    jit: Jit,
    elements: Cell, // Tagged array
    compiling: bool,
    relocate: bool,

    const Self = @This();

    pub fn init(vm: *FactorVM, owner: Cell, compiling: bool, relocate: bool) Self {
        // NOTE: jit.registerRoot() is NOT called here because this struct
        // will be returned by value (copied). The caller MUST call registerRoot()
        // after this struct is in its final location.
        return Self{
            .jit = Jit.init(vm, owner),
            .elements = layouts.false_object,
            .compiling = compiling,
            .relocate = relocate,
        };
    }

    /// Register the owner as a GC root. MUST be called after init() when the
    /// struct is in its final location.
    pub fn registerRoot(self: *Self) void {
        // Batch ensure capacity for all 4 roots (3 from Jit + 1 for elements)
        self.jit.vm.data_roots.ensureUnusedCapacity(self.jit.vm.allocator, 4) catch @panic("QuotationJit registerRoot: OOM");
        self.jit.vm.data_roots.appendAssumeCapacity(&self.jit.owner);
        self.jit.vm.data_roots.appendAssumeCapacity(&self.jit.literals.elements);
        self.jit.vm.data_roots.appendAssumeCapacity(&self.jit.parameters.elements);
        self.jit.vm.data_roots.appendAssumeCapacity(&self.elements);
    }

    pub fn deinit(self: *Self) void {
        removeRoot(self.jit.vm, &self.elements);
        self.jit.deinit();
    }

    // Initialize with quotation's array
    // Matches C++ quotation_jit::init_quotation: direct untag, no tag check.
    pub fn initQuotation(self: *Self, quot_cell: Cell) void {
        std.debug.assert(layouts.hasTag(quot_cell, .quotation));
        const quot: *const layouts.Quotation = @ptrFromInt(layouts.UNTAG(quot_cell));
        self.elements = quot.array;
    }

    // Get element at index from quotation array
    // Matches C++ quotation_jit::nth: array_nth(elements, index) with FACTOR_ASSERT only.
    fn nth(self: *const Self, index: Cell) Cell {
        std.debug.assert(self.elements != layouts.false_object);
        std.debug.assert(layouts.hasTag(self.elements, .array));
        const arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(self.elements));
        std.debug.assert(index < layouts.untagFixnumUnsigned(arr.capacity));
        return arr.data()[index];
    }

    // Get array length
    // Matches C++ array_capacity(elements.untagged()): direct untag, no checks.
    fn length(self: *const Self) Cell {
        std.debug.assert(self.elements != layouts.false_object);
        std.debug.assert(layouts.hasTag(self.elements, .array));
        const arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(self.elements));
        return layouts.untagFixnumUnsigned(arr.capacity);
    }

    // Check for fast-if pattern: [ true-quot ] [ false-quot ] if
    fn isFastIf(self: *const Self, i: Cell, len: Cell) bool {
        if (i + 3 != len) return false;
        if (!layouts.hasTag(self.nth(i + 1), .quotation)) return false;
        const if_word = self.jit.vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.jit_if_word)];
        return self.nth(i + 2) == if_word;
    }

    // Check for primitive call pattern: byte-array primitive
    fn isPrimitiveCall(self: *const Self, i: Cell, len: Cell) bool {
        const prim_word = self.jit.vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.jit_primitive_word)];
        return (i + 2) <= len and self.nth(i + 1) == prim_word;
    }

    // Check for dip pattern: [ quot ] dip
    fn isFastDip(self: *const Self, i: Cell, len: Cell) bool {
        const dip_word = self.jit.vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.jit_dip_word)];
        return (i + 2) <= len and self.nth(i + 1) == dip_word;
    }

    // Check for 2dip pattern: [ quot ] 2dip
    fn isFast2Dip(self: *const Self, i: Cell, len: Cell) bool {
        const dip2_word = self.jit.vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.jit_2dip_word)];
        return (i + 2) <= len and self.nth(i + 1) == dip2_word;
    }

    // Check for 3dip pattern: [ quot ] 3dip
    fn isFast3Dip(self: *const Self, i: Cell, len: Cell) bool {
        const dip3_word = self.jit.vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.jit_3dip_word)];
        return (i + 2) <= len and self.nth(i + 1) == dip3_word;
    }

    // Check for declare pattern: { decl } declare
    fn isDeclare(self: *const Self, i: Cell, len: Cell) bool {
        const declare_word = self.jit.vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.jit_declare_word)];
        return (i + 2) <= len and self.nth(i + 1) == declare_word;
    }

    // Check for mega lookup pattern: methods index cache mega-lookup
    fn isMegaLookup(self: *const Self, i: Cell, len: Cell) bool {
        if (i + 4 > len) return false;
        if (!layouts.hasTag(self.nth(i + 1), .fixnum)) return false;
        if (!layouts.hasTag(self.nth(i + 2), .array)) return false;
        const mega_word = self.jit.vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.mega_lookup_word)];
        return self.nth(i + 3) == mega_word;
    }

    // Check if word is a special subprimitive (signal handlers, unwinders)
    fn isSpecialSubprimitive(self: *const Self, obj: Cell) bool {
        const signal_handler = self.jit.vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.signal_handler_word)];
        const leaf_signal = self.jit.vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.leaf_signal_handler_word)];
        const unwind = self.jit.vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.unwind_native_frames_word)];
        return obj == signal_handler or obj == leaf_signal or obj == unwind;
    }

    // Check if quotation needs a stack frame
    // All quotations want a stack frame, except if they contain:
    //   1) calls to the special subprimitives
    //   2) mega cache lookups
    fn hasStackFrame(self: *const Self) bool {
        const len = self.length();
        for (0..len) |i| {
            const obj = self.nth(i);
            const tag = layouts.typeTag(obj);
            if (tag == .word and self.isSpecialSubprimitive(obj)) {
                return false;
            }
            if (tag == .array and self.isMegaLookup(i, len)) {
                return false;
            }
        }
        return true;
    }

    // Emit epilog if needed
    fn emitEpilog(self: *Self, needed: bool) !void {
        if (needed) {
            try self.jit.emit(.safepoint);
            try self.jit.emit(.epilog);
        }
    }

    // Emit a quotation reference (compile if needed)
    // Matches C++ quotation_jit::emit_quotation which uses data_root<quotation>
    fn emitQuotation(self: *Self, quot_cell: Cell) !void {
        std.debug.assert(layouts.hasTag(quot_cell, .quotation));

        // CRITICAL: Root the quotation before any operation that can trigger GC.
        // jitCompileQuotation (called below) can trigger nursery GC, moving
        // this quotation.  Without rooting, the stale quot_cell would be
        // embedded as a literal in the parent code block, causing crashes
        // when the compiled code later dereferences it.
        // Matches C++: data_root<quotation> quot(quot_, parent);
        var rooted_quot = quot_cell;
        self.jit.vm.data_roots.append(self.jit.vm.allocator, &rooted_quot) catch return error.OutOfMemory;
        defer _ = self.jit.vm.data_roots.pop();

        const quot: *const layouts.Quotation = @ptrFromInt(layouts.UNTAG(rooted_quot));

        // Get the quotation's array
        if (quot.array == layouts.false_object) {
            try self.jit.literal(rooted_quot);
            return;
        }

        const arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(quot.array));

        // If quotation is trivial (single word), compile direct call
        if (layouts.untagFixnumUnsigned(arr.capacity) == 1) {
            const first = arr.data()[0];
            if (layouts.hasTag(first, .word)) {
                try self.jit.literal(first);
                return;
            }
        }

        // Non-trivial quotation - compile it if compiling mode
        if (self.compiling) {
            self.jit.vm.jitCompileQuotation(rooted_quot, self.relocate);
        }

        // Use rooted_quot which tracks GC moves
        try self.jit.literal(rooted_quot);
    }

    // Main iteration over quotation elements
    pub fn iterateQuotation(self: *Self) !void {
        const stack_frame = self.hasStackFrame();

        self.jit.setPosition(0);

        // Emit prolog if needed
        if (stack_frame) {
            try self.jit.emit(.safepoint);
            try self.jit.emit(.prolog);
        }

        const len = self.length();
        var tail_call = false;

        var i: Cell = 0;
        while (i < len) : (i += 1) {
            self.jit.setPosition(@intCast(i));
            const obj = self.nth(i);
            const tag = layouts.typeTag(obj);

            switch (tag) {
                .word => {
                    const word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(obj));
                    // Check for subprimitive
                    if (word.subprimitive != layouts.false_object) {
                        tail_call = try self.jit.emitSubprimitive(obj, i == len - 1, stack_frame);
                    } else if (i == len - 1) {
                        // Tail position - emit jump
                        try self.emitEpilog(stack_frame);
                        tail_call = true;
                        try self.wordJump(obj);
                    } else {
                        // Non-tail position - emit call
                        try self.wordCall(obj);
                    }
                },
                .wrapper => {
                    // Push wrapped object
                    const wrapper: *const layouts.Wrapper = @ptrFromInt(layouts.UNTAG(obj));
                    try self.push(wrapper.object);
                },
                .byte_array => {
                    // Check for primitive call pattern
                    if (self.isPrimitiveCall(i, len)) {
                        // 32-bit x86 jit-load-vm emits rel-vm relocation
                        // needing an extra VM offset parameter. C++ guards
                        // this with #ifdef FACTOR_X86 (32-bit only, NOT
                        // FACTOR_AMD64). On x86-64 and ARM64 the VM pointer
                        // lives in a register, so no extra parameter.
                        if (comptime cpu.Arch.current() == .x86) {
                            try self.jit.parameter(layouts.tagFixnum(0));
                        }
                        try self.jit.parameter(obj);
                        try self.jit.parameter(layouts.false_object);
                        try self.jit.emit(.primitive);
                        i += 1; // Skip the primitive word
                    } else {
                        try self.push(obj);
                    }
                },
                .quotation => {
                    // Check for fast-if pattern: [ true ] [ false ] if
                    if (self.isFastIf(i, len)) {
                        try self.emitEpilog(stack_frame);
                        tail_call = true;
                        try self.emitQuotation(self.nth(i));
                        try self.emitQuotation(self.nth(i + 1));
                        try self.jit.emit(.jit_if);
                        i += 2;
                    }
                    // Check for dip patterns
                    else if (self.isFastDip(i, len)) {
                        try self.emitQuotation(obj);
                        try self.jit.emit(.dip);
                        i += 1;
                    } else if (self.isFast2Dip(i, len)) {
                        try self.emitQuotation(obj);
                        try self.jit.emit(.two_dip);
                        i += 1;
                    } else if (self.isFast3Dip(i, len)) {
                        try self.emitQuotation(obj);
                        try self.jit.emit(.three_dip);
                        i += 1;
                    } else {
                        try self.push(obj);
                    }
                },
                .array => {
                    // Check for mega lookup pattern
                    if (self.isMegaLookup(i, len)) {
                        tail_call = true;
                        try self.emitMegaCacheLookup(
                            self.nth(i),
                            layouts.untagFixnum(self.nth(i + 1)),
                            self.nth(i + 2),
                        );
                        i += 3;
                    }
                    // Check for declare pattern (ignore declarations)
                    else if (self.isDeclare(i, len)) {
                        i += 1;
                    } else {
                        try self.push(obj);
                    }
                },
                else => {
                    try self.push(obj);
                },
            }
        }

        // Emit return if no tail call was made
        if (!tail_call) {
            self.jit.setPosition(@intCast(len));
            try self.emitEpilog(stack_frame);
            try self.jit.emit(.return_template);
        }
    }

    // Push a literal onto the data stack
    // Matches C++ jit::push in vm/jit.hpp
    fn push(self: *Self, value: Cell) !void {
        try self.jit.emitWithLiteral(.push_literal, value);
    }

    // Emit word call
    // Matches C++ quotation_jit::word_call in vm/quotations.hpp
    fn wordCall(self: *Self, word_cell: Cell) !void {
        try self.jit.emitWithLiteral(.word_call, word_cell);
    }

    // Emit word jump (tail call)
    // Matches C++ quotation_jit::word_jump in vm/quotations.hpp
    fn wordJump(self: *Self, word_cell: Cell) !void {
        // On 32-bit platforms, emit an extra literal for xt_tail_pic_offset
        // This matches the C++ code: #ifndef FACTOR_64
        const is_64bit = @sizeOf(Cell) == 8;
        if (!is_64bit) {
            // xt_tail_pic_offset = 4 + 1 on x86 family, 4 on PPC (from vm/cpu-*.hpp)
            const xt_tail_pic_offset: Fixnum = if (comptime cpu.Arch.current().isX86Family()) 5 else 4;
            try self.jit.literal(layouts.tagFixnum(xt_tail_pic_offset));
        }
        try self.jit.literal(word_cell);
        try self.jit.emit(.word_jump);
    }

    // Emit mega cache lookup
    // Matches C++ quotation_jit::emit_mega_cache_lookup which uses
    // data_root<array> for both methods and cache
    fn emitMegaCacheLookup(self: *Self, methods_in: Cell, index: Fixnum, cache_in: Cell) !void {
        const vm = self.jit.vm;

        // Root methods and cache to protect from GC during code emission.
        // emitWithLiteral, push, and wordCall can all trigger nursery GC.
        var methods = methods_in;
        var cache = cache_in;
        try vm.data_roots.ensureUnusedCapacity(vm.allocator, 2);
        vm.data_roots.appendAssumeCapacity(&methods);
        defer _ = vm.data_roots.pop();
        vm.data_roots.appendAssumeCapacity(&cache);
        defer _ = vm.data_roots.pop();

        // Load object from datastack at offset
        const offset = layouts.tagFixnum(-index * @as(Fixnum, @sizeOf(Cell)));
        try self.jit.emitWithLiteral(.pic_load, offset);

        // Do cache lookup
        try self.jit.emitWithLiteral(.mega_lookup, cache);

        // Cache miss path
        try self.jit.emit(.prolog);
        try self.push(methods);
        try self.push(layouts.tagFixnum(index));
        try self.push(cache);
        const mega_miss = vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.mega_miss_word)];
        try self.wordCall(mega_miss);
        try self.jit.emit(.epilog);
        try self.jit.emit(.execute);
    }

    // Get stack frame size for a word
    pub fn wordStackFrameSize(self: *const Self, obj: Cell) Cell {
        if (self.isSpecialSubprimitive(obj)) {
            return SIGNAL_HANDLER_STACK_FRAME_SIZE;
        }
        return JIT_FRAME_SIZE;
    }

    // Compile to code block
    pub fn toCodeBlock(self: *Self, frame_size: Cell) !?*code_blocks.CodeBlock {
        return try self.jit.toCodeBlock(.unoptimized, frame_size);
    }

    // Get compiled code size
    pub fn codeSize(self: *const Self) usize {
        return self.jit.codeSize();
    }
};

// Check if quotation is compiled (not lazy)
pub fn isQuotationCompiled(vm: *FactorVM, quot: *const layouts.Quotation) bool {
    if (quot.entry_point == 0) return false;
    return quot.entry_point != vm.lazyJitCompileEntryPoint();
}

// Lazy JIT compilation - compile quotation on first use
// Matches C++ lazy_jit_compile (quotations.cpp:357-369)
pub fn lazyJitCompile(vm: *FactorVM, quot_cell: Cell) Cell {
    std.debug.assert(layouts.hasTag(quot_cell, .quotation));

    var rooted_quot = quot_cell;
    vm.data_roots.append(vm.allocator, &rooted_quot) catch return quot_cell;
    defer _ = vm.data_roots.pop();

    var quot: *layouts.Quotation = @ptrFromInt(layouts.UNTAG(rooted_quot));

    if (isQuotationCompiled(vm, quot)) return rooted_quot;

    const compiled = vm.jitCompileQuotationWithOwner(rooted_quot, rooted_quot, true);

    // Re-derive quot from rooted_quot after compilation (GC may have moved it).
    quot = @ptrFromInt(layouts.UNTAG(rooted_quot));

    if (compiled) |cb| {
        quot.entry_point = cb.entryPoint();
    }

    return rooted_quot;
}

// Tests
test "jit byte buffer" {
    const allocator = std.testing.allocator;
    var buf = std.ArrayList(u8){};
    defer buf.deinit(allocator);

    try buf.appendSlice(allocator, &[_]u8{ 1, 2, 3 });
    try buf.append(allocator, 4);

    try std.testing.expectEqual(@as(usize, 4), buf.items.len);
    try std.testing.expectEqualSlices(u8, &[_]u8{ 1, 2, 3, 4 }, buf.items);
}

test "jit cell buffer" {
    const allocator = std.testing.allocator;
    var buf = std.ArrayList(Cell){};
    defer buf.deinit(allocator);

    try buf.append(allocator, 100);
    try buf.append(allocator, 200);

    try std.testing.expectEqual(@as(usize, 2), buf.items.len);
    try std.testing.expectEqualSlices(Cell, &[_]Cell{ 100, 200 }, buf.items);
}

test "label basic operations" {
    var label = Label.init();
    try std.testing.expect(!label.isDefined());
    try std.testing.expectEqual(@as(?usize, null), label.getPosition());

    label.define(100);
    try std.testing.expect(label.isDefined());
    try std.testing.expectEqual(@as(?usize, 100), label.getPosition());
}

test "label manager create and define" {
    const allocator = std.testing.allocator;
    var mgr = LabelManager.init(allocator);
    defer mgr.deinit();

    // Create three labels
    const label1 = try mgr.makeLabel();
    const label2 = try mgr.makeLabel();
    const label3 = try mgr.makeLabel();

    try std.testing.expectEqual(@as(usize, 0), label1);
    try std.testing.expectEqual(@as(usize, 1), label2);
    try std.testing.expectEqual(@as(usize, 2), label3);

    // Initially undefined
    try std.testing.expect(!mgr.isLabelDefined(label1));
    try std.testing.expect(!mgr.isLabelDefined(label2));
    try std.testing.expect(!mgr.isLabelDefined(label3));

    // Define label2
    try mgr.defineLabel(label2, 50);
    try std.testing.expect(!mgr.isLabelDefined(label1));
    try std.testing.expect(mgr.isLabelDefined(label2));
    try std.testing.expect(!mgr.isLabelDefined(label3));
    try std.testing.expectEqual(@as(?usize, 50), mgr.getLabelPosition(label2));
}

test "label manager forward references" {
    const allocator = std.testing.allocator;
    var mgr = LabelManager.init(allocator);
    defer mgr.deinit();

    const label1 = try mgr.makeLabel();
    const label2 = try mgr.makeLabel();

    // Add forward references
    try mgr.addForwardRef(label1, 10, .relative);
    try mgr.addForwardRef(label2, 20, .relative);
    try mgr.addForwardRef(label1, 30, .relative);

    try std.testing.expectEqual(@as(usize, 3), mgr.forward_refs.items.len);
}

test "label fixup with x86_64 jump" {
    if (cpu.Arch.current() != .x86_64) return error.SkipZigTest;

    const allocator = std.testing.allocator;
    var mgr = LabelManager.init(allocator);
    defer mgr.deinit();

    // Create a code buffer with a forward jump
    var code_buffer = std.ArrayList(u8){};
    defer code_buffer.deinit(allocator);

    // Emit some padding
    try code_buffer.appendSlice(allocator, &[_]u8{ 0x90, 0x90, 0x90 }); // NOP instructions

    // Emit jump placeholder at offset 3
    const jump_offset = code_buffer.items.len;
    try code_buffer.append(allocator, cpu.X86Instruction.JMP_OPCODE); // JMP opcode
    try code_buffer.appendSlice(allocator, &[_]u8{ 0x00, 0x00, 0x00, 0x00 }); // Placeholder

    // Emit more code
    try code_buffer.appendSlice(allocator, &[_]u8{ 0x90, 0x90, 0x90, 0x90, 0x90 }); // More NOPs

    // Define the target at offset 13
    const target_offset = code_buffer.items.len;

    // Create label and forward reference
    const label_id = try mgr.makeLabel();
    try mgr.addForwardRef(label_id, jump_offset, .relative);
    try mgr.defineLabel(label_id, target_offset);

    // Fixup
    var fixups = try mgr.fixupLabels(code_buffer.items);
    defer fixups.deinit(allocator);

    // Verify the jump offset was patched correctly
    // Jump at offset 3, instruction ends at 8, target is 13, so offset should be 5
    const expected_offset: i32 = 5;
    const actual_offset = std.mem.readInt(i32, code_buffer.items[jump_offset + 1 ..][0..4], .little);
    try std.testing.expectEqual(expected_offset, actual_offset);

    // Verify fixup metadata
    try std.testing.expectEqual(@as(usize, 3), fixups.items.len); // 3 cells: class, offset, target
}

test "label backward reference" {
    if (cpu.Arch.current() != .x86_64) return error.SkipZigTest;

    const allocator = std.testing.allocator;
    var mgr = LabelManager.init(allocator);
    defer mgr.deinit();

    // Create label and define it at position 0
    const label_id = try mgr.makeLabel();
    try mgr.defineLabel(label_id, 0);

    // Verify it's defined
    try std.testing.expect(mgr.isLabelDefined(label_id));
    try std.testing.expectEqual(@as(?usize, 0), mgr.getLabelPosition(label_id));
}

test "label multiple forward references to same label" {
    if (cpu.Arch.current() != .x86_64) return error.SkipZigTest;

    const allocator = std.testing.allocator;
    var mgr = LabelManager.init(allocator);
    defer mgr.deinit();

    var code_buffer = std.ArrayList(u8){};
    defer code_buffer.deinit(allocator);

    // Create one label
    const label_id = try mgr.makeLabel();

    // Emit two jumps to the same label
    const jump1_offset = code_buffer.items.len;
    try code_buffer.append(allocator, cpu.X86Instruction.JMP_OPCODE);
    try code_buffer.appendSlice(allocator, &[_]u8{ 0x00, 0x00, 0x00, 0x00 });
    try mgr.addForwardRef(label_id, jump1_offset, .relative);

    try code_buffer.appendSlice(allocator, &[_]u8{ 0x90, 0x90 }); // Padding

    const jump2_offset = code_buffer.items.len;
    try code_buffer.append(allocator, cpu.X86Instruction.JMP_OPCODE);
    try code_buffer.appendSlice(allocator, &[_]u8{ 0x00, 0x00, 0x00, 0x00 });
    try mgr.addForwardRef(label_id, jump2_offset, .relative);

    try code_buffer.appendSlice(allocator, &[_]u8{ 0x90, 0x90 }); // Padding

    // Define the target
    const target_offset = code_buffer.items.len;
    try mgr.defineLabel(label_id, target_offset);

    // Fixup
    var fixups = try mgr.fixupLabels(code_buffer.items);
    defer fixups.deinit(allocator);

    // Both jumps should be patched
    // First jump: ends at 5, target at 14, offset = 9
    const offset1 = std.mem.readInt(i32, code_buffer.items[jump1_offset + 1 ..][0..4], .little);
    try std.testing.expectEqual(@as(i32, 9), offset1);

    // Second jump: ends at 12, target at 14, offset = 2
    const offset2 = std.mem.readInt(i32, code_buffer.items[jump2_offset + 1 ..][0..4], .little);
    try std.testing.expectEqual(@as(i32, 2), offset2);

    // Should have 6 fixup cells (2 fixups * 3 cells each)
    try std.testing.expectEqual(@as(usize, 6), fixups.items.len);
}

test "undefined label error" {
    const allocator = std.testing.allocator;
    var mgr = LabelManager.init(allocator);
    defer mgr.deinit();

    var code_buffer = std.ArrayList(u8){};
    defer code_buffer.deinit(allocator);

    // Create a label but don't define it
    const label_id = try mgr.makeLabel();

    // Add a forward reference
    try code_buffer.append(allocator, cpu.X86Instruction.JMP_OPCODE);
    try code_buffer.appendSlice(allocator, &[_]u8{ 0x00, 0x00, 0x00, 0x00 });
    try mgr.addForwardRef(label_id, 0, .relative);

    // Try to fixup - should fail because label is undefined
    const result = mgr.fixupLabels(code_buffer.items);
    try std.testing.expectError(error.UndefinedLabel, result);
}
