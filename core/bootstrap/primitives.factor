! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.strings arrays byte-arrays generic hashtables
hashtables.private io io.encodings.ascii kernel math
math.private math.order namespaces make parser sequences strings
vectors words quotations assocs layouts classes classes.builtin
classes.tuple classes.tuple.private kernel.private vocabs
vocabs.loader source-files definitions slots classes.union
classes.intersection classes.predicate compiler.units
bootstrap.image.private io.files accessors combinators ;
IN: bootstrap.primitives

"Creating primitives and basic runtime structures..." print flush

H{ } clone sub-primitives set

"vocab:bootstrap/syntax.factor" parse-file

architecture get {
    { "x86.32" "x86/32" }
    { "winnt-x86.64" "x86/64/winnt" }
    { "unix-x86.64" "x86/64/unix" }
    { "linux-ppc" "ppc/linux" }
    { "macosx-ppc" "ppc/macosx" }
    { "arm" "arm" }
} ?at [ "Bad architecture: " prepend throw ] unless
"vocab:cpu/" "/bootstrap.factor" surround parse-file

"vocab:bootstrap/layouts/layouts.factor" parse-file

! Now we have ( syntax-quot arch-quot layouts-quot ) on the stack

! Bring up a bare cross-compiling vocabulary.
"syntax" vocab vocab-words bootstrap-syntax set {
    dictionary
    new-classes
    changed-definitions changed-generics changed-effects
    outdated-generics forgotten-definitions
    root-cache source-files update-map implementors-map
} [ H{ } clone swap set ] each

init-caches

! Vocabulary for slot accessors
"accessors" create-vocab drop

dummy-compiler compiler-impl set

call( -- )
call( -- )
call( -- )

! After we execute bootstrap/layouts
num-types get f <array> builtins set

bootstrapping? on

