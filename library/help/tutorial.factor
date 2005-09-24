IN: help
USING: gadgets gadgets-books gadgets-borders gadgets-buttons
gadgets-editors gadgets-labels gadgets-layouts gadgets-panes
gadgets-presentations generic kernel lists math namespaces sdl
sequences strings styles ;

: <slide-title> ( text -- gadget )
    <label> dup 36 font-size set-paint-prop ;

: <underline> ( -- gadget )
    <gadget>
    dup << gradient f @{ 1 0 0 }@ @{ 64 64 64 }@ @{ 255 255 255 }@ >>
    interior set-paint-prop
    @{ 0 10 0 }@ over set-gadget-dim ;

GENERIC: tutorial-line ( object -- gadget )

M: string tutorial-line
    @{
        @{ [ "* " ?head ] [ <slide-title> ] }@
        @{ [ dup "--" = ] [ drop <underline> ] }@
        @{ [ t ] [ <label> ] }@
    }@ cond ;

: example-theme
    dup button-theme
    "Monospaced" font set-paint-prop ;

M: general-list tutorial-line
    car
    <label> [ label-text pane get pane-input set-editor-text ]
    <roll-button> dup example-theme ;

: <page> ( list -- gadget )
    [ tutorial-line ] map
    <pile> 1 over set-pack-fill [ add-gadgets ] keep
    empty-border ;

