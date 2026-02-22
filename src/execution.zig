// execution.zig - Factor VM execution engine
// Handles quotation execution, word dispatch, and primitive calls
//
// Factor normally uses JIT compilation where all code runs as native machine code.
// This module provides:
// 1. An interpreter for running quotations when JIT is not available
// 2. Entry points for calling compiled Factor code
// 3. Primitive dispatch

const std = @import("std");

const contexts = @import("contexts.zig");
const layouts = @import("layouts.zig");
const objects = @import("objects.zig");
const primitives = @import("primitives.zig");
const vm_mod = @import("vm.zig");

const Cell = layouts.Cell;
const Fixnum = layouts.Fixnum;
const FactorVM = vm_mod.FactorVM;

// Execution error types
pub const ExecutionError = error{
    StackUnderflow,
    StackOverflow,
    InvalidQuotation,
    InvalidWord,
    UndefinedWord,
    TypeError,
    NotImplemented,
};

// Interpreter for quotations
// This is used when JIT compilation is not available
pub const Interpreter = struct {
    vm: *FactorVM,
    recursion_depth: u32,

    const max_recursion_depth: u32 = 100000;
    const Self = @This();

    pub fn init(vm: *FactorVM) Self {
        return Self{ .vm = vm, .recursion_depth = 0 };
    }

    pub fn executeQuotation(self: *Self, quot_cell: Cell) ExecutionError!void {
        self.recursion_depth += 1;
        defer self.recursion_depth -= 1;

        if (self.recursion_depth > max_recursion_depth) {
            return ExecutionError.StackOverflow;
        }

        if (!layouts.hasTag(quot_cell, .quotation)) {
            return ExecutionError.InvalidQuotation;
        }

        const quot: *const layouts.Quotation = @ptrFromInt(layouts.UNTAG(quot_cell));
        const arr_cell = quot.array;

        if (!layouts.hasTag(arr_cell, .array)) {
            return ExecutionError.InvalidQuotation;
        }

        const arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(arr_cell));
        const len = layouts.untagFixnumUnsigned(arr.capacity);

        if (len > 1000) {
            return ExecutionError.InvalidQuotation;
        }

        const data = arr.data();

        // Check for mega-cache-lookup pattern: [ methods index cache mega-cache-lookup ]
        if (len == 4 and self.isMegaCacheLookupPattern(data[0..4], len)) {
            try self.executeMegaCacheLookup(data[0..4]);
            return;
        }

        // Execute each element
        for (0..len) |i| {
            const elem = data[i];
            try self.executeElement(elem);
        }
    }

    // Check if quotation matches mega-cache-lookup pattern
    fn isMegaCacheLookupPattern(self: *Self, data: []const Cell, len: Cell) bool {
        if (len != 4) return false;

        if (!layouts.hasTag(data[0], .array)) return false;
        if (!layouts.hasTag(data[1], .fixnum)) return false;
        if (!layouts.hasTag(data[2], .array)) return false;
        if (!layouts.hasTag(data[3], .word)) return false;

        const mega_lookup_word = self.vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.mega_lookup_word)];
        return data[3] == mega_lookup_word;
    }

    // Execute mega-cache-lookup pattern for generic dispatch
    fn executeMegaCacheLookup(self: *Self, data: []const Cell) ExecutionError!void {
        const ctx = self.vm.vm_asm.ctx;

        const methods_cell = data[0];
        const index_fixnum = data[1];
        const index = layouts.untagFixnum(index_fixnum);

        const index_usize: usize = @intCast(index);
        const obj_addr = ctx.datastack - (index_usize * @sizeOf(Cell));
        const obj = @as(*const Cell, @ptrFromInt(obj_addr)).*;

        const method = primitives.lookupMethod(obj, methods_cell);

        const method_tag = layouts.typeTag(method);
        if (method_tag == .quotation) {
            try self.executeQuotation(method);
        } else if (method_tag == .word) {
            try self.executeWord(method);
        } else {
            return ExecutionError.TypeError;
        }
    }

    fn executeElement(self: *Self, elem: Cell) ExecutionError!void {
        const tag = layouts.typeTag(elem);

        switch (tag) {
            .word => try self.executeWord(elem),
            .quotation => {
                self.vm.push(elem);
            },
            .wrapper => {
                const wrapper: *const layouts.Wrapper = @ptrFromInt(layouts.UNTAG(elem));
                self.vm.push(wrapper.object);
            },
            else => {
                self.vm.push(elem);
            },
        }
    }

    fn executeWord(self: *Self, word_cell: Cell) ExecutionError!void {
        const word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(word_cell));

        // Try built-in words first (single pass of string comparisons)
        if (try self.tryExecuteBuiltin(word)) return;

        // Execute the word's definition quotation
        const def = word.def;
        if (def == layouts.false_object) {
            return ExecutionError.UndefinedWord;
        }

        // Check for self-recursive definition (sub-primitive pattern)
        if (layouts.hasTag(def, .quotation)) {
            const quot: *const layouts.Quotation = @ptrFromInt(layouts.UNTAG(def));
            if (quot.array != layouts.false_object and layouts.hasTag(quot.array, .array)) {
                const arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(quot.array));
                const arr_len = layouts.untagFixnumUnsigned(arr.capacity);
                if (arr_len > 0 and arr.data()[0] == word_cell) {
                    @panic("Sub-primitive word not implemented - would cause infinite recursion");
                }
            }
        }

        try self.executeQuotation(def);
    }

    fn wordNameEquals(word: *const layouts.Word, target: []const u8) bool {
        if (word.name == layouts.false_object) return false;
        if (!layouts.hasTag(word.name, .string)) return false;
        const str: *const layouts.String = @ptrFromInt(layouts.UNTAG(word.name));
        const len = layouts.untagFixnumUnsigned(str.length);
        if (len != target.len) return false;
        const data = str.data();
        for (0..len) |i| {
            const ch: u8 = @truncate(data[i]);
            if (ch != target[i]) return false;
        }
        return true;
    }

    fn trueObject(self: *Self) Cell {
        return self.vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.canonical_true)];
    }

    fn boolObject(self: *Self, cond: bool) Cell {
        return if (cond) self.trueObject() else layouts.false_object;
    }

    // Try to execute a built-in word. Returns true if handled, false if not a builtin.
    fn tryExecuteBuiltin(self: *Self, word: *const layouts.Word) ExecutionError!bool {
        const ctx = self.vm.vm_asm.ctx;

        if (wordNameEquals(word, "swap")) {
            const y = ctx.pop();
            const x = ctx.pop();
            ctx.push(y);
            ctx.push(x);
        } else if (wordNameEquals(word, "dup")) {
            ctx.push(ctx.peek());
        } else if (wordNameEquals(word, "drop")) {
            _ = ctx.pop();
        } else if (wordNameEquals(word, "over")) {
            const y = ctx.pop();
            const x = ctx.peek();
            ctx.push(y);
            ctx.push(x);
        } else if (wordNameEquals(word, "rot")) {
            const z = ctx.pop();
            const y = ctx.pop();
            const x = ctx.pop();
            ctx.push(y);
            ctx.push(z);
            ctx.push(x);
        } else if (wordNameEquals(word, "-rot")) {
            const z = ctx.pop();
            const y = ctx.pop();
            const x = ctx.pop();
            ctx.push(z);
            ctx.push(x);
            ctx.push(y);
        } else if (wordNameEquals(word, "2dup")) {
            const y = ctx.pop();
            const x = ctx.peek();
            ctx.push(y);
            ctx.push(x);
            ctx.push(y);
        } else if (wordNameEquals(word, "2drop")) {
            _ = ctx.pop();
            _ = ctx.pop();
        } else if (wordNameEquals(word, "3dup")) {
            const z = ctx.pop();
            const y = ctx.pop();
            const x = ctx.peek();
            ctx.push(y);
            ctx.push(z);
            ctx.push(x);
            ctx.push(y);
            ctx.push(z);
        } else if (wordNameEquals(word, "pick")) {
            const z = ctx.pop();
            const y = ctx.pop();
            const x = ctx.peek();
            ctx.push(y);
            ctx.push(z);
            ctx.push(x);
        } else if (wordNameEquals(word, "nip")) {
            const y = ctx.pop();
            _ = ctx.pop();
            ctx.push(y);
        } else if (wordNameEquals(word, "dupd")) {
            const y = ctx.pop();
            const x = ctx.peek();
            ctx.push(x);
            ctx.push(y);
        } else if (wordNameEquals(word, "swapd")) {
            const z = ctx.pop();
            const y = ctx.pop();
            const x = ctx.pop();
            ctx.push(y);
            ctx.push(x);
            ctx.push(z);
        } else if (wordNameEquals(word, "die")) {
            primitives.callPrimitive(self.vm, @intFromEnum(primitives.PrimitiveIndex.die));
        } else if (wordNameEquals(word, "call")) {
            try self.executeQuotation(ctx.pop());
        } else if (wordNameEquals(word, "dip")) {
            const quot = ctx.pop();
            const x = ctx.pop();
            try self.executeQuotation(quot);
            ctx.push(x);
        } else if (wordNameEquals(word, "keep")) {
            const quot = ctx.pop();
            const x = ctx.peek();
            try self.executeQuotation(quot);
            ctx.push(x);
        } else if (wordNameEquals(word, "if")) {
            const false_quot = ctx.pop();
            const true_quot = ctx.pop();
            const cond = ctx.pop();
            try self.executeQuotation(if (cond == layouts.false_object) false_quot else true_quot);
        } else if (wordNameEquals(word, "?")) {
            const false_val = ctx.pop();
            const true_val = ctx.pop();
            const cond = ctx.pop();
            ctx.push(if (cond == layouts.false_object) false_val else true_val);
        } else if (wordNameEquals(word, "do-primitive")) {
            const prim_idx = ctx.pop();
            primitives.callPrimitive(self.vm, @intCast(layouts.untagFixnum(prim_idx)));
        } else if (wordNameEquals(word, "all-instances")) {
            primitives.callPrimitive(self.vm, @intFromEnum(primitives.PrimitiveIndex.all_instances));
        } else if (wordNameEquals(word, "special-object")) {
            primitives.callPrimitive(self.vm, @intFromEnum(primitives.PrimitiveIndex.special_object));
        } else if (wordNameEquals(word, "fwrite")) {
            primitives.callPrimitive(self.vm, @intFromEnum(primitives.PrimitiveIndex.fwrite));
        } else if (wordNameEquals(word, "fflush")) {
            primitives.callPrimitive(self.vm, @intFromEnum(primitives.PrimitiveIndex.fflush));
        } else if (wordNameEquals(word, "tag")) {
            ctx.push(layouts.tagFixnum(@intCast(layouts.TAG(ctx.pop()))));
        } else if (wordNameEquals(word, "length")) {
            const seq = ctx.pop();
            const tag = layouts.typeTag(seq);
            const addr = layouts.UNTAG(seq);
            const len: u64 = switch (tag) {
                .array => layouts.untagFixnumUnsigned(@as(*const layouts.Array, @ptrFromInt(addr)).capacity),
                .string => layouts.untagFixnumUnsigned(@as(*const layouts.String, @ptrFromInt(addr)).length),
                .byte_array => layouts.untagFixnumUnsigned(@as(*const layouts.ByteArray, @ptrFromInt(addr)).capacity),
                .quotation => blk: {
                    const quot: *const layouts.Quotation = @ptrFromInt(addr);
                    const arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(quot.array));
                    break :blk layouts.untagFixnumUnsigned(arr.capacity);
                },
                else => 0,
            };
            ctx.push(layouts.tagFixnum(@intCast(len)));
        } else if (wordNameEquals(word, "fixnum+") or wordNameEquals(word, "fixnum+fast")) {
            const y = ctx.pop();
            const x = ctx.pop();
            ctx.push(layouts.tagFixnum(layouts.untagFixnum(x) +% layouts.untagFixnum(y)));
        } else if (wordNameEquals(word, "fixnum-") or wordNameEquals(word, "fixnum-fast")) {
            const y = ctx.pop();
            const x = ctx.pop();
            ctx.push(layouts.tagFixnum(layouts.untagFixnum(x) -% layouts.untagFixnum(y)));
        } else if (wordNameEquals(word, "fixnum*") or wordNameEquals(word, "fixnum*fast")) {
            const y = ctx.pop();
            const x = ctx.pop();
            ctx.push(layouts.tagFixnum(layouts.untagFixnum(x) *% layouts.untagFixnum(y)));
        } else if (wordNameEquals(word, "fixnum-bitand")) {
            const y = ctx.pop();
            const x = ctx.pop();
            ctx.push(layouts.tagFixnum(layouts.untagFixnum(x) & layouts.untagFixnum(y)));
        } else if (wordNameEquals(word, "fixnum-bitor")) {
            const y = ctx.pop();
            const x = ctx.pop();
            ctx.push(layouts.tagFixnum(layouts.untagFixnum(x) | layouts.untagFixnum(y)));
        } else if (wordNameEquals(word, "fixnum-bitxor")) {
            const y = ctx.pop();
            const x = ctx.pop();
            ctx.push(layouts.tagFixnum(layouts.untagFixnum(x) ^ layouts.untagFixnum(y)));
        } else if (wordNameEquals(word, "fixnum-bitnot")) {
            ctx.push(layouts.tagFixnum(~layouts.untagFixnum(ctx.pop())));
        } else if (wordNameEquals(word, "fixnum-shift")) {
            const n_val = layouts.untagFixnum(ctx.pop());
            const x_val = layouts.untagFixnum(ctx.pop());
            const result = if (n_val >= 0)
                if (n_val < 64) x_val << @intCast(n_val) else @as(Fixnum, 0)
            else
                x_val >> @as(u6, @intCast(@min(63, -n_val)));
            ctx.push(layouts.tagFixnum(result));
        } else if (wordNameEquals(word, "fixnum<")) {
            const y = ctx.pop();
            const x = ctx.pop();
            ctx.push(self.boolObject(layouts.untagFixnum(x) < layouts.untagFixnum(y)));
        } else if (wordNameEquals(word, "fixnum<=")) {
            const y = ctx.pop();
            const x = ctx.pop();
            ctx.push(self.boolObject(layouts.untagFixnum(x) <= layouts.untagFixnum(y)));
        } else if (wordNameEquals(word, "fixnum>")) {
            const y = ctx.pop();
            const x = ctx.pop();
            ctx.push(self.boolObject(layouts.untagFixnum(x) > layouts.untagFixnum(y)));
        } else if (wordNameEquals(word, "fixnum>=")) {
            const y = ctx.pop();
            const x = ctx.pop();
            ctx.push(self.boolObject(layouts.untagFixnum(x) >= layouts.untagFixnum(y)));
        } else if (wordNameEquals(word, "both-fixnums?")) {
            const y = ctx.pop();
            const x = ctx.pop();
            ctx.push(self.boolObject(layouts.hasTag(x, .fixnum) and layouts.hasTag(y, .fixnum)));
        } else if (wordNameEquals(word, "eq?")) {
            const y = ctx.pop();
            const x = ctx.pop();
            ctx.push(self.boolObject(x == y));
        } else {
            return false;
        }
        return true;
    }

    // Execute special combinators
    pub fn call(self: *Self) ExecutionError!void {
        const quot = self.vm.pop();
        try self.executeQuotation(quot);
    }

    pub fn execute(self: *Self) ExecutionError!void {
        const word = self.vm.pop();
        try self.executeWord(word);
    }

    pub fn ifCombinator(self: *Self) ExecutionError!void {
        const false_quot = self.vm.pop();
        const true_quot = self.vm.pop();
        const cond = self.vm.pop();

        if (cond != layouts.false_object) {
            try self.executeQuotation(true_quot);
        } else {
            try self.executeQuotation(false_quot);
        }
    }

    pub fn dip(self: *Self) ExecutionError!void {
        const ctx = self.vm.vm_asm.ctx;
        const quot = ctx.pop();
        const x = ctx.pop();
        ctx.pushRetain(x);
        try self.executeQuotation(quot);
        const x_restored = ctx.popRetain();
        ctx.push(x_restored);
    }

    pub fn keep(self: *Self) ExecutionError!void {
        const ctx = self.vm.vm_asm.ctx;
        const quot = ctx.pop();
        const x = ctx.peek();
        ctx.pushRetain(x);
        try self.executeQuotation(quot);
        const x_restored = ctx.popRetain();
        ctx.push(x_restored);
    }
};

// Entry point for running Factor code
pub fn runFactor(vm: *FactorVM) !void {
    const startup_quot = vm.specialObject(objects.SpecialObject.startup_quot);

    if (startup_quot == layouts.false_object) {
        return;
    }

    if (layouts.hasTag(startup_quot, .quotation)) {
        const quot: *const layouts.Quotation = @ptrFromInt(layouts.UNTAG(startup_quot));

        if (quot.entry_point != 0) {
            vm.cToFactor(startup_quot);
            return;
        }
    }

    // Fall back to interpreter
    var interp = Interpreter.init(vm);
    try interp.executeQuotation(startup_quot);
}

// Tests
test "interpreter basic literals" {
    const allocator = std.testing.allocator;
    var vm = try FactorVM.init(allocator);
    defer vm.deinit();

    vm.vm_asm.ctx = try vm.newContext();
    vm.vm_asm.spare_ctx = try vm.newContext();

    var interp = Interpreter.init(vm);

    try interp.executeElement(layouts.tagFixnum(42));

    const result = vm.pop();
    try std.testing.expectEqual(layouts.tagFixnum(42), result);
}
