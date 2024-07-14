USING: help.markup help.syntax io kernel math parser
prettyprint sequences vocabs.loader namespaces stack-checker
help command-line see ;
IN: help.cookbook

ARTICLE: "cookbook-syntax" "Basic syntax cookbook"
"The following is a simple snippet of Factor code:"
{ $example "10 sq 5 - ." "95" }
"You can click on it to evaluate it in the listener, and it will print the same output value as indicated above."
$nl
"Factor has a very simple syntax. Your program consists of " { $emphasis "words" } " and " { $emphasis "literals" } ". In the above snippet, the words are " { $link sq } ", " { $link - } " and " { $link . } ". The two integers 10 and 5 are literals."
$nl
"Factor evaluates code left to right, and stores intermediate values on a " { $emphasis "stack" } ". If you think of the stack as a pile of papers, then " { $emphasis "pushing" } " a value on the stack corresponds to placing a piece of paper at the top of the pile, while " { $emphasis "popping" } " a value corresponds to removing the topmost piece."
$nl
"All words have a " { $emphasis "stack effect declaration" } ", for example " { $snippet "( x y -- z )" } " denotes that a word takes two inputs, with " { $snippet "y" } " at the top of the stack, and returns one output. Stack effect declarations can be viewed by browsing source code, or using tools such as " { $link see } "; they are also checked by the compiler. See " { $link "effects" } "."
$nl
"Coming back to the example in the beginning of this article, the following series of steps occurs as the code is evaluated:"
{ $table
    { { $strong "Action" } { $strong "Stack contents" } }
    { "10 is pushed on the stack." { $snippet "10" } }
    { { "The " { $link sq } " word is executed. It pops one input from the stack (the integer 10) and squares it, pushing the result." } { $snippet "100" } }
    { { "5 is pushed on the stack." } { $snippet "100 5" } }
    { { "The " { $link - } " word is executed. It pops two inputs from the stack (the integers 100 and 5) and subtracts 5 from 100, pushing the result." } { $snippet "95" } }
    { { "The " { $link . } " word is executed. It pops one input from the stack (the integer 95) and prints it in the listener's output area." } { } }
}
"Factor supports many other data types:"
{ $code
    "10.5"
    "\"character strings\""
    "{ 1 2 3 }"
    "! by the way, this is a comment"
}
{ $references
    { "Factor's syntax can be extended, the parser can be called reflectively, and the " { $link . } " word is in fact a general facility for turning almost any object into a form which can be parsed back in again. If this interests you, consult the following sections:" }
    "syntax"
    "parser"
    "prettyprint"
} ;

ARTICLE: "cookbook-colon-defs" "Shuffle word and definition cookbook"
"The " { $link dup } " word makes a copy of the value at the top of the stack:"
{ $example "5 dup * ." "25" }
"The " { $link sq } " word is actually defined as follows:"
{ $code ": sq ( x -- y ) dup * ;" }
"(You could have looked this up yourself by clicking on the " { $link sq } " word itself.)"
$nl
"Note the key elements in a word definition: The colon " { $link POSTPONE: : } " denotes the start of a word definition. The name of the new word and a stack effect declaration must immediately follow. The word definition then continues on until the " { $link POSTPONE: ; } " token signifies the end of the definition. This type of word definition is called a " { $emphasis "compound definition." }
$nl
"Factor is all about code reuse through short and logical colon definitions. Breaking up a problem into small pieces which are easy to test is called " { $emphasis "factoring." }
$nl
"Another example of a colon definition:"
{ $code ": neg ( x -- -x ) 0 swap - ;" }
"Here the " { $link swap } " shuffle word is used to interchange the top two stack elements. Note the difference that " { $link swap } " makes in the following two snippets:"
{ $code
    "5 0 -       ! Computes 5-0"
    "5 0 swap -  ! Computes 0-5"
}
"Also, in the above example a stack effect declaration is written between " { $snippet "(" } " and " { $snippet ")" } " with a mnemonic description of what the word does to the stack. See " { $link "effects" } " for details."
{ $curious
  "This syntax will be familiar to anybody who has used Forth before. However, unlike Forth, some additional static checks are performed. See " { $link "definition-checking" } " and " { $link "inference" } "."
}
{ $references
    { "A whole slew of shuffle words can be used to rearrange the stack. There are forms of word definition other than colon definition, words can be defined entirely at runtime, and word definitions can be " { $emphasis "annotated" } " with tracing calls and breakpoints without modifying the source code." }
    "shuffle-words"
    "words"
    "generic"
    "handbook-tools-reference"
} ;

