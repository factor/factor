! Copyright (C) 2004, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs bootstrap.image.primitives
bootstrap.image.private classes classes.builtin classes.intersection
classes.predicate classes.private classes.singleton classes.tuple
classes.tuple.private classes.union combinators compiler.units io
kernel kernel.private layouts make math math.private namespaces parser
quotations sequences slots source-files splitting vocabs vocabs.loader
words ;
IN: bootstrap.primitives

"* Creating primitives and basic runtime structures..." print flush

H{ } clone sub-primitives set

"resource:basis/bootstrap/syntax.factor" parse-file

: asm-file ( arch -- file )
    "-" split reverse "." join
    "resource:basis/bootstrap/assembler/" ".factor" surround ;

architecture get asm-file parse-file

"resource:basis/bootstrap/layouts.factor" parse-file

! Now we have ( syntax-quot arch-quot layouts-quot ) on the stack

! Bring up a bare cross-compiling vocabulary.
"syntax" lookup-vocab vocab-words-assoc bootstrap-syntax set

H{ } clone dictionary set
H{ } clone root-cache set
H{ } clone source-files set
H{ } clone update-map set
H{ } clone implementors-map set

init-caches

bootstrapping? on

call( -- ) ! layouts quot
call( -- ) ! arch quot

! Vocabulary for slot accessors
"accessors" create-vocab drop

! After we execute bootstrap/layouts
num-types get f <array> builtins set

