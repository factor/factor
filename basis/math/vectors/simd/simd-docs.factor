USING: help.markup help.syntax sequences math math.vectors
kernel.private classes.tuple.private
math.vectors.simd.intrinsics cpu.architecture ;
IN: math.vectors.simd

ARTICLE: "math.vectors.simd.intro" "Introduction to SIMD support"
"Modern CPUs support a form of data-level parallelism, where arithmetic operations on fixed-size short vectors can be done on all components in parallel. This is known as single-instruction-multiple-data (SIMD)."
$nl
"SIMD support in the processor takes the form of instruction sets which operate on vector registers. By operating on multiple scalar values at the same time, code which operates on points, colors, and other vector data can be sped up."
$nl
"In Factor, SIMD support is exposed in the form of special-purpose SIMD " { $link "sequence-protocol" } " implementations. These are fixed-length, homogeneous sequences. They are referred to as vectors, but should not be confused with Factor's " { $link "vectors" } ", which can hold any type of object and can be resized.)."
$nl
"The words in the " { $vocab-link "math.vectors" } " vocabulary, which can be used with any sequence of numbers, are special-cased by the compiler. If the compiler can prove that only SIMD vectors are used, it expands " { $link "math-vectors" } " into " { $link "math.vectors.simd.intrinsics" } ". While in the general case, SIMD intrinsics operate on heap-allocated SIMD vectors, that too can be optimized since in many cases the compiler unbox SIMD vectors, storing them directly in registers."
$nl
"Since the only difference between ordinary code and SIMD-accelerated code is that the latter uses special fixed-length SIMD sequences, the SIMD library is very easy to use. To ensure your code compiles to use vector instructions without boxing and unboxing overhead, follow the guidelines for " { $link "math.vectors.simd.efficiency" } "."
$nl
"There should never be any reason to use " { $link "math.vectors.simd.intrinsics" } " directly, but they too have a straightforward, but lower-level, interface." ;

ARTICLE: "math.vectors.simd.support" "Supported SIMD instruction sets and operations"
"At present, the SIMD support makes use of SSE2 and a few SSE3 instructions on x86 CPUs."
$nl
"SSE3 introduces horizontal adds (summing all components of a single vector register), which is useful for computing dot products. Where available, SSE3 operations are used to speed up " { $link sum } ", " { $link v. } ", " { $link norm-sq } ", " { $link norm } ", and " { $link distance } ". If SSE3 is not available, software fallbacks are used for " { $link sum } " and related words, decreasing performance."
$nl
"On PowerPC, or older x86 chips without SSE2, software fallbacks are used for all high-level vector operations. SIMD code can run with no loss in functionality, just decreased performance."
$nl
"The primities in the " { $vocab-link "math.vectors.simd.intrinsics" } " vocabulary do not have software fallbacks, but they should not be called directly in any case." ;

