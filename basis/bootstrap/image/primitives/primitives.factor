USING: alien.strings assocs io.encodings.ascii kernel kernel.private
locals quotations sequences words ;
IN: bootstrap.image.primitives

CONSTANT: all-primitives {
    {
        "alien"
        {
            { "<callback>" ( word return-rewind -- alien ) "primitive_callback" }
            { "<displaced-alien>" ( displacement c-ptr -- alien ) "primitive_displaced_alien" }
            { "alien-address" ( c-ptr -- addr ) "primitive_alien_address" }
            { "free-callback" ( alien -- ) "primitive_free_callback" }
        }
    }
    {
        "alien.private"
        {
            { "current-callback" ( -- n ) "primitive_current_callback" }
        }
    }
    {
        "alien.accessors"
        {
            { "alien-cell" ( c-ptr n -- value ) "primitive_alien_cell" }
            { "alien-double" ( c-ptr n -- value ) "primitive_alien_double" }
            { "alien-float" ( c-ptr n -- value ) "primitive_alien_float" }

            { "alien-signed-1" ( c-ptr n -- value ) "primitive_alien_signed_1" }
            { "alien-signed-2" ( c-ptr n -- value ) "primitive_alien_signed_2" }
            { "alien-signed-4" ( c-ptr n -- value ) "primitive_alien_signed_4" }
            { "alien-signed-8" ( c-ptr n -- value ) "primitive_alien_signed_8" }
            { "alien-signed-cell" ( c-ptr n -- value ) "primitive_alien_signed_cell" }

            { "alien-unsigned-1" ( c-ptr n -- value ) "primitive_alien_unsigned_1" }
            { "alien-unsigned-2" ( c-ptr n -- value ) "primitive_alien_unsigned_2" }
            { "alien-unsigned-4" ( c-ptr n -- value ) "primitive_alien_unsigned_4" }
            { "alien-unsigned-8" ( c-ptr n -- value ) "primitive_alien_unsigned_8" }
            { "alien-unsigned-cell" ( c-ptr n -- value ) "primitive_alien_unsigned_cell" }

            { "set-alien-cell" ( value c-ptr n -- ) "primitive_set_alien_cell" }
            { "set-alien-double" ( value c-ptr n -- ) "primitive_set_alien_double" }
            { "set-alien-float" ( value c-ptr n -- ) "primitive_set_alien_float" }

            { "set-alien-signed-1" ( value c-ptr n -- ) "primitive_set_alien_signed_1" }
            { "set-alien-signed-2" ( value c-ptr n -- ) "primitive_set_alien_signed_2" }
            { "set-alien-signed-4" ( value c-ptr n -- ) "primitive_set_alien_signed_4" }
            { "set-alien-signed-8" ( value c-ptr n -- ) "primitive_set_alien_signed_8" }
            { "set-alien-signed-cell" ( value c-ptr n -- ) "primitive_set_alien_signed_cell" }

            { "set-alien-unsigned-1" ( value c-ptr n -- ) "primitive_set_alien_unsigned_1" }
            { "set-alien-unsigned-2" ( value c-ptr n -- ) "primitive_set_alien_unsigned_2" }
            { "set-alien-unsigned-4" ( value c-ptr n -- ) "primitive_set_alien_unsigned_4" }
            { "set-alien-unsigned-8" ( value c-ptr n -- ) "primitive_set_alien_unsigned_8" }
            { "set-alien-unsigned-cell" ( value c-ptr n -- ) "primitive_set_alien_unsigned_cell" }
        }
    }
    {
        "alien.libraries"
        {
            { "(dlopen)" ( path -- dll ) "primitive_dlopen" }
            { "(dlsym)" ( name dll -- alien ) "primitive_dlsym" }
            { "(dlsym-raw)" ( name dll -- alien ) "primitive_dlsym_raw" }
            { "dlclose" ( dll -- ) "primitive_dlclose" }
            { "dll-valid?" ( dll -- ? ) "primitive_dll_validp" }
        }
    }
    {
        "arrays"
        {
            { "<array>" ( n elt -- array ) "primitive_array" }
            { "resize-array" ( n array -- new-array ) "primitive_resize_array" }
        }
    }
    {
        "byte-arrays"
        {
            { "(byte-array)" ( n -- byte-array ) "primitive_uninitialized_byte_array" }
            { "<byte-array>" ( n -- byte-array ) "primitive_byte_array" }
            {
                "resize-byte-array" ( n byte-array -- new-byte-array )
                "primitive_resize_byte_array"
            }
        }
    }
    {
        "classes.tuple.private"
        {
            { "<tuple-boa>" ( slots... layout -- tuple ) "primitive_tuple_boa" }
            { "<tuple>" ( layout -- tuple ) "primitive_tuple" }
        }
    }
    {
        "compiler.units"
        {
            {
                "modify-code-heap" ( alist update-existing? reset-pics? -- )
                "primitive_modify_code_heap"
            }
        }
    }
    {
        "generic.single.private"
        {
            { "inline-cache-miss" ( generic methods index cache -- ) f }
            { "inline-cache-miss-tail" ( generic methods index cache -- ) f }
            { "lookup-method" ( object methods -- method ) "primitive_lookup_method" }
            { "mega-cache-lookup" ( methods index cache -- ) f }
            { "mega-cache-miss" ( methods index cache -- method ) "primitive_mega_cache_miss" }
        }
    }
    {
        "io.files.private"
        {
            { "(exists?)" ( path -- ? ) "primitive_existsp" }
        }
    }
    {
        "io.streams.c"
        {
            { "(fopen)" ( path mode -- alien ) "primitive_fopen" }
            { "fclose" ( alien -- ) "primitive_fclose" }
            { "fflush" ( alien -- ) "primitive_fflush" }
            { "fgetc" ( alien -- byte/f ) "primitive_fgetc" }
            { "fputc" ( byte alien -- ) "primitive_fputc" }
            { "fread-unsafe" ( n buf alien -- count ) "primitive_fread" }
            { "fseek" ( alien offset whence -- ) "primitive_fseek" }
            { "ftell" ( alien -- n ) "primitive_ftell" }
            { "fwrite" ( data length alien -- ) "primitive_fwrite" }
        }
    }
    {
        "kernel"
        {
            { "(clone)" ( obj -- newobj ) "primitive_clone" }
            { "<wrapper>" ( obj -- wrapper ) "primitive_wrapper" }
            { "callstack>array" ( callstack -- array ) "primitive_callstack_to_array" }
            { "die" ( -- ) "primitive_die" }
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

            { "callstack-for" ( context -- array ) "primitive_callstack_for" }
            { "datastack-for" ( context -- array ) "primitive_datastack_for" }
            { "retainstack-for" ( context -- array ) "primitive_retainstack_for" }
            { "(identity-hashcode)" ( obj -- code ) "primitive_identity_hashcode" }
            { "become" ( old new -- ) "primitive_become" }
            { "callstack-bounds" ( -- start end ) "primitive_callstack_bounds" }
            { "check-datastack" ( array in# out# -- ? ) "primitive_check_datastack" }
            { "compute-identity-hashcode" ( obj -- ) "primitive_compute_identity_hashcode" }
            { "context-object" ( n -- obj ) "primitive_context_object" }
            {
                "innermost-frame-executing" ( callstack -- obj )
                "primitive_innermost_stack_frame_executing"
            }
            {
                "innermost-frame-scan" ( callstack -- n )
                "primitive_innermost_stack_frame_scan"
            }
            { "set-context-object" ( obj n -- ) "primitive_set_context_object" }
            { "set-datastack" ( array -- ) "primitive_set_datastack" }
            {
                "set-innermost-frame-quotation" ( n callstack -- )
                "primitive_set_innermost_stack_frame_quotation"
            }
            { "set-retainstack" ( array -- ) "primitive_set_retainstack" }
            { "set-special-object" ( obj n -- ) "primitive_set_special_object" }
            { "special-object" ( n -- obj ) "primitive_special_object" }
            { "strip-stack-traces" ( -- ) "primitive_strip_stack_traces" }
            { "unimplemented" ( -- * ) "primitive_unimplemented" }
        }
    }
    {
        "locals.backend"
        {
            { "drop-locals" ( n -- ) f }
            { "get-local" ( n -- obj ) f }
            { "load-local" ( obj -- ) f }
            { "load-locals" ( ... n -- ) "primitive_load_locals" }
        }
    }
    {
        "math"
        {
            { "bits>double" ( n -- x ) "primitive_bits_double" }
            { "bits>float" ( n -- x ) "primitive_bits_float" }
            { "double>bits" ( x -- n ) "primitive_double_bits" }
            { "float>bits" ( x -- n ) "primitive_float_bits" }
        }
    }
    {
        "math.parser.private"
        {
            {
                "(format-float)" ( n fill width precision format locale -- byte-array )
                "primitive_format_float"
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

            { "bignum*" ( x y -- z ) "primitive_bignum_multiply" }
            { "bignum+" ( x y -- z ) "primitive_bignum_add" }
            { "bignum-" ( x y -- z ) "primitive_bignum_subtract" }
            { "bignum-bit?" ( x n -- ? ) "primitive_bignum_bitp" }
            { "bignum-bitand" ( x y -- z ) "primitive_bignum_and" }
            { "bignum-bitnot" ( x -- y ) "primitive_bignum_not" }
            { "bignum-bitor" ( x y -- z ) "primitive_bignum_or" }
            { "bignum-bitxor" ( x y -- z ) "primitive_bignum_xor" }
            { "bignum-log2" ( x -- n ) "primitive_bignum_log2" }
            { "bignum-mod" ( x y -- z ) "primitive_bignum_mod" }
            { "bignum-gcd" ( x y -- z ) "primitive_bignum_gcd" }
            { "bignum-shift" ( x y -- z ) "primitive_bignum_shift" }
            { "bignum/i" ( x y -- z ) "primitive_bignum_divint" }
            { "bignum/mod" ( x y -- z w ) "primitive_bignum_divmod" }
            { "bignum<" ( x y -- ? ) "primitive_bignum_less" }
            { "bignum<=" ( x y -- ? ) "primitive_bignum_lesseq" }
            { "bignum=" ( x y -- ? ) "primitive_bignum_eq" }
            { "bignum>" ( x y -- ? ) "primitive_bignum_greater" }
            { "bignum>=" ( x y -- ? ) "primitive_bignum_greatereq" }
            { "bignum>fixnum" ( x -- y ) "primitive_bignum_to_fixnum" }
            { "bignum>fixnum-strict" ( x -- y ) "primitive_bignum_to_fixnum_strict" }
            { "fixnum-shift" ( x y -- z ) "primitive_fixnum_shift" }
            { "fixnum/i" ( x y -- z ) "primitive_fixnum_divint" }
            { "fixnum/mod" ( x y -- z w ) "primitive_fixnum_divmod" }
            { "fixnum>bignum" ( x -- y ) "primitive_fixnum_to_bignum" }
            { "fixnum>float" ( x -- y ) "primitive_fixnum_to_float" }
            { "float*" ( x y -- z ) "primitive_float_multiply" }
            { "float+" ( x y -- z ) "primitive_float_add" }
            { "float-" ( x y -- z ) "primitive_float_subtract" }
            { "float-u<" ( x y -- ? ) "primitive_float_less" }
            { "float-u<=" ( x y -- ? ) "primitive_float_lesseq" }
            { "float-u>" ( x y -- ? ) "primitive_float_greater" }
            { "float-u>=" ( x y -- ? ) "primitive_float_greatereq" }
            { "float/f" ( x y -- z ) "primitive_float_divfloat" }
            { "float<" ( x y -- ? ) "primitive_float_less" }
            { "float<=" ( x y -- ? ) "primitive_float_lesseq" }
            { "float=" ( x y -- ? ) "primitive_float_eq" }
            { "float>" ( x y -- ? ) "primitive_float_greater" }
            { "float>=" ( x y -- ? ) "primitive_float_greatereq" }
            { "float>bignum" ( x -- y ) "primitive_float_to_bignum" }
            { "float>fixnum" ( x -- y ) "primitive_float_to_fixnum" }
        }
    }
    {
        "memory"
        {
            { "all-instances" ( -- array ) "primitive_all_instances" }
            { "compact-gc" ( -- ) "primitive_compact_gc" }
            { "gc" ( -- ) "primitive_full_gc" }
            { "minor-gc" ( -- ) "primitive_minor_gc" }
            { "size" ( obj -- n ) "primitive_size" }
        }
    }
    {
        "memory.private"
        {
            { "(save-image)" ( path1 path2 then-die? -- ) "primitive_save_image" }
        }
    }
    {
        "quotations"
        {
            { "jit-compile" ( quot -- ) "primitive_jit_compile" }
            { "quotation-code" ( quot -- start end ) "primitive_quotation_code" }
            { "quotation-compiled?" ( quot -- ? ) "primitive_quotation_compiled_p" }
        }
    }
    {
        "quotations.private"
        {
            { "array>quotation" ( array -- quot ) "primitive_array_to_quotation" }
        }
    }
    {
        "slots.private"
        {
            { "set-slot" ( value obj n -- ) "primitive_set_slot" }
            { "slot" ( obj m -- value ) f }
        }
    }
    {
        "strings"
        {
            { "<string>" ( n ch -- string ) "primitive_string" }
            { "resize-string" ( n str -- newstr ) "primitive_resize_string" }
        }
    }
    {
        "strings.private"
        {
            { "set-string-nth-fast" ( ch n string -- ) "primitive_set_string_nth_fast" }
            { "string-nth-fast" ( n string -- ch ) f }
        }
    }
    {
        "system"
        {
            { "(exit)" ( n -- * ) "primitive_exit" }
            { "nano-count" ( -- ns ) "primitive_nano_count" }
        }
    }
    {
        "threads.private"
        {
            { "(sleep)" ( nanos -- ) "primitive_sleep" }
            { "(set-context)" ( obj context -- obj' ) f }
            { "(set-context-and-delete)" ( obj context -- * ) f }
            { "(start-context)" ( obj quot -- obj' ) f }
            { "(start-context-and-delete)" ( obj quot -- * ) f }
            { "context-object-for" ( n context -- obj ) "primitive_context_object_for" }
        }
    }
    {
        "tools.dispatch.private"
        {
            { "dispatch-stats" ( -- stats ) "primitive_dispatch_stats" }
            { "reset-dispatch-stats" ( -- ) "primitive_reset_dispatch_stats" }
        }
    }
    {
        "tools.memory.private"
        {
            { "(callback-room)" ( -- allocator-room ) "primitive_callback_room" }
            { "(code-blocks)" ( -- array ) "primitive_code_blocks" }
            { "(code-room)" ( -- allocator-room ) "primitive_code_room" }
            { "(data-room)" ( -- data-room ) "primitive_data_room" }
            { "disable-gc-events" ( -- events ) "primitive_disable_gc_events" }
            { "enable-gc-events" ( -- ) "primitive_enable_gc_events" }
        }
    }
    {
        "tools.profiler.sampling.private"
        {
            { "profiling" ( ? -- ) "primitive_sampling_profiler" }
            { "(get-samples)" ( -- samples/f ) "primitive_get_samples" }
            { "(clear-samples)" ( -- ) "primitive_clear_samples" }
        }
    }
    {
        "words"
        {
            { "word-code" ( word -- start end ) "primitive_word_code" }
            { "word-optimized?" ( word -- ? ) "primitive_word_optimized_p" }
        }
    }
    {
        "words.private"
        {
            { "(word)" ( name vocab hashcode -- word ) "primitive_word" }
        }
    }
}

: primitive-quot ( word vm-func -- quot )
    [ nip ascii string>alien [ do-primitive ] curry ] [ 1quotation ] if* ;

: primitive-word ( name vocab -- word )
    create-word dup t "primitive" set-word-prop ;

:: create-primitive ( vocab word effect vm-func -- )
    word vocab primitive-word
    dup vm-func primitive-quot effect define-declared ;

: create-primitives ( assoc -- )
    [ [ first3 create-primitive ] with each ] assoc-each ;
