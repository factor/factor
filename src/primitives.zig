// primitives.zig - Factor VM primitives dispatch hub
// Imports all primitive sub-modules and wires up the dispatch table.

const std = @import("std");
const builtin = @import("builtin");

const bignum = @import("bignum.zig");
const callstack_mod = @import("callstack.zig");
const layouts = @import("layouts.zig");
const vm_mod = @import("vm.zig");

const Cell = layouts.Cell;
const FactorVM = vm_mod.FactorVM;
const VMAssemblyFields = vm_mod.VMAssemblyFields;

// --- Sub-module imports ---

const code = @import("primitives/code.zig");
const ctx = @import("primitives/contexts.zig");
const diag = @import("primitives/diagnostics.zig");
const ffi = @import("primitives/alien.zig");
const io_prims = @import("primitives/io.zig");
const math_prims = @import("primitives/math.zig");
const misc = @import("primitives/misc.zig");
const obj = @import("primitives/objects.zig");

// --- Re-exports used by other modules ---

pub const lookupMethod = code.lookupMethod;
pub const updateCodeHeapWords = code.updateCodeHeapWords;
pub const nanoCountMonotonic = misc.nanoCountMonotonic;

// --- Primitive function signature ---

pub const PrimitiveFn = *const fn (*VMAssemblyFields) callconv(.c) void;

pub const PrimitiveIndex = enum(u16) {
    alien_address = 0,
    all_instances = 1,
    array = 2,
    array_to_quotation = 3,
    become = 4,
    bignum_add = 5,
    bignum_and = 6,
    bignum_bitp = 7,
    bignum_divint = 8,
    bignum_divmod = 9,
    bignum_eq = 10,
    bignum_greater = 11,
    bignum_greatereq = 12,
    bignum_less = 13,
    bignum_lesseq = 14,
    bignum_log2 = 15,
    bignum_mod = 16,
    bignum_gcd = 17,
    bignum_multiply = 18,
    bignum_not = 19,
    bignum_or = 20,
    bignum_shift = 21,
    bignum_subtract = 22,
    bignum_to_fixnum = 23,
    bignum_to_fixnum_strict = 24,
    bignum_xor = 25,
    bits_double = 26,
    bits_float = 27,
    byte_array = 28,
    callback = 29,
    callback_room = 30,
    callstack_bounds = 31,
    callstack_for = 32,
    callstack_to_array = 33,
    check_datastack = 34,
    clone = 35,
    code_blocks = 36,
    code_room = 37,
    compact_gc = 38,
    compute_identity_hashcode = 39,
    context_object = 40,
    context_object_for = 41,
    current_callback = 42,
    data_room = 43,
    datastack_for = 44,
    die = 45,
    disable_ctrl_break = 46,
    disable_gc_events = 47,
    dispatch_stats = 48,
    displaced_alien = 49,
    dlclose = 50,
    dll_validp = 51,
    dlopen = 52,
    dlsym = 53,
    double_bits = 54,
    enable_ctrl_break = 55,
    enable_gc_events = 56,
    existsp = 57,
    exit = 58,
    fclose = 59,
    fflush = 60,
    fgetc = 61,
    fixnum_divint = 62,
    fixnum_divmod = 63,
    fixnum_shift = 64,
    fixnum_to_bignum = 65,
    fixnum_to_float = 66,
    float_add = 67,
    float_bits = 68,
    float_divfloat = 69,
    float_eq = 70,
    float_greater = 71,
    float_greatereq = 72,
    float_less = 73,
    float_lesseq = 74,
    float_multiply = 75,
    float_subtract = 76,
    float_to_bignum = 77,
    float_to_fixnum = 78,
    fopen = 79,
    format_float = 80,
    fputc = 81,
    fread = 82,
    free_callback = 83,
    fseek = 84,
    ftell = 85,
    full_gc = 86,
    fwrite = 87,
    get_samples = 88,
    identity_hashcode = 89,
    innermost_stack_frame_executing = 90,
    innermost_stack_frame_scan = 91,
    jit_compile = 92,
    load_locals = 93,
    lookup_method = 94,
    mega_cache_miss = 95,
    minor_gc = 96,
    modify_code_heap = 97,
    nano_count = 98,
    quotation_code = 99,
    quotation_compiled_p = 100,
    reset_dispatch_stats = 101,
    resize_array = 102,
    resize_byte_array = 103,
    resize_string = 104,
    retainstack_for = 105,
    save_image = 106,
    set_context_object = 107,
    set_datastack = 108,
    set_innermost_stack_frame_quotation = 109,
    set_profiling = 110,
    set_retainstack = 111,
    set_slot = 112,
    set_special_object = 113,
    set_string_nth_fast = 114,
    size = 115,
    sleep = 116,
    special_object = 117,
    string = 118,
    strip_stack_traces = 119,
    tuple = 120,
    tuple_boa = 121,
    uninitialized_byte_array = 122,
    word = 123,
    word_code = 124,
    word_optimized_p = 125,
    wrapper = 126,
    alien_signed_cell = 127,
    set_alien_signed_cell = 128,
    alien_unsigned_cell = 129,
    set_alien_unsigned_cell = 130,
    alien_signed_8 = 131,
    set_alien_signed_8 = 132,
    alien_unsigned_8 = 133,
    set_alien_unsigned_8 = 134,
    alien_signed_4 = 135,
    set_alien_signed_4 = 136,
    alien_unsigned_4 = 137,
    set_alien_unsigned_4 = 138,
    alien_signed_2 = 139,
    set_alien_signed_2 = 140,
    alien_unsigned_2 = 141,
    set_alien_unsigned_2 = 142,
    alien_signed_1 = 143,
    set_alien_signed_1 = 144,
    alien_unsigned_1 = 145,
    set_alien_unsigned_1 = 146,
    alien_float = 147,
    set_alien_float = 148,
    alien_double = 149,
    set_alien_double = 150,
    alien_cell = 151,
    set_alien_cell = 152,
    float_unordered_less = 153,
    float_unordered_lesseq = 154,
    float_unordered_greater = 155,
    float_unordered_greatereq = 156,
    floating_point_supported = 157,
};

