USING: slides help.markup math arrays hashtables namespaces
sequences kernel sequences parser ;
IN: catalyst-talk

: catalyst-slides
{
    { $slide "What is Factor?"
        "Originally scripting for a Java game"
        "Language dev more fun than game dev"
        "Start with ideas which were mostly dead"
        "Throw in features from crazy languages"
        "Develop practical libraries and tools"
    }
    { $slide "Factor: a stack language"
        "Implicit parameter passing"
        { "Each " { $emphasis "word" } " is a function call" }
        { $code ": sq dup * ;" }
        { $code "2 3 + sq ." }
        "Minimal syntax and semantics = easy meta-programming"
        { "Related languages: Forth, Joy, PostScript" }
    }
    { $slide "Factor: a functional language"
        { { $emphasis "Quotations" } " can be passed around, constructed..." }
        { $code "[ sq 3 + ]" }
        { { $emphasis "Combinators" } " are words which take quotations, eg " { $link if } }
        { "For FP buffs: " { $link each } ", " { $link map } ", " { $link reduce } ", " { $link accumulate } ", " { $link interleave } ", " { $link subset } }
        { $code "{ 42 69 666 } [ sq 3 + ] map ." }
    }
    { $slide "Factor: an object-oriented language"
        { "Everything is an " { $emphasis "object" } }
        { "An object is an instance of a " { $emphasis "class" } }
        "Methods"
        "Generic words"
        "For CLOS buffs: we allow custom method combination, classes are objects too, there's a MOP"
    }
    
: (strip-tease) ( data n -- data )
    >r first3 r> head 3array ;

: strip-tease ( data -- seq )
    dup third length 1 - [
        2 + (strip-tease)
    ] curry* map ;

: STRIP-TEASE:
    parse-definition strip-tease [ parsed ] each ; parsing

    STRIP-TEASE:
        $slide "Primary school geometry recap"
        { $code
            "GENERIC: area ( shape -- meters^2 )"
            "TUPLE: square dimension ;"
            "M: square area square-dimension sq ;"
            "TUPLE: circle radius ;"
            "M: circle area circle-radius sq pi * ;"
            "TUPLE: rectangle width height ;"
            "M: rectangle area"
            "    dup rectangle-width"
            "    swap rectangle-height"
            "    * ;"
        }
    ;

    { $slide "Geometry example"
        { $code "10 <square> area ." }
        { $code "18 <circle> area ." }
        { $code "20 40 <rectangle> area ." }
    }
!    { $slide "Factor: a meta language"
!        "Writing code which writes code"
!        "Extensible parser: define new syntax"
!        "Compiler transforms"
!        "Here's an inefficient word:"
!        { $code
!            ": fib ( x -- y )"
!            "    dup 1 > ["
!            "        1 - dup fib swap 1 - fib +"
!            "    ] when ;"
!        }
!    }
!    { $slide "Memoization"
!        { { $link POSTPONE: : } " is just another word" }
!        "What if we could define a word which caches its results?"
!        { "The " { $vocab-link "memoize" } " library provides such a feature" }
!        { "Just change " { $link POSTPONE: : } " to " { $link POSTPONE: MEMO: } }
!        { $code
!            "MEMO: fib ( x -- y )"
!            "    dup 1 > ["
!            "        1 - dup fib swap 1 - fib +"
!            "    ] when ;"
!        }
!    }
    { $slide "Factor: a tool-building language"
        "Tools are not monolithic, but are themselves just sets of words"
        "Examples: parser, compiler, etc"
        "Parser: turns strings into objects"
        { $code "\"1\" <file-reader> contents parse" }
        "Prettyprinter: turns objects into strings"
        { $code "\"2\" <file-writer> [ . ] with-stream" }
    }
    { $slide "Factor: an interactive language"
        { "Let's hack " { $vocab-link "tetris" } }
        "Editor integration"
        { $code "\\ tetrominoes edit" }
        "Inspector"
        { $code "\\ tetrominoes get inspect" }
    }
    { $slide "C library interface"
        "No need to write C glue code!"
        "Callbacks from C to Factor"
        "Factor can be embedded in C apps"
        { "Example: " { $vocab-link "ogg.vorbis" } }
        { "Other bindings: OpenGL, OpenAL, X11, Win32, Cocoa, OpenSSL, memory mapped files, ..." }
    }
    { $slide "Native libraries"
        "XML, HTTP, SMTP, Unicode, calendar, ..."
        "Lazy lists, pattern matching, packed arrays, ..."
    }
    { $slide "Factor: a fun language"
        { "Let's play "
        { $vocab-link "space-invaders" }
        }
        { $url "http://factorcode.org" }
        { $url "http://factor-language.blogspot.com" }
        "irc.freenode.net #concatenative"
        "Have fun!"
    }
} ;

: catalyst-talk catalyst-slides slides-window ;

MAIN: catalyst-talk
