USING: alien alien.strings arrays assocs byte-arrays
io.encodings.ascii kernel kernel.private math quotations
sequences sequences.generalizations sequences.private strings words ;
IN: bootstrap.image.primitives

CONSTANT: all-primitives {
    {
        "alien"
        {
            {
                "<callback>" ( word return-rewind -- alien ) "callback"
                { word integer } { alien } f
            }
            {
                "<displaced-alien>" ( displacement c-ptr -- alien ) "displaced_alien"
                { integer c-ptr } { c-ptr } make-flushable
            }
            {
                "alien-address" ( c-ptr -- addr ) "alien_address"
                { alien } { integer } make-flushable
            }
            { "free-callback" ( alien -- ) "free_callback" { alien } { } f }
        }
    }
    {
        "alien.private"
        {
            { "current-callback" ( -- n ) "current_callback" { } { fixnum } make-flushable }
        }
    }
    {
        "alien.accessors"
        {
            {
                "alien-cell" ( c-ptr n -- value ) "alien_cell"
                { c-ptr integer } { pinned-c-ptr } make-flushable
            }
            {
                "alien-double" ( c-ptr n -- value ) "alien_double"
                { c-ptr integer } { float } make-flushable
            }
            {
                "alien-float" ( c-ptr n -- value ) "alien_float"
                { c-ptr integer } { float } make-flushable
            }
            {
                "alien-signed-1" ( c-ptr n -- value ) "alien_signed_1"
                { c-ptr integer } { fixnum } make-flushable
            }
            {
                "alien-signed-2" ( c-ptr n -- value ) "alien_signed_2"
                { c-ptr integer } { fixnum } make-flushable
            }
            {
                "alien-signed-4" ( c-ptr n -- value ) "alien_signed_4"
                { c-ptr integer } { integer } make-flushable
            }
            {
                "alien-signed-8" ( c-ptr n -- value ) "alien_signed_8"
                { c-ptr integer } { integer } make-flushable
            }
            {
                "alien-signed-cell" ( c-ptr n -- value ) "alien_signed_cell"
                { c-ptr integer } { integer } make-flushable
            }
            {
                "alien-unsigned-1" ( c-ptr n -- value ) "alien_unsigned_1"
                { c-ptr integer } { fixnum } make-flushable
            }
            {
                "alien-unsigned-2" ( c-ptr n -- value ) "alien_unsigned_2"
                { c-ptr integer } { fixnum } make-flushable
            }
            {
                "alien-unsigned-4" ( c-ptr n -- value ) "alien_unsigned_4"
                { c-ptr integer } { integer } make-flushable
            }
            {
                "alien-unsigned-8" ( c-ptr n -- value ) "alien_unsigned_8"
                { c-ptr integer } { integer } make-flushable
            }
            {
                "alien-unsigned-cell" ( c-ptr n -- value ) "alien_unsigned_cell"
                { c-ptr integer } { integer } make-flushable
            }
            {
                "set-alien-cell" ( value c-ptr n -- ) "set_alien_cell"
                { c-ptr c-ptr integer } { } f
            }
            {
                "set-alien-double" ( value c-ptr n -- ) "set_alien_double"
                { float c-ptr integer } { } f
            }
            {
                "set-alien-float" ( value c-ptr n -- ) "set_alien_float"
                { float c-ptr integer } { } f
            }
            {
                "set-alien-signed-1" ( value c-ptr n -- ) "set_alien_signed_1"
                { integer c-ptr integer } { } f
            }
            {
                "set-alien-signed-2" ( value c-ptr n -- ) "set_alien_signed_2"
                { integer c-ptr integer } { } f
            }
            {
                "set-alien-signed-4" ( value c-ptr n -- ) "set_alien_signed_4"
                { integer c-ptr integer } { } f
            }
            {
                "set-alien-signed-8" ( value c-ptr n -- ) "set_alien_signed_8"
                { integer c-ptr integer } { } f
            }
            {
                "set-alien-signed-cell" ( value c-ptr n -- ) "set_alien_signed_cell"
                { integer c-ptr integer } { } f
            }
            {
                "set-alien-unsigned-1" ( value c-ptr n -- ) "set_alien_unsigned_1"
                { integer c-ptr integer } { } f
            }
            {
                "set-alien-unsigned-2" ( value c-ptr n -- ) "set_alien_unsigned_2"
                { integer c-ptr integer } { } f
            }
            {
                "set-alien-unsigned-4" ( value c-ptr n -- ) "set_alien_unsigned_4"
                { integer c-ptr integer } { } f
            }
            {
                "set-alien-unsigned-8" ( value c-ptr n -- ) "set_alien_unsigned_8"
                { integer c-ptr integer } { } f
            }
            {
                "set-alien-unsigned-cell" ( value c-ptr n -- ) "set_alien_unsigned_cell"
                { integer c-ptr integer } { } f
            }
        }
    }
    {
        "alien.libraries"
        {
            { "(dlopen)" ( path -- dll ) "dlopen" { byte-array } { dll } f }
            { "(dlsym)" ( name dll -- alien ) "dlsym" { byte-array object } { c-ptr } f }
            { "dlclose" ( dll -- ) "dlclose" { dll } { } f }
            { "dll-valid?" ( dll -- ? ) "dll_validp" { object } { object } f }
        }
    }
    {
        "arrays"
        {
            {
                "<array>" ( n elt -- array ) "array"
                { integer-array-capacity object } { array } make-flushable
            }
            {
                "resize-array" ( n array -- new-array ) "resize_array"
                { integer array } { array } f
            }
        }
    }
    {
        "byte-arrays"
        {
            {
                "(byte-array)" ( n -- byte-array ) "uninitialized_byte_array"
                { integer-array-capacity } { byte-array } make-flushable
            }
            {
                "<byte-array>" ( n -- byte-array ) "byte_array"
                { integer-array-capacity } { byte-array } make-flushable
            }
            {
                "resize-byte-array" ( n byte-array -- new-byte-array )
                "resize_byte_array"
                { integer-array-capacity byte-array } { byte-array } f
            }
        }
    }
    {
        "classes.tuple.private"
        {
            {
                "<tuple-boa>" ( slots... layout -- tuple ) "tuple_boa"
                f f make-flushable
            }
            {
                "<tuple>" ( layout -- tuple ) "tuple"
                { array } { tuple } make-flushable
            }
        }
    }
    {
        "compiler.units"
        {
            {
                "modify-code-heap" ( alist update-existing? reset-pics? -- )
                "modify_code_heap"
                { array object object } { } f
            }
        }
    }
    {
        "formatting.private"
        {
            {
                "(format-float)" ( n fill width precision format locale -- byte-array )
                "format_float"
                { float byte-array fixnum fixnum byte-array byte-array } { byte-array }
                make-flushable
            }
        }
    }
    {
        "generic.single.private"
        {
            { "inline-cache-miss" ( generic methods index cache -- ) f f f f }
            { "inline-cache-miss-tail" ( generic methods index cache -- ) f f f f }
            {
                "lookup-method" ( object methods -- method ) "lookup_method"
                { object array } { word } f
            }
            { "mega-cache-lookup" ( methods index cache -- ) f f f f }
            { "mega-cache-miss" ( methods index cache -- method ) "mega_cache_miss" f f f }
        }
    }
    {
        "io.files.private"
        {
            { "(file-exists?)" ( path -- ? ) "existsp" { string } { object } f }
        }
    }
    {
        "io.streams.c"
        {
            {
                "(fopen)" ( path mode -- alien ) "fopen"
                { byte-array byte-array } { alien } f
            }
            { "fclose" ( alien -- ) "fclose" { alien } { } f }
            { "fflush" ( alien -- ) "fflush" { alien } { } f }
            { "fgetc" ( alien -- byte/f ) "fgetc" { alien } { object } f }
            { "fputc" ( byte alien -- ) "fputc" { object alien } { } f }
            {
                "fread-unsafe" ( n buf alien -- count ) "fread"
                { integer c-ptr alien } { integer } f
            }
            {
                "fseek" ( offset whence alien -- ) "fseek"
                { integer integer alien } { } f
            }
            { "ftell" ( alien -- n ) "ftell" { alien } { integer } f }
            { "fwrite" ( data length alien -- ) "fwrite" { c-ptr integer alien } { } f }
        }
    }
    {
        "kernel"
        {
            { "(clone)" ( obj -- newobj ) "clone" { object } { object } make-flushable }
            {
                "<wrapper>" ( obj -- wrapper ) "wrapper"
                { object } { wrapper } make-foldable
            }
            {
                "callstack>array" ( callstack -- array ) "callstack_to_array"
                { callstack } { array } make-flushable
            }
            { "die" ( -- ) "die" { } { } f }
            { "drop" ( x -- ) f f f f }
            { "2drop" ( x y -- ) f f f f }
            { "3drop" ( x y z -- ) f f f f }
            { "4drop" ( w x y z -- ) f f f f }
            { "dup" ( x -- x x ) f f f f }
            { "2dup" ( x y -- x y x y ) f f f f }
            { "3dup" ( x y z -- x y z x y z ) f f f f }
            { "4dup" ( w x y z -- w x y z w x y z ) f f f f }
            { "rot" ( x y z -- y z x ) f f f f }
            { "-rot" ( x y z -- z x y ) f f f f }
            { "dupd" ( x y -- x x y ) f f f f }
            { "swapd" ( x y z -- y x z ) f f f f }
            { "nip" ( x y -- y ) f f f f }
            { "2nip" ( x y z -- z ) f f f f }
            { "over" ( x y -- x y x ) f f f f }
            { "pick" ( x y z -- x y z x ) f f f f }
            { "swap" ( x y -- y x ) f f f f }
            { "eq?" ( obj1 obj2 -- ? ) f { object object } { object } make-foldable }
        }
    }
    {
        "kernel.private"
        {
            { "(call)" ( quot -- ) f f f f }
            { "(execute)" ( word -- ) f f f f }
            { "c-to-factor" ( -- ) f f f f }
            { "fpu-state" ( -- ) f { } { } f }
            { "lazy-jit-compile" ( -- ) f f f f }
            { "leaf-signal-handler" ( -- ) f { } { } f }
            { "set-callstack" ( callstack -- * ) f f f f }
            { "set-fpu-state" ( -- ) f { } { } f }
            { "signal-handler" ( -- ) f { } { } f }
            {
                "tag" ( object -- n ) f
                { object } { fixnum } make-foldable
            }
            { "unwind-native-frames" ( -- ) f f f f }
            {
                "callstack-for" ( context -- array ) "callstack_for"
                { c-ptr } { callstack } make-flushable
            }
            {
                "datastack-for" ( context -- array ) "datastack_for"
                { c-ptr } { array } make-flushable
            }
            {
                "retainstack-for" ( context -- array ) "retainstack_for"
                { c-ptr } { array } make-flushable
            }
            {
                "(identity-hashcode)" ( obj -- code ) "identity_hashcode"
                { object } { fixnum } f
            }
            { "become" ( old new -- ) "become" { array array } { } f }
            {
                "callstack-bounds" ( -- start end ) "callstack_bounds"
                { } { alien alien } make-flushable
            }
            {
                "check-datastack" ( array in# out# -- ? ) "check_datastack"
                { array integer integer } { object } make-flushable
            }
            {
                "compute-identity-hashcode" ( obj -- ) "compute_identity_hashcode"
                { object } { } f
            }
            {
                "context-object" ( n -- obj ) "context_object"
                { fixnum } { object } make-flushable
            }
            {
                "innermost-frame-executing" ( callstack -- obj )
                "innermost_stack_frame_executing"
                { callstack } { object } f
            }
            {
                "innermost-frame-scan" ( callstack -- n ) "innermost_stack_frame_scan"
                { callstack } { fixnum } f
            }
            {
                "set-context-object" ( obj n -- ) "set_context_object"
                { object fixnum } { } f
            }
            { "set-datastack" ( array -- ) "set_datastack" f f f }
            {
                "set-innermost-frame-quotation" ( n callstack -- )
                "set_innermost_stack_frame_quotation"
                { quotation callstack } { } f
            }
            { "set-retainstack" ( array -- ) "set_retainstack" f f f }
            {
                "set-special-object" ( obj n -- ) "set_special_object"
                { object fixnum } { } f
            }
            {
                "special-object" ( n -- obj ) "special_object"
                { fixnum } { object } make-flushable
            }
            {
                "strip-stack-traces" ( -- ) "strip_stack_traces"
                { } { } f
            }
        }
    }
    {
        "locals.backend"
        {
            { "drop-locals" ( n -- ) f f f f }
            { "get-local" ( n -- obj ) f f f f }
            { "load-local" ( obj -- ) f f f f }
            { "load-locals" ( ... n -- ) "load_locals" f f f }
        }
    }
    {
        "math"
        {
            {
                "bits>double" ( n -- x ) "bits_double"
                { integer } { float } make-foldable
            }
            {
                "bits>float" ( n -- x ) "bits_float"
                { integer } { float } make-foldable
            }
            {
                "double>bits" ( x -- n ) "double_bits"
                { real } { integer } make-foldable
            }
            {
                "float>bits" ( x -- n ) "float_bits"
                { real } { integer } make-foldable
            }
        }
    }
    {
        "math.private"
        {
            {
                "both-fixnums?" ( x y -- ? ) f
                { object object } { object } make-foldable
            }
            {
                "fixnum+fast" ( x y -- z ) f
                { fixnum fixnum } { fixnum } make-foldable
            }
            {
                "fixnum-fast" ( x y -- z ) f
                { fixnum fixnum } { fixnum } make-foldable
            }
            {
                "fixnum*fast" ( x y -- z ) f
                { fixnum fixnum } { fixnum } make-foldable
            }
            {
                "fixnum-bitand" ( x y -- z ) f
                { fixnum fixnum } { fixnum } make-foldable
            }
            {
                "fixnum-bitor" ( x y -- z ) f
                { fixnum fixnum } { fixnum } make-foldable
            }
            {
                "fixnum-bitxor" ( x y -- z ) f
                { fixnum fixnum } { fixnum } make-foldable
            }
            {
                "fixnum-bitnot" ( x -- y ) f
                { fixnum } { fixnum } make-foldable
            }
            {
                "fixnum-mod" ( x y -- z ) f
                { fixnum fixnum } { fixnum } make-foldable
            }
            {
                "fixnum-shift" ( x y -- z ) "fixnum_shift"
                { fixnum fixnum } { integer } make-foldable
            }
            {
                "fixnum-shift-fast" ( x y -- z ) f
                { fixnum fixnum } { fixnum } make-foldable
            }
            {
                "fixnum/i-fast" ( x y -- z ) f
                { fixnum fixnum } { fixnum } make-foldable
            }
            {
                "fixnum/mod" ( x y -- z w ) "fixnum_divmod"
                { fixnum fixnum } { integer fixnum } make-foldable
            }
            {
                "fixnum/mod-fast" ( x y -- z w ) f
                { fixnum fixnum } { fixnum fixnum } make-foldable
            }
            {
                "fixnum+" ( x y -- z ) f
                { fixnum fixnum } { integer } make-foldable
            }
            {
                "fixnum-" ( x y -- z ) f
                { fixnum fixnum } { integer } make-foldable
            }
            {
                "fixnum*" ( x y -- z ) f
                { fixnum fixnum } { integer } make-foldable
            }
            {
                "fixnum<" ( x y -- ? ) f
                { fixnum fixnum } { object } make-foldable
            }
            {
                "fixnum<=" ( x y -- z ) f
                { fixnum fixnum } { object } make-foldable
            }
            {
                "fixnum>" ( x y -- ? ) f
                { fixnum fixnum } { object } make-foldable
            }
            {
                "fixnum>=" ( x y -- ? ) f
                { fixnum fixnum } { object } make-foldable
            }
            {
                "bignum*" ( x y -- z ) "bignum_multiply"
                { bignum bignum } { bignum } make-foldable
            }
            {
                "bignum+" ( x y -- z ) "bignum_add"
                { bignum bignum } { bignum } make-foldable
            }
            {
                "bignum-" ( x y -- z ) "bignum_subtract"
                { bignum bignum } { bignum } make-foldable
            }
            {
                "bignum-bit?" ( x n -- ? ) "bignum_bitp"
                { bignum integer } { object } make-foldable
            }
            {
                "bignum-bitand" ( x y -- z ) "bignum_and"
                { bignum bignum } { bignum } make-foldable
            }
            {
                "bignum-bitnot" ( x -- y ) "bignum_not"
                { bignum } { bignum } make-foldable
            }
            {
                "bignum-bitor" ( x y -- z ) "bignum_or"
                { bignum bignum } { bignum } make-foldable
            }
            {
                "bignum-bitxor" ( x y -- z ) "bignum_xor"
                { bignum bignum } { bignum } make-foldable
            }
            {
                "bignum-log2" ( x -- n ) "bignum_log2"
                { bignum } { bignum } make-foldable
            }
            {
                "bignum-mod" ( x y -- z ) "bignum_mod"
                { bignum bignum } { integer } make-foldable
            }
            {
                "bignum-gcd" ( x y -- z ) "bignum_gcd"
                { bignum bignum } { bignum } make-foldable
            }
            {
                "bignum-shift" ( x y -- z ) "bignum_shift"
                { bignum fixnum } { bignum } make-foldable
            }
            {
                "bignum/i" ( x y -- z ) "bignum_divint"
                { bignum bignum } { bignum } make-foldable
            }
            {
                "bignum/mod" ( x y -- z w ) "bignum_divmod"
                { bignum bignum } { bignum integer } make-foldable
            }
            {
                "bignum<" ( x y -- ? ) "bignum_less"
                { bignum bignum } { object } make-foldable
            }
            {
                "bignum<=" ( x y -- ? ) "bignum_lesseq"
                { bignum bignum } { object } make-foldable
            }
            {
                "bignum=" ( x y -- ? ) "bignum_eq"
                { bignum bignum } { object } make-foldable
            }
            {
                "bignum>" ( x y -- ? ) "bignum_greater"
                { bignum bignum } { object } make-foldable
            }
            {
                "bignum>=" ( x y -- ? ) "bignum_greatereq"
                { bignum bignum } { object } make-foldable
            }
            {
                "bignum>fixnum" ( x -- y ) "bignum_to_fixnum"
                { bignum } { fixnum } make-foldable
            }
            {
                "bignum>fixnum-strict" ( x -- y ) "bignum_to_fixnum_strict"
                { bignum } { fixnum } make-foldable
            }
            {
                "fixnum/i" ( x y -- z ) "fixnum_divint"
                { fixnum fixnum } { integer } make-foldable
            }
            {
                "fixnum>bignum" ( x -- y ) "fixnum_to_bignum"
                { fixnum } { bignum } make-foldable
            }
            {
                "fixnum>float" ( x -- y ) "fixnum_to_float"
                { fixnum } { float } make-foldable
            }
            {
                "float*" ( x y -- z ) "float_multiply"
                { float float } { float } make-foldable
            }
            {
                "float+" ( x y -- z ) "float_add"
                { float float } { float } make-foldable
            }
            {
                "float-" ( x y -- z ) "float_subtract"
                { float float } { float } make-foldable
            }
            ! -u ones redundant?
            {
                "float-u<" ( x y -- ? ) "float_less"
                { float float } { object } make-foldable
            }
            {
                "float-u<=" ( x y -- ? ) "float_lesseq"
                { float float } { object } make-foldable
            }
            {
                "float-u>" ( x y -- ? ) "float_greater"
                { float float } { object } make-foldable
            }
            {
                "float-u>=" ( x y -- ? ) "float_greatereq"
                { float float } { object } make-foldable
            }
            {
                "float/f" ( x y -- z ) "float_divfloat"
                { float float } { float } make-foldable
            }
            {
                "float<" ( x y -- ? ) "float_less"
                { float float } { object } make-foldable
            }
            {
                "float<=" ( x y -- ? ) "float_lesseq"
                { float float } { object } make-foldable
            }
            {
                "float=" ( x y -- ? ) "float_eq"
                { float float } { object } make-foldable
            }
            {
                "float>" ( x y -- ? ) "float_greater"
                { float float } { object } make-foldable
            }
            {
                "float>=" ( x y -- ? ) "float_greatereq"
                { float float } { object } make-foldable
            }
            {
                "float>bignum" ( x -- y ) "float_to_bignum"
                { float } { bignum } make-foldable
            }
            {
                "float>fixnum" ( x -- y ) "float_to_fixnum"
                { float } { fixnum } make-foldable
            }
        }
    }
    {
        "memory"
        {
            { "all-instances" ( -- array ) "all_instances" { } { array } f }
            { "compact-gc" ( -- ) "compact_gc" { } { } f }
            { "gc" ( -- ) "full_gc" { } { } f }
            { "minor-gc" ( -- ) "minor_gc" { } { } f }
            { "size" ( obj -- n ) "size" { object } { fixnum } make-flushable }
        }
    }
    {
        "memory.private"
        {
            {
                "(save-image)" ( path1 path2 then-die? -- ) "save_image"
                { byte-array byte-array object } { } f
            }
        }
    }
    {
        "quotations"
        {
            { "jit-compile" ( quot -- ) "jit_compile" { quotation } { } f }
            {
                "quotation-code" ( quot -- start end ) "quotation_code"
                { quotation } { integer integer } make-flushable
            }
            {
                "quotation-compiled?" ( quot -- ? ) "quotation_compiled_p"
                { quotation } { object } f
            }
        }
    }
    {
        "quotations.private"
        {
            {
                "array>quotation" ( array -- quot ) "array_to_quotation"
                { array } { quotation } make-flushable
            }
        }
    }
    {
        "slots.private"
        {
            { "set-slot" ( value obj n -- ) "set_slot" { object object fixnum } { } f }
            { "slot" ( obj m -- value ) f { object fixnum } { object } make-flushable }
        }
    }
    {
        "strings"
        {
            {
                "<string>" ( n ch -- string ) "string"
                { integer-array-capacity integer } { string } make-flushable
            }
            {
                "resize-string" ( n str -- newstr ) "resize_string"
                { integer string } { string } f
            }
        }
    }
    {
        "strings.private"
        {
            {
                "set-string-nth-fast" ( ch n string -- ) "set_string_nth_fast"
                { fixnum fixnum string } { } f
            }
            {
                "string-nth-fast" ( n string -- ch ) f
                { fixnum string } { fixnum } make-flushable
            }
        }
    }
    {
        "system"
        {
            { "(exit)" ( n -- * ) "exit" { integer } { } f }
            { "disable-ctrl-break" ( -- ) "disable_ctrl_break" { } { } f }
            { "enable-ctrl-break" ( -- ) "enable_ctrl_break" { } { } f }
            { "nano-count" ( -- ns ) "nano_count" { } { integer } make-flushable }
        }
    }
    {
        "threads.private"
        {
            { "(sleep)" ( nanos -- ) "sleep" { integer } { } f }
            { "(set-context)" ( obj context -- obj' ) f { object alien } { object } f }
            { "(set-context-and-delete)" ( obj context -- * ) f { object alien } { } f }
            { "(start-context)" ( obj quot -- obj' ) f { object quotation } { object } f }
            { "(start-context-and-delete)" ( obj quot -- * ) f { object quotation } { } f }
            {
                "context-object-for" ( n context -- obj ) "context_object_for"
                { fixnum c-ptr } { object } make-flushable
            }
        }
    }
    {
        "tools.dispatch.private"
        {
            { "dispatch-stats" ( -- stats ) "dispatch_stats" { } { byte-array } f }
            { "reset-dispatch-stats" ( -- ) "reset_dispatch_stats" { } { } f }
        }
    }
    {
        "tools.memory.private"
        {
            {
                "(callback-room)" ( -- allocator-room ) "callback_room"
                { } { byte-array } make-flushable
            }
            {
                "(code-blocks)" ( -- array ) "code_blocks"
                { } { array } make-flushable
            }
            {
                "(code-room)" ( -- allocator-room ) "code_room"
                { } { byte-array } make-flushable
            }
            {
                "(data-room)" ( -- data-room ) "data_room"
                { } { byte-array } make-flushable
            }
            { "disable-gc-events" ( -- events ) "disable_gc_events" { } { object } f }
            { "enable-gc-events" ( -- ) "enable_gc_events" { } { } f }
        }
    }
    {
        "tools.profiler.sampling.private"
        {
            { "set-profiling" ( n -- ) "set_profiling" { object } { } f }
            { "get-samples" ( -- samples/f ) "get_samples" { } { object } f }
        }
    }
    {
        "words"
        {
            {
                "word-code" ( word -- start end ) "word_code"
                { word } { integer integer } make-flushable
            }
            { "word-optimized?" ( word -- ? ) "word_optimized_p" { word } { object } f }
        }
    }
    {
        "words.private"
        {
            {
                "(word)" ( name vocab hashcode -- word ) "word"
                { object object object } { word } make-flushable
            }
        }
    }
}

: primitive-quot ( word vm-func -- quot )
    [
        nip "primitive_" prepend ascii string>alien [ do-primitive ] curry
    ] [ 1quotation ] if* ;

: primitive-word ( name vocab -- word )
    create-word dup t "primitive" set-word-prop ;

:: create-primitive ( vocab word effect vm-func inputs outputs extra-word -- )
    word vocab primitive-word :> word
    word vm-func primitive-quot :> quot
    word quot effect define-declared
    word inputs "input-classes" set-word-prop
    word outputs "default-output-classes" set-word-prop
    word extra-word [ execute( x -- ) ] [ drop ] if* ;

: create-primitives ( assoc -- )
    [
        [ 6 firstn create-primitive ] with each
    ] assoc-each ;