[

! Create some empty vocabs where the below primitives and
! classes will go
{
    "alien"
    "alien.accessors"
    "alien.libraries"
    "arrays"
    "byte-arrays"
    "classes.private"
    "classes.tuple"
    "classes.tuple.private"
    "classes.predicate"
    "compiler.units"
    "continuations.private"
    "generic.single"
    "generic.single.private"
    "growable"
    "hashtables"
    "hashtables.private"
    "io"
    "io.files"
    "io.files.private"
    "io.streams.c"
    "locals.backend"
    "kernel"
    "kernel.private"
    "math"
    "math.parser.private"
    "math.private"
    "memory"
    "memory.private"
    "quotations"
    "quotations.private"
    "sbufs"
    "sbufs.private"
    "scratchpad"
    "sequences"
    "sequences.private"
    "slots.private"
    "strings"
    "strings.private"
    "system"
    "system.private"
    "threads.private"
    "tools.dispatch.private"
    "tools.profiler.private"
    "words"
    "words.private"
    "vectors"
    "vectors.private"
    "vm"
} [ create-vocab drop ] each

! Builtin classes
: lookup-type-number ( word -- n )
    global [ target-word ] bind type-number ;

: register-builtin ( class -- )
    [ dup lookup-type-number "type" set-word-prop ]
    [ dup "type" word-prop builtins get set-nth ]
    [ f f f builtin-class define-class ]
    tri ;

: prepare-slots ( slots -- slots' )
    [ [ dup pair? [ first2 create ] when ] map ] map ;

: define-builtin-slots ( class slots -- )
    prepare-slots make-slots 1 finalize-slots
    [ "slots" set-word-prop ] [ define-accessors ] 2bi ;

: define-builtin ( symbol slotspec -- )
    [ [ define-builtin-predicate ] keep ] dip define-builtin-slots ;

"fixnum" "math" create register-builtin
"bignum" "math" create register-builtin
"tuple" "kernel" create register-builtin
"float" "math" create register-builtin
"f" "syntax" lookup register-builtin
"array" "arrays" create register-builtin
"wrapper" "kernel" create register-builtin
"callstack" "kernel" create register-builtin
"string" "strings" create register-builtin
"quotation" "quotations" create register-builtin
"dll" "alien" create register-builtin
"alien" "alien" create register-builtin
"word" "words" create register-builtin
"byte-array" "byte-arrays" create register-builtin

! We need this before defining c-ptr below
"f" "syntax" lookup { } define-builtin

"f" "syntax" create [ not ] "predicate" set-word-prop
"f?" "syntax" vocab-words delete-at

! Some unions
"c-ptr" "alien" create [
    "alien" "alien" lookup ,
    "f" "syntax" lookup ,
    "byte-array" "byte-arrays" lookup ,
] { } make define-union-class

! A predicate class used for declarations
"array-capacity" "sequences.private" create
"fixnum" "math" lookup
[
    [ dup 0 fixnum>= ] %
    bootstrap-max-array-capacity <fake-bignum> [ fixnum<= ] curry ,
    [ [ drop f ] if ] %
] [ ] make
define-predicate-class

"array-capacity" "sequences.private" lookup
[ >fixnum ] bootstrap-max-array-capacity <fake-bignum> [ fixnum-bitand ] curry append
"coercer" set-word-prop

! Catch-all class for providing a default method.
"object" "kernel" create
[ f f { } intersection-class define-class ]
[ [ drop t ] "predicate" set-word-prop ]
bi

"object?" "kernel" vocab-words delete-at

! Empty class with no instances
"null" "kernel" create
[ f { } f union-class define-class ]
[ [ drop f ] "predicate" set-word-prop ]
bi

"null?" "kernel" vocab-words delete-at

"fixnum" "math" create { } define-builtin
"fixnum" "math" create ">fixnum" "math" create 1quotation "coercer" set-word-prop

"bignum" "math" create { } define-builtin
"bignum" "math" create ">bignum" "math" create 1quotation "coercer" set-word-prop

"float" "math" create { } define-builtin
"float" "math" create ">float" "math" create 1quotation "coercer" set-word-prop

"array" "arrays" create {
    { "length" { "array-capacity" "sequences.private" } read-only }
} define-builtin

"wrapper" "kernel" create {
    { "wrapped" read-only }
} define-builtin

"string" "strings" create {
    { "length" { "array-capacity" "sequences.private" } read-only }
    "aux"
} define-builtin

"quotation" "quotations" create {
    { "array" { "array" "arrays" } read-only }
    "cached-effect"
    "cache-counter"
} define-builtin

"dll" "alien" create {
    { "path" { "byte-array" "byte-arrays" } read-only }
} define-builtin

"alien" "alien" create {
    { "underlying" { "c-ptr" "alien" } read-only }
    "expired"
} define-builtin

"word" "words" create {
    { "hashcode" { "fixnum" "math" } }
    "name"
    "vocabulary"
    { "def" { "quotation" "quotations" } initial: [ ] }
    "props"
    "pic-def"
    "pic-tail-def"
    { "counter" { "fixnum" "math" } }
    { "sub-primitive" read-only }
} define-builtin

"byte-array" "byte-arrays" create {
    { "length" { "array-capacity" "sequences.private" } read-only }
} define-builtin

"callstack" "kernel" create { } define-builtin

"tuple" "kernel" create
[ { } define-builtin ]
[ define-tuple-layout ]
bi

! Create special tombstone values
"tombstone" "hashtables.private" create
tuple
{ "state" } define-tuple-class

"((empty))" "hashtables.private" create
"tombstone" "hashtables.private" lookup f
2array >tuple 1quotation (( -- value )) define-inline

"((tombstone))" "hashtables.private" create
"tombstone" "hashtables.private" lookup t
2array >tuple 1quotation (( -- value )) define-inline

! Some tuple classes
"curry" "kernel" create
tuple
{
    { "obj" read-only }
    { "quot" read-only }
} prepare-slots define-tuple-class

"curry" "kernel" lookup
{
    [ f "inline" set-word-prop ]
    [ make-flushable ]
    [ ]
    [
        [
            callable instance-check-quot %
            tuple-layout ,
            \ <tuple-boa> ,
        ] [ ] make
    ]
} cleave
(( obj quot -- curry )) define-declared

"compose" "kernel" create
tuple
{
    { "first" read-only }
    { "second" read-only }
} prepare-slots define-tuple-class

"compose" "kernel" lookup
{
    [ f "inline" set-word-prop ]
    [ make-flushable ]
    [ ]
    [
        [
            callable instance-check-quot [ dip ] curry %
            callable instance-check-quot %
            tuple-layout ,
            \ <tuple-boa> ,
        ] [ ] make
    ]
} cleave
(( quot1 quot2 -- compose )) define-declared

! Sub-primitive words
: make-sub-primitive ( word vocab effect -- )
    [
        create
        dup t "primitive" set-word-prop
        dup 1quotation
    ] dip define-declared ;

{
    { "mega-cache-lookup" "generic.single.private" (( methods index cache -- )) }
    { "inline-cache-miss" "generic.single.private" (( generic methods index cache -- )) }
    { "inline-cache-miss-tail" "generic.single.private" (( generic methods index cache -- )) }
    { "drop" "kernel" (( x -- )) }
    { "2drop" "kernel" (( x y -- )) }
    { "3drop" "kernel" (( x y z -- )) }
    { "dup" "kernel" (( x -- x x )) }
    { "2dup" "kernel" (( x y -- x y x y )) }
    { "3dup" "kernel" (( x y z -- x y z x y z )) }
    { "rot" "kernel" (( x y z -- y z x )) }
    { "-rot" "kernel" (( x y z -- z x y )) }
    { "dupd" "kernel" (( x y -- x x y )) }
    { "swapd" "kernel" (( x y z -- y x z )) }
    { "nip" "kernel" (( x y -- y )) }
    { "2nip" "kernel" (( x y z -- z )) }
    { "over" "kernel" (( x y -- x y x )) }
    { "pick" "kernel" (( x y z -- x y z x )) }
    { "swap" "kernel" (( x y -- y x )) }
    { "eq?" "kernel" (( obj1 obj2 -- ? )) }
    { "tag" "kernel.private" (( object -- n )) }
    { "(execute)" "kernel.private" (( word -- )) }
    { "(call)" "kernel.private" (( quot -- )) }
    { "unwind-native-frames" "kernel.private" (( -- )) }
    { "set-callstack" "kernel.private" (( cs -- * )) }
    { "lazy-jit-compile" "kernel.private" (( -- )) }
    { "c-to-factor" "kernel.private" (( -- )) }
    { "slot" "slots.private" (( obj m -- value )) }
    { "get-local" "locals.backend" (( n -- obj )) }
    { "load-local" "locals.backend" (( obj -- )) }
    { "drop-locals" "locals.backend" (( n -- )) }
    { "both-fixnums?" "math.private" (( x y -- ? )) }
    { "fixnum+fast" "math.private" (( x y -- z )) }
    { "fixnum-fast" "math.private" (( x y -- z )) }
    { "fixnum*fast" "math.private" (( x y -- z )) }
    { "fixnum-bitand" "math.private" (( x y -- z )) }
    { "fixnum-bitor" "math.private" (( x y -- z )) }
    { "fixnum-bitxor" "math.private" (( x y -- z )) }
    { "fixnum-bitnot" "math.private" (( x -- y )) }
    { "fixnum-mod" "math.private" (( x y -- z )) }
    { "fixnum-shift-fast" "math.private" (( x y -- z )) }
    { "fixnum/i-fast" "math.private" (( x y -- z )) }
    { "fixnum/mod-fast" "math.private" (( x y -- z w )) }
    { "fixnum+" "math.private" (( x y -- z )) }
    { "fixnum-" "math.private" (( x y -- z )) }
    { "fixnum*" "math.private" (( x y -- z )) }
    { "fixnum<" "math.private" (( x y -- ? )) }
    { "fixnum<=" "math.private" (( x y -- z )) }
    { "fixnum>" "math.private" (( x y -- ? )) }
    { "fixnum>=" "math.private" (( x y -- ? )) }
} [ first3 make-sub-primitive ] each

! Primitive words
: make-primitive ( word vocab function effect -- )
    [
        [
            create
            dup reset-word
            dup t "primitive" set-word-prop
        ] dip
        ascii string>alien [ do-primitive ] curry
    ] dip define-declared ;

{
    { "<callback>" "alien" "primitive_callback" (( return-rewind word -- alien )) }
    { "<displaced-alien>" "alien" "primitive_displaced_alien" (( displacement c-ptr -- alien )) }
    { "alien-address" "alien" "primitive_alien_address" (( c-ptr -- addr )) }
    { "alien-cell" "alien.accessors" "primitive_alien_cell" (( c-ptr n -- value )) }
    { "alien-double" "alien.accessors" "primitive_alien_double" (( c-ptr n -- value )) }
    { "alien-float" "alien.accessors" "primitive_alien_float" (( c-ptr n -- value )) }
    { "alien-signed-1" "alien.accessors" "primitive_alien_signed_1" (( c-ptr n -- value )) }
    { "alien-signed-2" "alien.accessors" "primitive_alien_signed_2" (( c-ptr n -- value )) }
    { "alien-signed-4" "alien.accessors" "primitive_alien_signed_4" (( c-ptr n -- value )) }
    { "alien-signed-8" "alien.accessors" "primitive_alien_signed_8" (( c-ptr n -- value )) }
    { "alien-signed-cell" "alien.accessors" "primitive_alien_signed_cell" (( c-ptr n -- value )) }
    { "alien-unsigned-1" "alien.accessors" "primitive_alien_unsigned_1" (( c-ptr n -- value )) }
    { "alien-unsigned-2" "alien.accessors" "primitive_alien_unsigned_2" (( c-ptr n -- value )) }
    { "alien-unsigned-4" "alien.accessors" "primitive_alien_unsigned_4" (( c-ptr n -- value )) }
    { "alien-unsigned-8" "alien.accessors" "primitive_alien_unsigned_8" (( c-ptr n -- value )) }
    { "alien-unsigned-cell" "alien.accessors" "primitive_alien_unsigned_cell" (( c-ptr n -- value )) }
    { "set-alien-cell" "alien.accessors" "primitive_set_alien_cell" (( value c-ptr n -- )) }
    { "set-alien-double" "alien.accessors" "primitive_set_alien_double" (( value c-ptr n -- )) }
    { "set-alien-float" "alien.accessors" "primitive_set_alien_float" (( value c-ptr n -- )) }
    { "set-alien-signed-1" "alien.accessors" "primitive_set_alien_signed_1" (( value c-ptr n -- )) }
    { "set-alien-signed-2" "alien.accessors" "primitive_set_alien_signed_2" (( value c-ptr n -- )) }
    { "set-alien-signed-4" "alien.accessors" "primitive_set_alien_signed_4" (( value c-ptr n -- )) }
    { "set-alien-signed-8" "alien.accessors" "primitive_set_alien_signed_8" (( value c-ptr n -- )) }
    { "set-alien-signed-cell" "alien.accessors" "primitive_set_alien_signed_cell" (( value c-ptr n -- )) }
    { "set-alien-unsigned-1" "alien.accessors" "primitive_set_alien_unsigned_1" (( value c-ptr n -- )) }
    { "set-alien-unsigned-2" "alien.accessors" "primitive_set_alien_unsigned_2" (( value c-ptr n -- )) }
    { "set-alien-unsigned-4" "alien.accessors" "primitive_set_alien_unsigned_4" (( value c-ptr n -- )) }
    { "set-alien-unsigned-8" "alien.accessors" "primitive_set_alien_unsigned_8" (( value c-ptr n -- )) }
    { "set-alien-unsigned-cell" "alien.accessors" "primitive_set_alien_unsigned_cell" (( value c-ptr n -- )) }
    { "(dlopen)" "alien.libraries" "primitive_dlopen" (( path -- dll )) }
    { "(dlsym)" "alien.libraries" "primitive_dlsym" (( name dll -- alien )) }
    { "dlclose" "alien.libraries" "primitive_dlclose" (( dll -- )) }
    { "dll-valid?" "alien.libraries" "primitive_dll_validp" (( dll -- ? )) }
    { "<array>" "arrays" "primitive_array" (( n elt -- array )) }
    { "resize-array" "arrays" "primitive_resize_array" (( n array -- newarray )) }
    { "(byte-array)" "byte-arrays" "primitive_uninitialized_byte_array" (( n -- byte-array )) }
    { "<byte-array>" "byte-arrays" "primitive_byte_array" (( n -- byte-array )) }
    { "resize-byte-array" "byte-arrays" "primitive_resize_byte_array" (( n byte-array -- newbyte-array )) }
    { "<tuple-boa>" "classes.tuple.private" "primitive_tuple_boa" (( ... layout -- tuple )) }
    { "<tuple>" "classes.tuple.private" "primitive_tuple" (( layout -- tuple )) }
    { "modify-code-heap" "compiler.units" "primitive_modify_code_heap" (( alist -- )) }
    { "lookup-method" "generic.single.private" "primitive_lookup_method" (( object methods -- method )) }
    { "mega-cache-miss" "generic.single.private" "primitive_mega_cache_miss" (( methods index cache -- method )) }
    { "(exists?)" "io.files.private" "primitive_existsp" (( path -- ? )) }
    { "(fopen)" "io.streams.c" "primitive_fopen" (( path mode -- alien )) }
    { "fclose" "io.streams.c" "primitive_fclose" (( alien -- )) }
    { "fflush" "io.streams.c" "primitive_fflush" (( alien -- )) }
    { "fgetc" "io.streams.c" "primitive_fgetc" (( alien -- ch/f )) }
    { "fputc" "io.streams.c" "primitive_fputc" (( ch alien -- )) }
    { "fread" "io.streams.c" "primitive_fread" (( n alien -- str/f )) }
    { "fseek" "io.streams.c" "primitive_fseek" (( alien offset whence -- )) }
    { "ftell" "io.streams.c" "primitive_ftell" (( alien -- n )) }
    { "fwrite" "io.streams.c" "primitive_fwrite" (( string alien -- )) }
    { "(clone)" "kernel" "primitive_clone" (( obj -- newobj )) }
    { "<wrapper>" "kernel" "primitive_wrapper" (( obj -- wrapper )) }
    { "callstack" "kernel" "primitive_callstack" (( -- cs )) }
    { "callstack>array" "kernel" "primitive_callstack_to_array" (( callstack -- array )) }
    { "datastack" "kernel" "primitive_datastack" (( -- ds )) }
    { "die" "kernel" "primitive_die" (( -- )) }
    { "retainstack" "kernel" "primitive_retainstack" (( -- rs )) }
    { "(identity-hashcode)" "kernel.private" "primitive_identity_hashcode" (( obj -- code )) }
    { "become" "kernel.private" "primitive_become" (( old new -- )) }
    { "call-clear" "kernel.private" "primitive_call_clear" (( quot -- * )) }
    { "check-datastack" "kernel.private" "primitive_check_datastack" (( array in# out# -- ? )) }
    { "compute-identity-hashcode" "kernel.private" "primitive_compute_identity_hashcode" (( obj -- )) }
    { "innermost-frame-executing" "kernel.private" "primitive_innermost_stack_frame_executing" (( callstack -- obj )) }
    { "innermost-frame-scan" "kernel.private" "primitive_innermost_stack_frame_scan" (( callstack -- n )) }
    { "set-datastack" "kernel.private" "primitive_set_datastack" (( ds -- )) }
    { "set-innermost-frame-quot" "kernel.private" "primitive_set_innermost_stack_frame_quot" (( n callstack -- )) }
    { "set-retainstack" "kernel.private" "primitive_set_retainstack" (( rs -- )) }
    { "set-special-object" "kernel.private" "primitive_set_special_object" (( obj n -- )) }
    { "special-object" "kernel.private" "primitive_special_object" (( n -- obj )) }
    { "strip-stack-traces" "kernel.private" "primitive_strip_stack_traces" (( -- )) }
    { "unimplemented" "kernel.private" "primitive_unimplemented" (( -- * )) }
    { "load-locals" "locals.backend" "primitive_load_locals" (( ... n -- )) }
    { "bits>double" "math" "primitive_bits_double" (( n -- x )) }
    { "bits>float" "math" "primitive_bits_float" (( n -- x )) }
    { "byte-array>bignum" "math" "primitive_byte_array_to_bignum" (( x -- y )) }
    { "double>bits" "math" "primitive_double_bits" (( x -- n )) }
    { "float>bits" "math" "primitive_float_bits" (( x -- n )) }
    { "(float>string)" "math.parser.private" "primitive_float_to_str" (( n -- str )) }
    { "(string>float)" "math.parser.private" "primitive_str_to_float" (( str -- n/f )) }
    { "bignum*" "math.private" "primitive_bignum_multiply" (( x y -- z )) }
    { "bignum+" "math.private" "primitive_bignum_add" (( x y -- z )) }
    { "bignum-" "math.private" "primitive_bignum_subtract" (( x y -- z )) }
    { "bignum-bit?" "math.private" "primitive_bignum_bitp" (( n x -- ? )) }
    { "bignum-bitand" "math.private" "primitive_bignum_and" (( x y -- z )) }
    { "bignum-bitnot" "math.private" "primitive_bignum_not" (( x -- y )) }
    { "bignum-bitor" "math.private" "primitive_bignum_or" (( x y -- z )) }
    { "bignum-bitxor" "math.private" "primitive_bignum_xor" (( x y -- z )) }
    { "bignum-log2" "math.private" "primitive_bignum_log2" (( x -- n )) }
    { "bignum-mod" "math.private" "primitive_bignum_mod" (( x y -- z )) }
    { "bignum-shift" "math.private" "primitive_bignum_shift" (( x y -- z )) }
    { "bignum/i" "math.private" "primitive_bignum_divint" (( x y -- z )) }
    { "bignum/mod" "math.private" "primitive_bignum_divmod" (( x y -- z w )) }
    { "bignum<" "math.private" "primitive_bignum_less" (( x y -- ? )) }
    { "bignum<=" "math.private" "primitive_bignum_lesseq" (( x y -- ? )) }
    { "bignum=" "math.private" "primitive_bignum_eq" (( x y -- ? )) }
    { "bignum>" "math.private" "primitive_bignum_greater" (( x y -- ? )) }
    { "bignum>=" "math.private" "primitive_bignum_greatereq" (( x y -- ? )) }
    { "bignum>fixnum" "math.private" "primitive_bignum_to_fixnum" (( x -- y )) }
    { "bignum>float" "math.private" "primitive_bignum_to_float" (( x -- y )) }
    { "fixnum-shift" "math.private" "primitive_fixnum_shift" (( x y -- z )) }
    { "fixnum/i" "math.private" "primitive_fixnum_divint" (( x y -- z )) }
    { "fixnum/mod" "math.private" "primitive_fixnum_divmod" (( x y -- z w )) }
    { "fixnum>bignum" "math.private" "primitive_fixnum_to_bignum" (( x -- y )) }
    { "fixnum>float" "math.private" "primitive_fixnum_to_float" (( x -- y )) }
    { "float*" "math.private" "primitive_float_multiply" (( x y -- z )) }
    { "float+" "math.private" "primitive_float_add" (( x y -- z )) }
    { "float-" "math.private" "primitive_float_subtract" (( x y -- z )) }
    { "float-mod" "math.private" "primitive_float_mod" (( x y -- z )) }
    { "float-u<" "math.private" "primitive_float_less" (( x y -- ? )) }
    { "float-u<=" "math.private" "primitive_float_lesseq" (( x y -- ? )) }
    { "float-u>" "math.private" "primitive_float_greater" (( x y -- ? )) }
    { "float-u>=" "math.private" "primitive_float_greatereq" (( x y -- ? )) }
    { "float/f" "math.private" "primitive_float_divfloat" (( x y -- z )) }
    { "float<" "math.private" "primitive_float_less" (( x y -- ? )) }
    { "float<=" "math.private" "primitive_float_lesseq" (( x y -- ? )) }
    { "float=" "math.private" "primitive_float_eq" (( x y -- ? )) }
    { "float>" "math.private" "primitive_float_greater" (( x y -- ? )) }
    { "float>=" "math.private" "primitive_float_greatereq" (( x y -- ? )) }
    { "float>bignum" "math.private" "primitive_float_to_bignum" (( x -- y )) }
    { "float>fixnum" "math.private" "primitive_float_to_fixnum" (( x -- y )) }
    { "all-instances" "memory" "primitive_all_instances" (( -- array )) }
    { "code-room" "memory" "primitive_code_room" (( -- code-room )) }
    { "compact-gc" "memory" "primitive_compact_gc" (( -- )) }
    { "data-room" "memory" "primitive_data_room" (( -- data-room )) }
    { "disable-gc-events" "memory" "primitive_disable_gc_events" (( -- events )) }
    { "enable-gc-events" "memory" "primitive_enable_gc_events" (( -- )) }
    { "gc" "memory" "primitive_full_gc" (( -- )) }
    { "minor-gc" "memory" "primitive_minor_gc" (( -- )) }
    { "size" "memory" "primitive_size" (( obj -- n )) }
    { "(save-image)" "memory.private" "primitive_save_image" (( path -- )) }
    { "(save-image-and-exit)" "memory.private" "primitive_save_image_and_exit" (( path -- )) }
    { "jit-compile" "quotations" "primitive_jit_compile" (( quot -- )) }
    { "quot-compiled?" "quotations" "primitive_quot_compiled_p" (( quot -- ? )) }
    { "quotation-code" "quotations" "primitive_quotation_code" (( quot -- start end )) }
    { "array>quotation" "quotations.private" "primitive_array_to_quotation" (( array -- quot )) }
    { "set-slot" "slots.private" "primitive_set_slot" (( value obj n -- )) }
    { "<string>" "strings" "primitive_string" (( n ch -- string )) }
    { "resize-string" "strings" "primitive_resize_string" (( n str -- newstr )) }
    { "set-string-nth-fast" "strings.private" "primitive_set_string_nth_fast" (( ch n string -- )) }
    { "set-string-nth-slow" "strings.private" "primitive_set_string_nth_slow" (( ch n string -- )) }
    { "string-nth" "strings.private" "primitive_string_nth" (( n string -- ch )) }
    { "(exit)" "system" "primitive_exit" (( n -- )) }
    { "nano-count" "system" "primitive_nano_count" (( -- ns )) }
    { "system-micros" "system" "primitive_system_micros" (( -- us )) }
    { "(sleep)" "threads.private" "primitive_sleep" (( nanos -- )) }
    { "dispatch-stats" "tools.dispatch.private" "primitive_dispatch_stats" (( -- stats )) }
    { "reset-dispatch-stats" "tools.dispatch.private" "primitive_reset_dispatch_stats" (( -- )) }
    { "profiling" "tools.profiler.private" "primitive_profiling" (( ? -- )) }
    { "vm-ptr" "vm" "primitive_vm_ptr" (( -- ptr )) }
    { "optimized?" "words" "primitive_optimized_p" (( word -- ? )) }
    { "word-code" "words" "primitive_word_code" (( word -- start end )) }
    { "(word)" "words.private" "primitive_word" (( name vocab -- word )) }
} [ first4 make-primitive ] each

! Bump build number
"build" "kernel" create build 1 + [ ] curry (( -- n )) define-declared

] with-compilation-unit
