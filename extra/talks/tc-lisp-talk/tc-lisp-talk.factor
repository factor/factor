! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs combinators constructors eval help.markup kernel
multiline namespaces parser sequences sequences.private slides
vocabs.refresh words fry ;
IN: talks.tc-lisp-talk

CONSTANT: tc-lisp-slides
{
    { $slide "Factor!"
        { $url "http://factorcode.org" }
        "Development started in 2003"
        "Open source (BSD license)"
        "Influenced by Forth, Lisp, and Smalltalk"
        "Blurs the line between language and library"
        "Interactive development"
    }
    { $slide "First, some examples"
        { $code "3 weeks ago noon monday ." }
        { $code "USE: roman 2009 >roman ." }
        { $code ": average ( seq -- x )
    [ sum ] [ length ] bi / ;" }
        { $code "1 miles [ km ] undo >float ." }
        { $code "[ readln eval>string print t ] loop" }
    }
    { $slide "XML Literals"
        { $code
        "USING: splitting xml.writer xml.syntax ;
{ \"one\" \"two\" \"three\" }
[ [XML <item><-></item> XML] ] map
<XML <doc><-></doc> XML> pprint-xml"
        }
    }
    { $slide "Differences between Factor and Lisp"
        "Single-implementation language"
        "Less nesting, shorter word length"
        { "Dynamic reloading of code from files with " { $link refresh-all } }
        "More generic protocols -- sequences, assocs, streams"
        "More cross-platform"
        "No standard for the language"
        "Evaluates left to right"
    }
    { $slide "Terminology"
        { "Words - functions" }
        { "Vocabularies - collections of code in the same namespace" }
        { "Quotations - blocks of code" { $code "[ dup reverse append ]" } }
        { "Combinators - higher order functions" }
        { "Static stack effect - known stack effect at compile-time" }
    }
    { $slide "Defining a word"
        "Defined at parse time"
        "Parts: name, stack effect, definition"
        "Composed of tokens separated by whitespace"
        { $code ": palindrome? ( string -- ? ) dup reverse = ;" }
    }
    { $slide "Non-static stack effect"
        "Not a good practice, nor useful"
        "Not compiled by the optimizing compiler"
        { $code "100 <iota> [ ] each" }
    }
    { $slide "Module system"
        "Code divided up into vocabulary roots"
        "core/ -- just enough code to bootstrap Factor"
        "basis/ -- optimizing compiler, the UI, tools, libraries"
        "extra/ -- demos, unpolished code, experiments"
        "work/ -- your works in progress"
    }
    { $slide "Module system (part 2)"
        "Each vocabulary corresponds to a directory on disk, with documentation and test files"
        { "Code for the " { $snippet "math" } " vocabulary: " { $snippet "~/factor/core/math/math.factor" } }
        { "Documentation for the " { $snippet "math" } " vocabulary: " { $snippet "~/factor/core/math/math-docs.factor" } }
        { "Unit tests for the " { $snippet "math" } " vocabulary: " { $snippet " ~/factor/core/math/math-tests.factor" } }
    }
    { $slide "Using a library"
        "Each file starts with a USING: list"
        "To use a library, simply include it in this list"
        "Refreshing code loads dependencies correctly"
    }
    { $slide "Object system"
        "Based on CLOS"
        { "We define generic words that operate on the top of the stack with " { $link POSTPONE: GENERIC:  } " or on an implicit parameter with " { $link POSTPONE: HOOK: } }
    }
    { $slide "Object system example: shape protocol"
        "In ~/factor/work/shapes/shapes.factor"
        { $code "IN: shapes

GENERIC: area ( shape -- x )
GENERIC: perimeter ( shape -- x )"
        }
    }
    { $slide "Implementing the shape protocol: circles"
        "In ~/factor/work/shapes/circle/circle.factor"
        { $code "USING: shapes constructors math
math.constants ;
IN: shapes.circle

TUPLE: circle radius ;
CONSTRUCTOR: <circle> circle ( radius -- obj ) ;
M: circle area radius>> sq pi * ;
M: circle perimeter radius>> pi * 2 * ;"
        }
    }
    { $slide "Dynamic variables"
        "Implemented as a stack of hashtables"
        { "Useful words are " { $link get } ", " { $link set } }
        "Input, output, error streams are stored in dynamic variables"
        { $code "\"Today is the first day of the rest of your life.\"
[
    readln print
] with-string-reader"
        }
    }
    { $slide "The global namespace"
        "The global namespace is just the namespace at the bottom of the namespace stack"
        { "Useful words are " { $link get-global } ", " { $link set-global } }
        "Factor idiom for changing a particular namespace"
        { $code "SYMBOL: king
global [ \"Henry VIII\" king set ] with-variables"
        }
        { $code "with-scope" }
        { $code "namestack" }
    }
    { $slide "Hooks"
        "Dispatch on a dynamic variable"
        { $code "HOOK: computer-name os ( -- string )
M: macosx computer-name uname first ;
macosx \ os set-global
computer-name"
        }
    }
    { $slide "Interpolate"
        "Replaces variables in a string"
        { $code
"\"Dawg\" \"name\" set
\"rims\" \"noun\" set
\"bling\" \"verb1\" set
\"roll\" \"verb2\" set
[
    \"Sup ${name}, we heard you liked ${noun}, so we put ${noun} on your car so you can ${verb1} while you ${verb2}.\"
    interpolate
] with-string-writer print "
        }
    }
    { $slide "Sequence protocol"
        "All sequences obey a protocol of generics"
        { "Is an object a " { $link sequence? } }
        { "Getting the " { $link length } }
        { "Accessing the " { $link nth  } " element" }
        { "Setting an element - " { $link set-nth } }
    }
    { $slide "Examples of sequences in Factor"
        "Arrays are mutable"
        "Vectors are mutable and growable"
        { "Arrays " { $code "{ \"abc\" \"def\" 50 }" } }
        { "Vectors " { $code "V{ \"abc\" \"def\" 50 }" } }
        { "Byte-arrays " { $code "B{ 1 2 3 }" } }
        { "Byte-vectors " { $code "BV{ 11 22 33 }" } }
    }
    { $slide "Specialized arrays and vectors"
        { "Specialized int arrays " { $code "int-array{ -20 -30 40 }" } }
        { "Specialized uint arrays " { $code "uint-array{ 20 30 40 }" } }
        { "Specialized float vectors " { $code "float-vector{ 20 30 40 }" } }
        "35 others C-type arrays"
    }
    { $slide "Specialized arrays code"
        "One line per array/vector"
        { "In ~/factor/basis/specialized-arrays/float/float.factor"
            { $code "<< \"float\" define-array >>" }
        }
        { "In ~/factor/basis/specialized-vectors/float/float.factor"
            { $code "<< \"float\" define-vector >>" }
        }
    }

    { $slide "Speciailzied arrays are implemented using functors"
        "Like C++ templates"
        "Eliminate boilerplate in ways other abstractions don't"
        "Contains a definition section and a functor body"
        "Uses the interpolate vocabulary"
    }
    { $slide "Functor for sorting"
        { $code
            "<FUNCTOR: define-sorting ( NAME QUOT -- )

NAME<=> DEFINES ${NAME}<=>
NAME>=< DEFINES ${NAME}>=<

WHERE

: NAME<=> ( obj1 obj2 -- <=> ) QUOT compare ;
: NAME>=< ( obj1 obj2 -- >=< )
    NAME<=> invert-comparison ;

;FUNCTOR>"
        }
    }
    { $slide "Example of sorting functor"
        { $code "USING: sorting.functor ;
<< \"length\" [ length ] define-sorting >>"
        }
        { $code
            "{ { 1 2 3 } { 1 2 } { 1 } }
[ length<=> ] sort"
        }
    }
    { $slide "Combinators"
        "Used to implement higher order functions (dataflow and control flow)"
        "Compiler optimizes away quotations completely"
        "Optimized code is just tight loops in registers"
        "Most loops can be expressed with combinators or tail-recursion"
    }
    { $slide "Combinators that act on one value"
        { $link bi }
        { $code "10 [ 1 - ] [ 1 + ] bi" }
        { $link tri }
        { $code "10 [ 1 - ] [ 1 + ] [ 2 * ] tri" }
    }
    { $slide "Combinators that act on two values"
        { $link 2bi }
        { $code "10 1 [ - ] [ + ] 2bi" }
        { $link bi* }
        { $code "10 20 [ 1 - ] [ 1 + ] bi*" }
        { $link bi@ }
        { $code "5 9 [ sq ] bi@" }
    }
    { $slide "Sequence combinators"

        { $link each }
        { $code "{ 1 2 3 4 5 } [ sq . ] each" }
        { $link map }
        { $code "{ 1 2 3 4 5 } [ sq ] map" }
        { $link filter }
        { $code "{ 1 2 3 4 5 } [ even? ] filter" }
    }
    { $slide "Multiple sequence combinators"

        { $link 2each }
        { $code "{ 1 2 3 } { 10 20 30 } [ + . ] 2each" }
        { $link 2map }
        { $code "{ 1 2 3 } { 10 20 30 } [ + ] 2map" }
    }
    { $slide "Control flow: if"
        { $link if }
        { $code "10 random dup even? [ 2 / ] [ 1 - ] if" }
        { $link when }
        { $code "10 random dup even? [ 2 / ] when" }
        { $link unless }
        { $code "10 random dup even? [ 1 - ] unless" }
    }
    { $slide "Control flow: case"
        { $link case }
        { $code "ERROR: not-possible obj ;
10 random 5 <=> {
    { +lt+ [ \"Less\" ] }
    { +gt+ [ \"More\" ] }
    { +eq+ [ \"Equal\" ] }
    [ not-possible ]
} case"
        }
    }
    { $slide "Fry"
        "Used to construct quotations"
        { "'Holes', represented by " { $snippet "_" } " are filled left to right" }
        { $code "10 4 '[ _ + ] call" }
        { $code "3 4 '[ _ sq _ + ] call" }
    }
    { $slide "Locals"
        "When data flow combinators and shuffle words are not enough"
        "Name your input parameters"
        "Used in about 1% of all words"
    }
    { $slide "Locals example"
        "Area of a triangle using Heron's formula"
        { $code
            ":: area ( a b c -- x )
    a b c + + 2 / :> p
    p
    p a - *
    p b - *
    p c - * sqrt ;"
        }
    }
    { $slide "Previous example without locals"
        "A bit unwieldy..."
        { $code
            ": area ( a b c -- x )
    [ ] [ + + 2 / ] 3bi
    [ '[ _ - ] tri@ ] [ neg ] bi
    * * * sqrt ;" }
    }
    { $slide "More idiomatic version"
        "But there's a trick: put the lengths in an array"
        { $code ": v-n ( v n -- w ) '[ _ - ] map ;

: area ( seq -- x )
    [ 0 suffix ] [ sum 2 / ] bi
    v-n product sqrt ;" }
    }
    { $slide "Implementing an abstraction"
        { "Suppose we want to get the price of the customer's first order, but any one of the steps along the way could be a nil value (" { $link f } " in Factor):" }
        { $code
            "dup [ orders>> ] when"
            "dup [ first ] when"
            "dup [ price>> ] when"
        }
    }
    { $slide "This is hard with mainstream syntax!"
        { $code
            "var customer = ...;
var orders = (customer == null ? null : customer.orders);
var order = (orders == null ? null : orders[0]);
var price = (order == null ? null : order.price);" }
    }
    { $slide "An ad-hoc solution"
        "Something like..."
        { $code "var price = customer.?orders.?[0].?price;" }
    }
    { $slide "Macros in Factor"
        "Expand at compile-time"
        "Return a quotation to be compiled"
        "Can express non-static stack effects"
        "Not as widely used as combinators, 60 macros so far"
        { $code "{ 1 2 3 4 5 } 5 firstn" }
    }
    { $slide "A macro solution"
        "Returns a quotation to the compiler"
        "Constructed using map, fry, and concat"
        { $code "MACRO: plox ( seq -- quot )
    [
        '[ dup _ when ]
    ] map [ ] concat-as ;"
        }
    }
    { $slide "Macro example"
        "Return the caaar of a sequence"
        { "Return " { $snippet "f" } " on failure" }
        { $code ": caaar ( seq/f -- x/f )
    {
        [ first ]
        [ first ]
        [ first ]
    } plox ;"
        }
        { $code "{ { f } } caaar" }
        { $code "{ { { 1 2 3 } } } caaar" }
    }
    { $slide "Smart combinators"
        "Use stack checker to infer inputs and outputs"
        "Even fewer uses than macros"
        { $code "{ 1 10 20 34 } sum" }
        { $code "[ 1 10 20 34 ] sum-outputs" }
        { $code "[ 2 2 [ even? ] both? ] [ + ] [ - ] smart-if" }
    }
    { $slide "Fibonacci"
        "Not tail recursive"
        "Call tree is huge"
        { $code ": fib ( n -- x )
    dup 1 <= [
        [ 1 - fib ] [ 2 - fib ] bi +
    ] unless ;"
        }
        { $code "36 <iota> [ fib ] map ." }
    }
    { $slide "Memoized Fibonacci"
        "Change one word and it's efficient"
        { $code "MEMO: fib ( n -- x )
    dup 1 <= [
        [ 1 - fib ] [ 2 - fib ] bi +
    ] unless ;"
        }
        { $code "36 <iota> [ fib ] map ." }
    }
    { $slide "Destructors"
        "Deterministic resource disposal"
        "Any step can fail and we don't want to leak resources"
        "We want to conditionally clean up sometimes -- if everything succeeds, we might wish to retain the buffer"
    }

    { $slide "Example in C"
        { $code
"void do_stuff()
{
    void *obj1, *obj2;
    if(!(*obj1 = malloc(256))) goto end;
    if(!(*obj2 = malloc(256))) goto cleanup1;
    ... work goes here...
cleanup2: free(*obj2);
cleanup1: free(*obj1);
end: return;
}"
    }
    }
    { $slide "Example: allocating and disposing two buffers"
        { $code ": do-stuff ( -- )
    [
        256 malloc &free
        256 malloc &free
        ... work goes here ...
    ] with-destructors ;"
        }
    }
    { $slide "Example: allocating two buffers for later"
        { $code ": do-stuff ( -- )
    [
        256 malloc |free
        256 malloc |free
        ... work goes here ...
    ] with-destructors ;"
        }
    }
    { $slide "Example: disposing of an output port"
        { $code "M: output-port dispose*
    [
        {
            [ handle>> &dispose drop ]
            [ buffer>> &dispose drop ]
            [ port-flush ]
            [ handle>> shutdown ]
        } cleave
    ] with-destructors ;"
        }
    }
    { $slide "Rapid application development"
        "We lost the dice to Settlers of Catan: Cities and Knights"
        "Two regular dice, one special die"
        { $vocab-link "dice" }
    }
    { $slide "The essence of Factor"
        "Nicely named words abstract away the stack, leaving readable code"
        { $code ": surround ( seq left right -- seq' )
    swapd 3append ;"
        }
        { $code ": glue ( left right middle -- seq' )
    swap 3append ;"
        }
        { $code HEREDOC: xyz
"a" "b" "c" 3append
"a" """""""" surround
"a" "b" ", " glue
xyz
        }
    }
    { $slide "C FFI demo"
        "Easy to call C functions from Factor"
        "Handles C structures, C types, callbacks"
        "Used extensively in the Windows and Unix backends"
        { $code
            "FUNCTION: double pow ( double x, double y ) ;
2 5.0 pow ."
        }
    }
    { $slide "Windows win32 example"
        { $code
"M: windows gmt-offset
    ( -- hours minutes seconds )
    \"TIME_ZONE_INFORMATION\" <c-object>
    dup GetTimeZoneInformation {
        { TIME_ZONE_ID_INVALID [
            win32-error-string throw
        ] }
        { TIME_ZONE_ID_STANDARD [
            TIME_ZONE_INFORMATION-Bias
        ] }
    } case neg 60 /mod 0 ;"
        }
    }
    { $slide "Struct and function"
        { $code "C-STRUCT: TIME_ZONE_INFORMATION
    { \"LONG\" \"Bias\" }
    { { \"WCHAR\" 32 } \"StandardName\" }
    { \"SYSTEMTIME\" \"StandardDate\" }
    { \"LONG\" \"StandardBias\" }
    { { \"WCHAR\" 32 } \"DaylightName\" }
    { \"SYSTEMTIME\" \"DaylightDate\" }
    { \"LONG\" \"DaylightBias\" } ;"
        }
        { $code "FUNCTION: DWORD GetTimeZoneInformation (
    LPTIME_ZONE_INFORMATION
        lpTimeZoneInformation
) ;"
        }

    }
    { $slide "Cocoa FFI"
        { $code "IMPORT: NSAlert [
    NSAlert -> new
    [ -> retain ] [
        \"Raptor\" <CFString> &CFRelease
        -> setMessageText:
    ] [
        \"Look out!\" <CFString> &CFRelease
        -> setInformativeText:
    ] tri -> runModal drop
] with-destructors"
        }
    }
    { $slide "Deployment demo"
        "Vocabularies can be deployed"
        "Standalone .app on Mac"
        "An executable and dll on Windows"
        { $vocab-link "webkit-demo" }
    }
    { $slide "Interesting programs"
        { $vocab-link "terrain" }
        { $vocab-link "gpu.demos.raytrace" }
        { $vocab-link "gpu.demos.bunny" }
    }
    { $slide "Factor's source tree"
        "Lines of code in core/: 9,500"
        "Lines of code in basis/: 120,000"
        "Lines of code in extra/: 51,000"
        "Lines of tests: 44,000"
        "Lines of documentation: 44,500"
    }
    { $slide "VM trivia"
        "Lines of C++ code: 12860"
        "Generational garbage collection"
        "Non-optimizing compiler"
        "Loads an image file and runs it"
    }
    { $slide "Why should I use Factor?"
        "More abstractions over time"
        "We fix reported bugs quickly"
        "Stackable, fluent language"
        "Supports extreme programming"
        "Beer-friendly programming"
    }
    { $slide "Questions?"
    }
}

: tc-lisp-talk ( -- )
    tc-lisp-slides "TC Lisp talk" slides-window ;

MAIN: tc-lisp-talk
