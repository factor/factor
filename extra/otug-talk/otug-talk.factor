! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: slides help.markup math arrays hashtables namespaces sequences
kernel sequences parser memoize io.encodings.binary locals
kernel.private help.vocabs assocs quotations tools.vocabs
tools.annotations tools.crossref help.topics math.functions
compiler.tree.optimizer compiler.cfg.optimizer fry ui.gadgets.panes
tetris tetris.game combinators generalizations multiline
sequences.private ;
IN: otug-talk

: $tetris ( element -- )
    drop [ <default-tetris> <tetris-gadget> gadget. ] ($block) ;

CONSTANT: otug-slides
{
    { $slide "Factor!"
        { $url "http://factorcode.org" }
        "Development started in 2003"
        "Open source (BSD license)"
        "Influenced by Forth, Lisp, and Smalltalk"
        "Blurs the line between language and library"
        "Interactive development"
    }
    { $slide "Part 1: the language" }
    { $slide "Basics"
        "Stack based, dynamically typed"
        { "A " { $emphasis "word" } " is a named piece of code" }
        { "Values are passed between words on a " { $emphasis "stack" } }
        "Code evaluates left to right"
        "Example:"
        { $code "2 3 + ." }
    }
    { $slide "Quotations"
        { "A " { $emphasis "quotation" } " is a block of code pushed on the stack" }
        { "Syntax: " { $snippet "[ ... ]" } }
        "Example:"
        { $code
            "\"/etc/passwd\" ascii file-lines"
            "[ \"#\" head? not ] filter"
            "[ \":\" split first ] map"
            "."
        }
    }
    { $slide "Words"
        { "We can define new words with " { $snippet ": name ... ;" } " syntax" }
        { $code ": remove-comments ( lines -- lines' )" "    [ \"#\" head? not ] filter ;" }
        { "Words are grouped into " { $emphasis "vocabularies" } }
        { $link "vocab-index" }
        "Libraries and applications are vocabularies"
        { $vocab-link "spheres" }
    }
    { $slide "Constructing quotations"
        { "Suppose we want a " { $snippet "remove-comments*" } " word" }
        { $code ": remove-comments* ( lines string -- lines' )" "    [ ??? head? not ] filter ;" }
        { "We use " { $link POSTPONE: '[ } " instead of " { $link POSTPONE: [ } }
        { "Create “holes” with " { $link _ } }
        "Holes filled in left to right when quotation pushed on the stack"
    }
    { $slide "Constructing quotations"
        { $code ": remove-comments* ( lines string -- lines' )" "    '[ _ head? not ] filter ;" "" ": remove-comments ( lines -- lines' )" "    \"#\" remove-comments* ;" }
        { { $link @ } " inserts a quotation" }
        { $code ": replicate ( n quot -- seq )" "    '[ drop @ ] map ;" }
        { $code "10 [ 1 10 [a,b] random ] replicate ." }
    }
    { $slide "Combinators"
        { "A " { $emphasis "combinator" } " is a word taking quotations as input" }
        { "Used for control flow, data flow, iteration" }
        { $code "100 [ 5 mod 3 = [ \"Fizz!\" print ] when ] each" }
        { "Control flow: " { $link if } ", " { $link when } ", " { $link unless } ", " { $link cond } }
        { "Iteration: " { $link map } ", " { $link filter } ", " { $link all? } ", ..." }
    }
    { $slide "Data flow combinators - simple example"
        "All examples so far used “pipeline style”"
        "What about using a value more than once, or operating on values not at top of stack?"
        { $code "{ 10 70 54 } [ sum ] [ length ] bi / ." }
        { $code "5 [ 1 + ] [ sqrt ] [ 1 - ] tri 3array ." }
    }
    { $slide "Data flow combinators - cleave family"
        { { $link bi } ", " { $link tri } ", " { $link cleave } }
        { $image "resource:extra/otug-talk/bi.tiff" }
    }
    { $slide "Data flow combinators - cleave family"
        { { $link 2bi } ", " { $link 2tri } ", " { $link 2cleave } }
        { $image "resource:extra/otug-talk/2bi.tiff" }
    }
    { $slide "Data flow combinators"
        "First, let's define a data type:"
        { $code "TUPLE: person first-name last-name ;" }
        "Make an instance:"
        { $code "person new" "    \"Joe\" >>first-name" "    \"Sixpack\" >>last-name" }
    }
    { $slide "Data flow combinators"
        "Let's do stuff with it:"
        { $code
            "[ first-name>> ] [ last-name>> ] bi"
            "[ 2 head ] [ 5 head ] bi*"
            "[ >upper ] bi@"
            "\".\" glue ."
        }
    }
    { $slide "Data flow combinators - spread family"
        { { $link bi* } ", " { $link tri* } ", " { $link spread } }
        { $image "resource:extra/otug-talk/bi_star.tiff" }
    }
    { $slide "Data flow combinators - spread family"
        { { $link 2bi* } }
        { $image "resource:extra/otug-talk/2bi_star.tiff" }
    }
    { $slide "Data flow combinators - apply family"
        { { $link bi@ } ", " { $link tri@ } ", " { $link napply } }
        { $image "resource:extra/otug-talk/bi_at.tiff" }
    }
    { $slide "Data flow combinators - apply family"
        { { $link 2bi@ } }
        { $image "resource:extra/otug-talk/2bi_at.tiff" }
    }
    { $slide "Shuffle words"
        "When data flow combinators are not enough"
        { $link "shuffle-words" }
        "Lower-level, Forth/PostScript-style stack manipulation"
    }
    { $slide "Locals"
        "When data flow combinators and shuffle words are not enough"
        "Name your input parameters"
        "Used in about 1% of all words"
    }
    { $slide "Locals example"
        "Area of a triangle using Heron's formula"
        { $code
            <" :: area ( a b c -- x )
    a b c + + 2 / :> p
    p
    p a - *
    p b - *
    p c - * sqrt ;">
        }
    }
    { $slide "Previous example without locals"
        "A bit unwieldy..."
        { $code
            <" : area ( a b c -- x )
    [ ] [ + + 2 / ] 3bi
    [ '[ _ - ] tri@ ] [ neg ] bi
    * * * sqrt ;"> }
    }
    { $slide "More idiomatic version"
        "But there's a trick: put the points in an array"
        { $code <" : v-n ( v n -- w ) '[ _ - ] map ;

: area ( points -- x )
    [ 0 suffix ] [ sum 2 / ] bi
    v-n product sqrt ;"> }
    }
    ! { $slide "The parser"
    !     "All data types have a literal syntax"
    !     "Literal hashtables and arrays are very useful in data-driven code"
    !     { $code "H{ { \"cookies\" 12 } { \"milk\" 10 } }" }
    !     "Libraries can define new parsing words"
    ! }
    { $slide "Programming without named values"
        "Minimal glue between words"
        "Easy multiple return values"
        { "Avoid useless variable names: " { $snippet "x" } ", " { $snippet "n" } ", " { $snippet "a" } ", ..." }
        { { $link at } " and " { $link at* } }
        { $code "at* [ ... ] [ ... ] if" }
    }
    { $slide "Stack language idioms"
        "Enables new idioms not possible before"
        "We get the effect of “keyword parameters” for free"
        { $vocab-link "smtp-example" }
    }
    { $slide "“Perfect” factoring"
        { $table
            { { $link head } { $link head-slice } }
            { { $link tail } { $link tail-slice } }
        }
        { "Modifier: " { $link from-end } }
        { "Modifier: " { $link short } }
        "4*2*2=16 operations, 6 words!"
    }
    { $slide "Modifiers"
        "“Modifiers” can express MN combinations using M+N words"
        { $code
            "\"Hello, Joe\" 4 head ."
            "\"Hello, Joe\" 3 tail ."
            "\"Hello, Joe\" 3 from-end tail ."
        }
        { $code
            "\"Hello world\" 5 short head ."
            "\"Hi\" 5 short tail ."
        }
    }
    { $slide "Modifiers"
        { "C-style " { $snippet "while" } " and " { $snippet "do while" } " loops" }
    }
    { $slide "Modifiers"
        { $code ": bank ( n -- n )" "    readln string>number +" "    dup \"Balance: $\" write . ;" }
        { $code "0 [ dup 0 > ] [ bank ] while" }
    }
    { $slide "Modifiers"
        { $code "0 [ dup 0 > ] [ bank ] [ ] do while" }
        { { $link do } " executes one iteration of a " { $link while } " loop" }
        { { $link while } " calls " { $link do } }
    }
    { $slide "More “pipeline style” code"
        { "Suppose we want to get the price of the customer's first order, but any one of the steps along the way could be a nil value (" { $link f } " in Factor):" }
        { $code
            "dup [ orders>> ] when"
            "dup [ first ] when"
            "dup [ price>> ] when"
        }
    }
    { $slide "This is hard with mainstream syntax!"
        { $code
            <" var customer = ...;
var orders = (customer == null ? null : customer.orders);
var order = (orders == null ? null : orders[0]);
var price = (order == null ? null : order.price);"> }
    }
    { $slide "An ad-hoc solution"
        "Something like..."
        { $code "var price = customer.?orders.?[0].?price;" }
    }
    ! { $slide "Stack languages are fundamental"
    !     "Very simple semantics"
    !     "Easy to generate stack code programatically"
    !     "Everything is almost entirely library code in Factor"
    !     "Factor is easy to extend"
    ! }
    { $slide "Part 2: the implementation" }
    { $slide "Interactive development"
        { $tetris }
    }
    { $slide "Application deployment"
        { $vocab-link "webkit-demo" }
        "Demonstrates Cocoa binding"
        "Let's deploy a stand-alone binary with the deploy tool"
        "Deploy tool generates binaries with no external dependencies"
    }
    { $slide "The UI"
        "Renders with OpenGL"
        "Backends for Cocoa, Windows, X11: managing windows, input events, clipboard"
        "Cross-platform API"
    }
    { $slide "UI example"
        { $code
    <" <pile>
    { 5 5 } >>gap
    1 >>fill
    "Hello world!" <label> add-gadget
    "Click me!" [ drop beep ]
    <bevel-button> add-gadget
    <editor> <scroller> add-gadget
"UI test" open-window "> }
    }
    { $slide "Help system"
        "Help markup is just literal data"
        { "Look at the help for " { $link T{ link f + } } }
        "These slides are built with the help system and a custom style sheet"
        { $vocab-link "otug-talk" }
    }
    { $slide "The VM"
        "Lowest level is the VM: ~12,000 lines of C"
        "Generational garbage collection"
        "Non-optimizing compiler"
        "Loads an image file and runs it"
        "Initial image generated from another Factor instance:"
        { $code "\"x86.32\" make-image" }
    }
    { $slide "The core library"
        "Core library, ~9,000 lines of Factor"
        "Source parser, arrays, strings, math, hashtables, basic I/O, ..."
        "Packaged into boot image because VM doesn't have a parser"
    }
    { $slide "The basis library"
        "Basis library, ~80,000 lines of Factor"
        "Bootstrap process loads code from basis, runs compiler, saves image"
        "Loaded by default: optimizing compiler, tools, help system, UI, ..."
        "Optional: HTTP server, XML, database access, ..."
    }
    { $slide "Non-optimizing compiler"
        "Glues together chunks of machine code"
        "Most words compiled as calls, some inlined"
        "Used for listener interactions, and bootstrap"
    }
    { $slide "Optimizing compiler"
        "Converts Factor code into high-level SSA form"
        "Performs global optimizations"
        "Converts high-level SSA into low-level SSA"
        "Performs local optimizations"
        "Register allocation"
        "Machine code generation: x86, x86-64, PowerPC"
    }
    { $slide "Optimizing compiler"
        "Makes high-level language features cheap to use"
        "Eliminate redundant method dispatch by inferring types"
        "Eliminate redundant integer overflow checks by inferring ranges"
    }
    { $slide "Optimizing compiler"
        "Eliminate redundant memory allocation (escape analysis)"
        "Eliminate redundant loads/stores (alias analysis)"
        "Eliminate redundant computations (value numbering)"
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
        "Good for increasing stability"
    }
    { $slide "Community"
        "#concatenative irc.freenode.net: 60-70 users"
        "factor-talk@lists.sf.net: 189 subscribers"
        "About 30 people have code in the Factor repository"
        "Easy to get started: binaries, lots of docs, friendly community..."
    }
    { $slide "Selling points"
        "Expressive language"
        "Comprehensive library"
        "Efficient implementation"
        "Powerful interactive tools"
        "Stand-alone application deployment"
        "Moving fast"
    }
    { $slide "That's all, folks"
        "It is hard to cover everything in a single talk"
        "Factor has many cool things that I didn't talk about"
        "Questions?"
    }
}

: otug-talk ( -- ) otug-slides slides-window ;

MAIN: otug-talk
