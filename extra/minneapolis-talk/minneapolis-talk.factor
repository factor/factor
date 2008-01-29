USING: slides help.markup math arrays hashtables namespaces
sequences kernel sequences parser ;
IN: minneapolis-talk

: minneapolis-slides
{
    { $slide "What is Factor?"
        "Dynamically typed, stack language"
        "Have our cake and eat it too"
        "Research -vs- production"
        "High level -vs- performance"
        "Interactive -vs- stand-alone apps"
    }
    { $slide "The view from 10,000 feet"
        "Influenced by Forth, Lisp, Joy, Smalltalk, even Java..."
        "Vocabularies: modules"
        "Words: named functions, classes, variables"
        "Combinators: higher-order functions"
        "Quotations: anonymous functions"
        "Other concepts are familiar: classes, objects, etc"
    }
    { $slide "Stack-based programming"
        { "Most languages are " { $emphasis "applicative" } }
        "Words pop inputs from the stack and push outputs on the stack"
        "Literals are pushed on the stack"
        { $code "{ 1 2 } { 7 } append reverse sum ." }
        "With the stack you can omit unnecessary names"
        "You can still name things: lexical/dynamic variables, sequences, associations, objects, ..."
    }
    { $slide "Functional programming"
        "A quotation is a sequence of literals and words"
        "Combinators replace imperative-style loops"
        "A simple example:"
        { $code "10 [ \"Hello world\" print ] times" }
        { "Partial application: " { $link curry } }
        { $code "{ 3 1 3 3 7 } [ 5 + ] map ." }
        { $code "{ 3 1 3 3 7 } 5 [ + ] curry map ." }
    }
    { $slide "Word definitions"
        { $code ": name ( inputs -- outputs ) definition ;" }
        "Stack effect comments document stack inputs and outputs."
        "Example from previous slide:"
        { $code ": add-each ( seq n -- newseq ) [ + ] curry map ;" }
        { $code "{ 3 1 3 3 7 } add-each ." }
        "Copy and paste factoring"
    }
    { $slide "Object-oriented programming"
        "Define a tuple class and a constructor:"
        { $code
            "TUPLE: person name address ;"
            "C: <person> person"
        }
        "Create an instance:"
        { $code "\"Cosmo Kramer\" \"100 Blah blah St, New York\" <person>" }
        "We can inspect it and edit it"
        "We can reshape the class:"
        { $code "TUPLE: person name address age phone-number ;" }
        { $code "TUPLE: person name address phone-number age ;" }
    }
    STRIP-TEASE:
        $slide "Primary school geometry recap"
        { $code
            "TUPLE: square dimension ;"
            "TUPLE: circle radius ;"
            "TUPLE: rectangle width height ;"
            ""
            "GENERIC: area ( shape -- meters^2 )"
            "M: square area square-dimension sq ;"
            "M: circle area circle-radius sq pi * ;"
            "M: rectangle area"
            "    { rectangle-width rectangle-height } get-slots * ;"
        }
    ;

    { $slide "Geometry example"
        { $code "10 <square> area ." }
        { $code "18 <circle> area ." }
        { $code "20 40 <rectangle> area ." }
    }
    { $slide "Factor: a meta language"
        "Here's fibonacci:"
        { $code
            ": fib ( x -- y )"
            "    dup 1 > ["
            "        1 - dup fib swap 1 - fib +"
            "    ] when ;"
        }
        "It is slow:"
        { $code
            "20 [ fib ] map ."
        }
        "Let's profile it!"
    }
    { $slide "Memoization"
        { { $link POSTPONE: : } " is just another word" }
        "What if we could define a word which caches its results?"
        { "The " { $vocab-link "memoize" } " library provides such a feature" }
        { "Just change " { $link POSTPONE: : } " to " { $link POSTPONE: MEMO: } }
        { $code
            "MEMO: fib ( x -- y )"
            "    dup 1 > ["
            "        1 - dup fib swap 1 - fib +"
            "    ] when ;"
        }
        "It is faster:"
        { $code
            "20 [ fib ] map ."
        }
    }
    { $slide "The Factor UI"
        "Written in Factor"
        "Renders with OpenGL"
        "Backends for Windows, X11, Cocoa"
        "You can call Windows, X11, Cocoa APIs directly too"
        "OpenGL 2.1 shaders, OpenAL 3D audio..."
    }
    { $slide "Implementation"
        "Very small C core"
        "Non-optimizing compiler"
        "Optimizing compiler"
        "Generational garbage collector"
        "Non-blocking I/O"
    }
    { $slide "Live coding demo"
        
    }
    { $slide "C library interface"
        "Efficient"
        "No need to write C code"
        "Supports floats, structs, unions, ..."
        "Function pointers, callbacks"
    }
    { $slide "Live coding demo"
        
    }
    { $slide "Community"
        "Factor development began in 2003"
        "About a dozen contributors"
        "Handful of \"core contributors\""
        { "Web site: " { $url "http://factorcode.org" } }
        "IRC: #concatenative on irc.freenode.net"
        "Mailing list: factor-talk@lists.sf.net"
        { "Let's play " { $vocab-link "space-invaders" } }
    }
} ;

: minneapolis-talk minneapolis-slides slides-window ;

MAIN: minneapolis-talk
