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
        { default-style
            H{
                { font "serif" }
                { font-size 24 }
                { wrap-margin 700 }
            }
        }
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
        { bullet "\u00b7 " }
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

: <page> ( list -- gadget )
    [
        mslug-stylesheet clone [
            [ print-element ] with-default-style
        ] bind
    ] make-pane
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
    "Stack-based"
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
{ $slide "Data types - hashtables"
    "Hashtables: literal syntax, utility words, higher-order combinators..."
    { $code
        "H{ { \"grass\" \"green\" } { \"chicken\" \"white\" } }"
        "H{ { \"carrot\" \"orange\" } }"
        "hash-union"
    }
    "Option+h"
    "Prettyprinter -vs- inspector"
}
{ $slide "Data types - others"
    "Queues, graphs, splay trees, double linked lists, lazy lists..."
}
{ $slide "Variables"
    "Dynamic scope"
    { $code "SYMBOL: foo" "5 foo set" "foo get ." }
    { $code "SYMBOL: foo" "[ 6 foo set foo get ] with-scope" }
    "Dynamic scope can be analyzed statically:"
    { $code "SYMBOL: bar" "bar get sq foo set" }
}
{ $slide "Encapsulating variable usage"
    { "Stream-like sequence construction:"
    { $code
        ": print-name ( name -- )"
        "    [ \"Greetings, \" % % \".\" % ] \"\" make print ;"
    } }
    "Key factors:"
    { $code "%" }
    { $code "[ % ] \"\" make" }
    { "Also, I/O:"
    { $code ": 100-bytes [ 100 read ] with-stream ;" "\"foo.txt\" <file-reader> 100-bytes" } }
}
{ $slide "Custom data types"
    { "Built-in classes: " { $link integer } ", " { $link array } ", " { $link hashtable } "..." }
    { "You can define your own:"
        { $code "TUPLE: rectangle w h ;" "TUPLE: circle r ;" }
    }
    { $code "100 200 <rectangle>" }
    { $code "rectangle-w ." }
}
{ $slide "Polymorphism"
    { "Generic words:"
        { $code
            "GENERIC: area ( shape -- n )"
            "M: rectangle area"
            "    dup rectangle-w swap rectangle-h * ;"
            "M: circle area circle-r sq pi * ;"
        }
    }
    { "Methods in classes -vs- methods in functions?" }
    { "Both: " { $link array } " -vs- " { $link nth } }
}
{ $slide "More polymorphism"
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
    }
    "Create an editor, wrap it in a scroller:"
    { $code
        "<editor>"
    }
    "Length filter:"
    { $code "dup control-model"
        "[ concat length number>string ] <filter>"
    }
}
{ $slide "Models continued"
    "Layout:"
    { $code "{"
    "    { [ <label-control> ] f f @top }"
    "    { [ <scroller> ] f f @center }"
    "} make-frame"
    }
    "Window:"
    { $code
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
{ $slide "The compiler"
    "Performance is a goal"
    "Compromise: The compiler only compiles words with a static stack effect"
    "Three stages"
    { "First stage transforms a quotation into the " { $emphasis "dataflow representation" } }
    "Second stage: high-level optimizations"
    "Third stage: register allocation, peephole optimization, code generation"
    "Compiled code saved in the image"
    "Compiler invoked explicitly (not a ``JIT'')"
}
{ $slide "High-level optimizer"
    "Quotations <-> dataflow conversion is ``loss-less''"
    "Really, just rewriting quotations"
    "Type inference"
    "Partial evaluation"
    "Arithmetic identities"
    "Optimistic specialization"
}
{ $slide "Low level optimizer"
    "Caching stack in registers"
    "Shuffling renames registers"
    "Unboxing floats"
    "Tail call optimization"
}
{ $slide "Assember DSL"
    "The compiler emits machine code:"
    { $code
        "char-reg PUSH"
        "\"n\" operand 2 SHR"
        "char-reg dup XOR"
        "\"obj\" operand \"n\" operand ADD"
        "char-reg-16 \"obj\" operand string-offset [+] MOV"
        "char-reg tag-bits SHL"
        "\"obj\" operand char-reg MOV"
        "char-reg POP"
    }
}
{ $slide "Assember DSL - continued"
    { "It's all done with " { $link make } }
    { $code "USE: assembler" "[ EAX ECX MOV ] { } make ." }
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
