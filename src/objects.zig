// objects.zig - Special object indices
// Must be kept in sync with:
//   core/kernel/kernel.factor
//   basis/bootstrap/image/image.factor

const std = @import("std");
const layouts = @import("layouts.zig");
const Cell = layouts.Cell;

pub const special_object_count: Cell = 85;

// Special object indices
pub const SpecialObject = enum(Cell) {
    // non-local exit hook, used by library only
    walker_hook = 3,
    // used to pass the value in callcc1
    callcc_1 = 4,

    // quotation called when VM throws an error
    error_handler_quot = 5,

    // sizeof(cell)
    cell_size = 7,
    // CPU architecture
    cpu = 8,
    // operating system name
    os = 9,

    // command line arguments
    args = 10,
    // stdin FILE* handle
    stdin = 11,
    // stdout FILE* handle
    stdout = 12,

    // image path name
    image = 13,
    // runtime executable path name
    executable = 14,

    // are we embedded in another app?
    embedded = 15,
    // used when Factor is embedded in a C app
    eval_callback = 16,
    // used when Factor is embedded in a C app
    yield_callback = 17,
    // used when Factor is embedded in a C app
    sleep_callback = 18,

    // startup quotation
    startup_quot = 20,
    // global namespace
    global = 21,
    // shutdown quotation
    shutdown_quot = 22,

    // Quotation compilation in quotations.cpp
    jit_prolog = 23,
    jit_primitive_word = 24,
    jit_primitive = 25,
    jit_word_jump = 26,
    jit_word_call = 27,
    jit_if_word = 28,
    jit_if = 29,
    jit_safepoint = 30,
    jit_epilog = 31,
    jit_return = 32,
    jit_unused = 33,
    jit_push_literal = 34,
    jit_dip_word = 35,
    jit_dip = 36,
    jit_2dip_word = 37,
    jit_2dip = 38,
    jit_3dip_word = 39,
    jit_3dip = 40,
    jit_execute = 41,
    jit_declare_word = 42,

    // External entry points (defined in bootstrap/assembler/)
    c_to_factor_word = 43,
    lazy_jit_compile_word = 44,
    unwind_native_frames_word = 45,
    get_fpu_state_word = 46,
    set_fpu_state_word = 47,
    signal_handler_word = 48,
    leaf_signal_handler_word = 49,
    win_exception_handler = 50,

    // Vector used by the sampling profiler to store collected call frames
    sample_callstacks = 51,

    // Incremented on every modify-code-heap call; invalidates call inline caching
    redefinition_counter = 52,

    // Callback stub generation in callbacks.cpp
    callback_stub = 53,

    // Polymorphic inline cache generation in inline_cache.cpp
    pic_load = 54,
    pic_tag = 55,
    pic_tuple = 56,
    pic_check_tag = 57,
    pic_check_tuple = 58,
    pic_hit = 59,
    pic_miss_word = 60,
    pic_miss_tail_word = 61,

    // Megamorphic cache generation in dispatch.cpp
    mega_lookup = 62,
    mega_lookup_word = 63,
    mega_miss_word = 64,

    // default quotation for undefined words
    undefined = 65,

    // stderr FILE* handle
    stderr = 66,

    // have we bootstrapped?
    stage2 = 67,

    current_thread = 68,

    threads = 69,
    run_queue = 70,
    sleep_queue = 71,

    // version string of the compiler we were built with
    vm_compiler = 72,

    waiting_callbacks = 73,

    // file descriptor for pipe used to communicate signals (unix only)
    signal_pipe = 74,
    // when the binary was built
    vm_compile_time = 75,
    // factor version
    vm_version = 76,
    // git label (git describe --all --long)
    vm_git_label = 77,

    // Canonical truth value. In Factor, 't'
    canonical_true = 78,

    // Canonical bignums. These need to be kept in the image in case
    // some heap objects refer to them.
    bignum_zero = 79,
    bignum_pos_one = 80,
    bignum_neg_one = 81,
};

// Determine if a special object should be saved in images
// save-image-and-exit discards special objects that are filled in on startup
// anyway, to reduce image size
pub fn isSaveSpecial(i: Cell) bool {
    return (i >= @intFromEnum(SpecialObject.startup_quot) and
        i <= @intFromEnum(SpecialObject.leaf_signal_handler_word)) or
        (i >= @intFromEnum(SpecialObject.redefinition_counter) and
            i <= @intFromEnum(SpecialObject.undefined)) or
        i == @intFromEnum(SpecialObject.stage2) or
        (i >= @intFromEnum(SpecialObject.canonical_true) and
            i <= @intFromEnum(SpecialObject.bignum_neg_one));
}

pub const context_object_count: Cell = 4;
