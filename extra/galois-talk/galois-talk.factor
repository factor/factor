! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: slides help.markup math arrays hashtables namespaces
sequences kernel sequences parser memoize io.encodings.binary
locals kernel.private help.vocabs assocs quotations
urls peg.ebnf tools.annotations tools.crossref
help.topics math.functions compiler.tree.optimizer
compiler.cfg.optimizer fry ;
IN: galois-talk

CONSTANT: galois-slides
{
    { $slide "Factor!"
        { $url "http://factorcode.org" }
        "Development started in 2003"
        "Open source (BSD license)"
        "Influenced by Forth, Lisp, and Smalltalk"
        "Blurs the line between language and library"
        "Interactive development"
    }
    { $slide "Words and the stack"
        "Stack based, dynamically typed"
        { $code "{ 1 1 3 4 4 8 9 9 } dup duplicates diff ." }
        "Words: named code snippets"
        { $code ": remove-duplicates ( seq -- seq' )" "    dup duplicates diff ;" }
        { $code "{ 1 1 3 4 4 8 9 9 } remove-duplicates ." }
    }
    { $slide "Vocabularies"
        "Vocabularies: named sets of words"
        { $link "vocab-index" }
        { { $link POSTPONE: USING: } " loads dependencies" }
        "Source, docs, tests in one place"
    }
    { $slide "Interactive development"
        "Programming is hard, let's play tetris"
        { $vocab-link "tetris" }
        "Tetris is hard too... let's cheat"
        "Factor workflow: change code, F2, test, repeat"
    }
    { $slide "Quotations"
        "Quotation: unnamed block of code"
        "Combinators: words taking quotations"
        { $code "10 dup 0 < [ 1 - ] [ 1 + ] if ." }
        { $code "{ -1 1 -2 0 3 } [ 0 max ] map ." }
        "Partial application:"
        { $code ": clamp ( seq n -- seq' ) '[ _ max ] map ;" "{ -1 1 -2 0 3 } 0 clamp" }
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
        "Predicate classes"
        { $code
            "PREDICATE: positive < integer 0 > ;"
            "PREDICATE: negative < integer 0 < ;"
            ""
            "GENERIC: abs ( n -- )"
            ""
            "M: positive abs ;"
            "M: negative abs -1 * ;"
            "M: integer abs ;"
        }
    }
    { $slide "Object system"
        "More: inheritance, type declarations, read-only slots, union, intersection, singleton classes, reflection"
        "Object system is entirely implemented in Factor"
    }
    { $slide "The parser"
        "All data types have a literal syntax"
        "Literal hashtables and arrays are very useful in data-driven code"
        "\"Code is data\" because quotations are objects (enables Lisp-style macros)"
        { $code "H{ { \"cookies\" 12 } { \"milk\" 10 } }" }
        "Libraries can define new parsing words"
    }
    { $slide "Example: regexp"
        { $vocab-link "regexp" }
        "Pre-compiles regexp at parse time"
        "Implemented with library code"
        { $code "USE: regexp" }
        { $code "\"ababbc\" \"[ab]+c\" <regexp> matches? ." }
        { $code "\"ababbc\" R/ [ab]+c/ matches? ." }
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
            ": check-drinking-age ( age -- )"
            "    21"
            "    [ \"You're underage!\" print ]"
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
    { $slide "Help system"
        "Help markup is just literal data"
        { "Look at the help for " { $link T{ link f + } } }
        "These slides are built with the help system and a custom style sheet"
        { $vocab-link "galois-talk" }
    }
    { $slide "Why stack-based?"
        "Because nobody else is doing it"
        "Interesting properties: concatenation is composition, chaining functions together, \"fluent\" interfaces, new combinators"
        { $vocab-link "smtp-example" }
        { $code
            "{ \"chicken\" \"beef\" \"pork\" \"turkey\" }"
            "[ 5 short head ] map ."
        }
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
        "Combinators, partial application"
        "Boxed complex numbers"
        "Boxed floats"
        { "Redundancy in " { $link absq } " and " { $link sq } }
    }
    { $slide "Compiler: high-level optimizer"
        "High-level SSA IR"
        "Type inference (classes, intervals, arrays with a fixed length, literals, ...)"
        "Escape analysis and tuple unboxing"
    }
    { $slide "Compiler: high-level optimizer"
        "Loop index becomes a fixnum, complex numbers unboxed, generic arithmetic inlined, higher-order code become first-order..."
        { $code "[ c pixel ] optimized." }
    }
    { $slide "Compiler: low-level optimizer"
        "Low-level SSA IR"
        "Alias analysis"
        "Value numbering"
        "Linear scan register allocation"
    }
    { $slide "Compiler: low-level optimizer"
        "Redundant stack operations eliminated, intermediate floats unboxed..."
        { $code "[ c pixel ] test-mr mr." }
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
    { $slide "That's all, folks"
        "It is hard to cover everything in a single talk"
        "Factor has many cool things that I didn't talk about"
        "Questions?"
    }
}

: galois-talk ( -- ) galois-slides slides-window ;

MAIN: galois-talk
