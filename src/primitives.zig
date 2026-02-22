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

// Primitive index enum - must match C++ VM order exactly (vm/primitives.hpp)
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
};

pub const primitive_count = @typeInfo(PrimitiveIndex).@"enum".fields.len;

// --- Dispatch table ---

pub const primitives: [primitive_count]PrimitiveFn = init_primitives();

fn init_primitives() [primitive_count]PrimitiveFn {
    var table: [primitive_count]PrimitiveFn = [_]PrimitiveFn{misc.primitive_stub} ** primitive_count;

    // Object primitives
    table[@intFromEnum(PrimitiveIndex.clone)] = obj.primitive_clone;
    table[@intFromEnum(PrimitiveIndex.wrapper)] = obj.primitive_wrapper;
    table[@intFromEnum(PrimitiveIndex.set_slot)] = obj.primitive_set_slot;
    table[@intFromEnum(PrimitiveIndex.tuple)] = obj.primitive_tuple;
    table[@intFromEnum(PrimitiveIndex.tuple_boa)] = obj.primitive_tuple_boa;
    table[@intFromEnum(PrimitiveIndex.identity_hashcode)] = obj.primitive_identity_hashcode;
    table[@intFromEnum(PrimitiveIndex.compute_identity_hashcode)] = obj.primitive_compute_identity_hashcode;
    table[@intFromEnum(PrimitiveIndex.become)] = obj.primitive_become;
    table[@intFromEnum(PrimitiveIndex.array)] = obj.primitive_array;
    table[@intFromEnum(PrimitiveIndex.resize_array)] = obj.primitive_resize_array;
    table[@intFromEnum(PrimitiveIndex.byte_array)] = obj.primitive_byte_array;
    table[@intFromEnum(PrimitiveIndex.uninitialized_byte_array)] = obj.primitive_uninitialized_byte_array;
    table[@intFromEnum(PrimitiveIndex.resize_byte_array)] = obj.primitive_resize_byte_array;
    table[@intFromEnum(PrimitiveIndex.string)] = obj.primitive_string;
    table[@intFromEnum(PrimitiveIndex.resize_string)] = obj.primitive_resize_string;
    table[@intFromEnum(PrimitiveIndex.set_string_nth_fast)] = obj.primitive_set_string_nth_fast;
    table[@intFromEnum(PrimitiveIndex.word)] = obj.primitive_word;
    table[@intFromEnum(PrimitiveIndex.word_code)] = obj.primitive_word_code;
    table[@intFromEnum(PrimitiveIndex.quotation_code)] = obj.primitive_quotation_code;

    // Context primitives
    table[@intFromEnum(PrimitiveIndex.special_object)] = ctx.primitive_special_object;
    table[@intFromEnum(PrimitiveIndex.set_special_object)] = ctx.primitive_set_special_object;
    table[@intFromEnum(PrimitiveIndex.context_object)] = ctx.primitive_context_object;
    table[@intFromEnum(PrimitiveIndex.set_context_object)] = ctx.primitive_set_context_object;
    table[@intFromEnum(PrimitiveIndex.context_object_for)] = ctx.primitive_context_object_for;
    table[@intFromEnum(PrimitiveIndex.datastack_for)] = ctx.primitive_datastack_for;
    table[@intFromEnum(PrimitiveIndex.retainstack_for)] = ctx.primitive_retainstack_for;
    table[@intFromEnum(PrimitiveIndex.set_datastack)] = ctx.primitive_set_datastack;
    table[@intFromEnum(PrimitiveIndex.set_retainstack)] = ctx.primitive_set_retainstack;
    table[@intFromEnum(PrimitiveIndex.check_datastack)] = ctx.primitive_check_datastack;
    table[@intFromEnum(PrimitiveIndex.load_locals)] = ctx.primitive_load_locals;

    // Diagnostics / GC primitives
    table[@intFromEnum(PrimitiveIndex.die)] = diag.primitive_die;
    table[@intFromEnum(PrimitiveIndex.minor_gc)] = diag.primitive_minor_gc;
    table[@intFromEnum(PrimitiveIndex.full_gc)] = diag.primitive_full_gc;
    table[@intFromEnum(PrimitiveIndex.compact_gc)] = diag.primitive_compact_gc;
    table[@intFromEnum(PrimitiveIndex.enable_gc_events)] = diag.primitive_enable_gc_events;
    table[@intFromEnum(PrimitiveIndex.disable_gc_events)] = diag.primitive_disable_gc_events;
    table[@intFromEnum(PrimitiveIndex.data_room)] = diag.primitive_data_room;
    table[@intFromEnum(PrimitiveIndex.code_room)] = diag.primitive_code_room;
    table[@intFromEnum(PrimitiveIndex.callback_room)] = diag.primitive_callback_room;
    table[@intFromEnum(PrimitiveIndex.all_instances)] = diag.primitive_all_instances;
    table[@intFromEnum(PrimitiveIndex.reset_dispatch_stats)] = diag.primitive_reset_dispatch_stats;
    table[@intFromEnum(PrimitiveIndex.dispatch_stats)] = diag.primitive_dispatch_stats;
    table[@intFromEnum(PrimitiveIndex.set_profiling)] = diag.primitive_set_profiling;
    table[@intFromEnum(PrimitiveIndex.get_samples)] = diag.primitive_get_samples;

    // Code heap / compilation primitives
    table[@intFromEnum(PrimitiveIndex.modify_code_heap)] = code.primitive_modify_code_heap;
    table[@intFromEnum(PrimitiveIndex.code_blocks)] = code.primitive_code_blocks;
    table[@intFromEnum(PrimitiveIndex.strip_stack_traces)] = code.primitive_strip_stack_traces;
    table[@intFromEnum(PrimitiveIndex.innermost_stack_frame_executing)] = code.primitive_innermost_stack_frame_executing;
    table[@intFromEnum(PrimitiveIndex.innermost_stack_frame_scan)] = code.primitive_innermost_stack_frame_scan;
    table[@intFromEnum(PrimitiveIndex.set_innermost_stack_frame_quotation)] = code.primitive_set_innermost_stack_frame_quotation;
    table[@intFromEnum(PrimitiveIndex.quotation_compiled_p)] = code.primitive_quotation_compiled_p;
    table[@intFromEnum(PrimitiveIndex.jit_compile)] = code.primitive_jit_compile;
    table[@intFromEnum(PrimitiveIndex.array_to_quotation)] = code.primitive_array_to_quotation;
    table[@intFromEnum(PrimitiveIndex.word_optimized_p)] = code.primitive_word_optimized_p;
    table[@intFromEnum(PrimitiveIndex.lookup_method)] = code.primitive_lookup_method;
    table[@intFromEnum(PrimitiveIndex.mega_cache_miss)] = code.primitive_mega_cache_miss;
    table[@intFromEnum(PrimitiveIndex.callstack_for)] = code.primitive_callstack_for;
    table[@intFromEnum(PrimitiveIndex.callstack_to_array)] = callstack_mod.primitive_callstack_to_array;
    table[@intFromEnum(PrimitiveIndex.callstack_bounds)] = callstack_mod.primitive_callstack_bounds;

    // I/O primitives
    table[@intFromEnum(PrimitiveIndex.fopen)] = io_prims.primitive_fopen;
    table[@intFromEnum(PrimitiveIndex.fclose)] = io_prims.primitive_fclose;
    table[@intFromEnum(PrimitiveIndex.fflush)] = io_prims.primitive_fflush;
    table[@intFromEnum(PrimitiveIndex.fgetc)] = io_prims.primitive_fgetc;
    table[@intFromEnum(PrimitiveIndex.fputc)] = io_prims.primitive_fputc;
    table[@intFromEnum(PrimitiveIndex.fread)] = io_prims.primitive_fread;
    table[@intFromEnum(PrimitiveIndex.fwrite)] = io_prims.primitive_fwrite;
    table[@intFromEnum(PrimitiveIndex.ftell)] = io_prims.primitive_ftell;
    table[@intFromEnum(PrimitiveIndex.fseek)] = io_prims.primitive_fseek;
    table[@intFromEnum(PrimitiveIndex.existsp)] = io_prims.primitive_existsp;
    table[@intFromEnum(PrimitiveIndex.save_image)] = io_prims.primitive_save_image;

    // Math primitives
    table[@intFromEnum(PrimitiveIndex.fixnum_to_bignum)] = math_prims.primitive_fixnum_to_bignum;
    table[@intFromEnum(PrimitiveIndex.fixnum_to_float)] = math_prims.primitive_fixnum_to_float;
    table[@intFromEnum(PrimitiveIndex.fixnum_shift)] = math_prims.primitive_fixnum_shift;
    table[@intFromEnum(PrimitiveIndex.fixnum_divint)] = math_prims.primitive_fixnum_divint;
    table[@intFromEnum(PrimitiveIndex.fixnum_divmod)] = math_prims.primitive_fixnum_divmod;
    table[@intFromEnum(PrimitiveIndex.bignum_to_fixnum)] = math_prims.primitive_bignum_to_fixnum;
    table[@intFromEnum(PrimitiveIndex.bignum_to_fixnum_strict)] = math_prims.primitive_bignum_to_fixnum_strict;
    table[@intFromEnum(PrimitiveIndex.bignum_add)] = math_prims.primitive_bignum_add;
    table[@intFromEnum(PrimitiveIndex.bignum_subtract)] = math_prims.primitive_bignum_subtract;
    table[@intFromEnum(PrimitiveIndex.bignum_multiply)] = math_prims.primitive_bignum_multiply;
    table[@intFromEnum(PrimitiveIndex.bignum_divint)] = math_prims.primitive_bignum_divint;
    table[@intFromEnum(PrimitiveIndex.bignum_divmod)] = math_prims.primitive_bignum_divmod;
    table[@intFromEnum(PrimitiveIndex.bignum_mod)] = math_prims.primitive_bignum_mod;
    table[@intFromEnum(PrimitiveIndex.bignum_gcd)] = math_prims.primitive_bignum_gcd;
    table[@intFromEnum(PrimitiveIndex.bignum_and)] = math_prims.primitive_bignum_and;
    table[@intFromEnum(PrimitiveIndex.bignum_or)] = math_prims.primitive_bignum_or;
    table[@intFromEnum(PrimitiveIndex.bignum_xor)] = math_prims.primitive_bignum_xor;
    table[@intFromEnum(PrimitiveIndex.bignum_not)] = math_prims.primitive_bignum_not;
    table[@intFromEnum(PrimitiveIndex.bignum_shift)] = math_prims.primitive_bignum_shift;
    table[@intFromEnum(PrimitiveIndex.bignum_less)] = math_prims.primitive_bignum_less;
    table[@intFromEnum(PrimitiveIndex.bignum_lesseq)] = math_prims.primitive_bignum_lesseq;
    table[@intFromEnum(PrimitiveIndex.bignum_eq)] = math_prims.primitive_bignum_eq;
    table[@intFromEnum(PrimitiveIndex.bignum_greater)] = math_prims.primitive_bignum_greater;
    table[@intFromEnum(PrimitiveIndex.bignum_greatereq)] = math_prims.primitive_bignum_greatereq;
    table[@intFromEnum(PrimitiveIndex.bignum_bitp)] = math_prims.primitive_bignum_bitp;
    table[@intFromEnum(PrimitiveIndex.bignum_log2)] = math_prims.primitive_bignum_log2;
    table[@intFromEnum(PrimitiveIndex.float_to_fixnum)] = math_prims.primitive_float_to_fixnum;
    table[@intFromEnum(PrimitiveIndex.float_to_bignum)] = math_prims.primitive_float_to_bignum;
    table[@intFromEnum(PrimitiveIndex.float_add)] = math_prims.primitive_float_add;
    table[@intFromEnum(PrimitiveIndex.float_subtract)] = math_prims.primitive_float_subtract;
    table[@intFromEnum(PrimitiveIndex.float_multiply)] = math_prims.primitive_float_multiply;
    table[@intFromEnum(PrimitiveIndex.float_divfloat)] = math_prims.primitive_float_divfloat;
    table[@intFromEnum(PrimitiveIndex.float_less)] = math_prims.primitive_float_less;
    table[@intFromEnum(PrimitiveIndex.float_lesseq)] = math_prims.primitive_float_lesseq;
    table[@intFromEnum(PrimitiveIndex.float_eq)] = math_prims.primitive_float_eq;
    table[@intFromEnum(PrimitiveIndex.float_greater)] = math_prims.primitive_float_greater;
    table[@intFromEnum(PrimitiveIndex.float_greatereq)] = math_prims.primitive_float_greatereq;
    table[@intFromEnum(PrimitiveIndex.float_bits)] = math_prims.primitive_float_bits;
    table[@intFromEnum(PrimitiveIndex.bits_float)] = math_prims.primitive_bits_float;
    table[@intFromEnum(PrimitiveIndex.double_bits)] = math_prims.primitive_double_bits;
    table[@intFromEnum(PrimitiveIndex.bits_double)] = math_prims.primitive_bits_double;
    table[@intFromEnum(PrimitiveIndex.format_float)] = math_prims.primitive_format_float;

    // Misc primitives
    table[@intFromEnum(PrimitiveIndex.exit)] = misc.primitive_exit;
    table[@intFromEnum(PrimitiveIndex.nano_count)] = misc.primitive_nano_count;
    table[@intFromEnum(PrimitiveIndex.sleep)] = misc.primitive_sleep;
    table[@intFromEnum(PrimitiveIndex.size)] = misc.primitive_size;
    table[@intFromEnum(PrimitiveIndex.enable_ctrl_break)] = misc.primitive_enable_ctrl_break;
    table[@intFromEnum(PrimitiveIndex.disable_ctrl_break)] = misc.primitive_disable_ctrl_break;

    // Alien/FFI primitives
    table[@intFromEnum(PrimitiveIndex.alien_address)] = ffi.primitive_alien_address;
    table[@intFromEnum(PrimitiveIndex.displaced_alien)] = ffi.primitive_displaced_alien;
    table[@intFromEnum(PrimitiveIndex.alien_cell)] = ffi.primitive_alien_cell;
    table[@intFromEnum(PrimitiveIndex.set_alien_cell)] = ffi.primitive_set_alien_cell;
    table[@intFromEnum(PrimitiveIndex.alien_signed_cell)] = ffi.primitive_alien_signed_cell;
    table[@intFromEnum(PrimitiveIndex.set_alien_signed_cell)] = ffi.primitive_set_alien_signed_cell;
    table[@intFromEnum(PrimitiveIndex.alien_unsigned_cell)] = ffi.primitive_alien_unsigned_cell;
    table[@intFromEnum(PrimitiveIndex.set_alien_unsigned_cell)] = ffi.primitive_set_alien_unsigned_cell;
    table[@intFromEnum(PrimitiveIndex.alien_signed_1)] = ffi.primitive_alien_signed_1;
    table[@intFromEnum(PrimitiveIndex.set_alien_signed_1)] = ffi.primitive_set_alien_signed_1;
    table[@intFromEnum(PrimitiveIndex.alien_unsigned_1)] = ffi.primitive_alien_unsigned_1;
    table[@intFromEnum(PrimitiveIndex.set_alien_unsigned_1)] = ffi.primitive_set_alien_unsigned_1;
    table[@intFromEnum(PrimitiveIndex.alien_signed_2)] = ffi.primitive_alien_signed_2;
    table[@intFromEnum(PrimitiveIndex.set_alien_signed_2)] = ffi.primitive_set_alien_signed_2;
    table[@intFromEnum(PrimitiveIndex.alien_unsigned_2)] = ffi.primitive_alien_unsigned_2;
    table[@intFromEnum(PrimitiveIndex.set_alien_unsigned_2)] = ffi.primitive_set_alien_unsigned_2;
    table[@intFromEnum(PrimitiveIndex.alien_signed_4)] = ffi.primitive_alien_signed_4;
    table[@intFromEnum(PrimitiveIndex.set_alien_signed_4)] = ffi.primitive_set_alien_signed_4;
    table[@intFromEnum(PrimitiveIndex.alien_unsigned_4)] = ffi.primitive_alien_unsigned_4;
    table[@intFromEnum(PrimitiveIndex.set_alien_unsigned_4)] = ffi.primitive_set_alien_unsigned_4;
    table[@intFromEnum(PrimitiveIndex.alien_signed_8)] = ffi.primitive_alien_signed_8;
    table[@intFromEnum(PrimitiveIndex.set_alien_signed_8)] = ffi.primitive_set_alien_signed_8;
    table[@intFromEnum(PrimitiveIndex.alien_unsigned_8)] = ffi.primitive_alien_unsigned_8;
    table[@intFromEnum(PrimitiveIndex.set_alien_unsigned_8)] = ffi.primitive_set_alien_unsigned_8;
    table[@intFromEnum(PrimitiveIndex.alien_float)] = ffi.primitive_alien_float;
    table[@intFromEnum(PrimitiveIndex.set_alien_float)] = ffi.primitive_set_alien_float;
    table[@intFromEnum(PrimitiveIndex.alien_double)] = ffi.primitive_alien_double;
    table[@intFromEnum(PrimitiveIndex.set_alien_double)] = ffi.primitive_set_alien_double;
    table[@intFromEnum(PrimitiveIndex.dlopen)] = ffi.primitive_dlopen;
    table[@intFromEnum(PrimitiveIndex.dlsym)] = ffi.primitive_dlsym;
    table[@intFromEnum(PrimitiveIndex.dlclose)] = ffi.primitive_dlclose;
    table[@intFromEnum(PrimitiveIndex.dll_validp)] = ffi.primitive_dll_validp;
    table[@intFromEnum(PrimitiveIndex.current_callback)] = ffi.primitive_current_callback;
    table[@intFromEnum(PrimitiveIndex.callback)] = ffi.primitive_callback;
    table[@intFromEnum(PrimitiveIndex.free_callback)] = ffi.primitive_free_callback;

    return table;
}

// Call a primitive by index
pub inline fn callPrimitive(vm: *FactorVM, index: u16) void {
    if (comptime builtin.mode == .Debug or builtin.mode == .ReleaseSafe) {
        if (index >= primitive_count) return;
    }
    primitives[index](&vm.vm_asm);
}

// --- Integer conversion helpers (called directly by FFI code) ---

pub export fn to_unsigned_8(n: Cell, vm_asm: *VMAssemblyFields) callconv(.c) u64 {
    switch (layouts.typeTag(n)) {
        .fixnum => return layouts.untagFixnumUnsigned(n),
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
        math_prims.primitive_float_lesseq,
        math_prims.primitive_float_greater,
        math_prims.primitive_float_greatereq,
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

    var test_obj: [3]Cell = .{ 0, 0, 0 };
    test_obj[0] = @as(Cell, @intFromEnum(layouts.TypeTag.array)) << 2;
    test_obj[1] = layouts.tagFixnum(1);
    test_obj[2] = layouts.tagFixnum(123);

    const obj_addr = @intFromPtr(&test_obj) | @intFromEnum(layouts.TypeTag.array);

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
