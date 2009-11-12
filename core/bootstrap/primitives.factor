! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays byte-arrays generic hashtables
hashtables.private io kernel math math.private math.order
namespaces make parser sequences strings vectors words
quotations assocs layouts classes classes.builtin classes.tuple
classes.tuple.private kernel.private vocabs vocabs.loader
source-files definitions slots classes.union
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
    [ create dup 1quotation ] dip define-declared ;

{
    { "(execute)" "kernel.private" (( word -- )) }
    { "(call)" "kernel.private" (( quot -- )) }
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
    { "fixnum<" "math.private" (( x y -- ? )) }
    { "fixnum<=" "math.private" (( x y -- z )) }
    { "fixnum>" "math.private" (( x y -- ? )) }
    { "fixnum>=" "math.private" (( x y -- ? )) }
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
    { "slot" "slots.private" (( obj m -- value )) }
    { "get-local" "locals.backend" (( n -- obj )) }
    { "load-local" "locals.backend" (( obj -- )) }
    { "drop-locals" "locals.backend" (( n -- )) }
    { "mega-cache-lookup" "generic.single.private" (( methods index cache -- )) }
} [ first3 make-sub-primitive ] each

! Primitive words
: make-primitive ( word vocab n effect -- )
    [
        [ create dup reset-word ] dip
        [ do-primitive ] curry
    ] dip define-declared ;