ARTICLE: "cookbook-combinators" "Control flow cookbook"
"A " { $emphasis "quotation" } " is an object containing code which can be evaluated."
{ $code
    "2 2 + .     ! Prints 4"
    "[ 2 2 + . ] ! Pushes a quotation"
}
"The quotation pushed by the second example will print 4 when called by " { $link call } "."
$nl
"Quotations are used to implement control flow. For example, conditional execution is done with " { $link if } ":"
{ $code
    ": sign-test ( n -- )"
    "    dup 0 < ["
    "        drop \"negative\""
    "    ] ["
    "        zero? [ \"zero\" ] [ \"positive\" ] if"
    "    ] if print ;"
}
"The " { $link if } " word takes a boolean, a true quotation, and a false quotation, and executes one of the two quotations depending on the value of the boolean. In Factor, any object not equal to the special value " { $link f } " is considered true, while " { $link f } " is false."
$nl
"Another useful form of control flow is iteration. You can do something several times:"
{ $code "10 [ \"Factor rocks!\" print ] times" }
"Now we can look at a new data type, the array:"
{ $code "{ 1 2 3 }" }
"An array differs from a quotation in that it cannot be evaluated; it simply stores data."
$nl
"You can perform an operation on each element of an array:"
{ $example
    "USING: io sequences prettyprint ;"
    "{ 1 2 3 } [ \"The number is \" write . ] each"
    "The number is 1\nThe number is 2\nThe number is 3"
}
"You can transform each element, collecting the results in a new array:"
{ $example "{ 5 12 0 -12 -5 } [ sq ] map ." "{ 25 144 0 144 25 }" }
"You can create a new array, only containing elements which satisfy some condition:"
{ $example
    ": negative? ( n -- ? ) 0 < ;"
    "{ -12 10 16 0 -1 -3 -9 } [ negative? ] filter ."
    "{ -12 -1 -3 -9 }"
}
{ $references
    { "Since quotations are objects, they can be constructed and taken apart at will. You can write code that writes code. Arrays are just one of the various types of sequences, and the sequence operations such as " { $link each } " and " { $link map } " operate on all types of sequences. There are many more sequence iteration operations than the ones above, too." }
    "combinators"
    "sequences"
} ;

ARTICLE: "cookbook-variables" "Dynamic variables cookbook"
"A symbol is a word which pushes itself on the stack when executed. Try it:"
{ $example "SYMBOL: foo" "foo ." "foo" }
"Before using a variable, you must define a symbol for it:"
{ $code "SYMBOL: name" }
"Symbols can be passed to the " { $link get } " and " { $link set } " words to read and write variable values:"
{ $unchecked-example "\"Slava\" name set" "name get print" "Slava" }
"If you set variables inside a " { $link with-scope } ", their values will be lost after leaving the scope:"
{ $unchecked-example
    ": print-name ( -- ) name get print ;"
    "\"Slava\" name set"
    "["
    "    \"Diana\" name set"
    "    \"There, the name is \" write  print-name"
    "] with-scope"
    "\"Here, the name is \" write  print-name"
    "There, the name is Diana\nHere, the name is Slava"
}
{ $references
    "There is a lot more to be said about dynamically-scoped variables and namespaces."
    "namespaces"
} ;