pub const primitive_count = @typeInfo(PrimitiveIndex).@"enum".field_names.len;

// --- Dispatch table ---

pub const primitives: [primitive_count]PrimitiveFn = init_primitives();

fn init_primitives() [primitive_count]PrimitiveFn {
    var table: [primitive_count]PrimitiveFn = @splat(misc.primitive_stub);

    table[@backingInt(PrimitiveIndex.floating_point_supported)] = math_prims.primitive_floating_point_supported;

    // Object primitives
    table[@backingInt(PrimitiveIndex.clone)] = obj.primitive_clone;
    table[@backingInt(PrimitiveIndex.wrapper)] = obj.primitive_wrapper;
    table[@backingInt(PrimitiveIndex.set_slot)] = obj.primitive_set_slot;
    table[@backingInt(PrimitiveIndex.tuple)] = obj.primitive_tuple;
    table[@backingInt(PrimitiveIndex.tuple_boa)] = obj.primitive_tuple_boa;
    table[@backingInt(PrimitiveIndex.identity_hashcode)] = obj.primitive_identity_hashcode;
    table[@backingInt(PrimitiveIndex.compute_identity_hashcode)] = obj.primitive_compute_identity_hashcode;
    table[@backingInt(PrimitiveIndex.become)] = obj.primitive_become;
    table[@backingInt(PrimitiveIndex.array)] = obj.primitive_array;
    table[@backingInt(PrimitiveIndex.resize_array)] = obj.primitive_resize_array;
    table[@backingInt(PrimitiveIndex.byte_array)] = obj.primitive_byte_array;
    table[@backingInt(PrimitiveIndex.uninitialized_byte_array)] = obj.primitive_uninitialized_byte_array;
    table[@backingInt(PrimitiveIndex.resize_byte_array)] = obj.primitive_resize_byte_array;
    table[@backingInt(PrimitiveIndex.string)] = obj.primitive_string;
    table[@backingInt(PrimitiveIndex.resize_string)] = obj.primitive_resize_string;
    table[@backingInt(PrimitiveIndex.set_string_nth_fast)] = obj.primitive_set_string_nth_fast;
    table[@backingInt(PrimitiveIndex.word)] = obj.primitive_word;
    table[@backingInt(PrimitiveIndex.word_code)] = obj.primitive_word_code;
    table[@backingInt(PrimitiveIndex.quotation_code)] = obj.primitive_quotation_code;

    // Context primitives
    table[@backingInt(PrimitiveIndex.special_object)] = ctx.primitive_special_object;
    table[@backingInt(PrimitiveIndex.set_special_object)] = ctx.primitive_set_special_object;
    table[@backingInt(PrimitiveIndex.context_object)] = ctx.primitive_context_object;
    table[@backingInt(PrimitiveIndex.set_context_object)] = ctx.primitive_set_context_object;
    table[@backingInt(PrimitiveIndex.context_object_for)] = ctx.primitive_context_object_for;
    table[@backingInt(PrimitiveIndex.datastack_for)] = ctx.primitive_datastack_for;
    table[@backingInt(PrimitiveIndex.retainstack_for)] = ctx.primitive_retainstack_for;
    table[@backingInt(PrimitiveIndex.set_datastack)] = ctx.primitive_set_datastack;
    table[@backingInt(PrimitiveIndex.set_retainstack)] = ctx.primitive_set_retainstack;
    table[@backingInt(PrimitiveIndex.check_datastack)] = ctx.primitive_check_datastack;
    table[@backingInt(PrimitiveIndex.load_locals)] = ctx.primitive_load_locals;

    // Diagnostics / GC primitives
    table[@backingInt(PrimitiveIndex.die)] = diag.primitive_die;
    table[@backingInt(PrimitiveIndex.minor_gc)] = diag.primitive_minor_gc;
    table[@backingInt(PrimitiveIndex.full_gc)] = diag.primitive_full_gc;
    table[@backingInt(PrimitiveIndex.compact_gc)] = diag.primitive_compact_gc;
    table[@backingInt(PrimitiveIndex.enable_gc_events)] = diag.primitive_enable_gc_events;
    table[@backingInt(PrimitiveIndex.disable_gc_events)] = diag.primitive_disable_gc_events;
    table[@backingInt(PrimitiveIndex.data_room)] = diag.primitive_data_room;
    table[@backingInt(PrimitiveIndex.code_room)] = diag.primitive_code_room;
    table[@backingInt(PrimitiveIndex.callback_room)] = diag.primitive_callback_room;
    table[@backingInt(PrimitiveIndex.all_instances)] = diag.primitive_all_instances;
    table[@backingInt(PrimitiveIndex.reset_dispatch_stats)] = diag.primitive_reset_dispatch_stats;
    table[@backingInt(PrimitiveIndex.dispatch_stats)] = diag.primitive_dispatch_stats;
    table[@backingInt(PrimitiveIndex.set_profiling)] = diag.primitive_set_profiling;
    table[@backingInt(PrimitiveIndex.get_samples)] = diag.primitive_get_samples;

    // Code heap / compilation primitives
    table[@backingInt(PrimitiveIndex.modify_code_heap)] = code.primitive_modify_code_heap;
    table[@backingInt(PrimitiveIndex.code_blocks)] = code.primitive_code_blocks;
    table[@backingInt(PrimitiveIndex.strip_stack_traces)] = code.primitive_strip_stack_traces;
    table[@backingInt(PrimitiveIndex.innermost_stack_frame_executing)] = code.primitive_innermost_stack_frame_executing;
    table[@backingInt(PrimitiveIndex.innermost_stack_frame_scan)] = code.primitive_innermost_stack_frame_scan;
    table[@backingInt(PrimitiveIndex.set_innermost_stack_frame_quotation)] = code.primitive_set_innermost_stack_frame_quotation;
    table[@backingInt(PrimitiveIndex.quotation_compiled_p)] = code.primitive_quotation_compiled_p;
    table[@backingInt(PrimitiveIndex.jit_compile)] = code.primitive_jit_compile;
    table[@backingInt(PrimitiveIndex.array_to_quotation)] = code.primitive_array_to_quotation;
    table[@backingInt(PrimitiveIndex.word_optimized_p)] = code.primitive_word_optimized_p;
    table[@backingInt(PrimitiveIndex.lookup_method)] = code.primitive_lookup_method;
    table[@backingInt(PrimitiveIndex.mega_cache_miss)] = code.primitive_mega_cache_miss;
    table[@backingInt(PrimitiveIndex.callstack_for)] = code.primitive_callstack_for;
    table[@backingInt(PrimitiveIndex.callstack_to_array)] = callstack_mod.primitive_callstack_to_array;
    table[@backingInt(PrimitiveIndex.callstack_bounds)] = callstack_mod.primitive_callstack_bounds;

    // I/O primitives
    table[@backingInt(PrimitiveIndex.fopen)] = io_prims.primitive_fopen;
    table[@backingInt(PrimitiveIndex.fclose)] = io_prims.primitive_fclose;
    table[@backingInt(PrimitiveIndex.fflush)] = io_prims.primitive_fflush;
    table[@backingInt(PrimitiveIndex.fgetc)] = io_prims.primitive_fgetc;
    table[@backingInt(PrimitiveIndex.fputc)] = io_prims.primitive_fputc;
    table[@backingInt(PrimitiveIndex.fread)] = io_prims.primitive_fread;
    table[@backingInt(PrimitiveIndex.fwrite)] = io_prims.primitive_fwrite;
    table[@backingInt(PrimitiveIndex.ftell)] = io_prims.primitive_ftell;
    table[@backingInt(PrimitiveIndex.fseek)] = io_prims.primitive_fseek;
    table[@backingInt(PrimitiveIndex.existsp)] = io_prims.primitive_existsp;
    table[@backingInt(PrimitiveIndex.save_image)] = io_prims.primitive_save_image;

    // Math primitives
    table[@backingInt(PrimitiveIndex.fixnum_to_bignum)] = math_prims.primitive_fixnum_to_bignum;
    table[@backingInt(PrimitiveIndex.fixnum_to_float)] = math_prims.primitive_fixnum_to_float;
    table[@backingInt(PrimitiveIndex.fixnum_shift)] = math_prims.primitive_fixnum_shift;
    table[@backingInt(PrimitiveIndex.fixnum_divint)] = math_prims.primitive_fixnum_divint;
    table[@backingInt(PrimitiveIndex.fixnum_divmod)] = math_prims.primitive_fixnum_divmod;
    table[@backingInt(PrimitiveIndex.bignum_to_fixnum)] = math_prims.primitive_bignum_to_fixnum;
    table[@backingInt(PrimitiveIndex.bignum_to_fixnum_strict)] = math_prims.primitive_bignum_to_fixnum_strict;
    table[@backingInt(PrimitiveIndex.bignum_add)] = math_prims.primitive_bignum_add;
    table[@backingInt(PrimitiveIndex.bignum_subtract)] = math_prims.primitive_bignum_subtract;
    table[@backingInt(PrimitiveIndex.bignum_multiply)] = math_prims.primitive_bignum_multiply;
    table[@backingInt(PrimitiveIndex.bignum_divint)] = math_prims.primitive_bignum_divint;
    table[@backingInt(PrimitiveIndex.bignum_divmod)] = math_prims.primitive_bignum_divmod;
    table[@backingInt(PrimitiveIndex.bignum_mod)] = math_prims.primitive_bignum_mod;
    table[@backingInt(PrimitiveIndex.bignum_gcd)] = math_prims.primitive_bignum_gcd;
    table[@backingInt(PrimitiveIndex.bignum_and)] = math_prims.primitive_bignum_and;
    table[@backingInt(PrimitiveIndex.bignum_or)] = math_prims.primitive_bignum_or;
    table[@backingInt(PrimitiveIndex.bignum_xor)] = math_prims.primitive_bignum_xor;
    table[@backingInt(PrimitiveIndex.bignum_not)] = math_prims.primitive_bignum_not;
    table[@backingInt(PrimitiveIndex.bignum_shift)] = math_prims.primitive_bignum_shift;
    table[@backingInt(PrimitiveIndex.bignum_less)] = math_prims.primitive_bignum_less;
    table[@backingInt(PrimitiveIndex.bignum_lesseq)] = math_prims.primitive_bignum_lesseq;
    table[@backingInt(PrimitiveIndex.bignum_eq)] = math_prims.primitive_bignum_eq;
    table[@backingInt(PrimitiveIndex.bignum_greater)] = math_prims.primitive_bignum_greater;
    table[@backingInt(PrimitiveIndex.bignum_greatereq)] = math_prims.primitive_bignum_greatereq;
    table[@backingInt(PrimitiveIndex.bignum_bitp)] = math_prims.primitive_bignum_bitp;
    table[@backingInt(PrimitiveIndex.bignum_log2)] = math_prims.primitive_bignum_log2;
    table[@backingInt(PrimitiveIndex.float_to_fixnum)] = math_prims.primitive_float_to_fixnum;
    table[@backingInt(PrimitiveIndex.float_to_bignum)] = math_prims.primitive_float_to_bignum;
    table[@backingInt(PrimitiveIndex.float_add)] = math_prims.primitive_float_add;
    table[@backingInt(PrimitiveIndex.float_subtract)] = math_prims.primitive_float_subtract;
    table[@backingInt(PrimitiveIndex.float_multiply)] = math_prims.primitive_float_multiply;
    table[@backingInt(PrimitiveIndex.float_divfloat)] = math_prims.primitive_float_divfloat;
    table[@backingInt(PrimitiveIndex.float_less)] = math_prims.primitive_float_less;
    table[@backingInt(PrimitiveIndex.float_unordered_less)] = math_prims.primitive_float_unordered_less;
    table[@backingInt(PrimitiveIndex.float_lesseq)] = math_prims.primitive_float_lesseq;
    table[@backingInt(PrimitiveIndex.float_unordered_lesseq)] = math_prims.primitive_float_unordered_lesseq;
    table[@backingInt(PrimitiveIndex.float_eq)] = math_prims.primitive_float_eq;
    table[@backingInt(PrimitiveIndex.float_greater)] = math_prims.primitive_float_greater;
    table[@backingInt(PrimitiveIndex.float_unordered_greater)] = math_prims.primitive_float_unordered_greater;
    table[@backingInt(PrimitiveIndex.float_greatereq)] = math_prims.primitive_float_greatereq;
    table[@backingInt(PrimitiveIndex.float_unordered_greatereq)] = math_prims.primitive_float_unordered_greatereq;
    table[@backingInt(PrimitiveIndex.float_bits)] = math_prims.primitive_float_bits;
    table[@backingInt(PrimitiveIndex.bits_float)] = math_prims.primitive_bits_float;
    table[@backingInt(PrimitiveIndex.double_bits)] = math_prims.primitive_double_bits;
    table[@backingInt(PrimitiveIndex.bits_double)] = math_prims.primitive_bits_double;
    table[@backingInt(PrimitiveIndex.format_float)] = math_prims.primitive_format_float;

    // Misc primitives
    table[@backingInt(PrimitiveIndex.exit)] = misc.primitive_exit;
    table[@backingInt(PrimitiveIndex.nano_count)] = misc.primitive_nano_count;
    table[@backingInt(PrimitiveIndex.sleep)] = misc.primitive_sleep;
    table[@backingInt(PrimitiveIndex.size)] = misc.primitive_size;
    table[@backingInt(PrimitiveIndex.enable_ctrl_break)] = misc.primitive_enable_ctrl_break;
    table[@backingInt(PrimitiveIndex.disable_ctrl_break)] = misc.primitive_disable_ctrl_break;

    // Alien/FFI primitives
    table[@backingInt(PrimitiveIndex.alien_address)] = ffi.primitive_alien_address;
    table[@backingInt(PrimitiveIndex.displaced_alien)] = ffi.primitive_displaced_alien;
    table[@backingInt(PrimitiveIndex.alien_cell)] = ffi.primitive_alien_cell;
    table[@backingInt(PrimitiveIndex.set_alien_cell)] = ffi.primitive_set_alien_cell;
    table[@backingInt(PrimitiveIndex.alien_signed_cell)] = ffi.primitive_alien_signed_cell;
    table[@backingInt(PrimitiveIndex.set_alien_signed_cell)] = ffi.primitive_set_alien_signed_cell;
    table[@backingInt(PrimitiveIndex.alien_unsigned_cell)] = ffi.primitive_alien_unsigned_cell;
    table[@backingInt(PrimitiveIndex.set_alien_unsigned_cell)] = ffi.primitive_set_alien_unsigned_cell;
    table[@backingInt(PrimitiveIndex.alien_signed_1)] = ffi.primitive_alien_signed_1;
    table[@backingInt(PrimitiveIndex.set_alien_signed_1)] = ffi.primitive_set_alien_signed_1;
    table[@backingInt(PrimitiveIndex.alien_unsigned_1)] = ffi.primitive_alien_unsigned_1;
    table[@backingInt(PrimitiveIndex.set_alien_unsigned_1)] = ffi.primitive_set_alien_unsigned_1;
    table[@backingInt(PrimitiveIndex.alien_signed_2)] = ffi.primitive_alien_signed_2;
    table[@backingInt(PrimitiveIndex.set_alien_signed_2)] = ffi.primitive_set_alien_signed_2;
    table[@backingInt(PrimitiveIndex.alien_unsigned_2)] = ffi.primitive_alien_unsigned_2;
    table[@backingInt(PrimitiveIndex.set_alien_unsigned_2)] = ffi.primitive_set_alien_unsigned_2;
    table[@backingInt(PrimitiveIndex.alien_signed_4)] = ffi.primitive_alien_signed_4;
    table[@backingInt(PrimitiveIndex.set_alien_signed_4)] = ffi.primitive_set_alien_signed_4;
    table[@backingInt(PrimitiveIndex.alien_unsigned_4)] = ffi.primitive_alien_unsigned_4;
    table[@backingInt(PrimitiveIndex.set_alien_unsigned_4)] = ffi.primitive_set_alien_unsigned_4;
    table[@backingInt(PrimitiveIndex.alien_signed_8)] = ffi.primitive_alien_signed_8;
    table[@backingInt(PrimitiveIndex.set_alien_signed_8)] = ffi.primitive_set_alien_signed_8;
    table[@backingInt(PrimitiveIndex.alien_unsigned_8)] = ffi.primitive_alien_unsigned_8;
    table[@backingInt(PrimitiveIndex.set_alien_unsigned_8)] = ffi.primitive_set_alien_unsigned_8;
    table[@backingInt(PrimitiveIndex.alien_float)] = ffi.primitive_alien_float;
    table[@backingInt(PrimitiveIndex.set_alien_float)] = ffi.primitive_set_alien_float;
    table[@backingInt(PrimitiveIndex.alien_double)] = ffi.primitive_alien_double;
    table[@backingInt(PrimitiveIndex.set_alien_double)] = ffi.primitive_set_alien_double;
    table[@backingInt(PrimitiveIndex.dlopen)] = ffi.primitive_dlopen;
    table[@backingInt(PrimitiveIndex.dlsym)] = ffi.primitive_dlsym;
    table[@backingInt(PrimitiveIndex.dlclose)] = ffi.primitive_dlclose;
    table[@backingInt(PrimitiveIndex.dll_validp)] = ffi.primitive_dll_validp;
    table[@backingInt(PrimitiveIndex.current_callback)] = ffi.primitive_current_callback;
    table[@backingInt(PrimitiveIndex.callback)] = ffi.primitive_callback;
    table[@backingInt(PrimitiveIndex.free_callback)] = ffi.primitive_free_callback;

    return table;
}

