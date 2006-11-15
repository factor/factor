! Slava Pestov's presentation at the Montreal Scheme/Lisp User's
! Group, November 22nd 2006.

! http://schemeway.dyndns.org/mslug/mslug-home

USING: gadgets gadgets-books gadgets-borders gadgets-buttons
gadgets-text gadgets-labels gadgets gadgets-panes
gadgets-presentations gadgets-theme generic kernel math
namespaces sequences strings styles models help io arrays
hashtables modules ;
IN: mslug

: mslug-stylesheet
    H{
        { code-style
            H{
                { font "monospace" }
                { font-size 24 }
                { page-color { 0.4 0.4 0.4 0.3 } }
            }
        }
        { table-content-style
            H{ { wrap-margin 700 } }
        }
        { bullet "\u00b7" }
    } ;

: $title ( string -- )
    [ H{ { font "serif" } { font-size 36 } } format ] ($block) ;

: $divider ( -- )
    [
        <gadget>
        T{ gradient f { { 0.25 0.25 0.25 1.0 } { 1.0 1.0 1.0 1.0 } } }
        over set-gadget-interior
        { 750 10 } over set-gadget-dim
        { 1 0 } over set-gadget-orientation
        gadget.
    ] ($block) ;

: page-theme
    T{ gradient f { { 0.8 0.8 1.0 1.0 } { 1.0 0.8 1.0 1.0 } } }
    swap set-gadget-interior ;

: tutorial-style
    H{
        { font "serif" }
        { font-size 24 }
        { wrap-margin 700 }
    } ;

: <page> ( list -- gadget )
    [ tutorial-style [ print-element ] with-style ] make-pane
    dup page-theme ;

: $slide ( element -- )
    unclip $title
    $divider
    $list ;

: $module ( element -- )
    first dup module [ write ] ($code) ;

