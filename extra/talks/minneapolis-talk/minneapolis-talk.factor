USING: slides help.markup math arrays hashtables namespaces
sequences kernel parser memoize ;
IN: talks.minneapolis-talk

CONSTANT: minneapolis-slides
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
    }
    { $slide "Stack-based programming"
        { "Most languages are " { $emphasis "applicative" } }
        "Words pop inputs from the stack and push outputs on the stack"
        "Literals are pushed on the stack"
        { $code "{ 1 2 } { 7 } append reverse sum ." }
    }
    { $slide "Stack-based programming"
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
        { $code ": name ( inputs -- outputs )"
        "    definition ;" }
        "Stack effect comments document stack inputs and outputs."
        "Example from previous slide:"
        { $code ": add-each ( seq n -- newseq )"
        "    [ + ] curry map ;" }
        { $code "{ 3 1 3 3 7 } 5 add-each ." }
    }
    { $slide "Object-oriented programming"
        { "Define a tuple class and a constructor:"
        { $code
            "TUPLE: person name address ;"
            "C: <person> person"
        } }
        { "Create an instance:"
        { $code
            "\"Cosmo Kramer\""
            "\"100 Blah blah St, New York\""
            "<person>"
        } }
    }
    { $slide "Object-oriented programming"
        "We can inspect it and edit objects"
        "We can reshape the class!"
        { $code "TUPLE: person" "name address age phone-number ;" }
        { $code "TUPLE: person" "name address phone-number age ;" }
    }
    { $slide "An example"
        { $code
            "TUPLE: square dimension ;"
            "C: <square> square"
            ""
            "TUPLE: circle radius ;"
            "C: <circle> circle"
            ""
            "TUPLE: rectangle width height ;"
            "C: <rectangle> rectangle"
        }
    }
    STRIP-TEASE:
        $slide "An example"
        { $code
            "USE: math.constants"
            "GENERIC: area ( shape -- meters^2 )"
            "M: square area square-dimension sq ;"
            "M: circle area circle-radius sq pi * ;"
            "M: rectangle area"
            "    dup rectangle-width"
            "    swap rectangle-height * ;"
        }
    ;

    { $slide "An example"
        { $code "10 <square> area ." }
        { $code "18 <circle> area ." }
        { $code "20 40 <rectangle> area ." }
    }
    { $slide "Meta language"
        "Here's fibonacci:"
        { $code
            ": fib ( x -- y )"
            "    dup 1 > ["
            "        1 - dup fib swap 1 - fib +"
            "    ] when ;"
        }
        "It is slow:"
        { $code
            "35 <iota> [ fib ] map ."
        }
        "Let's profile it!"
    }
    { $slide "Memoization"
        { { $link POSTPONE: : } " is just another word" }
        "What if we could define a word which caches its results?"
        { "The " { $vocab-link "memoize" } " library provides such a feature" }
        { "Just change " { $link POSTPONE: : } " to " { $link POSTPONE: MEMO: } }
    }
    { $slide "Memoization"
        { $code
            "USE: memoize"
            ""
            "MEMO: fib ( x -- y )"
            "    dup 1 > ["
            "        1 - dup fib swap 1 - fib +"
            "    ] when ;"
        }
        "It is faster:"
        { $code
            "35 <iota> [ fib ] map ."
        }
    }
    { $slide "The Factor UI"
        "Written in Factor"
        "Renders with OpenGL"
        "Backends for Windows, X11, Cocoa"
        "You can call Windows, X11, Cocoa APIs directly too"
        "OpenGL 2.1 shaders, OpenAL 3D audio..."
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
    { $slide "Deployment"
        { "Let's play " { $vocab-link "tetris" } }
    }
    { $slide "Implementation"
        "Portable: Windows, Mac OS X, Linux"
        "Non-optimizing compiler"
        "Optimizing compiler: x86, x86-64, PowerPC, ARM"
        "Generational garbage collector"
        "Non-blocking I/O"
    }
    { $slide "Some statistics"
        "VM: 11,800 lines of C"
        "Core library: 22,600 lines of Factor"
        "Docs, tests, extra libraries: 117,000 lines of Factor"
    }
    { $slide "But wait, there's more!"
        "Web server and framework, syntax highlighting, Ogg Theora video, SMTP, embedded Prolog, efficient unboxed arrays, XML, Unicode 5.0, memory mapped files, regular expressions, LDAP, database access, coroutines, Factor->JavaScript compiler, JSON, pattern matching, advanced math, parser generators, serialization, RSS/Atom, ..."
    }
    { $slide "Community"
        "Factor development began in 2003"
        "About a dozen contributors"
        "Handful of \"core contributors\""
        { "Web site: " { $url "http://factorcode.org" } }
        "IRC: #concatenative on irc.freenode.net"
        "Mailing list: factor-talk@lists.sf.net"
    }
    { $slide "Questions?" }
}

: minneapolis-talk ( -- )
    minneapolis-slides "Minneapolis talk" slides-window ;

MAIN: minneapolis-talk