[

call( -- ) ! syntax-quot

! create-word some empty vocabs where the below primitives and
! classes will go
{
    "alien"
    "alien.accessors"
    "alien.libraries"
    "alien.private"
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
    "tools.memory.private"
    "tools.profiler.sampling.private"
    "words"
    "words.private"
    "vectors"
    "vectors.private"
    "vm"
} [ create-vocab drop ] each

! Builtin classes
: lookup-type-number ( word -- n )
    [ target-word ] with-global type-number ;

: register-builtin ( class -- )
    [ dup lookup-type-number "type" set-word-prop ]
    [ dup "type" word-prop builtins get set-nth ]
    [ f f f builtin-class define-class ]
    tri ;

: prepare-slots ( slots -- slots' )
    [ [ dup pair? [ first2 create-word ] when ] map ] map ;

: define-builtin-slots ( class slots -- )
    prepare-slots make-slots 1 finalize-slots
    [ "slots" set-word-prop ] [ define-accessors ] 2bi ;

: define-builtin-predicate ( class -- )
    dup class>type [ eq? ] curry [ tag ] prepend define-predicate ;

: define-builtin ( symbol slotspec -- )
    [ [ define-builtin-predicate ] keep ] dip define-builtin-slots ;

{
    { "alien" "alien" }
    { "array" "arrays" }
    { "bignum" "math" }
    { "byte-array" "byte-arrays" }
    { "callstack" "kernel" }
    { "dll" "alien" }
    { "fixnum" "math" }
    { "float" "math" }
    { "quotation" "quotations" }
    { "string" "strings" }
    { "tuple" "kernel" }
    { "word" "words" }
    { "wrapper" "kernel" }
} [ create-word register-builtin ] assoc-each

"f" "syntax" lookup-word register-builtin

! We need this before defining c-ptr below
"f" "syntax" lookup-word { } define-builtin

"f" "syntax" create-word [ not ] "predicate" set-word-prop
"f?" "syntax" vocab-words-assoc delete-at

"t" "syntax" lookup-word define-singleton-class

! Some unions
"c-ptr" "alien" create-word [
    "alien" "alien" lookup-word ,
    "f" "syntax" lookup-word ,
    "byte-array" "byte-arrays" lookup-word ,
] { } make define-union-class

"integer" "math" create-word
"fixnum" "math" lookup-word "bignum" "math" lookup-word 2array
define-union-class

! Two predicate classes used for declarations.
"array-capacity" "sequences.private" create-word
"fixnum" "math" lookup-word
[
    [ dup 0 fixnum>= ] %
    bootstrap-max-array-capacity <fake-bignum> [ fixnum<= ] curry ,
    [ [ drop f ] if ] %
] [ ] make
define-predicate-class

"array-capacity" "sequences.private" lookup-word
[ integer>fixnum-strict ] bootstrap-max-array-capacity <fake-bignum> [ fixnum-bitand ] curry append
"coercer" set-word-prop

"integer-array-capacity" "sequences.private" create-word
"integer" "math" lookup-word
[
    [ dup 0 >= ] %
    bootstrap-max-array-capacity <fake-bignum> [ <= ] curry ,
    [ [ drop f ] if ] %
] [ ] make
define-predicate-class

! Catch-all class for providing a default method.
"object" "kernel" create-word
[ f f { } intersection-class define-class ]
[ [ drop t ] "predicate" set-word-prop ]
bi

"object?" "kernel" vocab-words-assoc delete-at

! Empty class with no instances
"null" "kernel" create-word
[ f { } f union-class define-class ]
[ [ drop f ] "predicate" set-word-prop ]
bi

"null?" "kernel" vocab-words-assoc delete-at

"fixnum" "math" create-word { } define-builtin
"fixnum" "math" create-word "integer>fixnum-strict" "math" create-word 1quotation "coercer" set-word-prop

"bignum" "math" create-word { } define-builtin
"bignum" "math" create-word ">bignum" "math" create-word 1quotation "coercer" set-word-prop

"float" "math" create-word { } define-builtin
"float" "math" create-word ">float" "math" create-word 1quotation "coercer" set-word-prop

"array" "arrays" create-word {
    { "length" { "array-capacity" "sequences.private" } read-only }
} define-builtin

"wrapper" "kernel" create-word {
    { "wrapped" read-only }
} define-builtin

"string" "strings" create-word {
    { "length" { "array-capacity" "sequences.private" } read-only }
    "aux"
} define-builtin

"quotation" "quotations" create-word {
    { "array" { "array" "arrays" } read-only }
    "cached-effect"
    "cache-counter"
} define-builtin

"dll" "alien" create-word {
    { "path" { "byte-array" "byte-arrays" } read-only }
} define-builtin

"alien" "alien" create-word {
    { "underlying" { "c-ptr" "alien" } read-only }
    "expired"
} define-builtin

"word" "words" create-word {
    { "hashcode" { "fixnum" "math" } }
    "name"
    "vocabulary"
    { "def" { "quotation" "quotations" } initial: [ ] }
    "props"
    "pic-def"
    "pic-tail-def"
    { "sub-primitive" read-only }
} define-builtin

"byte-array" "byte-arrays" create-word {
    { "length" { "array-capacity" "sequences.private" } read-only }
} define-builtin

"callstack" "kernel" create-word { } define-builtin

"tuple" "kernel" create-word
[ { } define-builtin ]
[ define-tuple-layout ]
bi

! create-word special tombstone values
"tombstone" "hashtables.private" create-word
tuple
{ "state" } define-tuple-class

"+empty+" "hashtables.private" create-word
{ f } "tombstone" "hashtables.private" lookup-word
slots>tuple 1quotation ( -- value ) define-inline

"+tombstone+" "hashtables.private" create-word
{ t } "tombstone" "hashtables.private" lookup-word
slots>tuple 1quotation ( -- value ) define-inline

! Some tuple classes

"curried" "kernel" create-word
tuple
{
    { "obj" read-only }
    { "quot" read-only }
} prepare-slots define-tuple-class

"curry" "kernel" create-word
{
    [ f "inline" set-word-prop ]
    [ make-flushable ]
} cleave

"curry" "kernel" lookup-word
[
    callable instance-check-quot %
    "curried" "kernel" lookup-word tuple-layout ,
    \ <tuple-boa> ,
] [ ] make
( obj quot -- curry ) define-declared

"composed" "kernel" create-word
tuple
{
    { "first" read-only }
    { "second" read-only }
} prepare-slots define-tuple-class

"compose" "kernel" create-word
{
    [ f "inline" set-word-prop ]
    [ make-flushable ]
} cleave

"compose" "kernel" lookup-word
[
    callable instance-check-quot [ dip ] curry %
    callable instance-check-quot %
    "composed" "kernel" lookup-word tuple-layout ,
    \ <tuple-boa> ,
] [ ] make
( quot1 quot2 -- compose ) define-declared

"* Declaring primitives..." print flush
all-primitives create-primitives

! Bump build number
"build" "kernel" create-word build 1 + [ ] curry ( -- n ) define-declared

] with-compilation-unit