ARTICLE: "math.vectors.simd.types" "SIMD vector types"
"Each SIMD vector type is named " { $snippet "scalar-count" } ", where " { $snippet "scalar" } " is a scalar C type such as " { $snippet "float" } " or " { $snippet "double" } ", and " { $snippet "count" } " is a vector dimension, such as 2, 4, or 8."
$nl
"The following vector types are defined:"
{ $subsection float-4 }
{ $subsection double-2 }
{ $subsection float-8 }
{ $subsection double-4 }
"For each vector type, several words are defined:"
{ $table
    { "Word" "Stack effect" "Description" }
    { { $snippet "type-with" } { $snippet "( x -- simd-array )" } "creates a new instance where all components are set to a single scalar" }
    { { $snippet "type-boa" } { $snippet "( ... -- simd-array )" } "creates a new instance where components are read from the stack" }
    { { $snippet ">type" } { $snippet "( seq -- simd-array )" } "creates a new instance initialized with the elements of an existing sequence, which must have the correct length" }
    { { $snippet "type{" } { $snippet "type{ elements... }" } "parsing word defining literal syntax for an SIMD vector; the correct number of elements must be given" }
}
"The " { $link float-4 } " and " { $link double-2 } " types correspond to 128-bit vector registers. The " { $link float-8 } " and " { $link double-4 } " types are not directly supported in hardware, and instead unbox to a pair of 128-bit vector registers."
$nl
"Operations on " { $link float-4 } " instances:"
{ $subsection float-4-with }
{ $subsection float-4-boa }
{ $subsection POSTPONE: float-4{ }
"Operations on " { $link double-2 } " instances:"
{ $subsection double-2-with }
{ $subsection double-2-boa }
{ $subsection POSTPONE: double-2{ }
"Operations on " { $link float-8 } " instances:"
{ $subsection float-8-with }
{ $subsection float-8-boa }
{ $subsection POSTPONE: float-8{ }
"Operations on " { $link double-4 } " instances:"
{ $subsection double-4-with }
{ $subsection double-4-boa }
{ $subsection POSTPONE: double-4{ }
"To actually perform vector arithmetic on SIMD vectors, use " { $link "math-vectors" } " words."
{ $see-also "c-types-specs" } ;

ARTICLE: "math.vectors.simd.efficiency" "Writing efficient SIMD code"
"Since SIMD vectors are heap-allocated objects, it is important to write code in a style which is conducive to the compiler being able to inline generic dispatch and eliminate allocation."
$nl
"If the inputs to a " { $vocab-link "math.vectors" } " word are statically known to be SIMD vectors, the call is converted into an SIMD primitive, and the output is then also known to be an SIMD vector (or scalar, depending on the operation); this information propagates forward within a single word (together with any inlined words and macro expansions). Any intermediate values which are not stored into collections, or returned from the word, are furthermore unboxed."
$nl
"To check if optimizations are being performed, pass a quotation to the " { $snippet "optimizer-report." } " and " { $snippet "optimized." } " words in the " { $vocab-link "compiler.tree.debugger" } " vocabulary, and look for calls to " { $link "math.vectors.simd.intrinsics" } " as opposed to high-level " { $link "math-vectors" } "."
$nl
"For example, in the following, no SIMD operations are used at all, because the compiler's propagation pass does not consider dynamic variable usage:"
{ $code
"""USING: compiler.tree.debugger math.vectors
math.vectors.simd ;
SYMBOLS: x y ;

[
    double-4{ 1.5 2.0 3.7 0.4 } x set
    double-4{ 1.5 2.0 3.7 0.4 } y set
    x get y get v+
] optimizer-report.""" }
"The following word benefits from SIMD optimization, because it begins with an unsafe declaration:"
{ $code
"""USING: compiler.tree.debugger kernel.private
math.vectors math.vectors.simd ;

: interpolate ( v a b -- w )
    { float-4 float-4 float-4 } declare
    [ v* ] [ [ 1.0 ] dip n-v v* ] bi-curry* bi v+ ;

\ interpolate optimizer-report.""" }
"Note that using " { $link declare } " is not recommended. Safer ways of getting type information for the input parameters to a word include defining methods on a generic word (the value being dispatched upon has a statically known type in the method body), as well as using " { $link "hints" } " and " { $link POSTPONE: inline } " declarations."
$nl
"Here is a better version of the " { $snippet "interpolate" } " words above that uses hints:"
{ $code
"""USING: compiler.tree.debugger hints
math.vectors math.vectors.simd ;

: interpolate ( v a b -- w )
    [ v* ] [ [ 1.0 ] dip n-v v* ] bi-curry* bi v+ ;

HINTS: interpolate float-4 float-4 float-4 ;

\ interpolate optimizer-report. """ }
"This time, the optimizer report lists calls to both SIMD primitives and high-level vector words, because hints cause two code paths to be generated. The " { $snippet "optimized." } " word can be used to make sure that the fast code path consists entirely of calls to primitives."
$nl
"If the " { $snippet "interpolate" } " word was to be used in several places with different types of vectors, it would be best to declare it " { $link POSTPONE: inline } "."
$nl
"In the " { $snippet "interpolate" } " word, there is still a call to the " { $link <tuple-boa> } " primitive, because the return value at the end is being boxed on the heap. In the next example, no memory allocation occurs at all because the SIMD vectors are stored inside a struct class (see " { $link "classes.struct" } "); also note the use of inlining:"
{ $code
"""USING: compiler.tree.debugger math.vectors math.vectors.simd ;
IN: simd-demo

STRUCT: actor
{ id int }
{ position float-4 }
{ velocity float-4 }
{ acceleration float-4 } ;

GENERIC: advance ( dt object -- )

: update-velocity ( dt actor -- )
    [ acceleration>> n*v ] [ velocity>> v+ ] [ ] tri
    (>>velocity) ; inline

: update-position ( dt actor -- )
    [ velocity>> n*v ] [ position>> v+ ] [ ] tri
    (>>position) ; inline

M: actor advance ( dt actor -- )
    [ >float ] dip
    [ update-velocity ] [ update-position ] 2bi ;

M\ actor advance optimized."""
}
"The " { $vocab-link "compiler.cfg.debugger" } " vocabulary can give a lower-level picture of the generated code, that includes register assignments and other low-level details. To look at low-level optimizer output, call " { $snippet "test-mr mr." } " on a word or quotation:"
{ $code
"""USE: compiler.tree.debugger

M\ actor advance test-mr mr.""" }
"An example of a high-performance algorithm that uses SIMD primitives can be found in the " { $vocab-link "benchmark.nbody-simd" } " vocabulary." ;

ARTICLE: "math.vectors.simd.intrinsics" "Low-level SIMD primitives"
"The words in the " { $vocab-link "math.vectors.simd.intrinsics" } " vocabulary are used to implement SIMD support. These words have three disadvantages compared to the higher-level " { $link "math-vectors" } " words:"
{ $list
    "They operate on raw byte arrays, with a separate “representation” parameter passed in to determine the type of the operands and result."
    "They are unsafe; passing values which are not byte arrays, or byte arrays with the wrong size, will dereference invalid memory and possibly crash Factor."
    { "They do not have software fallbacks; if the current CPU does not have SIMD support, a " { $link bad-simd-call } " error will be thrown." }
}
"The compiler converts " { $link "math-vectors" } " into SIMD primitives automatically in cases where it is safe; this means that the input types are known to be SIMD vectors, and the CPU supports SIMD."
$nl
"It is best to avoid calling these primitives directly. To write efficient high-level code that compiles down to primitives and avoids memory allocation, see " { $link "math.vectors.simd.efficiency" } "."
{ $subsection (simd-v+) }
{ $subsection (simd-v-) }
{ $subsection (simd-v/) }
{ $subsection (simd-vmin) }
{ $subsection (simd-vmax) }
{ $subsection (simd-vsqrt) }
{ $subsection (simd-sum) }
{ $subsection (simd-broadcast) }
{ $subsection (simd-gather-2) }
{ $subsection (simd-gather-4) }
"There are two primitives which are used to implement accessing SIMD vector fields of " { $link "classes.struct" } ":"
{ $subsection alien-vector }
{ $subsection set-alien-vector }
"For the most part, the above primitives correspond directly to vector arithmetic words. They take a representation parameter, which is one of the singleton members of the " { $link vector-rep } " union in the " { $vocab-link "cpu.architecture" } " vocabulary." ;

ARTICLE: "math.vectors.simd.alien" "SIMD data in struct classes"
"Struct classes may contain fields which store SIMD data; use one of the following C type names:"
{ $code
"""float-4
double-2
float-8
double-4""" }
"Passing SIMD data as function parameters is not yet supported." ;

ARTICLE: "math.vectors.simd" "Hardware vector arithmetic (SIMD)"
"The " { $vocab-link "math.vectors.simd" } " vocabulary extends the " { $vocab-link "math.vectors" } " vocabulary to support efficient vector arithmetic on small, fixed-size vectors."
{ $subsection "math.vectors.simd.intro" }
{ $subsection "math.vectors.simd.types" }
{ $subsection "math.vectors.simd.support" }
{ $subsection "math.vectors.simd.efficiency" }
{ $subsection "math.vectors.simd.alien" }
{ $subsection "math.vectors.simd.intrinsics" } ;

! ! ! float-4

HELP: float-4
{ $class-description "A sequence of four single-precision floating point values. New instances can be created with " { $link float-4-with } " or " { $link float-4-boa } "." } ;

HELP: float-4-with
{ $values { "x" float } { "simd-array" float-4 } }
{ $description "Creates a new vector with all four components equal to a scalar." } ;

HELP: float-4-boa
{ $values { "a" float } { "b" float } { "c" float } { "d" float } { "simd-array" float-4 } }
{ $description "Creates a new vector from four scalar components." } ;

HELP: float-4{
{ $syntax "float-4{ a b c d }" }
{ $description "Literal syntax for a " { $link float-4 } "." } ;

! ! ! double-2

HELP: double-2
{ $class-description "A sequence of two double-precision floating point values. New instances can be created with " { $link double-2-with } " or " { $link double-2-boa } "." } ;

HELP: double-2-with
{ $values { "x" float } { "simd-array" double-2 } }
{ $description "Creates a new vector with both components equal to a scalar." } ;

HELP: double-2-boa
{ $values { "a" float } { "b" float } { "simd-array" double-2 } }
{ $description "Creates a new vector from two scalar components." } ;

HELP: double-2{
{ $syntax "double-2{ a b }" }
{ $description "Literal syntax for a " { $link double-2 } "." } ;

! ! ! float-8

HELP: float-8
{ $class-description "A sequence of eight single-precision floating point values. New instances can be created with " { $link float-8-with } " or " { $link float-8-boa } "." } ;

HELP: float-8-with
{ $values { "x" float } { "simd-array" float-8 } }
{ $description "Creates a new vector with all eight components equal to a scalar." } ;

HELP: float-8-boa
{ $values { "a" float } { "b" float } { "c" float } { "d" float } { "e" float } { "f" float } { "g" float } { "h" float } { "simd-array" float-8 } }
{ $description "Creates a new vector from eight scalar components." } ;

HELP: float-8{
{ $syntax "float-8{ a b c d e f g h }" }
{ $description "Literal syntax for a " { $link float-8 } "." } ;

! ! ! double-4

HELP: double-4
{ $class-description "A sequence of four double-precision floating point values. New instances can be created with " { $link double-4-with } " or " { $link double-4-boa } "." } ;

HELP: double-4-with
{ $values { "x" float } { "simd-array" double-4 } }
{ $description "Creates a new vector with all four components equal to a scalar." } ;

HELP: double-4-boa
{ $values { "a" float } { "b" float } { "c" float } { "d" float } { "simd-array" double-4 } }
{ $description "Creates a new vector from four scalar components." } ;

HELP: double-4{
{ $syntax "double-4{ a b c d }" }
{ $description "Literal syntax for a " { $link double-4 } "." } ;

ABOUT: "math.vectors.simd"