: tutorial-pages
    [
        [
            "* Factor: a dynamic language"
            "--"
            "This series of slides presents a quick overview of Factor."
            ""
            "Factor is interactive, which means you can test out the code"
            "in this tutorial immediately."
            ""
            "Code examples will insert themselves in the listener's input"
            "area when clicked:"
            ""
            [ "\"hello world\" print" ]
            ""
            "You can then press ENTER to execute the code, or edit it first."
            ""
            "http://factor.sourceforge.net"
        ] [
            "* The view from 10,000 feet"
            "--"
            "- Everything is an object"
            "- A word is a basic unit of code"
            "- Words are identified by names, and organized in vocabularies"
            "- Words pass parameters on the stack"
            "- Code blocks can be passed as parameters to words"
            "- Word definitions are very short with very high code reuse"
        ] [
            "* Basic syntax"
            "--"
            "Factor code is made up of whitespace-speparated tokens."
            "Recall the example from the first slide:"
            ""
            [ "\"hello world\" print" ]
            ""
            "The first token (\"hello world\") is a string."
            "The second token (print) is a word."
            "The string is pushed on the stack, and the print word prints it."
        ] [
            "* The stack"
            "--"
            "- The stack is like a pile of papers."
            "- You can ``push'' papers on the top of the pile,"
            "  and ``pop'' papers from the top of the pile."
            ""
            "Here is another code example:"
            ""
            [ "2 3 + ." ]
            ""
            "Try running it in the listener now."
        ] [
            "* Postfix arithmetic"
            "--"
            "What happened when you ran it?"
            ""
            "The two numbers (2 3) are pushed on the stack."
            "Then, the + word pops them and pushes the result (5)."
            "Then, the . word prints this result."
            ""
            "This is called postfix arithmetic."
            "Traditional arithmetic is called infix: 3 + (6 * 2)"
            "Lets translate this into postfix: 3 6 2 * + ."
        ] [
            "* Colon definitions"
            "--"
            "We can define new words in terms of existing words."
            ""
            [ ": twice  2 * ;" ]
            ""
            "This defines a new word named ``twice'' that calls ``2 *''."
            "Try the following in the listener:"
            ""
            [ "3 twice twice ." ]
            ""
            "The result is the same as if you wrote:"
            ""
            [ "3 2 * 2 * ." ]
        ] [
            "* Stack effects"
            "--"
            "When we look at the definition of the ``twice'' word,"
            "it is intuitively obvious that it takes one value from the stack,"
            "and leaves one value behind. However, with more complex"
            "definitions, it is better to document this so-called"
            "``stack effect''."
            ""
            "A stack effect comment is written between ( and )."
            "Factor ignores stack effect comments. Don't you!"
            ""
            "The stack effect of twice is ( x -- 2*x )."
            "The stack effect of + is ( x y -- x+y )."
            "The stack effect of . is ( object -- )."
        ] [
            "* Reading user input"
            "--"
            "User input is read using the readln ( -- string ) word."
            "Note its stack effect; it puts a string on the stack."
            ""
            "This program will ask your name, then greet you:"
            ""
            [ "\"What is your name?\" print" ]
            [ "readln \"Hello, \" write print" ]
        ] [
            "* Shuffle words"
            "--"
            "The word ``twice'' we defined is useless."
            "Let's try something more useful: squaring a number."
            ""
            "We want a word with stack effect ( n -- n*n )."
            "However, we cannot use * by itself, since its stack effect"
            "is ( x y -- x*y ); it expects two inputs."
            ""
            "However, we can use the word ``dup''. It has stack effect"
            "( object -- object object ), and it does exactly what we"
            "need. The ``dup'' word is known as a shuffle word."
        ] [
            "* The squared word"
            "--"
            "Try entering the following word definition:"
            ""
            [ ": square ( n -- n*n ) dup * ;" ]
            ""
            "Shuffle words solve the problem where we need to compose"
            "two words, but their stack effects do not ``fit''."
            ""
            "Some of the most commonly-used shuffle words:"
            ""
            "drop ( object -- )"
            "swap ( obj1 obj2 -- obj2 obj1 )"
            "over ( obj1 obj2 -- obj1 obj2 obj1 )"
        ] [
            "* Another shuffle example"
            "--"
            "Now let us write a word that negates a number."
            "Start by entering the following in the listener"
            ""
            [ "0 10 - ." ]
            ""
            "It will print -10, as expected. Now notice that this the same as:"
            ""
            [ "10 0 swap - ." ]
            ""
            "So indeed, we can factor out the definition ``0 swap -'':"
            ""
            [ ": negate ( n -- -n ) 0 swap - ;" ]
        ] [
            "* Seeing words"
            "--"
            "If you have entered every definition in this tutorial,"
            "you will now have several new colon definitions:"
            ""
            "  twice"
            "  square"
            "  negate"
            ""
            "You can look at previously-entered word definitions using 'see'."
            "Try the following:"
            ""
            [ "\\ negate see" ]
            ""
            "Prefixing a word with \\ pushes it on the stack, instead of"
            "executing it. So the see word has stack effect ( word -- )."
        ] [
            "* Branches"
            "--"
            "Now suppose we want to write a word that computes the"
            "absolute value of a number; that is, if it is less than 0,"
            "the number will be negated to yield a positive result."
            ""
            [ ": absolute ( x -- |x| ) dup 0 < [ negate ] when ;" ]
            ""
            "If the top of the stack is negative, the word negates it"
            "again, making it positive."
            ""
            "The < ( x y -- x<y ) word outputs a boolean."
            "In Factor, any object can be used as a truth value."
            "- The f object is false."
            "- Anything else is true."
        ] [
            "* More branches"
            "--"
            "On the previous slide, you saw the 'when' conditional:"
            ""
            [ "  ... condition ... [ ... true case ... ] when" ]
            ""
            "Another commonly-used form is 'unless':"
            ""
            [ "  ... condition ... [ ... false case ... ] unless" ]
            ""
            "The 'if' conditional takes action on both branches:"
            ""
            [ "  ... condition ... [ ... ] [ ... ] if" ]
        ] [
            "* Combinators"
            "--"
            "if, when, unless are words that take lists of code as input."
            ""
            "Lists of code are called ``quotations''."
            "Words that take quotations are called ``combinators''."
            ""
            "Another combinator is times ( n quot -- )."
            "It calls a quotation n times."
            ""
            "Try this:"
            ""
            [ "10 [ \"Hello combinators\" print ] times" ]
        ] [
            "* Sequences"
            "--"
            "You have already seen strings, very briefly:"
            ""
            "  \"Hello world\""
            ""
            "Strings are part of a class of objects called sequences."
            "Two other types of sequences you will use a lot are:"
            ""
            "  Lists: [ 1 3 \"hi\" 10 2 ]"
            "  Vectors: { \"the\" [ \"quick\" \"brown\" ] \"fox\" }"
            ""
            "As you can see in the second example, lists and vectors"
            "can contain any type of object, including other lists"
            "and vectors."
        ] [
            "* Sequences and combinators"
            "--"
            "A very useful combinator is each ( seq quot -- )."
            "It calls a quotation with each element of the sequence in turn."
            ""
            "Try this:"
            ""
            [ "{ 10 20 30 } [ . ] each" ]
            ""
            "A closely-related combinator is map ( seq quot -- seq )."
            "It also calls a quotation with each element."
            "However, it then collects the outputs of the quotation"
            "into a new sequence."
            ""
            "Try this:"
            ""
            [ "{ 10 20 30 } [ 3 + ] map ." ]
            "==> { 13 23 33 }"
        ] [
            "* Numbers - integers and ratios"
            "--"
            "Factor's supports arbitrary-precision integers and ratios."
            ""
            "Try the following:"
            ""
            [ ": factorial ( n -- n! ) 0 <range> product ;" ]
            [ "100 factorial ." ]
            ""
            [ "1 3 / 1 2 / + ." ]
            ""
            "Rational numbers are added, multiplied and reduced to"
            "lowest terms in the same way you learned in grade school."
        ] [
            "* Numbers - higher math"
            "--"
            [ "2 sqrt ." ]
            ""
            [ "-1 sqrt ." ]
            ""
            [ "{ { 10 3 } { 7 5 } { -2 0 } }" ]
            [ "{ { 11 2 } { 4 8 } } m." ]
            ""
            "... and there is much more for the math geeks."
        ] [
            "* Object oriented programming"
            "--"
            "Each object belongs to a class."
            "Generic words act differently based on an object's class."
            ""
            [ "GENERIC: describe ( object -- )" ]
            [ "M: integer describe \"The integer \" write . ;" ]
            [ "M: string describe \"The string \" write . ;" ]
            [ "M: object describe drop \"Unknown object\" print ;" ]
            ""
            "Each M: line defines a ``method.''"
            "Method definitions may appear in independent source files."
            ""
            "integer, string, object are built-in classes."
        ] [
            "* Defining new classes"
            "--"
            "New classes can be defined:"
            ""
            [ "TUPLE: point x y ;" ]
            [ "M: point describe" ]
            [ "  \"x =\" write dup point-x ." ]
            [ "  \"y =\" write point-y . ;" ]
            [ "100 200 <point> describe" ]
            ""
            "A tuple is a collection of named slots."
            ""
            "Tuples support custom constructors, delegation..."
            "see the developer's handbook for details."
        ] [
            "* The library"
            "--"
            "Offers a good selection of highly-reusable words:"
            "- Operations on sequences"
            "- Variety of mathematical functions"
            "- Web server and web application framework"
            "- Graphical user interface framework"
            "Browsing the library:"
            "- To list all vocabularies:"
            [ "vocabs ." ]
            "- To list all words in a vocabulary:"
            [ "\"sequences\" words ." ]
            "- To show a word definition:"
            [ "\\ reverse see" ]
        ] [
            "* Learning more"
            "--"
            "Hopefully this tutorial has sparked your interest in Factor."
            ""
            "You can learn more by reading the Factor developer's handbook:"
            ""
            "http://factor.sourceforge.net/handbook.pdf"
            ""
            "Also, point your IRC client to irc.freenode.net and hop in the"
            "#concatenative channel to chat with other Factor geeks."
        ]
    ] ;

: tutorial-theme
    dup @{ 204 204 255 }@ background set-paint-prop
    dup << gradient f @{ 0 1 0 }@ @{ 204 204 255 }@ @{ 255 204 255 }@ >>
    interior set-paint-prop
    dup "Sans Serif" font set-paint-prop
    18 font-size set-paint-prop ;

: <tutorial> ( pages -- browser )
    tutorial-pages [ <page> ] map <book>
    dup tutorial-theme <book-browser> ;

: tutorial ( -- )
    <tutorial> gadget. ;

: <tutorial-button>
    "Tutorial" <label>
    [ drop [ tutorial ] pane get pane-call ] <button> ;
