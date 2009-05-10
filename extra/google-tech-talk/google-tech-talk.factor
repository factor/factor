! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: slides help.markup math arrays hashtables namespaces
sequences kernel sequences parser memoize io.encodings.binary
locals kernel.private help.vocabs assocs quotations
urls peg.ebnf tools.annotations tools.crossref
help.topics math.functions compiler.tree.optimizer
compiler.cfg.optimizer fry ;
IN: google-tech-talk

CONSTANT: google-slides
{
    { $slide "Factor!"
        { $url "http://factorcode.org" }
        "Development started in 2003"
        "Open source (BSD license)"
        "First result for \"Factor\" on Google :-)"
        "Influenced by Forth, Lisp, and Smalltalk (but don't worry if you don't know them)"
    }
    { $slide "Language overview"
        "Words operate on a stack"
        "Functional"
        "Object-oriented"
        "Rich collections library"
        "Rich input/output library"
        "Optional named local variables"
        "Extensible syntax"
    }
    { $slide "Example: factorial"
        "Lame example, but..."
        { $code "USE: math.ranges" ": factorial ( n -- n! )" "    1 [a,b] product ;" }
        { $code "100 factorial ." }
    }
    { $slide "Example: sending an e-mail"
        { $vocab-link "smtp-example" }
        "Demonstrates basic stack syntax and tuple slot setters"
    }
    { $slide "Functional programming"
        "Code is data in Factor"
        { { $snippet "[ ... ]" } " is a block of code pushed on the stack" }
        { "We call them " { $emphasis "quotations" } }
        { "Words which take quotations as input are called " { $emphasis "combinators" } }
    }
    { $slide "Functional programming"
        { $code "10 dup 0 < [ 1 - ] [ 1 + ] if ." }
        { $code "10 [ \"Hello Googlers!\" print ] times" }
        { $code
            "USING: io.encodings.ascii unicode.case ;"
            "{ \"tomato\" \"orange\" \"banana\" }"
            "\"out.txt\" ascii ["
            "    [ >upper print ] each"
            "] with-file-writer"
        }
    }
    { $slide "Object system: motivation"
        "Encapsulation, polymorphism, inheritance"
        "Smalltalk, Python, Java approach: methods inside classes"
        "Often the \"message sending\" metaphor is used to describe such systems"
    }
    { $slide "Object system: motivation"
        { $code
            "class Rect {"
            "  int x, y;"
            "  int area() { ... }"
            "  int perimeter() { ... }"
            "}"
            ""
            "class Circle {"
            "  int radius;"
            "  int area() { ... }"
            "  int perimeter() { ... }"
            "}"
        }
    }
    { $slide "Object system: motivation"
        "Classical functional language approach: functions switch on a type"
        { $code
            "data Shape = Rect w h | Circle r"
            ""
            "area s = s of"
            "  (Rect w h) = ..."
            "| (Circle r) = ..."
            ""
            "perimeter s = s of"
            "  (Rect w h) = ..."
            "| (Circle r) = ..."
        }
    }
    { $slide "Object system: motivation"
        "First approach: hard to extend existing types with new operations (open classes, etc are a hack)"
        "Second approach: hard to extend existing operations with new types"
        "Common Lisp Object System (CLOS): decouples classes from methods."
        "Factor's object system is a simplified CLOS"
    }
    { $slide "Object system"
        "A tuple is a user-defined class which holds named values."
        { $code
            "TUPLE: rectangle width height ;"
            "TUPLE: circle radius ;"
        }
    }
    { $slide "Object system"
        "Constructing instances:"
        { $code "rectangle new" }
        { $code "rectangle boa" }
        "Let's encapsulate:"
        { $code
            ": <rectangle> ( w h -- r ) rectangle boa ;"
            ": <circle> ( r -- c ) circle boa ;"
        }
    }
    { $slide "Object system"
        "Generic words and methods"
        { $code "GENERIC: area ( shape -- n )" }
        "Two methods:"
        { $code
            "USE: math.constants"
            ""
            "M: rectangle area"
            "    [ width>> ] [ height>> ] bi * ;"
            ""
            "M: circle area radius>> sq pi * ;"
        }
    }
    { $slide "Object system"
        "We can compute areas now."
        { $code "100 20 <rectangle> area ." }
        { $code "3 <circle> area ." }
    }
    { $slide "Object system"
        "New operation, existing types:"
        { $code
            "GENERIC: perimeter ( shape -- n )"
            ""
            "M: rectangle perimeter"
            "    [ width>> ] [ height>> ] bi + 2 * ;"
            ""
            "M: circle perimeter"
            "    radius>> 2 * pi * ;"
        }
    }
    { $slide "Object system"
        "We can compute perimeters now."
        { $code "100 20 <rectangle> perimeter ." }
        { $code "3 <circle> perimeter ." }
    }
    { $slide "Object system"
        "New type, extending existing operations:"
        { $code
            "TUPLE: triangle base height ;"
            ""
            ": <triangle> ( b h -- t ) triangle boa ;"
            ""
            "M: triangle area"
            "    [ base>> ] [ height>> ] bi * 2 / ;"
        }
    }
    { $slide "Object system"
        "New type, extending existing operations:"
        { $code
            ": hypotenuse ( x y -- z ) [ sq ] bi@ + sqrt ;"
            ""
            "M: triangle perimeter"
            "    [ base>> ] [ height>> ] bi"
            "    [ + ] [ hypotenuse ] 2bi + ;"
        }
    }
    { $slide "Object system"
        "We can ask an object if its a rectangle:"
        { $code "70 65 <rectangle> rectangle? ." }
        { $code "13 <circle> rectangle? ." }
        { "How do we tell if something is a " { $emphasis "shape" } "?" }
    }
    { $slide "Object system"
        "We define a mixin class for shapes, and add our existing data types as instances:"
        { $code
            "MIXIN: shape"
            "INSTANCE: rectangle shape"
            "INSTANCE: circle shape"
            "INSTANCE: triangle shape"
        }
    }
    { $slide "Object system"
        "Now, we can ask objects if they are shapes or not:"
        { $code "13 <circle> shape? ." }
        { $code "3.14 shape? ." }
    }
    { $slide "Object system"
        "Or put methods on shapes:"
        { $code
            "GENERIC: tell-me ( obj -- )"
            ""
            "M: shape tell-me"
            "    \"My area is \" write area . ;"
            ""
            "M: integer tell-me"
            "    \"I am \" write"
            "    even? \"even\" \"odd\" ? print ;"
        }
    }
    { $slide "Object system"
        "Let's test our new generic word:"
        { $code "13 <circle> tell-me" }
        { $code "103 76 <rectangle> tell-me" }
        { $code "101 tell-me" }
        { { $link integer } ", " { $link array } ", and others are built-in classes" }
    }
    { $slide "Object system"
        "Anyone can define new shapes..."
        { $code
            "TUPLE: parallelogram ... ;"
            ""
            "INSTANCE: parallelogram shape"
            ""
            "M: parallelogram area ... ;"
            ""
            "M: parallelogram perimeter ... ;"
        }
    }
    { $slide "Object system"
        "More: inheritance, type declarations, read-only slots, predicate, intersection, singleton classes, reflection"
        "Object system is entirely implemented in Factor: 2184 lines"
        { { $vocab-link "generic" } ", " { $vocab-link "classes" } ", " { $vocab-link "slots" } }
    }
    { $slide "Collections"
        "Sequences (arrays, vector, strings, ...)"
        "Associative mappings (hashtables, ...)"
        { "More: deques, heaps, purely functional structures, disjoint sets, and more: "
        { $link T{ vocab-tag f "collections" } } }
    }
    { $slide "Sequences"
        { "Protocol: " { $link length } ", " { $link set-length } ", " { $link nth } ", " { $link set-nth } }
        { "Combinators: " { $link each } ", " { $link map } ", " { $link filter } ", " { $link produce } ", and more: " { $link "sequences-combinators" } }
        { "Utilities: " { $link append } ", " { $link reverse } ", " { $link first } ",  " { $link second } ", ..." }
    }
    { $slide "Example: bin packing"
        { "We have " { $emphasis "m" } " objects and " { $emphasis "n" } " bins, and we want to distribute these objects as evenly as possible." }
        { $vocab-link "distribute-example" }
        "Demonstrates various sequence utilities and vector words"
        { $code "20 13 distribute ." }
    }
    { $slide "Unicode strings"
        "Strings are sequences of 21-bit Unicode code points"
        "Efficient implementation: ASCII byte string unless it has chars > 127"
        "If a byte char has high bit set, the remaining 14 bits come from auxilliary vector"
    }
    { $slide "Unicode strings"
        "Unicode-aware case conversion, char classes, collation, word breaks, and so on..."
        { $code "USE: unicode.case" "\"ß\" >upper ." }
    }
    { $slide "Unicode strings"
        "All external byte I/O is encoded/decoded"
        "ASCII, UTF8, UTF16, EBCDIC..."
        { $code "USE: io.encodings.utf8" "\"document.txt\" utf8" "[ readln ] with-file-reader" }
        { "Binary I/O is supported as well with the " { $link binary } " encoding" }
    }
    { $slide "Associative mappings"
        { "Protocol: " { $link assoc-size } ", " { $link at* } ", " { $link set-at } ", " { $link delete-at } }
        { "Combinators: " { $link assoc-each } ", " { $link assoc-map } ", " { $link assoc-filter } ", and more: " { $link "assocs-combinators" } }
        { "Utilities: " { $link at } ", " { $link key? } ", ..." }
    }
    ! { $slide "Example: soundex"
    !     { $vocab-link "soundex" }
    !     "From Wikipedia: \"Soundex is a phonetic algorithm for indexing names by sound, as pronounced in English.\""
    !     "Factored into many small words, uses sequence and assoc operations, no explicit loops"
    ! }
    { $slide "Locals and lexical scope"
        "Sometimes, there's no good stack solution to a problem"
        "Or, you're porting existing code in a quick-and-dirty way"
        "Our solution: implement named locals as a DSL in Factor"
        "Influenced by Scheme and Lisp"
    }
    { $slide "Locals and lexical scope"
        { "Define lambda words with " { $link POSTPONE: :: } }
        { "Establish bindings with " { $link POSTPONE: [let } " and " { $link POSTPONE: [let* } }
        "Mutable bindings with correct semantics"
        { "Named inputs for quotations with " { $link POSTPONE: [| } }
        "Full closures"
    }
    { $slide "Locals and lexical scope"
        "Two examples:"
        { $vocab-link "lambda-quadratic" }
        { $vocab-link "closures-example" }
    }
    { $slide "Locals and lexical scope"
        "Locals are entirely implemented in Factor: 477 lines"
        "Example of compile-time meta-programming"
        "No performance penalty -vs- using the stack"
        "In the base image, only 59 words out of 13,000 use locals"
    }
    { $slide "The parser"
        "All data types have a literal syntax"
        "Literal hashtables and arrays are very useful in data-driven code"
        "\"Code is data\" because quotations are objects (enables Lisp-style macros)"
        { $code "H{ { \"cookies\" 12 } { \"milk\" 10 } }" }
        "Libraries can define new parsing words"
    }
    { $slide "The parser"
        { "Example: URLs define a " { $link POSTPONE: URL" } " word" }
        { $code "URL\" http://paste.factorcode.org/paste?id=81\"" }
    }
    { $slide "Example: memoization"
        { "Memoization with " { $link POSTPONE: MEMO: } }
        { $code
            ": fib ( m -- n )"
            "    dup 1 > ["
            "        [ 1 - fib ] [ 2 - fib ] bi +"
            "    ] when ;"
        }
        "Very slow! Let's profile it..."
    }
    { $slide "Example: memoization"
        { "Let's use " { $link POSTPONE: : } " instead of " { $link POSTPONE: MEMO: } }
        { $code
            "MEMO: fib ( m -- n )"
            "    dup 1 > ["
            "        [ 1 - fib ] [ 2 - fib ] bi +"
            "    ] when ;"
        }
        "Much faster"
    }
    { $slide "Meta-circularity"
        { { $link POSTPONE: MEMO: } " is just a library word" }
        { "But so is " { $link POSTPONE: : } }
        "Factor's parser is written in Factor"
        { "All syntax is just parsing words: " { $link POSTPONE: [ } ", " { $link POSTPONE: " } }
    }
    { $slide "Extensible syntax, DSLs"
        "Most parsing words fall in one of two categories"
        "First category: literal syntax for new data types"
        "Second category: defining new types of words"
        "Some parsing words are more complicated"
    }
    { $slide "Parser expression grammars"
        { { $link POSTPONE: EBNF: } ": a complex parsing word" }
        "Implements a custom syntax for expressing parsers"
        { "Example: " { $vocab-link "printf-example" } }
        { $code "\"vegan\" \"cheese\" \"%s is not %s\\n\" printf" }
        { $code "5 \"Factor\" \"%s is %d years old\\n\" printf" }
    }
    { $slide "Input/output library"
        "One of Factor's strongest points: portable, full-featured, efficient"
        { $vocab-link "io.files" }
        { $vocab-link "io.launcher" }
        { $vocab-link "io.monitors" }
        { $vocab-link "io.mmap" }
        { $vocab-link "http.client" }
        "... and so on"
    }
    { $slide "Example: file system monitors"
        { $code
            "USE: io.monitors"
            ""
            ": forever ( quot -- ) '[ @ t ] loop ; inline"
            ""
            "\"/tmp\" t <monitor>"
            "'[ _ next-change . ] forever"
        }
    }
    { $slide "Example: time server"
        { $vocab-link "time-server" }
        { "Demonstrates " { $vocab-link "io.servers.connection" } " vocabulary, threads" }
    }
    { $slide "Example: what is my IP?"
        { $vocab-link "webapps.ip" }
        "Simple web app, defines a single action, use an XHTML template"
        "Web framework supports more useful features: sessions, SSL, form validation, ..."
    }
    { $slide "Example: Yahoo! web search"
        { $vocab-link "yahoo" }
        { "Demonstrates " { $vocab-link "http.client" } ", " { $vocab-link "xml" } }
    }
    { $slide "Example: simple web browser"
        { $vocab-link "webkit-demo" }
        "Demonstrates Cocoa binding"
        "Let's deploy a stand-alone binary with the deploy tool"
        "Deploy tool generates binaries with no external dependencies"
    }
    { $slide "Example: environment variables"
        { $vocab-link "environment" }
        "Hooks are generic words which dispatch on dynamically-scoped variables"
        { "Implemented in an OS-specific way: " { $vocab-link "environment.unix" } ", " { $vocab-link "environment.winnt" } }
    }
    { $slide "Example: environment variables"
        "Implementations use C FFI"
        "Call C functions, call function pointers, call Factor from C, structs, floats, ..."
        "No need to write C wrapper code"
    }
    { $slide "Implementation"
        "VM: 12,000 lines of C"
        "Generational garbage collection"
        "core: 9,000 lines of Factor"
        "Optimizing native code compiler for x86, PowerPC"
        "basis: 80,000 lines of Factor"
    }
    { $slide "Compiler"
        { "Let's look at " { $vocab-link "benchmark.mandel" } }
        "A naive implementation would be very slow"
        "Combinators, currying, partial application"
        "Boxed complex numbers"
        "Boxed floats"
        { "Redundancy in " { $link absq } " and " { $link sq } }
    }
    { $slide "Compiler: front-end"
        "Builds high-level tree SSA IR"
        "Stack code with uniquely-named values"
        "Inlines combinators and calls to quotations"
        { $code "USING: compiler.tree.builder compiler.tree.debugger ;" "[ c pixel ] build-tree nodes>quot ." }
    }
    { $slide "Compiler: high-level optimizer"
        "12 optimization passes"
        { $link optimize-tree }
        "Some passes collect information, others use the results of past analysis to rewrite the code"
    }
    { $slide "Compiler: propagation pass"
        "Propagation pass computes types with type function"
        { "Example: output type of " { $link + } " depends on the types of inputs" }
        "Type: can be a class, a numeric interval, array with a certain length, tuple with certain type slots, literal value, ..."
        "Mandelbrot: we infer that we're working on complex floats"
    }
    { $slide "Compiler: propagation pass"
        "Propagation also supports \"constraints\""
        { $code "[ dup array? [ first ] when ] optimized." }
        { $code "[ >fixnum dup 0 < [ 1 + ] when ] optimized." }
        { $code
            "["
            "    >fixnum"
            "    dup [ -10 > ] [ 10 < ] bi and"
            "    [ 1 + ] when"
            "] optimized."
        }
    }
    { $slide "Compiler: propagation pass"
        "Eliminates method dispatch, inlines method bodies"
        "Mandelbrot: we infer that integer indices are fixnums"
        "Mandelbrot: we eliminate generic arithmetic"
    }
    { $slide "Compiler: escape analysis"
        "We identify allocations for tuples which are never returned or passed to other words (except slot access)"
        { "Partial application with " { $link POSTPONE: '[ } }
        "Complex numbers"
    }
    { $slide "Compiler: escape analysis"
        { "Virtual sequences: " { $link <slice> } ", " { $link <reversed> } }
        { $code "[ <reversed> [ . ] each ] optimized." }
        { "Mandelbrot: we unbox " { $link curry } ", complex number allocations" }
    }
    { $slide "Compiler: dead code elimination"
        "Cleans up the mess from previous optimizations"
        "After inlining and dispatch elimination, dead code comes up because of unused generality"
        { "No-ops like " { $snippet "0 +" } ", " { $snippet "1 *" } }
        "Literals which are never used"
        "Side-effect-free words whose outputs are dropped"
    }
    { $slide "Compiler: low level IR"
        "Register-based SSA"
        "Stack operations expand into low-level instructions"
        { $code "[ 5 ] test-mr mr." }
        { $code "[ swap ] test-mr mr." }
        { $code "[ append reverse ] test-mr mr." }
    }
    { $slide "Compiler: low-level optimizer"
        "5 optimization passes"
        { $link optimize-cfg }
        "Gets rid of redundancy which is hidden in high-level stack code"
    }
    { $slide "Compiler: optimize memory"
        "First pass optimizes stack and memory operations"
        { "Example: " { $link 2array } }
        { { $link <array> } " fills array with initial value" }
        "What if we immediately store new values into the array?"
        { $code "\\ 2array test-mr mr." }
        "Mandelbrot: we optimize stack operations"
    }
    { $slide "Compiler: value numbering"
        "Identifies expressions which are computed more than once in a basic block"
        "Simplifies expressions with various identities"
        "Mandelbrot: redundant float boxing and unboxing, redundant arithmetic"
    }
    { $slide "Compiler: dead code elimination"
        "Dead code elimination for low-level IR"
        "Again, cleans up results of prior optimizations"
    }
    { $slide "Compiler: register allocation"
        "IR assumes an infinite number of registers which are only assigned once"
        "Real CPUs have a finite set of registers which can be assigned any number of times"
        "\"Linear scan register allocation with second-chance binpacking\""
    }
    { $slide "Compiler: register allocation"
        "3 steps:"
        "Compute live intervals"
        "Allocate registers"
        "Assign registers and insert spills"
    }
    { $slide "Compiler: register allocation"
        "Step 1: compute live intervals"
        "We number all instructions consecutively"
        "A live interval associates a virtual register with a list of usages"
    }
    { $slide "Compiler: register allocation"
        "Step 2: allocate registers"
        "We scan through sorted live intervals"
        "If a physical register is available, assign"
        "Otherwise, find live interval with furthest away use, split it, look at both parts again"
    }
    { $slide "Compiler: register allocation"
        "Step 3: assign registers and insert spills"
        "Simple IR rewrite step"
        "After register allocation, one vreg may have several live intervals, and different physical registers at different points in time"
        "Hence, \"second chance\""
        { "Mandelbrot: " { $code "[ c pixel ] test-mr mr." } }
    }
    { $slide "Compiler: code generation"
        "Iterate over list of instructions"
        "Extract tuple slots and call hooks"
        { $vocab-link "cpu.architecture" }
        "Finally, we hand the code to the VM"
        { $code "\\ 2array disassemble" }
    }
    { $slide "Garbage collection"
        "All roots are identified precisely"
        "Generational copying for data"
        "Mark sweep for native code"
    }
    { $slide "Project infrastructure"
        { $url "http://factorcode.org" }
        { $url "http://concatenative.org" }
        { $url "http://docs.factorcode.org" }
        { $url "http://planet.factorcode.org" }
        "Uses our HTTP server, SSL, DB, Atom libraries..."
    }
    { $slide "Project infrastructure"
        "Build farm, written in Factor"
        "12 platforms"
        "Builds Factor and all libraries, runs tests, makes binaries"
        "Saves us from the burden of making releases by hand"
        "Maintains stability"
    }
    { $slide "Community"
        "#concatenative irc.freenode.net: 50-60 members"
        "factor-talk@lists.sf.net: 180 subscribers"
        "About 30 people have code in the Factor repository"
        "Easy to get started: binaries, lots of docs, friendly community..."
    }
    { $slide "Future direction: Factor 1.0"
        "Continue doing what we're doing:"
        "Polish off some language features"
        "Stability"
        "Performance"
        "Documentation"
        "Developer tools"
    }
    { $slide "Future direction: Factor 2.0"
        "Native threads"
        "Syntax-aware Factor editor"
        "Embedding Factor in C apps"
        "Cross-compilation for smaller devices"
    }
    { $slide "That's all, folks"
        "It is hard to cover everything in a single talk"
        "Factor has many cool things that I didn't talk about"
        "Put your prejudices aside and give it a shot!"
    }
    { $slide "Questions?" }
}

: google-talk ( -- ) google-slides slides-window ;

MAIN: google-talk
