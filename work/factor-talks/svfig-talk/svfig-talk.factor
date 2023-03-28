USING: help.markup namespaces peg.ebnf slides typed ;
IN: svfig-talk

CONSTANT: svfig-slides
{
    { $slide "Factor!"
        { $url "https://factorcode.org" }
        "Development started in 2003"
        "Open source (BSD license)"
        "Influenced by Forth, Lisp, and Smalltalk"
        "Blurs the line between language and library"
        "Interactive development"
        "Upcoming release: 0.99, then... 0.100?"
    }

    { $slide "Concepts"
        "Concatenative"
        "Dynamic types"
        "Extensible syntax"
        "Fully-compiled"
        "Cross-platform"
        "Clickable"
        "Useful?"
    }

    { $slide "Concatenative"
        { $code "1 2 + ." }
        { $code "3 weeks ago noon ." }
        { $code "\"hello\" rot13 ." }
        { $code "URL\" https://factorcode.org\" http-get" }
        { $code "10 [ \"Hello, Factor\" print ] times" }
        { $code "{ 4 8 15 16 23 42 } [ sum ] [ length ] bi / ." }
    }

    { $slide "Words"
        "Defined at parse time"
        "Parts: name, stack effect, definition"
        "Composed of tokens separated by whitespace"
        { $code ": palindrome? ( string -- ? ) dup reverse = ;" }
        "Unit tests"
        { $code "{ f } [ \"hello\" palindrome? ] unit-test"
                ""
                "{ t } [ \"racecar\" palindrome? ] unit-test"
        }
    }

    { $slide "Quotations"
        "Quotation: un-named blocks of code"
        { $code "[ \"Hello, World\" print ]" }
        "Combinators: words taking quotations"
        { $code "10 dup 0 < [ 1 - ] [ 1 + ] if ." }
        { $code "{ -1 1 -2 0 3 } [ 0 max ] map ." }
    }

    { $slide "Vocabularies"
        "Vocabularies: named sets of words"
        { $link "vocab-index" }
        { { $link POSTPONE: USING: } " loads dependencies" }
        "Source, docs, tests in one place"
    }

    { $slide "Debugging Tools"
        { "Let's implement the " { $snippet "fortune" } " program" }
        { $code
            "\"/usr/local/share/games/fortunes/science\""
            "ascii file-lines"
            "{ \"%\" } split random"
            "[ print ] each"
        }
        "Let's try it out!"
    }

    { $slide "Native Performance"
        { $snippet "wc -l factor.image" }
        "Counting lines is reasonably fast..."
        { $code
            ": simple-wc ( path -- n )"
            "    binary <file-reader> ["
            "        0 swap ["
            "            [ CHAR: \\n = ] count +"
            "        ] each-stream-block-slice"
            "    ] with-disposal ;"
        }
        { $code "[ \"factor.image\" simple-wc ] time" }
    }

    { $slide "Native Performance"
        "But it can be even faster!"
        { $code
            "USE: tools.wc"
            "[ \"factor.image\" wc ] time"
        }
        "Deploy as binary"
        { $code "\"tools.wc\" deploy" }
    }

    { $slide "Visual Tools"
        { $code
            "\"Bigger\" { 12 18 24 72 } ["
            "    font-size associate format nl"
            "] with each"
        }
        { $code
            "10 <iota> ["
            "    \"Hello, World!\""
            "    swap 10 / 1 over - over 1 <rgba>"
            "    background associate format nl"
            "] each"
        }
        { $code
            "USE: images.http"
            "\"https://factorcode.org/logo.png\" http-image."
        }
        { $code
            "USE: lcd"
            "<time-display> gadget."
        }
    }

    { $slide "Interactive Development"
        "Programming is hard, let's play tetris"
        { $vocab-link "tetris" }
        "Tetris is hard too... let's cheat"
        { $code "\"tetris.tetromino\" edit" }
        { "Factor workflow: change code, " { $snippet "F2" } ", test, repeat" }
    }

    { $slide "Parsing Words"
        "Extensible syntax, DSLs"
        "Most parsing words fall in one of two categories"
        "First category: literal syntax for new data types"
        "Second category: defining new types of words"
        "Some parsing words are more complicated"
    }

    { $slide "Parsing Words - Pairs"
        "Generic array syntax"
        { $code "{ 1 2 }" }
        { $code "\\ { see" }
        "Custom pair syntax"
        { $code "SYNTAX: => dup pop scan-object 2array suffix! ;" }
        { $code "1 => 2" }
    }

    { $slide "Parsing Words - Dice"
        { $vocab-link "dice" }
        { $code "ROLL: 2d8+5"
                ""
                "\"You do %s points of damage!\\n\" printf" }
        { $code "\\ ROLL: see" }
        { $code "[ ROLL: 2d8+5 ] ." }
    }

    { $slide "Parsing Words - Regexp"
        { $vocab-link "regexp" }
        "Pre-compiles regexp at parse time"
        "Implemented with library code"
        { $code "\"ababbc\" \"[ab]+c\" <regexp> matches? ." }
        { $code "\"ababbc\" R/ [ab]+c/ matches? ." }
    }

    { $slide "Parsing Words - XML"
        { $vocab-link "xml" }
        "Implemented with library code"
        "Useful syntax forms"
        { $code
            "{ \"three\" \"blind\" \"mice\" }"
            "[ [XML <li><-></li> XML] ] map"
            "[XML <ul><-></ul> XML]"
            "pprint-xml"
        }
    }

    { $slide "Local Variables"
        "Sometimes, there's no good stack solution to a problem"
        "Or, you're porting existing code in a quick-and-dirty way"
        "Combinator with 5 parameters!"
        { $code
            ":: branch ( a b neg zero pos -- )"
            "    a b = zero [ a b < neg pos if ] if ; inline"
        }
        "Unwieldy with the stack"
    }

    { $slide "Local Variables"
        { $code
            ": check-voting-age ( age -- )"
            "    18"
            "    [ \"You're underage, sorry...\" print ]"
            "    [ \"Yay, register to vote!\" print ]"
            "    [ \"Participate in democracy!\" print ]"
            "    branch ;"
        }
        "Locals are entirely implemented in Factor"
        "Example of compile-time meta-programming"
        "No performance penalty -vs- using the stack"
    }

    { $slide "Dynamic Variables"
        "Implemented as a stack of hashtables"
        { "Useful words are " { $link get } ", " { $link set } }
        "Input, output, error streams are stored in dynamic variables"
        "Read from a string..."
        { $code "\"cat\\ndog\\nfish\" [ readln ] with-string-reader" }
        "Read from a file..."
        { $code "\"LICENSE.txt\" utf8 [ readln ] with-file-reader" }
    }

    { $slide "Destructors"
        "Deterministic resource disposal"
        "Any step can fail and we don't want to leak resources"
        "We want to conditionally clean up sometimes"
        { $code ": do-stuff ( -- )
    [
        256 malloc &free
        256 malloc &free
        ... work goes here ...
    ] with-destructors ;"
        }
    }

    { $slide "Profiling"
        { $code
            ": fib ( m -- n )"
            "    dup 1 > ["
            "        [ 1 - fib ] [ 2 - fib ] bi +"
            "    ] when ;"
        }
        { $code "[ 40 fib ] time" }
        "Very slow! Let's profile it..."
        { $code "[ 40 fib ] profile" }
        "Not tail recursive"
        "Call tree is huge"
    }

    { $slide "Profiling - Typed"
        { "Type declarations with " { $link POSTPONE: TYPED: } }
        { $code
            "TYPED: fib ( m: fixnum -- n )"
            "    dup 1 > ["
            "        [ 1 - fib ] [ 2 - fib ] bi +"
            "    ] when ;"
        }
        "A bit faster"
    }

    { $slide "Profiling - Memoize"
        { "Memoization using " { $link POSTPONE: MEMO: } }
        { $code
            "MEMO: fib ( m -- n )"
            "    dup 1 > ["
            "        [ 1 - fib ] [ 2 - fib ] bi +"
            "    ] when ;"
        }
        "Much faster"
        { $code "10,000 fib number>string "
                "80 group [ print ] each" }
    }

    { $slide "Macros"
        "Expand at compile-time"
        "Return a quotation to be compiled"
        "Can express non-static stack effects"
        { $code "MACRO: ndup ( n -- quot )"
                "    [ \\ dup ] [ ] replicate-as ;"
        }
        { $code "[ 5 ndup ] infer" }
        { $code "[ 5 ndup ] expand-macros" }
    }

    { $slide "PEG / EBNF"
        { { $link POSTPONE: EBNF: } ": a complex parsing word" }
        "Implements a custom syntax for expressing parsers"
        { "Example: " { $vocab-link "printf" } }
        { $code "\"Factor\""
                "2003 <year> ago duration>years"
                ""
                "\"%s is %d years old\\n\" printf" }
        { $code "[ \"%s monkeys\" printf ] expand-macros" }
    }

    { $slide "Objects"
        "A tuple is a user-defined class which holds named values."
        { $code
            "TUPLE: rectangle width height ;"
            ""
            "TUPLE: circle radius ;"
        }
    }

    { $slide "Objects"
        "Constructing instances:"
        { $code "rectangle new" }
        { $code "rectangle boa" }
        "Let's encapsulate:"
        { $code
            ": <rectangle> ( w h -- r ) rectangle boa ;"
            ""
            ": <circle> ( r -- c ) circle boa ;"
        }
    }

    { $slide "Single Dispatch"
        ! "Generic words and methods"
        { $code "GENERIC: area ( shape -- n )" }
        "Two methods:"
        { $code
            "M: rectangle area"
            "    [ width>> ] [ height>> ] bi * ;"
            ""
            "M: circle area radius>> sq pi * ;"
        }
        "We can compute areas now."
        { $code "100 20 <rectangle> area ." }
        { $code "3 <circle> area ." }
    }

    { $slide "Multiple Dispatch"
        { $code "SINGLETONS: rock paper scissors ;" }
        "Win conditions:"
        { $code "FROM: multi-methods => GENERIC: METHOD: ;"
                ""
                "GENERIC: beats? ( obj1 obj2 -- ? )"
                ""
                "METHOD: beats? { scissors paper } 2drop t ;"
                "METHOD: beats? { rock  scissors } 2drop t ;"
                "METHOD: beats? { paper     rock } 2drop t ;"
                "METHOD: beats? { object  object } 2drop f ;"
        }
    }

    { $slide "Multiple Dispatch"
        "Let's play a game..."
        { $code ": play. ( obj -- )"
                "    { rock paper scissors } random {"
                "        { [ 2dup beats? ] [ \"WIN\" ] }"
                "        { [ 2dup = ] [ \"TIE\" ] }"
                "        [ \"LOSE\" ]"
                "    } cond \"%s vs. %s: %s\\n\" printf ;"
        }
        "With a simple interface:"
        { $code ": rock ( -- ) \\ rock play. ;"
                ": paper ( -- ) \\ paper play. ;"
                ": scissors ( -- ) \\ scissors play. ;"
        }
    }

    { $slide "Object System"
        "Supports \"duck typing\""
        "Two tuples can have a slot with the same name"
        "Code that uses accessors will work on both"
        "Objects are not hashtables; slot access is very fast"
        "Tuple slots can be reordered/redefined"
        "Instances in memory will be updated"
    }

    { $slide "Object System"
        "Predicate classes"
        { $code
            "PREDICATE: positive < integer 0 > ;"
            "PREDICATE: negative < integer 0 < ;"
            ""
            "GENERIC: abs ( m -- n )"
            ""
            "M: positive abs ;"
            "M: negative abs -1 * ;"
            "M: integer abs ;"
        }
    }
    { $slide "Object System"
        "And lots more features..."
        "Inheritance, type declarations, read-only slots, union, intersection, singleton classes, reflection"
        "Object system is entirely implemented in Factor"
    }

    { $slide "Assembly"
        "Access the Time Stamp Counter"
        { $code
"HOOK: rdtsc cpu ( -- n )

M: x86.64 rdtsc
    longlong { } cdecl [
        RAX 0 MOV
        RDTSC
        RDX 32 SHL
        RAX RDX OR
    ] alien-assembly ;" }
    }

    { $slide "FFI"
        { $code "NAME
     sqrt – square root function

SYNOPSIS
     #include <math.h>

     double
     sqrt(double x);" }
        "Let's use it!"
        { $code "FUNCTION: double sqrt ( double x )" }
    }

    { $slide "Infix"
        { "Syntax experiments with " { $vocab-link "infix" } }
        "Infix word definitions:"
        { $code "INFIX:: foo ( x y -- z ) sqrt(x)+y**3 ;" }
        "Inline also:"
        { $code "[let \"hello\" :> seq"
                "    [infix seq[::-1] infix]"
                "]"
        }
    }

    { $slide "Implementation"
        "VM in C++ (12,000 lines of code)"
        "VM features primitives, garbage collection, etc."
        "Lines of code: 300,000"
        "Lines of tests: 80,000"
        "Lines of docs: 70,000"
        "One big repository, and we love contributions!"
    }

    { $slide "Project Infrastructure"
        { $url "https://factorcode.org" }
        { $url "https://concatenative.org" }
        { $url "https://docs.factorcode.org" }
        { $url "https://planet.factorcode.org" }
        { $url "https://paste.factorcode.org" }
        "Uses our HTTP server, SSL, DB, Atom libraries..."
    }

    { $slide "Project Infrastructure"
        "Build farm, written in Factor"
        "Multiple OS and architecture"
        "Builds Factor and all libraries, runs tests, makes binaries"
        "Saves us from the burden of making releases by hand"
        "Maintains stability"
    }

    { $slide "Demo"
        "It is hard to cover everything in a single talk"
        "Factor has many cool things that I didn't talk about"
        { $code "\"demos\" run" }
        "Let's look at a real program!"
    }

    { $slide "Cool Things"
        { $code
            "USE: xkcd"
            "XKCD: 138"
        }
        { $code
            "USE: reddit"
            "\"programming\" subreddit."
        }
    }

    { $slide "Cool Things"
        { $vocab-link "minesweeper" }
        { $vocab-link "game-of-life" }
        { $vocab-link "boids" }
        { $vocab-link "pong" }
    }

    { $slide "Cool Things"
        "8080 cpu emulator"
        { $code
            "\"resource:roms\" rom-root set-global"
        }
        { $vocab-link "roms.space-invaders" }
    }

    { $slide "Cool Things"
        { $vocab-link "bloom-filters" }
        { $vocab-link "cuckoo-filters" }
        { $vocab-link "persistent" }
        { $vocab-link "trees" }
        { $vocab-link "tuple-arrays" }
        { $vocab-link "specialized-arrays" }
    }

    { $slide "Cool Things"
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
        { $code
            "USE: emojify"
            "\"I :heart: Factor! :+1!\" emojify ."
        }
    }

    { $slide "Cool Things"
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

    { $slide "Cool Things"
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
        { $code "./factor -run=file-server" }
        { $code "./factor -run=file-monitor" }
        { $code "./factor -run=tools.dns microsoft.com" }
        { $code "./factor -run=tools.cal" }
    }
}

: svfig-talk ( -- ) svfig-slides "SVFIG Talk" slides-window ;

MAIN: svfig-talk
