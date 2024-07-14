USING: classes.tuple.private cpu.architecture help.markup
help.syntax kernel.private math.vectors
math.vectors.simd.intrinsics sequences ;
IN: math.vectors.simd

ARTICLE: "math.vectors.simd.intro" "Introduction to SIMD support"
"Modern CPUs support a form of data-level parallelism, where arithmetic operations on fixed-size short vectors can be done on all components in parallel. This is known as single-instruction-multiple-data (SIMD)."
$nl
"SIMD support in the processor takes the form of instruction sets which operate on vector registers. By operating on multiple scalar values at the same time, code which operates on points, colors, and other vector data can be sped up."
$nl
"In Factor, SIMD support is exposed in the form of special-purpose SIMD " { $link "sequence-protocol" } " implementations. These are fixed-length, homogeneous sequences. They are referred to as vectors, but should not be confused with Factor's " { $link "vectors" } ", which can hold any type of object and can be resized."
$nl
"The words in the " { $vocab-link "math.vectors" } " vocabulary, which can be used with any sequence of numbers, are special-cased by the compiler. If the compiler can prove that only SIMD vectors are used, it expands " { $link "math-vectors" } " into " { $link "math.vectors.simd.intrinsics" } ". While in the general case, SIMD intrinsics operate on heap-allocated SIMD vectors, that too can be optimized since in many cases the compiler unbox SIMD vectors, storing them directly in registers."
$nl
"Since the only difference between ordinary code and SIMD-accelerated code is that the latter uses special fixed-length SIMD sequences, the SIMD library is very easy to use. To ensure your code compiles to use vector instructions without boxing and unboxing overhead, follow the guidelines for " { $link "math.vectors.simd.efficiency" } "."
$nl
"There should never be any reason to use " { $link "math.vectors.simd.intrinsics" } " directly, but they too have a straightforward, but lower-level, interface." ;

ARTICLE: "math.vectors.simd.support" "Supported SIMD instruction sets and operations"
"At present, the SIMD support makes use of a subset of SSE up to SSE4.1. The subset used depends on the current CPU type."
$nl
"SSE1 only supports single-precision SIMD (" { $snippet "float-4" } ")."
$nl
"SSE2 introduces double-precision SIMD (" { $snippet "double-2" } ") and integer SIMD (all types). Integer SIMD is missing a few features; in particular, the " { $link vmin } " and " { $link vmax } " operations only work on " { $snippet "uchar-16" } " and " { $snippet "short-8" } "."
$nl
"SSE3 introduces horizontal adds (summing all components of a single vector register), which are useful for computing dot products. Where available, SSE3 operations are used to speed up " { $link sum } ", " { $link vdot } ", " { $link norm-sq } ", " { $link norm } ", and " { $link distance } "."
$nl
"SSSE3 introduces " { $link vabs } " for " { $snippet "char-16" } ", " { $snippet "short-8" } " and " { $snippet "int-4" } "."
$nl
"SSE4.1 introduces " { $link vmin } " and " { $link vmax } " for all remaining integer types, a faster instruction for " { $link vdot } ", and a few other things."
$nl
"On PowerPC, or older x86 chips without SSE, software fallbacks are used for all high-level vector operations. SIMD code can run with no loss in functionality, just decreased performance."
$nl
"The primitives in the " { $vocab-link "math.vectors.simd.intrinsics" } " vocabulary do not have software fallbacks, but they should not be called directly in any case." ;

ARTICLE: "math.vectors.simd.types" "SIMD vector types"
"Each SIMD vector type is named " { $snippet "scalar-count" } ", where " { $snippet "scalar" } " is a scalar C type and " { $snippet "count" } " is a vector dimension."
$nl
"The following 128-bit vector types are defined in the " { $vocab-link "math.vectors.simd" } " vocabulary:"
{ $code
    "char-16"
    "uchar-16"
    "short-8"
    "ushort-8"
    "int-4"
    "uint-4"
    "longlong-2"
    "ulonglong-2"
    "float-4"
    "double-2"
}
"Double-width 256-bit vector types are defined in the " { $vocab-link "math.vectors.simd.cords" } " vocabulary:"
{ $code
    "char-32"
    "uchar-32"
    "short-16"
    "ushort-16"
    "int-8"
    "uint-8"
    "longlong-4"
    "ulonglong-4"
    "float-8"
    "double-4"
} ;