// Call a primitive by index
pub fn callPrimitive(vm: *FactorVM, index: u16) void {
    if (comptime builtin.mode == .debug or builtin.mode == .safe) {
        if (index >= primitive_count) return;
    }
    primitives[index](&vm.vm_asm);
}

// --- Integer conversion helpers (called directly by FFI code) ---

pub export fn to_unsigned_8(n: Cell, vm_asm: *VMAssemblyFields) callconv(.c) u64 {
    switch (layouts.typeTag(n)) {
        .fixnum => return @bitCast(@as(i64, layouts.untagFixnum(n))),
        .bignum => {
            const bn: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(n));
            return bignum.toUint64(bn);
        },
        else => {
            vm_asm.getVM().typeError(.fixnum, n);
        },
    }
}

pub export fn to_signed_8(n: Cell, vm_asm: *VMAssemblyFields) callconv(.c) i64 {
    switch (layouts.typeTag(n)) {
        .fixnum => return layouts.untagFixnum(n),
        .bignum => {
            const bn: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(n));
            return bignum.toInt64(bn);
        },
        else => {
            vm_asm.getVM().typeError(.fixnum, n);
        },
    }
}

pub export fn to_unsigned_4(n: Cell, vm_asm: *VMAssemblyFields) callconv(.c) u32 {
    switch (layouts.typeTag(n)) {
        .fixnum => return @truncate(layouts.untagFixnumUnsigned(n)),
        .bignum => {
            const bn: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(n));
            return @truncate(bignum.toUint64(bn));
        },
        else => {
            vm_asm.getVM().typeError(.fixnum, n);
        },
    }
}

