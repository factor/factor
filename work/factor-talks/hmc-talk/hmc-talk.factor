USING: fry help.markup help.topics kernel locals math
math.functions memoize peg.ebnf slides ;
IN: hmc-talk

CONSTANT: hmc-slides
{
    { $slide "Factor!"
        { $url "http://factorcode.org" }
        "Development started in 2003"
        "Open source (BSD license)"
        "Influenced by Forth, Lisp, and Smalltalk"
        "Blurs the line between language and library"
        "Interactive development"
    }

    { $slide "Concepts"
        "Concatenative"
        "Dynamic types"
        "Extensible syntax"
        "Fully-compiled"
        "Cross-platform"
        "Interactive Development"
        "Code is data"
        "Pervasive unit testing"
        "Clickable"
    }

    { $slide "Words and the stack"
        "Stack based, dynamically typed"
        { $code "{ 1 1 3 4 4 8 9 9 } dup duplicates diff ." }
        "Words: named code snippets"
        { $code ": remove-duplicates ( seq -- seq' )" "    dup duplicates diff ;" }
        { $code "{ 1 1 3 4 4 8 9 9 } remove-duplicates ." }
    }

    { $slide "Words and the stack"
        { $code
            "\"/opt/homebrew/share/games/fortunes/science\""
            "ascii file-lines"
            "{ \"%\" } split random"
            "[ print ] each"
        }
        { $code
            ": fortune ( -- )"
            "    \"/opt/homebrew/share/games/fortunes/science\""
            "    ascii file-lines"
            "    { \"%\" } split random"
            "    [ print ] each ;"
        }
        { $code
            "5 [ fortune nl ] times"
        }
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
        { "Let's use " { $link POSTPONE: MEMO: } " instead of " { $link POSTPONE: : } }
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
        { "Example: " { $vocab-link "printf" } }
        { $code "\"cheese\" \"vegan\" \"%s is not %s\\n\" printf" }
        { $code "\"Factor\" 5 \"%s is %d years old\\n\" printf" }
        { $code "[ \"%s monkeys\" printf ] expand-macros" }
    }
    { $slide "Locals and lexical scope"
        "Sometimes, there's no good stack solution to a problem"
        "Or, you're porting existing code in a quick-and-dirty way"
        "Our solution: implement named locals as a DSL in Factor"
        "Influenced by Scheme and Lisp"
    }
    { $slide "Locals and lexical scope"
        { "Define lambda words with " { $link POSTPONE: :: } }
        { "Establish bindings with " { $link POSTPONE: [let } " and " { $snippet "[let*" } }
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
        { $vocab-link "hmc-talk" }
    }
    { $slide "Why stack-based?"
        "Because nobody else is doing it"
        "Interesting properties: concatenation is composition, chaining functions together, \"fluent\" interfaces, new combinators"
        { $vocab-link "simple-rpg" }
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
        { $code "[ c pixel ] regs." }
    }
    { $slide "Compiler: assembly"
        "Generic assembly generated..."
        { $code "[ c pixel ] disassemble" }
    }
    { $slide "Compiler: assembly"
        "Efficient assembly generated..."
        { $code "[ { fixnum fixnum } declare c pixel ] disassemble" }
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
        { $url "http://paste.factorcode.org" }
        "Uses our HTTP server, SSL, DB, Atom libraries..."
    }
    { $slide "Project infrastructure"
        "Build farm, written in Factor"
        "Multiple OS and architecture"
        "Builds Factor and all libraries, runs tests, makes binaries"
        "Saves us from the burden of making releases by hand"
        "Maintains stability"
    }

    { $slide "That's all, folks"
        "It is hard to cover everything in a single talk"
        "Factor has many cool things that I didn't talk about"
        "Questions?"
    }

    { $slide "Cool things"
        { $code
            "USE: xkcd"
            "XKCD: 138"
        }
        { $code
            "USE: reddit"
            "\"programming\" subreddit."
        }
    }

    { $slide "Cool things"
        { $vocab-link "minesweeper" }
        { $vocab-link "game-of-life" }
        { $vocab-link "boids" }
    }

    { $slide "Cool things"
        "8080 cpu emulator"
        { $code
            "\"resource:roms\" rom-root set-global"
        }
        { $vocab-link "roms.space-invaders" }
    }

    { $slide "Cool things"
        { $vocab-link "bloom-filters" }
        { $vocab-link "cuckoo-filters" }
        { $vocab-link "persistent" }
        { $vocab-link "trees" }
        { $vocab-link "tuple-arrays" }
        { $vocab-link "specialized-arrays" }
    }

    { $slide "Cool things"
        { $code
            "USE: text-to-speech"
            "\"hello\" speak-text"
        }
        { $code
            "USE: morse"
            "\"hello\" play-as-morse"
        }
        { $code
            "USE flip-text"
            "\"hello\" flip-text ."
        }
    }

    { $slide "Cool things"
        { $code
            "{ 12 18 24 72 }"
            "[ \"Bigger\" swap font-size associate format nl ] each"
        }

        { $code
            "10 <iota> ["
            "   \"Hello world\""
            "   swap 10 / 1 over - over 1 <rgba>"
            "   background associate format nl"
            "] each"
        }
    }

    { $slide "Cool things"
        { $code
            "USE: google.charts"
            "\"x = \\\\frac{-b \\\\pm \\\\sqrt {b^2-4ac}}{2a}\""
            "<formula> 200 >>width 75 >>height chart."
        }
        { $code
            "100 [ 100 random ] replicate"
            "100 [ 100 random ] replicate"
            "zip <scatter> chart."
        }
        { $code
            "\"/usr/share/dict/words\" utf8 file-lines"
            "[ >lower 1 head ] histogram-by"
            "sort-keys <bar>"
            "    COLOR: green >>foreground"
            "    400 >>width"
            "    10 >>bar-width"
            "chart."
        }
    }

    { $slide "Cool things"
        { $code
            "USE: http.client"
            "\\ http-get see"
        }
        { $code
            "\"http\" apropos"
        }
        { $code
            "USE: images.http"
            "\"https://factorcode.org/logo.png\" http-image."
        }
    }

    { $slide "Cool things"
        "Tab completion"
        { $code
            "http"
        }
        { $code
            "P\" vocab:math"
        }
        { $code
            "COLOR: "
        }
    }

    { $slide "Cool things"
        { $code
            "USE: emojify"
            "\"I :heart: Factor! :+1!\" emojify ."
        }
        { $code
            "USE: dice"
            "ROLL: 2d8+4"
            "\"You do %s points of damage!\" printf"
        }
    }

    { $slide "Cool things"
        { $code
            "USING: sequences xml.syntax xml.writer ;"
            "{ \"three\" \"blind\" \"mice\" }"
            "[ [XML <li><-></li> XML] ] map"
            "[XML <ul><-></ul> XML]"
            "pprint-xml"
        }
    }

    { $slide "Cool things"
        { $code
            "USE: io.streams.256color"
            "[ listener ] with-256color"
            "\"math\" about"
        }
    }

    { $slide "Cool things"
        { $code "./factor -run=tetris" }
        { $code "./factor -run=file-server" }
        { $code "./factor -run=file-monitor" }
        { $code "./factor -run=tools.dns microsoft.com" }
        { $code "./factor -run=tools.cal" }
    }
}

: hmc-talk ( -- ) hmc-slides "HMC Talk" slides-window ;

MAIN: hmc-talk