ARTICLE: "math.vectors.simd.words" "SIMD vector words"
"For each SIMD vector type, several words are defined, where " { $snippet "type" } " is the type in question:"
{ $table
    { { $strong "Word" } { $strong "Stack effect" } { $strong "Description" } }
    { { $snippet "type-with" } { $snippet "( x -- simd-array )" } "creates a new instance where all components are set to a single scalar" }
    { { $snippet "type-boa" } { $snippet "( ... -- simd-array )" } "creates a new instance where components are read from the stack" }
    { { $snippet "type-cast" } { $snippet "( simd-array -- simd-array' )" } "creates a new SIMD array where the underlying data is taken from another SIMD array, with no format conversion" }
    { { $snippet ">type" } { $snippet "( seq -- simd-array )" } "creates a new instance initialized with the elements of an existing sequence, which must have the correct length" }
    { { $snippet "type{" } { $snippet "type{ elements... }" } "parsing word defining literal syntax for an SIMD vector; the correct number of elements must be given" }
}
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
"USING: compiler.tree.debugger math.vectors
math.vectors.simd ;
SYMBOLS: x y ;

[
    float-4{ 1.5 2.0 3.7 0.4 } x set
    float-4{ 1.5 2.0 3.7 0.4 } y set
    x get y get v+
] optimizer-report." }
"The following word benefits from SIMD optimization, because it begins with an unsafe declaration:"
{ $code
"USING: compiler.tree.debugger kernel.private
math.vectors math.vectors.simd ;
IN: simd-demo

: interpolate ( v a b -- w )
    { float-4 float-4 float-4 } declare
    [ v* ] [ [ 1.0 ] dip n-v v* ] bi-curry* bi v+ ;

\\ interpolate optimizer-report." }
"Note that using " { $link declare } " is not recommended. Safer ways of getting type information for the input parameters to a word include defining methods on a generic word (the value being dispatched upon has a statically known type in the method body), as well as using " { $link "hints" } " and " { $link POSTPONE: inline } " declarations."
$nl
"Here is a better version of the " { $snippet "interpolate" } " words above that uses hints:"
{ $code
"USING: compiler.tree.debugger hints
math.vectors math.vectors.simd ;
IN: simd-demo

: interpolate ( v a b -- w )
    [ v* ] [ [ 1.0 ] dip n-v v* ] bi-curry* bi v+ ;

HINTS: interpolate float-4 float-4 float-4 ;

\\ interpolate optimizer-report. " }
"This time, the optimizer report lists calls to both SIMD primitives and high-level vector words, because hints cause two code paths to be generated. The " { $snippet "optimized." } " word can be used to make sure that the fast code path consists entirely of calls to primitives."
$nl
"If the " { $snippet "interpolate" } " word was to be used in several places with different types of vectors, it would be best to declare it " { $link POSTPONE: inline } "."
$nl
"In the " { $snippet "interpolate" } " word, there is still a call to the " { $link <tuple-boa> } " primitive, because the return value at the end is being boxed on the heap. In the next example, no memory allocation occurs at all because the SIMD vectors are stored inside a struct class (see " { $link "classes.struct" } "); also note the use of inlining:"
{ $code
"USING: compiler.tree.debugger math.vectors math.vectors.simd ;
IN: simd-demo

STRUCT: actor
{ id int }
{ position float-4 }
{ velocity float-4 }
{ acceleration float-4 } ;

GENERIC: advance ( dt object -- )

: update-velocity ( dt actor -- )
    [ acceleration>> n*v ] [ velocity>> v+ ] [ ] tri
    velocity<< ; inline

: update-position ( dt actor -- )
    [ velocity>> n*v ] [ position>> v+ ] [ ] tri
    position<< ; inline

M: actor advance ( dt actor -- )
    [ >float ] dip
    [ update-velocity ] [ update-position ] 2bi ;

M\\ actor advance optimized."
}
"The " { $vocab-link "compiler.cfg.debugger" } " vocabulary can give a lower-level picture of the generated code, that includes register assignments and other low-level details. To look at low-level optimizer output, call " { $snippet "regs." } " on a word or quotation:"
{ $code
"USE: compiler.tree.debugger

M\\ actor advance regs." }
"Example of a high-performance algorithms that use SIMD primitives can be found in the following vocabularies:"
{ $list
    { $vocab-link "benchmark.nbody-simd" }
    { $vocab-link "benchmark.raytracer-simd" }
    { $vocab-link "random.sfmt" }
} ;

ARTICLE: "math.vectors.simd.intrinsics" "Low-level SIMD primitives"
"The words in the " { $vocab-link "math.vectors.simd.intrinsics" } " vocabulary are used to implement SIMD support. These words have three disadvantages compared to the higher-level " { $link "math-vectors" } " words:"
{ $list
    "They operate on raw byte arrays, with a separate \"representation\" parameter passed in to determine the type of the operands and result."
    "They are unsafe; passing values which are not byte arrays, or byte arrays with the wrong size, will dereference invalid memory and possibly crash Factor."
}
"The compiler converts " { $link "math-vectors" } " into SIMD primitives automatically in cases where it is safe; this means that the input types are known to be SIMD vectors, and the CPU supports SIMD."
$nl
"It is best to avoid calling SIMD primitives directly. To write efficient high-level code that compiles down to primitives and avoids memory allocation, see " { $link "math.vectors.simd.efficiency" } "."
$nl
"There are two primitives which are used to implement accessing SIMD vector fields of " { $link "classes.struct" } ":"
{ $subsections
    alien-vector
    set-alien-vector
}
"For the most part, the above primitives correspond directly to vector arithmetic words. They take a representation parameter, which is one of the singleton members of the " { $link vector-rep } " union in the " { $vocab-link "cpu.architecture" } " vocabulary." ;

ARTICLE: "math.vectors.simd.alien" "SIMD data in struct classes"
"Struct classes may contain fields which store SIMD data; for each SIMD vector type listed in " { $snippet "math.vectors.simd.types" } " there is a C type with the same name."
$nl
"Only SIMD struct fields are allowed at the moment; passing SIMD data as function parameters is not yet supported." ;

ARTICLE: "math.vectors.simd.accuracy" "Numerical accuracy of SIMD primitives"
"No guarantees are made that " { $vocab-link "math.vectors.simd" } " words will give identical results on different SSE versions, or between the hardware intrinsics and the software fallbacks."
$nl
"In particular, horizontal operations on " { $snippet "float-4" } " vectors are affected by this. They are computed with lower precision in intrinsics than the software fallback. Horizontal operations include anything involving adding together the components of a vector, such as " { $link sum } " or " { $link normalize } "." ;

ARTICLE: "math.vectors.simd" "Hardware vector arithmetic (SIMD)"
"The " { $vocab-link "math.vectors.simd" } " vocabulary extends the " { $vocab-link "math.vectors" } " vocabulary to support efficient vector arithmetic on small, fixed-size vectors."
{ $subsections
    "math.vectors.simd.intro"
    "math.vectors.simd.types"
    "math.vectors.simd.words"
    "math.vectors.simd.support"
    "math.vectors.simd.accuracy"
    "math.vectors.simd.efficiency"
    "math.vectors.simd.alien"
    "math.vectors.simd.intrinsics"
} ;

ABOUT: "math.vectors.simd"