pub export fn to_signed_4(n: Cell, vm_asm: *VMAssemblyFields) callconv(.c) i32 {
    switch (layouts.typeTag(n)) {
        .fixnum => return @truncate(layouts.untagFixnum(n)),
        .bignum => {
            const bn: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(n));
            return @truncate(bignum.toInt64(bn));
        },
        else => {
            vm_asm.getVM().typeError(.fixnum, n);
        },
    }
}

// --- Force-keep all exported primitives ---

pub fn getAllPrimitives() [primitive_count]PrimitiveFn {
    return .{
        math_prims.primitive_fixnum_to_bignum,
        math_prims.primitive_fixnum_to_float,
        math_prims.primitive_fixnum_shift,
        math_prims.primitive_fixnum_divint,
        math_prims.primitive_fixnum_divmod,
        math_prims.primitive_bignum_to_fixnum,
        math_prims.primitive_bignum_to_fixnum_strict,
        math_prims.primitive_bignum_add,
        math_prims.primitive_bignum_subtract,
        math_prims.primitive_bignum_multiply,
        math_prims.primitive_bignum_divint,
        math_prims.primitive_bignum_divmod,
        math_prims.primitive_bignum_mod,
        math_prims.primitive_bignum_gcd,
        math_prims.primitive_bignum_and,
        math_prims.primitive_bignum_or,
        math_prims.primitive_bignum_xor,
        math_prims.primitive_bignum_not,
        math_prims.primitive_bignum_shift,
        math_prims.primitive_bignum_less,
        math_prims.primitive_bignum_lesseq,
        math_prims.primitive_bignum_greater,
        math_prims.primitive_bignum_greatereq,
        math_prims.primitive_bignum_eq,
        math_prims.primitive_bignum_log2,
        math_prims.primitive_bignum_bitp,
        math_prims.primitive_float_add,
        math_prims.primitive_float_subtract,
        math_prims.primitive_float_multiply,
        math_prims.primitive_float_divfloat,
        math_prims.primitive_float_less,
        math_prims.primitive_float_unordered_less,
        math_prims.primitive_float_lesseq,
        math_prims.primitive_float_unordered_lesseq,
        math_prims.primitive_float_greater,
        math_prims.primitive_float_unordered_greater,
        math_prims.primitive_float_greatereq,
        math_prims.primitive_float_unordered_greatereq,
        math_prims.primitive_float_eq,
        math_prims.primitive_float_to_fixnum,
        math_prims.primitive_float_to_bignum,
        math_prims.primitive_format_float,
        obj.primitive_array,
        obj.primitive_resize_array,
        obj.primitive_byte_array,
        obj.primitive_resize_byte_array,
        obj.primitive_uninitialized_byte_array,
        obj.primitive_tuple,
        obj.primitive_tuple_boa,
        ffi.primitive_alien_address,
        ffi.primitive_displaced_alien,
        ffi.primitive_dlopen,
        ffi.primitive_dlsym,
        ffi.primitive_dlclose,
        ffi.primitive_dll_validp,
        ffi.primitive_current_callback,
        ffi.primitive_callback,
        ffi.primitive_free_callback,
        ffi.primitive_alien_signed_1,
        ffi.primitive_alien_unsigned_1,
        ffi.primitive_alien_signed_2,
        ffi.primitive_alien_unsigned_2,
        ffi.primitive_alien_signed_4,
        ffi.primitive_alien_unsigned_4,
        ffi.primitive_alien_signed_8,
        ffi.primitive_alien_unsigned_8,
        ffi.primitive_alien_signed_cell,
        ffi.primitive_alien_unsigned_cell,
        ffi.primitive_alien_cell,
        ffi.primitive_alien_float,
        ffi.primitive_alien_double,
        ffi.primitive_set_alien_signed_1,
        ffi.primitive_set_alien_unsigned_1,
        ffi.primitive_set_alien_signed_2,
        ffi.primitive_set_alien_unsigned_2,
        ffi.primitive_set_alien_signed_4,
        ffi.primitive_set_alien_unsigned_4,
        ffi.primitive_set_alien_signed_8,
        ffi.primitive_set_alien_unsigned_8,
        ffi.primitive_set_alien_signed_cell,
        ffi.primitive_set_alien_unsigned_cell,
        ffi.primitive_set_alien_cell,
        ffi.primitive_set_alien_float,
        ffi.primitive_set_alien_double,
        code.primitive_modify_code_heap,
        code.primitive_lookup_method,
        code.primitive_mega_cache_miss,
        io_prims.primitive_existsp,
        obj.primitive_clone,
        obj.primitive_wrapper,
        obj.primitive_set_slot,
        obj.primitive_string,
        obj.primitive_resize_string,
        obj.primitive_set_string_nth_fast,
        obj.primitive_quotation_code,
        code.primitive_quotation_compiled_p,
        code.primitive_jit_compile,
        code.primitive_array_to_quotation,
        obj.primitive_word,
        obj.primitive_word_code,
        code.primitive_word_optimized_p,
        math_prims.primitive_float_bits,
        math_prims.primitive_bits_float,
        math_prims.primitive_double_bits,
        math_prims.primitive_bits_double,
        io_prims.primitive_fopen,
        io_prims.primitive_fclose,
        io_prims.primitive_fflush,
        io_prims.primitive_fgetc,
        io_prims.primitive_fputc,
        io_prims.primitive_fread,
        io_prims.primitive_fwrite,
        io_prims.primitive_ftell,
        io_prims.primitive_fseek,
        diag.primitive_data_room,
        diag.primitive_code_room,
        diag.primitive_callback_room,
        diag.primitive_minor_gc,
        diag.primitive_full_gc,
        diag.primitive_compact_gc,
        io_prims.primitive_save_image,
        diag.primitive_all_instances,
        misc.primitive_size,
        ctx.primitive_context_object,
        ctx.primitive_set_context_object,
        ctx.primitive_context_object_for,
        ctx.primitive_datastack_for,
        ctx.primitive_retainstack_for,
        ctx.primitive_set_datastack,
        ctx.primitive_set_retainstack,
        code.primitive_callstack_for,
        callstack_mod.primitive_callstack_to_array,
        callstack_mod.primitive_callstack_bounds,
        ctx.primitive_check_datastack,
        ctx.primitive_load_locals,
        ctx.primitive_special_object,
        ctx.primitive_set_special_object,
        obj.primitive_identity_hashcode,
        obj.primitive_compute_identity_hashcode,
        obj.primitive_become,
        misc.primitive_exit,
        diag.primitive_die,
        misc.primitive_nano_count,
        misc.primitive_sleep,
        diag.primitive_reset_dispatch_stats,
        diag.primitive_dispatch_stats,
        diag.primitive_set_profiling,
        diag.primitive_get_samples,
        code.primitive_code_blocks,
        code.primitive_strip_stack_traces,
        diag.primitive_enable_gc_events,
        diag.primitive_disable_gc_events,
        code.primitive_innermost_stack_frame_executing,
        code.primitive_innermost_stack_frame_scan,
        code.primitive_set_innermost_stack_frame_quotation,
        misc.primitive_enable_ctrl_break,
        misc.primitive_disable_ctrl_break,
        math_prims.primitive_floating_point_supported,
    };
}