: slides
{
{ $slide "Factor programming language"
    "Inspirations: Forth, Joy, Common Lisp, others..."
    "Powerful language features"
    "Interactive development"
    "Why stack-based?"
    "Syntax: ``s-expressions''"
    "Code is data"
    { "Simple evaluation semantics; left to right:"
    { $code "2 3 + 7 * 9 /" } }
    "Functions are called ``words''"
    "Vocabularies"
    "Short definitions, heavy reuse"
}
{ $slide "First program"
    {
        "Functional ``hello world'':"
        { $code
            ": factorial ( n -- n! )"
            "    dup 0 <= ["
            "        drop 1"
            "    ] ["
            "        dup 1 - factorial *"
            "    ] if ;"
        }
    }
    "Shuffle words, conditionals, recursion, code as parameters..."
    "Bignums!"
    { $code "100 factorial ." }
    "Reflection:"
    { $code "\\ factorial see" }
}
{ $slide "Data types - sequences"
    { "Sequences: everything is an array"
    { $code "{ 1 2 3 } { t f } append reverse ." } }
    { "Familiar higher order functions"
    { $code "{ { 1 2 } { 3 4 } } [ reverse ] map ." } }
    { "Integers are sequences, too:"
    { $code "100 [ sq ] map ." }
    { $code "100 [ 4 mod 3 = ] subset ." }
    { $code "0 100 [ 1 + * ] reduce ." } }
}
{ $slide "Data types - hashtables, lazy lists"
    "Hashtables: literal syntax, utility words, higher-order combinators..."
    { $code
        "H{ { \"grass\" \"green\" } { \"chicken\" \"white\" } }"
        "H{ { \"carrot\" \"orange\" } }"
        "hash-union"
    }
    "Prettyprinter -vs- inspector"
    { "Lazy lists"
    { $code "\"contrib/lazy-lists\" require" "USE: lazy-lists" } }
    { $code
        ": squares naturals [ sq ] lmap ;"
        ": first-five-squares 5 squares ltake list>array ;"
    }
    "Option+h"
}
{ $slide "Data types - others"
    "Queues, graphs, splay trees, double linked lists..."
}
{ $slide "Variables"
    "Dynamic scope - WHY?"
    { $code "SYMBOL: foo" "5 foo set" "foo get ." }
    { $code "SYMBOL: foo" "[ 6 foo set foo get . ] with-scope" }
    "Dynamic scope can be analyzed statically:"
    { $code "SYMBOL: bar" "bar get sq foo set" }
}
{ $slide "Encapsulating variable usage"
    { "Stream-like sequence construction:"
    { $code
        ": print-name ( name -- )"
        "    [ \"Greetings, \" % % \".\" ] \"\" make print ;"
    } }
    "Key factors:"
    { $code "%" }
    { $code "[ % ] \"\" make" }
    { "Also, I/O:"
    { $code ": 100-bytes [ 100 read ] with-stream ;" "\"foo.txt\" <file-reader> 100-bytes" } }
}
{ $slide "Custom data types and polymorphism"
    { "Built-in classes: " { $link integer } ", " { $link array } ", " { $link hashtable } "..." }
    { "You can define your own:"
        { $code "TUPLE: rectangle w h ;" "TUPLE: circle r ;" }
    }
    { $code "100 200 <rectangle>" }
    { $code "rectangle-w ." }
    { "Generic words:"
        { $code
            "GENERIC: area ( shape -- n )"
            "M: rectangle area"
            "    dup rectangle-w swap rectangle-h * ;"
            "M: circle area circle-r sq pi * ;"
        }
    }
    { "Philosophy: " { $link array } " -vs- " { $link nth } }
}
{ $slide "Polymorphism continued"
    "Tuples can have custom constructor words"
    { "Delegation instead of inheritance"
    { $code
        "TUPLE: colored-shape color ;"
        "C: colored-shape ( shape color -- shape )"
        "    [ set-colored-shape-color ] keep"
        "    [ set-delegate ] keep ;"
    } }
    { $code "100 200 <rectangle>" "{ 0.5 0.5 1 } <colored-shape>" "area ." }
    "Advanced features: predicate classes, union classes, method combination"
}
{ $slide "The compiler"
    "Most code has a static stack effect"
    { "Combinators have a static stack effect if quotations are known:"
    { $code "[ sq ] map" } }
    "First stage: construct dataflow graph"
    "Second stage: optimize"
    "Third stage: emit machine code"
    "Compiled code saved in the image"
    "Compiler invoked explicitly (not a ``JIT'')"
}
{ $slide "The compiler, continued"
    "Rewrite rules"
    "Identities"
    "Intrinsics"
    "Register allocation"
    "Unboxing floats"
}
{ $slide "The Factor UI"
    "Factor UI is totally implemented in Factor"
    "OpenGL, FreeType, plus platform-specific code"
    { "Gadgets:"
    { $code
        "USING: gadgets gadgets-labels ;"
        "\"Hello world\" <label> \"Hi\" open-titled-window"
    } }
    "Presentations and operations"
    "Models"
}
{ $slide "Models"
    { $code
        "USING: models gadgets-scrolling gadgets-text ;"
        "<editor> dup <scroller> swap control-model"
        "[ concat length number>string ] <filter>"
        "<label-control>"
        "2array make-pile"
        "\"Model test\" open-titled-window"
    }
}
{ $slide "This talk"
    "Uses Factor help markup language with a tweaked stylesheet"
    "Each slide is a gadget"
    "Slides are grouped in a custom gadget which handles Up/Down arrow keys to move between slides"
    "Let's look at the source code:"
    { $module "examples/mslug-talk" }
}
{ $slide "The end"
    { $url "http://factorcode.org" }
    { $url "http://factor-language.blogspot.com" }
    { "irc.freenode.net #concatenative" }
}
} ;

TUPLE: mslug ;

C: mslug ( -- gadget )
    slides [ <page> ] map <book>
    over set-gadget-delegate ;

: change-page ( book n -- )
    over control-value + over gadget-children length rem
    swap control-model set-model ;

: next-page ( book -- ) 1 change-page ;

: prev-page ( book -- ) -1 change-page ;

\ mslug H{
    { T{ key-down f f "DOWN" } [ next-page ] }
    { T{ key-down f f "UP" } [ prev-page ] }
} set-gestures

PROVIDE: examples/mslug-talk ;

MAIN: examples/mslug-talk
    <mslug> "Presentation" open-titled-window ;
