USING: alien.strings assocs io.encodings.ascii kernel kernel.private
locals quotations sequences words ;
IN: bootstrap.image.primitives

CONSTANT: all-primitives {
    {
        "alien"
        {
            { "<callback>" ( word return-rewind -- alien ) "callback" }
            { "<displaced-alien>" ( displacement c-ptr -- alien ) "displaced_alien" }
            { "alien-address" ( c-ptr -- addr ) "alien_address" }
            { "free-callback" ( alien -- ) "free_callback" }
        }
    }
    {
        "alien.private"
        {
            { "current-callback" ( -- n ) "current_callback" }
        }
    }
    {
        "alien.accessors"
        {
            { "alien-cell" ( c-ptr n -- value ) "alien_cell" }
            { "alien-double" ( c-ptr n -- value ) "alien_double" }
            { "alien-float" ( c-ptr n -- value ) "alien_float" }

            { "alien-signed-1" ( c-ptr n -- value ) "alien_signed_1" }
            { "alien-signed-2" ( c-ptr n -- value ) "alien_signed_2" }
            { "alien-signed-4" ( c-ptr n -- value ) "alien_signed_4" }
            { "alien-signed-8" ( c-ptr n -- value ) "alien_signed_8" }
            { "alien-signed-cell" ( c-ptr n -- value ) "alien_signed_cell" }

            { "alien-unsigned-1" ( c-ptr n -- value ) "alien_unsigned_1" }
            { "alien-unsigned-2" ( c-ptr n -- value ) "alien_unsigned_2" }
            { "alien-unsigned-4" ( c-ptr n -- value ) "alien_unsigned_4" }
            { "alien-unsigned-8" ( c-ptr n -- value ) "alien_unsigned_8" }
            { "alien-unsigned-cell" ( c-ptr n -- value ) "alien_unsigned_cell" }

            { "set-alien-cell" ( value c-ptr n -- ) "set_alien_cell" }
            { "set-alien-double" ( value c-ptr n -- ) "set_alien_double" }
            { "set-alien-float" ( value c-ptr n -- ) "set_alien_float" }

            { "set-alien-signed-1" ( value c-ptr n -- ) "set_alien_signed_1" }
            { "set-alien-signed-2" ( value c-ptr n -- ) "set_alien_signed_2" }
            { "set-alien-signed-4" ( value c-ptr n -- ) "set_alien_signed_4" }
            { "set-alien-signed-8" ( value c-ptr n -- ) "set_alien_signed_8" }
            { "set-alien-signed-cell" ( value c-ptr n -- ) "set_alien_signed_cell" }

            { "set-alien-unsigned-1" ( value c-ptr n -- ) "set_alien_unsigned_1" }
            { "set-alien-unsigned-2" ( value c-ptr n -- ) "set_alien_unsigned_2" }
            { "set-alien-unsigned-4" ( value c-ptr n -- ) "set_alien_unsigned_4" }
            { "set-alien-unsigned-8" ( value c-ptr n -- ) "set_alien_unsigned_8" }
            { "set-alien-unsigned-cell" ( value c-ptr n -- ) "set_alien_unsigned_cell" }
        }
    }
    {
        "alien.libraries"
        {
            { "(dlopen)" ( path -- dll ) "dlopen" }
            { "(dlsym)" ( name dll -- alien ) "dlsym" }
            { "(dlsym-raw)" ( name dll -- alien ) "dlsym_raw" }
            { "dlclose" ( dll -- ) "dlclose" }
            { "dll-valid?" ( dll -- ? ) "dll_validp" }
        }
    }
    {
        "arrays"
        {
            { "<array>" ( n elt -- array ) "array" }
            { "resize-array" ( n array -- new-array ) "resize_array" }
        }
    }
    {
        "byte-arrays"
        {
            { "(byte-array)" ( n -- byte-array ) "uninitialized_byte_array" }
            { "<byte-array>" ( n -- byte-array ) "byte_array" }
            {
                "resize-byte-array" ( n byte-array -- new-byte-array )
                "resize_byte_array"
            }
        }
    }
    {
        "classes.tuple.private"
        {
            { "<tuple-boa>" ( slots... layout -- tuple ) "tuple_boa" }
            { "<tuple>" ( layout -- tuple ) "tuple" }
        }
    }
    {
        "compiler.units"
        {
            {
                "modify-code-heap" ( alist update-existing? reset-pics? -- )
                "modify_code_heap"
            }
        }
    }
    {
        "generic.single.private"
        {
            { "inline-cache-miss" ( generic methods index cache -- ) f }
            { "inline-cache-miss-tail" ( generic methods index cache -- ) f }
            { "lookup-method" ( object methods -- method ) "lookup_method" }
            { "mega-cache-lookup" ( methods index cache -- ) f }
            { "mega-cache-miss" ( methods index cache -- method ) "mega_cache_miss" }
        }
    }
    {
        "io.files.private"
        {
            { "(exists?)" ( path -- ? ) "existsp" }
        }
    }
    {
        "io.streams.c"
        {
            { "(fopen)" ( path mode -- alien ) "fopen" }
            { "fclose" ( alien -- ) "fclose" }
            { "fflush" ( alien -- ) "fflush" }
            { "fgetc" ( alien -- byte/f ) "fgetc" }
            { "fputc" ( byte alien -- ) "fputc" }
            { "fread-unsafe" ( n buf alien -- count ) "fread" }
            { "fseek" ( alien offset whence -- ) "fseek" }
            { "ftell" ( alien -- n ) "ftell" }
            { "fwrite" ( data length alien -- ) "fwrite" }
        }
    }
    {
        "kernel"
        {
            { "(clone)" ( obj -- newobj ) "clone" }
            { "<wrapper>" ( obj -- wrapper ) "wrapper" }
            { "callstack>array" ( callstack -- array ) "callstack_to_array" }
            { "die" ( -- ) "die" }
            { "drop" ( x -- ) f }
            { "2drop" ( x y -- ) f }
            { "3drop" ( x y z -- ) f }
            { "4drop" ( w x y z -- ) f }
            { "dup" ( x -- x x ) f }
            { "2dup" ( x y -- x y x y ) f }
            { "3dup" ( x y z -- x y z x y z ) f }
            { "4dup" ( w x y z -- w x y z w x y z ) f }
            { "rot" ( x y z -- y z x ) f }
            { "-rot" ( x y z -- z x y ) f }
            { "dupd" ( x y -- x x y ) f }
            { "swapd" ( x y z -- y x z ) f }
            { "nip" ( x y -- y ) f }
            { "2nip" ( x y z -- z ) f }
            { "over" ( x y -- x y x ) f }
            { "pick" ( x y z -- x y z x ) f }
            { "swap" ( x y -- y x ) f }
            { "eq?" ( obj1 obj2 -- ? ) f }
        }
    }
    {
        "kernel.private"
        {
            { "(call)" ( quot -- ) f }
            { "(execute)" ( word -- ) f }
            { "c-to-factor" ( -- ) f }
            { "fpu-state" ( -- ) f }
            { "lazy-jit-compile" ( -- ) f }
            { "leaf-signal-handler" ( -- ) f }
            { "set-callstack" ( callstack -- * ) f }
            { "set-fpu-state" ( -- ) f }
            { "signal-handler" ( -- ) f }
            { "tag" ( object -- n ) f }
            { "unwind-native-frames" ( -- ) f }

            { "callstack-for" ( context -- array ) "callstack_for" }
            { "datastack-for" ( context -- array ) "datastack_for" }
            { "retainstack-for" ( context -- array ) "retainstack_for" }
            { "(identity-hashcode)" ( obj -- code ) "identity_hashcode" }
            { "become" ( old new -- ) "become" }
            { "callstack-bounds" ( -- start end ) "callstack_bounds" }
            { "check-datastack" ( array in# out# -- ? ) "check_datastack" }
            { "compute-identity-hashcode" ( obj -- ) "compute_identity_hashcode" }
            { "context-object" ( n -- obj ) "context_object" }
            {
                "innermost-frame-executing" ( callstack -- obj )
                "innermost_stack_frame_executing"
            }
            {
                "innermost-frame-scan" ( callstack -- n )
                "innermost_stack_frame_scan"
            }
            { "set-context-object" ( obj n -- ) "set_context_object" }
            { "set-datastack" ( array -- ) "set_datastack" }
            {
                "set-innermost-frame-quotation" ( n callstack -- )
                "set_innermost_stack_frame_quotation"
            }
            { "set-retainstack" ( array -- ) "set_retainstack" }
            { "set-special-object" ( obj n -- ) "set_special_object" }
            { "special-object" ( n -- obj ) "special_object" }
            { "strip-stack-traces" ( -- ) "strip_stack_traces" }
            { "unimplemented" ( -- * ) "unimplemented" }
        }
    }
    {
        "locals.backend"
        {
            { "drop-locals" ( n -- ) f }
            { "get-local" ( n -- obj ) f }
            { "load-local" ( obj -- ) f }
            { "load-locals" ( ... n -- ) "load_locals" }
        }
    }
    {
        "math"
        {
            { "bits>double" ( n -- x ) "bits_double" }
            { "bits>float" ( n -- x ) "bits_float" }
            { "double>bits" ( x -- n ) "double_bits" }
            { "float>bits" ( x -- n ) "float_bits" }
        }
    }
    {
        "math.parser.private"
        {
            {
                "(format-float)" ( n fill width precision format locale -- byte-array )
                "format_float"
            }
        }
    }
    {
        "math.private"
        {
            { "both-fixnums?" ( x y -- ? ) f }
            { "fixnum+fast" ( x y -- z ) f }
            { "fixnum-fast" ( x y -- z ) f }
            { "fixnum*fast" ( x y -- z ) f }
            { "fixnum-bitand" ( x y -- z ) f }
            { "fixnum-bitor" ( x y -- z ) f }
            { "fixnum-bitxor" ( x y -- z ) f }
            { "fixnum-bitnot" ( x -- y ) f }
            { "fixnum-mod" ( x y -- z ) f }
            { "fixnum-shift-fast" ( x y -- z ) f }
            { "fixnum/i-fast" ( x y -- z ) f }
            { "fixnum/mod-fast" ( x y -- z w ) f }
            { "fixnum+" ( x y -- z ) f }
            { "fixnum-" ( x y -- z ) f }
            { "fixnum*" ( x y -- z ) f }
            { "fixnum<" ( x y -- ? ) f }
            { "fixnum<=" ( x y -- z ) f }
            { "fixnum>" ( x y -- ? ) f }
            { "fixnum>=" ( x y -- ? ) f }

            { "bignum*" ( x y -- z ) "bignum_multiply" }
            { "bignum+" ( x y -- z ) "bignum_add" }
            { "bignum-" ( x y -- z ) "bignum_subtract" }
            { "bignum-bit?" ( x n -- ? ) "bignum_bitp" }
            { "bignum-bitand" ( x y -- z ) "bignum_and" }
            { "bignum-bitnot" ( x -- y ) "bignum_not" }
            { "bignum-bitor" ( x y -- z ) "bignum_or" }
            { "bignum-bitxor" ( x y -- z ) "bignum_xor" }
            { "bignum-log2" ( x -- n ) "bignum_log2" }
            { "bignum-mod" ( x y -- z ) "bignum_mod" }
            { "bignum-gcd" ( x y -- z ) "bignum_gcd" }
            { "bignum-shift" ( x y -- z ) "bignum_shift" }
            { "bignum/i" ( x y -- z ) "bignum_divint" }
            { "bignum/mod" ( x y -- z w ) "bignum_divmod" }
            { "bignum<" ( x y -- ? ) "bignum_less" }
            { "bignum<=" ( x y -- ? ) "bignum_lesseq" }
            { "bignum=" ( x y -- ? ) "bignum_eq" }
            { "bignum>" ( x y -- ? ) "bignum_greater" }
            { "bignum>=" ( x y -- ? ) "bignum_greatereq" }
            { "bignum>fixnum" ( x -- y ) "bignum_to_fixnum" }
            { "bignum>fixnum-strict" ( x -- y ) "bignum_to_fixnum_strict" }
            { "fixnum-shift" ( x y -- z ) "fixnum_shift" }
            { "fixnum/i" ( x y -- z ) "fixnum_divint" }
            { "fixnum/mod" ( x y -- z w ) "fixnum_divmod" }
            { "fixnum>bignum" ( x -- y ) "fixnum_to_bignum" }
            { "fixnum>float" ( x -- y ) "fixnum_to_float" }
            { "float*" ( x y -- z ) "float_multiply" }
            { "float+" ( x y -- z ) "float_add" }
            { "float-" ( x y -- z ) "float_subtract" }
            { "float-u<" ( x y -- ? ) "float_less" }
            { "float-u<=" ( x y -- ? ) "float_lesseq" }
            { "float-u>" ( x y -- ? ) "float_greater" }
            { "float-u>=" ( x y -- ? ) "float_greatereq" }
            { "float/f" ( x y -- z ) "float_divfloat" }
            { "float<" ( x y -- ? ) "float_less" }
            { "float<=" ( x y -- ? ) "float_lesseq" }
            { "float=" ( x y -- ? ) "float_eq" }
            { "float>" ( x y -- ? ) "float_greater" }
            { "float>=" ( x y -- ? ) "float_greatereq" }
            { "float>bignum" ( x -- y ) "float_to_bignum" }
            { "float>fixnum" ( x -- y ) "float_to_fixnum" }
        }
    }
    {
        "memory"
        {
            { "all-instances" ( -- array ) "all_instances" }
            { "compact-gc" ( -- ) "compact_gc" }
            { "gc" ( -- ) "full_gc" }
            { "minor-gc" ( -- ) "minor_gc" }
            { "size" ( obj -- n ) "size" }
        }
    }
    {
        "memory.private"
        {
            { "(save-image)" ( path1 path2 then-die? -- ) "save_image" }
        }
    }
    {
        "quotations"
        {
            { "jit-compile" ( quot -- ) "jit_compile" }
            { "quotation-code" ( quot -- start end ) "quotation_code" }
            { "quotation-compiled?" ( quot -- ? ) "quotation_compiled_p" }
        }
    }
    {
        "quotations.private"
        {
            { "array>quotation" ( array -- quot ) "array_to_quotation" }
        }
    }
    {
        "slots.private"
        {
            { "set-slot" ( value obj n -- ) "set_slot" }
            { "slot" ( obj m -- value ) f }
        }
    }
    {
        "strings"
        {
            { "<string>" ( n ch -- string ) "string" }
            { "resize-string" ( n str -- newstr ) "resize_string" }
        }
    }
    {
        "strings.private"
        {
            { "set-string-nth-fast" ( ch n string -- ) "set_string_nth_fast" }
            { "string-nth-fast" ( n string -- ch ) f }
        }
    }
    {
        "system"
        {
            { "(exit)" ( n -- * ) "exit" }
            { "nano-count" ( -- ns ) "nano_count" }
        }
    }
    {
        "threads.private"
        {
            { "(sleep)" ( nanos -- ) "sleep" }
            { "(set-context)" ( obj context -- obj' ) f }
            { "(set-context-and-delete)" ( obj context -- * ) f }
            { "(start-context)" ( obj quot -- obj' ) f }
            { "(start-context-and-delete)" ( obj quot -- * ) f }
            { "context-object-for" ( n context -- obj ) "context_object_for" }
        }
    }
    {
        "tools.dispatch.private"
        {
            { "dispatch-stats" ( -- stats ) "dispatch_stats" }
            { "reset-dispatch-stats" ( -- ) "reset_dispatch_stats" }
        }
    }
    {
        "tools.memory.private"
        {
            { "(callback-room)" ( -- allocator-room ) "callback_room" }
            { "(code-blocks)" ( -- array ) "code_blocks" }
            { "(code-room)" ( -- allocator-room ) "code_room" }
            { "(data-room)" ( -- data-room ) "data_room" }
            { "disable-gc-events" ( -- events ) "disable_gc_events" }
            { "enable-gc-events" ( -- ) "enable_gc_events" }
        }
    }
    {
        "tools.profiler.sampling.private"
        {
            { "profiling" ( ? -- ) "sampling_profiler" }
            { "(get-samples)" ( -- samples/f ) "get_samples" }
            { "(clear-samples)" ( -- ) "clear_samples" }
        }
    }
    {
        "words"
        {
            { "word-code" ( word -- start end ) "word_code" }
            { "word-optimized?" ( word -- ? ) "word_optimized_p" }
        }
    }
    {
        "words.private"
        {
            { "(word)" ( name vocab hashcode -- word ) "word" }
        }
    }
}

: primitive-quot ( word vm-func -- quot )
    [
        nip "primitive_" prepend ascii string>alien [ do-primitive ] curry
    ] [ 1quotation ] if* ;

: primitive-word ( name vocab -- word )
    create-word dup t "primitive" set-word-prop ;

:: create-primitive ( vocab word effect vm-func -- )
    word vocab primitive-word
    dup vm-func primitive-quot effect define-declared ;

: create-primitives ( assoc -- )
    [ [ first3 create-primitive ] with each ] assoc-each ;