comptime {
    _ = &getAllPrimitives;
}

// --- Tests ---

test "primitive_special_object" {
    const allocator = std.testing.allocator;
    var vm = try FactorVM.init(allocator);
    defer vm.deinit();

    vm.vm_asm.ctx = try vm.newContext();
    vm.vm_asm.spare_ctx = try vm.newContext();

    const special_index: usize = 0;
    vm.vm_asm.special_objects[special_index] = layouts.tagFixnum(42);

    vm.push(layouts.tagFixnum(@intCast(special_index)));
    ctx.primitive_special_object(&vm.vm_asm);

    const result = vm.pop();
    try std.testing.expectEqual(layouts.tagFixnum(42), result);
}

test "primitive_slot" {
    const allocator = std.testing.allocator;
    var vm = try FactorVM.init(allocator);
    defer vm.deinit();

    vm.vm_asm.ctx = try vm.newContext();
    vm.vm_asm.spare_ctx = try vm.newContext();

    // Ensure 16-byte alignment so UNTAG (which clears low 4 bits) preserves the address.
    var test_obj: [3]Cell align(16) = .{ 0, 0, 0 };
    test_obj[0] = @as(Cell, @backingInt(layouts.TypeTag.array)) << 2;
    test_obj[1] = layouts.tagFixnum(1);
    test_obj[2] = layouts.tagFixnum(123);

    const obj_addr = @intFromPtr(&test_obj) | @backingInt(layouts.TypeTag.array);

    vm.push(obj_addr);
    vm.push(layouts.tagFixnum(2));
    obj.primitive_slot(&vm.vm_asm);

    const result = vm.pop();
    try std.testing.expectEqual(layouts.tagFixnum(123), result);
}

test "primitive_identity_hashcode" {
    const allocator = std.testing.allocator;
    var vm = try FactorVM.init(allocator);
    defer vm.deinit();

    vm.vm_asm.ctx = try vm.newContext();
    vm.vm_asm.spare_ctx = try vm.newContext();

    vm.push(layouts.tagFixnum(42));
    obj.primitive_identity_hashcode(&vm.vm_asm);

    const result = vm.pop();
    try std.testing.expectEqual(layouts.tagFixnum(42), result);
}
