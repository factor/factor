! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: slides help.markup math arrays hashtables namespaces
sequences kernel sequences parser memoize io.encodings.binary
locals kernel.private help.vocabs assocs quotations
urls peg.ebnf tools.vocabs tools.annotations tools.crossref
help.topics math.functions compiler.tree.optimizer
compiler.cfg.optimizer fry ;
IN: vpri-talk

CONSTANT: vpri-slides
{
    { $slide "Factor!"
        { $url "http://factorcode.org" }
        "Development started in 2003"
        "Open source (BSD license)"
        "Influenced by Forth, Lisp, and Smalltalk"
        "Blurs the line between language and library"
        "Interactive development"
    }
    { $slide "Programming is hard"
        "Let's play tetris instead"
        { $vocab-link "tetris" }
        "Tetris is hard too... let's cheat"
        "Factor workflow: change code, F2, test, repeat"
    }
    { $slide "Basics"
        "Stack based, dynamically typed"
        { $code "{ 1 1 3 4 4 8 9 9 } dup duplicates diff ." }
        "Words: named code snippets"
        { $code ": remove-duplicates ( seq -- seq' )" "    dup duplicates diff ;" }
        { $code "{ 1 1 3 4 4 8 9 9 } remove-duplicates ." }
        "Vocabularies: named sets of words"
        { $link "vocab-index" }
    }
    { $slide "Quotations"
        "Quotation: unnamed block of code"
        "Combinators: words taking quotations"
        { $code "{ 1 1 3 4 4 8 9 9 }" "[ { 1 3 8 } member? ] filter ." }
        { $code "{ -1 1 -2 0 3 } [ 0 max ] map" }
        "Partial application:"
        { $code ": clamp ( seq n -- seq' ) '[ _ max ] map" "{ -1 1 -2 0 3 } 0 clamp ;" }
    }
    { $slide "Object system"
        "CLOS with single dispatch"
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
        "We can compute perimiters now."
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
        "Object system handles dynamic redefinition very well"
        { $code "TUPLE: person name age occupation ;" }
        "Make an instance..."
    }
    { $slide "Object system"
        "Let's add a new slot:"
        { $code "TUPLE: person name age address occupation ;" }
        "Fill it in with inspector..."
        "Change the order:"
        { $code "TUPLE: person name occupation address ;" }
    }
    { $slide "Object system"
        "How does it work?"
        "Objects are not hashtables; slot access is very fast"
        "Redefinition walks the heap; expensive but rare"
    }
    { $slide "Object system"
        "Supports \"duck typing\""
        "Two tuples can have a slot with the same name"
        "Code that uses accessors will work on both"
        "Accessors are auto-generated generic words"
    }
    { $slide "Object system"
        "More: inheritance, type declarations, read-only slots, predicate, intersection, singleton classes, reflection"
        "Object system is entirely implemented in Factor"
        { { $vocab-link "generic" } ", " { $vocab-link "classes" } ", " { $vocab-link "slots" } }
    }
    { $slide "The parser"
        "All data types have a literal syntax"
        "Literal hashtables and arrays are very useful in data-driven code"
        "\"Code is data\" because quotations are objects (enables Lisp-style macros)"
        { $code "H{ { \"cookies\" 12 } { \"milk\" 10 } }" }
        "Libraries can define new parsing words"
    }
    { $slide "Example: float arrays"
        { $vocab-link "specialized-arrays.float" }
        "Avoids boxing and unboxing overhead"
        "Implemented with library code"
        { $code "float-array{ 3.14 7.6 10.3 }" }
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
    { $slide "Example: printf"
        { { $link POSTPONE: EBNF: } ": a complex parsing word" }
        "Implements a custom syntax for expressing parsers: like OMeta!"
        { "Example: " { $vocab-link "printf-example" } }
        { $code "\"vegan\" \"cheese\" \"%s is not %s\\n\" printf" }
        { $code "5 \"Factor\" \"%s is %d years old\\n\" printf" }
    }
    { $slide "Example: simple web browser"
        { $vocab-link "webkit-demo" }
        "Demonstrates Cocoa binding"
        "Let's deploy a stand-alone binary with the deploy tool"
        "Deploy tool generates binaries with no external dependencies"
    }
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
        "Combinator with 5 parameters!"
        { $code
            ":: branch ( a b neg zero pos -- )"
            "    a b = zero [ a b < neg pos if ] if ; inline"
        }
        "Unwieldy with the stack"
    }
    { $slide "Locals and lexical scope"
        { $code
            "ERROR: underage-exception ;"
            ""
            ": check-drinking-age ( age -- )"
            "    21"
            "    [ underage-exception ]"
            "    [ \"Grats, you're now legal\" print ]"
            "    [ \"Go get hammered\" print ]"
            "    branch ;"
        }
    }
    { $slide "Locals and lexical scope"
        "Locals are entirely implemented in Factor"
        "Example of compile-time meta-programming"
        "No performance penalty -vs- using the stack"
        "In the base image, only 59 words out of 13,000 use locals"
    }
    { $slide "More about partial application"
        { { $link POSTPONE: '[ } " is \"fry syntax\"" }
        { $code "'[ _ + ] == [ + ] curry" }
        { $code "'[ @ t ] == [ t ] compose" }
        { $code "'[ _ nth @ ] == [ [ nth ] curry ] dip compose" }
        { $code "'[ [ _ ] dip nth ] == [ [ ] curry dip nth ] curry" }
        { "Fry and locals desugar to " { $link curry } ", " { $link compose } }
    }
    { $slide "More about partial application"
        { { $link call } " is fundamental" }
        { { $link quotation } ", " { $link curry } " and " { $link compose } " are classes" }
        { $code
            "GENERIC: call ( quot -- )"
            "M: curry call uncurry call ;"
            "M: compose call uncompose slip call ;"
            "M: quotation call (call) ;"
        }
        { "So " { $link curry } ", " { $link compose } " are library features" }
    }
    { $slide "Why stack-based?"
        "Because nobody else is doing it"
        "Interesting properties: concatenation is composition, chaining functions together, \"fluent\" interfaces, new combinators"
        { $vocab-link "smtp-example" }
        { $code
            "{ \"chicken\" \"beef\" \"pork\" \"turkey\" }"
            "[ 5 short head ] map ."
        }
        "To rattle people's cages"
    }
    { $slide "Help system"
        "Help markup is just literal data"
        { "Look at the help for " { $link T{ link f + } } }
        "These slides are built with the help system and a custom style sheet"
        { $vocab-link "vpri-talk" }
    }
    { $slide "Some line counts"
        "VM: 12,000 lines of C"
        "core: 9,000 lines of Factor"
        "basis: 80,000 lines of Factor"
    }
    { $slide "More line counts"
        "Object system (core): 2184 lines"
        "Dynamic variables (core): 40 lines"
        "Deterministic scoped destructors (core): 56 lines"
        "Optimizing compiler (basis): 12938 lines"
        "Lexical variables and closures (basis): 477 lines"
        "Fry (basis): 51 lines"
        "Help system (basis): 1831 lines"
    }
    { $slide "Implementation"
        "VM: garbage collection, bignums, ..."
        "Bootstrap image: parser, hashtables, object system, ..."
        "Non-optimizing compiler"
        "Stage 2 bootstrap: optimizing compiler, UI, ..."
        "Full image contains machine code"
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
        { "Partial application with " { $link curry } " and " { $link compose } }
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
        { $code "[ c pixel ] optimized." }
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
    { $slide "History"
        "Started in 2003, implemented in Java"
        "Scripting language for a 2D shooter game"
        "Interactive development is addictive"
        "I wanted to write entire applications in Factor"
        "Added JVM bytecode compiler pretty early on"
    }
    { $slide "History"
        "Wrote native C implementation, mid-2004"
        "Added native compiler at some point"
        "Added an FFI, SDL bindings, then UI"
        "Switched UI to OpenGL and native APIs"
        "Generational GC"
        "Got rid of interpreter"
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
    { $slide "Research areas"
        "Identify areas where stack languages are lacking, and try to find idioms, abstractions or DSLs to solve these problems"
        "Factor is a good platform for DSLs (fry, locals, EBNF, help, ...); what about implementing a complete language on top?"
        "Static typing, soft typing, for stack-based languages"
    }
    { $slide "That's all, folks"
        "It is hard to cover everything in a single talk"
        "Factor has many cool things that I didn't talk about"
        "Questions?"
    }
}

: vpri-talk ( -- ) vpri-slides slides-window ;

MAIN: vpri-talk