ARTICLE: "cookbook-vocabs" "Vocabularies cookbook"
"Rather than being in one flat list, words belong to vocabularies; every word is contained in exactly one. When parsing a word name, the parser searches through vocabularies. When working at the listener, a useful set of vocabularies is already available. In a source file, all used vocabularies must be imported."
$nl
"For example, a source file containing the following code will print a parse error if you try loading it:"
{ $code "\"Hello world\" print" }
"The " { $link print } " word is contained inside the " { $vocab-link "io" } " vocabulary, which is available in the listener but must be explicitly added to the search path in source files:"
{ $code
    "USE: io"
    "\"Hello world\" print"
}
"Typically a source file will refer to words in multiple vocabularies, and they can all be added to the search path in one go:"
{ $code "USING: arrays kernel math ;" }
"New words go into the " { $vocab-link "scratchpad" } " vocabulary by default. You can change this with " { $link POSTPONE: IN: } ":"
{ $code
    "IN: time-machine"
    ": time-travel ( when what -- ) frob fizz flap ;"
}
"Note that words must be defined before being referenced. The following is generally invalid:"
{ $code
    ": frob ( what -- ) accelerate particles ;"
    ": accelerate ( -- ) accelerator on ;"
    ": particles ( what -- ) [ (particles) ] each ;"
}
"You would have to place the first definition after the two others for the parser to accept the file. If you have a set of mutually recursive words, you can use " { $link POSTPONE: DEFER: } "."
{ $references
    { }
    "word-search"
    "words"
    "parser"
} ;

ARTICLE: "cookbook-application" "Application cookbook"
"Vocabularies can define a main entry point:"
{ $code "IN: game-of-life"
"..."
": play-life ( -- ) ... ;"
""
"MAIN: play-life"
}
"See " { $link POSTPONE: MAIN: } " for details. The " { $link run } " word loads a vocabulary if necessary, and calls its main entry point; try the following, it's fun:"
{ $code "\"tetris\" run" }
"Factor can deploy stand-alone executables; they do not have any external dependencies and consist entirely of compiled native machine code:"
{ $code "\"tetris\" deploy-tool" }
{ $references
    { }
    "vocabs.loader"
    "tools.deploy"
    "ui.tools.deploy"
    "cookbook-scripts"
} ;