{
    { "bignum>fixnum" "math.private" (( x -- y )) }
    { "float>fixnum" "math.private" (( x -- y )) }
    { "fixnum>bignum" "math.private" (( x -- y )) }
    { "float>bignum" "math.private" (( x -- y )) }
    { "fixnum>float" "math.private" (( x -- y )) }
    { "bignum>float" "math.private" (( x -- y )) }
    { "(string>float)" "math.parser.private" (( str -- n/f )) }
    { "(float>string)" "math.parser.private" (( n -- str )) }
    { "float>bits" "math" (( x -- n )) }
    { "double>bits" "math" (( x -- n )) }
    { "bits>float" "math" (( n -- x )) }
    { "bits>double" "math" (( n -- x )) }
    { "fixnum+" "math.private" (( x y -- z )) }
    { "fixnum-" "math.private" (( x y -- z )) }
    { "fixnum*" "math.private" (( x y -- z )) }
    { "fixnum/i" "math.private" (( x y -- z )) }
    { "fixnum/mod" "math.private" (( x y -- z w )) }
    { "fixnum-shift" "math.private" (( x y -- z )) }
    { "bignum=" "math.private" (( x y -- ? )) }
    { "bignum+" "math.private" (( x y -- z )) }
    { "bignum-" "math.private" (( x y -- z )) }
    { "bignum*" "math.private" (( x y -- z )) }
    { "bignum/i" "math.private" (( x y -- z )) }
    { "bignum-mod" "math.private" (( x y -- z )) }
    { "bignum/mod" "math.private" (( x y -- z w )) }
    { "bignum-bitand" "math.private" (( x y -- z )) }
    { "bignum-bitor" "math.private" (( x y -- z )) }
    { "bignum-bitxor" "math.private" (( x y -- z )) }
    { "bignum-bitnot" "math.private" (( x -- y )) }
    { "bignum-shift" "math.private" (( x y -- z )) }
    { "bignum<" "math.private" (( x y -- ? )) }
    { "bignum<=" "math.private" (( x y -- ? )) }
    { "bignum>" "math.private" (( x y -- ? )) }
    { "bignum>=" "math.private" (( x y -- ? )) }
    { "bignum-bit?" "math.private" (( n x -- ? )) }
    { "bignum-log2" "math.private" (( x -- n )) }
    { "byte-array>bignum" "math" (( x -- y ))  }
    { "float=" "math.private" (( x y -- ? )) }
    { "float+" "math.private" (( x y -- z )) }
    { "float-" "math.private" (( x y -- z )) }
    { "float*" "math.private" (( x y -- z )) }
    { "float/f" "math.private" (( x y -- z )) }
    { "float-mod" "math.private" (( x y -- z )) }
    { "float<" "math.private" (( x y -- ? )) }
    { "float<=" "math.private" (( x y -- ? )) }
    { "float>" "math.private" (( x y -- ? )) }
    { "float>=" "math.private" (( x y -- ? )) }
    { "float-u<" "math.private" (( x y -- ? )) }
    { "float-u<=" "math.private" (( x y -- ? )) }
    { "float-u>" "math.private" (( x y -- ? )) }
    { "float-u>=" "math.private" (( x y -- ? )) }
    { "(word)" "words.private" (( name vocab -- word )) }
    { "word-xt" "words" (( word -- start end )) }
    { "getenv" "kernel.private" (( n -- obj )) }
    { "setenv" "kernel.private" (( obj n -- )) }
    { "(exists?)" "io.files.private" (( path -- ? )) }
    { "minor-gc" "memory" (( -- )) }
    { "gc" "memory" (( -- )) }
    { "compact-gc" "memory" (( -- )) }
    { "(save-image)" "memory.private" (( path -- )) }
    { "(save-image-and-exit)" "memory.private" (( path -- )) }
    { "datastack" "kernel" (( -- ds )) }
    { "retainstack" "kernel" (( -- rs )) }
    { "callstack" "kernel" (( -- cs )) }
    { "set-datastack" "kernel" (( ds -- )) }
    { "set-retainstack" "kernel" (( rs -- )) }
    { "set-callstack" "kernel" (( cs -- )) }
    { "exit" "system" (( n -- )) }
    { "data-room" "memory" (( -- data-room )) }
    { "code-room" "memory" (( -- code-room )) }
    { "micros" "system" (( -- us )) }
    { "modify-code-heap" "compiler.units" (( alist -- )) }
    { "(dlopen)" "alien.libraries" (( path -- dll )) }
    { "(dlsym)" "alien.libraries" (( name dll -- alien )) }
    { "dlclose" "alien.libraries" (( dll -- )) }
    { "<byte-array>" "byte-arrays" (( n -- byte-array )) }
    { "(byte-array)" "byte-arrays" (( n -- byte-array )) }
    { "<displaced-alien>" "alien" (( displacement c-ptr -- alien )) }
    { "alien-signed-cell" "alien.accessors" (( c-ptr n -- value )) }
    { "set-alien-signed-cell" "alien.accessors" (( value c-ptr n -- )) }
    { "alien-unsigned-cell" "alien.accessors" (( c-ptr n -- value )) }
    { "set-alien-unsigned-cell" "alien.accessors" (( value c-ptr n -- )) }
    { "alien-signed-8" "alien.accessors" (( c-ptr n -- value )) }
    { "set-alien-signed-8" "alien.accessors" (( value c-ptr n -- )) }
    { "alien-unsigned-8" "alien.accessors" (( c-ptr n -- value )) }
    { "set-alien-unsigned-8" "alien.accessors" (( value c-ptr n -- )) }
    { "alien-signed-4" "alien.accessors" (( c-ptr n -- value )) }
    { "set-alien-signed-4" "alien.accessors" (( value c-ptr n -- )) }
    { "alien-unsigned-4" "alien.accessors" (( c-ptr n -- value )) }
    { "set-alien-unsigned-4" "alien.accessors" (( value c-ptr n -- )) }
    { "alien-signed-2" "alien.accessors" (( c-ptr n -- value )) }
    { "set-alien-signed-2" "alien.accessors" (( value c-ptr n -- )) }
    { "alien-unsigned-2" "alien.accessors" (( c-ptr n -- value )) }
    { "set-alien-unsigned-2" "alien.accessors" (( value c-ptr n -- )) }
    { "alien-signed-1" "alien.accessors" (( c-ptr n -- value )) }
    { "set-alien-signed-1" "alien.accessors" (( value c-ptr n -- )) }
    { "alien-unsigned-1" "alien.accessors" (( c-ptr n -- value )) }
    { "set-alien-unsigned-1" "alien.accessors" (( value c-ptr n -- )) }
    { "alien-float" "alien.accessors" (( c-ptr n -- value )) }
    { "set-alien-float" "alien.accessors" (( value c-ptr n -- )) }
    { "alien-double" "alien.accessors" (( c-ptr n -- value )) }
    { "set-alien-double" "alien.accessors" (( value c-ptr n -- )) }
    { "alien-cell" "alien.accessors" (( c-ptr n -- value )) }
    { "set-alien-cell" "alien.accessors" (( value c-ptr n -- )) }
    { "alien-address" "alien" (( c-ptr -- addr )) }
    { "set-slot" "slots.private" (( value obj n -- )) }
    { "string-nth" "strings.private" (( n string -- ch )) }
    { "set-string-nth-fast" "strings.private" (( ch n string -- )) }
    { "set-string-nth-slow" "strings.private" (( ch n string -- )) }
    { "resize-array" "arrays" (( n array -- newarray )) }
    { "resize-string" "strings" (( n str -- newstr )) }
    { "<array>" "arrays" (( n elt -- array )) }
    { "all-instances" "memory" (( -- array )) }
    { "size" "memory" (( obj -- n )) }
    { "die" "kernel" (( -- )) }
    { "(fopen)" "io.streams.c" (( path mode -- alien )) }
    { "fgetc" "io.streams.c" (( alien -- ch/f )) }
    { "fread" "io.streams.c" (( n alien -- str/f )) }
    { "fputc" "io.streams.c" (( ch alien -- )) }
    { "fwrite" "io.streams.c" (( string alien -- )) }
    { "fflush" "io.streams.c" (( alien -- )) }
    { "ftell" "io.streams.c" (( alien -- n )) }
    { "fseek" "io.streams.c" (( alien offset whence -- )) }
    { "fclose" "io.streams.c" (( alien -- )) }
    { "<wrapper>" "kernel" (( obj -- wrapper )) }
    { "(clone)" "kernel" (( obj -- newobj )) }
    { "<string>" "strings" (( n ch -- string )) }
    { "array>quotation" "quotations.private" (( array -- quot )) }
    { "quotation-xt" "quotations" (( quot -- xt )) }
    { "<tuple>" "classes.tuple.private" (( layout -- tuple )) }
    { "profiling" "tools.profiler.private" (( ? -- )) }
    { "become" "kernel.private" (( old new -- )) }
    { "(sleep)" "threads.private" (( us -- )) }
    { "<tuple-boa>" "classes.tuple.private" (( ... layout -- tuple )) }
    { "callstack>array" "kernel" (( callstack -- array )) }
    { "innermost-frame-executing" "kernel.private" (( callstack -- obj )) }
    { "innermost-frame-scan" "kernel.private" (( callstack -- n )) }
    { "set-innermost-frame-quot" "kernel.private" (( n callstack -- )) }
    { "call-clear" "kernel" (( quot -- )) }
    { "resize-byte-array" "byte-arrays" (( n byte-array -- newbyte-array )) }
    { "dll-valid?" "alien.libraries" (( dll -- ? )) }
    { "unimplemented" "kernel.private" (( -- * )) }
    { "jit-compile" "quotations" (( quot -- )) }
    { "load-locals" "locals.backend" (( ... n -- )) }
    { "check-datastack" "kernel.private" (( array in# out# -- ? )) }
    { "inline-cache-miss" "generic.single.private" (( generic methods index cache -- )) }
    { "inline-cache-miss-tail" "generic.single.private" (( generic methods index cache -- )) }
    { "mega-cache-miss" "generic.single.private" (( methods index cache -- method )) }
    { "lookup-method" "generic.single.private" (( object methods -- method )) }
    { "reset-dispatch-stats" "tools.dispatch.private" (( -- )) }
    { "dispatch-stats" "tools.dispatch.private" (( -- stats )) }
    { "optimized?" "words" (( word -- ? )) }
    { "quot-compiled?" "quotations" (( quot -- ? )) }
    { "vm-ptr" "vm" (( -- ptr )) }
    { "strip-stack-traces" "kernel.private" (( -- )) }
    { "<callback>" "alien" (( word -- alien )) }
    { "enable-gc-events" "memory" (( -- )) }
    { "disable-gc-events" "memory" (( -- events )) }
    { "(identity-hashcode)" "kernel.private" (( obj -- code )) }
    { "compute-identity-hashcode" "kernel.private" (( obj -- )) }
} [ [ first3 ] dip swap make-primitive ] each-index

! Bump build number
"build" "kernel" create build 1 + [ ] curry (( -- n )) define-declared