ARTICLE: "cookbook-scripts" "Scripting cookbook"
"Factor can be used for command-line scripting on Unix-like systems."
$nl
"To run a script, simply pass it as an argument to the Factor executable:"
{ $code "./factor cleanup.factor" }
"To test a script in the listener, you can use " { $link run-file } "." 
$nl
"The script may access command line arguments by inspecting the value of the " { $link command-line } " variable. It can also get its own path from the " { $link script } " variable."
{ $heading "Example: ls" }
"Here is an example implementing a simplified version of the Unix " { $snippet "ls" } " command in Factor:"
{ $code
    "USING: command-line namespaces io io.files
io.pathnames tools.files sequences kernel ;

command-line get [
    \".\" directory.
] [
    dup length 1 = [ first directory. ] [
        [ [ nl write \":\" print ] [ directory. ] bi ] each
    ] if
] if-empty"
}
"You can put it in a file named " { $snippet "ls.factor" } ", and then run it, to list the " { $snippet "/usr/bin" } " directory for example:"
{ $code "./factor ls.factor /usr/bin" }
{ $heading "Example: grep" }
"The following is a more complicated example, implementing something like the Unix " { $snippet "grep" } " command:"
{ $code "USING: kernel fry io io.files io.encodings.ascii sequences
regexp command-line namespaces ;
IN: grep

: grep-lines ( pattern -- )
    '[ dup _ matches? [ print ] [ drop ] if ] each-line ;

: grep-file ( pattern filename -- )
    ascii [ grep-lines ] with-file-reader ;

: grep-usage ( -- )
    \"Usage: factor grep.factor <pattern> [<file>...]\" print ;

command-line get [
    grep-usage
] [
    unclip <regexp> swap [
        grep-lines
    ] [
        [ grep-file ] with each
    ] if-empty
] if-empty" }
"You can run it like so,"
{ $code "./factor grep.factor '.*hello.*' myfile.txt" }
"You'll notice this script takes a while to start. This is because it is loading and compiling the " { $vocab-link "regexp" } " vocabulary every time. To speed up startup, load the vocabulary into your image, and save the image:"
{ $code "USE: regexp" "save" }
"Now, the " { $snippet "grep.factor" } " script will start up much faster. See " { $link "images" } " for details."
{ $heading "Executable scripts" }
"It is also possible to make executable scripts. A Factor file can begin with a 'shebang' like the following:"
{ $code "#!/usr/bin/env factor" }
"If the text file is made executable, then it can be run, assuming the " { $snippet "factor" } " binary is in your " { $snippet "$PATH" } "."
{ $references
    { }
    "command-line"
    "cookbook-application"
    "images"
} ;

ARTICLE: "cookbook-philosophy" "Factor philosophy"
"Learning a stack language is like learning to ride a bicycle: it takes a bit of practice and you might graze your knees a couple of times, but once you get the hang of it, it becomes second nature."
$nl
"The most common difficulty encountered by beginners is trouble reading and writing code as a result of trying to place too many values on the stack at a time."
$nl
"Keep the following guidelines in mind to avoid losing your sense of balance:"
{ $list
    "Simplify, simplify, simplify. Break your program up into small words which operate on a few values at a time. Most word definitions should fit on a single line; very rarely should they exceed two or three lines."
    "In addition to keeping your words short, keep them meaningful. Give them good names, and make sure each word only does one thing. Try documenting your words; if the documentation for a word is unclear or complex, chances are the word definition is too. Don't be afraid to refactor your code."
    "If your code looks repetitive, factor it some more."
    "If after factoring, your code still looks repetitive, introduce combinators."
    "If after introducing combinators, your code still looks repetitive, look into using meta-programming techniques."
    "Try to place items on the stack in the order in which they are needed. If everything is in the correct order, no shuffling needs to be performed."
    "If you find yourself writing a stack comment in the middle of a word, break the word up."
    { "Use " { $link "cleave-combinators" } " and " { $link "spread-combinators" } " instead of " { $link "shuffle-words" } " to give your code more structure." }
    { "Not everything has to go on the stack. The " { $vocab-link "namespaces" } " vocabulary provides dynamically-scoped variables, and the " { $vocab-link "locals" } " vocabulary provides lexically-scoped variables. Learn both and use them where they make sense, but keep in mind that overuse of variables makes code harder to factor." }
    "Every time you define a word which simply manipulates sequences, hashtables or objects in an abstract way which is not related to your program domain, check the library to see if you can reuse an existing definition."
    { "Write unit tests. Factor provides good support for unit testing; see " { $link "tools.test" } ". Once your program has a good test suite you can refactor with confidence and catch regressions early." }
    "Don't write Factor as if it were C. Imperative programming and indexed loops are almost always not the most idiomatic solution."
    { "Use sequences, assocs and objects to group related data. Object allocation is very cheap. Don't be afraid to create tuples, pairs and triples. Don't be afraid of operations which allocate new objects either, such as " { $link append } "." }
    { "If you find yourself writing a loop with a sequence and an index, there's almost always a better way. Learn the " { $link "sequences-combinators" } " by heart." }
    { "If you find yourself writing a heavily nested loop which performs several steps on each iteration, there is almost always a better way. Break the problem down into a series of passes over the data instead, gradually transforming it into the desired result with a series of simple loops. Factor the loops out and reuse them. If you're working on anything math-related, learn " { $link "math-vectors" } " by heart." }
    { "If you find yourself wishing you could iterate over the datastack, or capture the contents of the datastack into a sequence, or push each element of a sequence onto the datastack, there is almost always a better way. Use " { $link "sequences" } " instead." }
    "Don't use meta-programming if there's a simpler way."
    "Don't worry about efficiency unless your program is too slow. Don't prefer complex code to simple code just because you feel it will be more efficient. The Factor compiler is designed to make idiomatic code run fast."
    { "None of the above are hard-and-fast rules: there are exceptions to all of them. But one rule unconditionally holds: " { $emphasis "there is always a simpler way" } "." }
}
"Factor tries to implement as much of itself as possible, because this improves simplicity and performance. One consequence is that Factor exposes its internals for extension and study. You even have the option of using low-level features not usually found in high-level languages, such as manual memory management, pointer arithmetic, and inline assembly code."
$nl
"Unsafe features are tucked away so that you will not invoke them by accident, or have to use them to solve conventional programming problems. However when the need arises, unsafe features are invaluable, for example you might have to do some pointer arithmetic when interfacing directly with C libraries." ;

ARTICLE: "cookbook-pitfalls" "Pitfalls to avoid"
"Factor is a very clean and consistent language. However, it has some limitations and leaky abstractions you should keep in mind, as well as behaviors which differ from other languages you may be used to."
{ $list
    "Factor only makes use of one native thread, and Factor threads are scheduled co-operatively. C library calls block the entire VM."
    "Factor does not hide anything from the programmer, all internals are exposed. It is your responsibility to avoid writing fragile code which depends too much on implementation detail."
    { "If a literal object appears in a word definition, the object itself is pushed on the stack when the word executes, not a copy. If you intend to mutate this object, you must " { $link clone } " it first. See " { $link "syntax-literals" } "." }
    { "Also, " { $link dup } " and related shuffle words don't copy entire objects or arrays; they only duplicate the reference to them. If you want to guard an object against mutation, use " { $link clone } "." }
    { "For a discussion of potential issues surrounding the " { $link f } " object, see " { $link "booleans" } "." }
    { "Factor's object system is quite flexible. Careless usage
    of union, mixin and predicate classes can lead to similar problems to those caused by \"multiple inheritance\" in other languages. In particular, it is possible to have two classes such that they have a non-empty intersection and yet neither is a subclass of the other. If a generic word defines methods on two such classes, various disambiguation rules are applied to ensure method dispatch remains deterministic, however they may not be what you expect. See " { $link "method-order" } " for details." }
    { "If " { $link run-file } " throws a stack depth assertion, it means that the top-level form in the file left behind values on the stack. The stack depth is compared before and after loading a source file, since this type of situation is almost always an error. If you have a legitimate need to load a source file which returns data in some manner, define a word in the source file which produces this data on the stack and call the word after loading the file." }
} ;

ARTICLE: "cookbook-next" "Next steps"
"Once you have read through " { $link "first-program" } " and " { $link "cookbook" } ", the best way to keep learning Factor is to start looking at some simple example programs. Here are a few particularly nice vocabularies which should keep you busy for a little while:"
{ $list
    { $vocab-link "base64" }
    { $vocab-link "roman" }
    { $vocab-link "rot13" }
    { $vocab-link "smtp" }
    { $vocab-link "time-server" }
    { $vocab-link "tools.hexdump" }
    { $vocab-link "webapps.counter" }
}
"If you see code in there that you do not understand, use " { $link see } " and " { $link help } " to explore." ;

ARTICLE: "cookbook" "Factor cookbook"
"The Factor cookbook is a high-level overview of the most important concepts required to program in Factor."
{ $subsections
    "cookbook-syntax"
    "cookbook-colon-defs"
    "cookbook-combinators"
    "cookbook-variables"
    "cookbook-vocabs"
    "cookbook-application"
    "cookbook-scripts"
    "cookbook-philosophy"
    "cookbook-pitfalls"
    "cookbook-next"
} ;

ABOUT: "cookbook"
