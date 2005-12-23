IN: help
USING: io ;

ARTICLE: "tutorial-overview" "The view from 10,000 feet"
"- Everything is an object"
"- A word is a basic unit of code"
"- Words are identified by names, and organized in vocabularies"
"- Words pass parameters on the stack"
"- Code blocks can be passed as parameters to words"
"- Word definitions are very short with very high code reuse" ;

ARTICLE: "tutorial-syntax" "Basic syntax"
"Factor code is made up of whitespace-speparated tokens. Recall the example from the first slide:"
{ $code "\"hello world\" print" }
"The first token (\"hello world\") is a string."
"The second token (print) is a word."
"The string is pushed on the stack, and the print word prints it." ;

ARTICLE: "tutorial-stack" "The stack"
"- The stack is like a pile of papers."
"- You can ``push'' papers on the top of the pile,"
"  and ``pop'' papers from the top of the pile."
"Here is another code example:"
{ $code "2 3 + ." }
"Try running it in the listener now." ;

ARTICLE: "tutorial-postfix" "Postfix arithmetic"
"What happened when you ran it? The two numbers (2 3) are pushed on the stack. Then, the + word pops them and pushes the result (5). Then, the . word prints this result."
"This is called postfix arithmetic."
"Traditional arithmetic is called infix: 3 + (6 * 2)"
"Lets translate this into postfix: 3 6 2 * + ." ;


ARTICLE: "tutorial-colon-def" "Colon definitions"
"We can define new words in terms of existing words."
{ $code ": twice  2 * ;" }
"This defines a new word named ``twice'' that calls ``2 *''. Try the following in the listener:"
{ $code "3 twice twice ." }
"The result is the same as if you wrote:"
{ $code "3 2 * 2 * ." } ;

ARTICLE: "tutorial-stack-effects" "Stack effects"
"When we look at the definition of the ``twice'' word, it is intuitively obvious that it takes one value from the stack, and leaves one value behind. However, with more complex definitions, it is better to document this so-called ``stack effect''."
"A stack effect comment is written between ( and ). Factor ignores stack effect comments. Don't you!"
"The stack effect of twice is ( x -- 2*x )."
"The stack effect of + is ( x y -- x+y )."
"The stack effect of . is ( object -- )." ;

ARTICLE: "tutorial-input" "Reading user input"
"User input is read using the readln ( -- string ) word. Note its stack effect; it puts a string on the stack."
"This program will ask your name, then greet you:"
{ $code "\"What is your name?\" print\nreadln \"Hello, \" write print" } ;

ARTICLE: "tutorial-shuffle" "Shuffle words"
"The word ``twice'' we defined is useless. Let's try something more useful: squaring a number."
"We want a word with stack effect ( n -- n*n ). We cannot use * by itself, since its stack effect is ( x y -- x*y ); it expects two inputs."
"However, we can use the word ``dup''. It has stack effect ( object -- object object ), and it does exactly what we need. The ``dup'' word is known as a shuffle word." ;

ARTICLE: "tutorial-squared" "The squared word"
"Try entering the following word definition:"
{ $code ": square ( n -- n*n ) dup * ;" }
"Shuffle words solve the problem where we need to compose two words, but their stack effects do not ``fit''."
"Some of the most commonly-used shuffle words:"
{ $code "drop ( object -- )\nswap ( obj1 obj2 -- obj2 obj1 )\nover ( obj1 obj2 -- obj1 obj2 obj1 )" } ;

ARTICLE: "tutorial-shuffle-again" "Another shuffle example"
"Now let us write a word that negates a number."
"Start by entering the following in the listener"
{ $code "0 10 - ." }
"It will print -10, as expected. Now notice that this the same as:"
{ $code "10 0 swap - ." }
"So indeed, we can factor out the definition ``0 swap -'':"
{ $code ": negate ( n -- -n ) 0 swap - ;" } ;

ARTICLE: "tutorial-see" "Seeing words"
"If you have entered every definition in this tutorial, you will now have several new colon definitions:"
{ $code "twice\nsquare\nnegate" }
"You can look at previously-entered word definitions using 'see'. Try the following:"
{ $code "\\ negate see" }
"Prefixing a word with \\ pushes it on the stack, instead of executing it. So the see word has stack effect ( word -- )." ;

ARTICLE: "tutorial-branches" "Branches"
"Now suppose we want to write a word that computes the absolute value of a number; that is, if it is less than 0, the number will be negated to yield a positive result."
{ $code ": absolute ( x -- |x| ) dup 0 < [ negate ] when ;" }
"If the top of the stack is negative, the word negates it again, making it positive. The < ( x y -- x<y ) word outputs a boolean. In Factor, any object can be used as a truth value."
"- The f object is false."
"- Anything else is true."
"Another commonly-used form is 'unless':"
{ $code "  ... condition ... [ ... false case ... ] unless" }
"The 'if' conditional takes action on both branches:"
{ $code "  ... condition ... [ ... ] [ ... ] if" } ;

ARTICLE: "tutorial-combinators" "Combinators"
"if, when, unless are words that take lists of code as input."
"Lists of code are called ``quotations''. Words that take quotations are called ``combinators''."
"Another combinator is times ( n quot -- ). It calls a quotation n times."
"Try this:"
{ $code "10 [ \"Hello combinators\" print ] times" } ;

ARTICLE: "tutorial-sequences" "Sequences"
"You have already seen strings, very briefly:"
"  \"Hello world\""
"Strings are part of a class of objects called sequences. Two other types of sequences you will use a lot are:"
"Lists: [ 1 3 \"hi\" 10 2 ]"
"Arrays: { \"the\" { \"quick\" \"brown\" } \"fox\" }"
"As you can see in the second example, lists and arrays can contain any type of object, including other lists and arrays." ;

ARTICLE: "tutorial-seq-combinators" "Sequences and combinators"
"A very useful combinator is each ( seq quot -- ). It calls a quotation with each element of the sequence in turn."
"Try this:"
{ $code "{ 10 20 30 } [ . ] each" }
"A closely-related combinator is map ( seq quot -- seq ). It also calls a quotation with each element."
"However, it then collects the outputs of the quotation into a new sequence."
"Try this:"
{ $code "{ 10 20 30 } [ 3 + ] map ." } ;

ARTICLE: "tutorial-rationals" "Numbers - integers and ratios"
"Factor supports arbitrary-precision integers and ratios."
"Try the following:"
{ $code ": factorial ( n -- n! ) 1 swap <range> product ;\n100 factorial .\n1 3 / 1 2 / + ." }
"Rational numbers are added, multiplied and reduced to lowest terms in the same way you learned in grade school." ;

ARTICLE: "tutorial-oop" "Object oriented programming"
"Each object belongs to a class. Generic words act differently based on an object's class."
{ $code "GENERIC: describe ( object -- )\nM: integer describe \"The integer \" write . ;\nM: string describe \"The string \" write . ;\nM: object describe drop \"Unknown object\" print ;" }
"Each M: line defines a ``method.'' Method definitions may appear in independent source files. Examples of built-in classes are integer, string, and object." ;

ARTICLE: "tutorial-classes" "Defining new classes"
"New classes can be defined:"
{ $code "TUPLE: point x y ;\nM: point describe\n  \"x =\" write dup point-x .\n  \"y =\" write point-y . ;\n100 200 <point> describe" }
"A tuple is a collection of named slots. Tuples support custom constructors, delegation... see the developer's handbook for details." ;

ARTICLE: "tutorial-library" "The library"
"Offers a good selection of highly-reusable words:"
"- Operations on sequences"
"- Variety of mathematical functions"
"- Web server and web application framework"
"- Graphical user interface framework"
"Browsing the library:"
"- To list all vocabularies:"
{ $code "vocabs." }
"- To list all words in a vocabulary:"
{ $code "\"sequences\" words." }
"- To show a word definition:"
{ $code "\\ reverse see" } ;

ARTICLE: "tutorial-more" "Learning more"
"Hopefully this tutorial has sparked your interest in Factor."
"You can learn more by reading the Factor developer's handbook:"
{ $url "http://factorcode.org/handbook.pdf" }
"Also, point your IRC client to irc.freenode.net and hop in the #concatenative channel to chat with other Factor geeks." ;

ARTICLE: "tutorial" "Factor tutorial"
"Welcome to the Factor tutorial!"
"Factor is interactive, which means you can test out the code in this tutorial immediately."
"Code examples will insert themselves in the listener's input area when clicked:"
{ $code "\"hello world\" print" }
"You can then press ENTER to execute the code, or edit it first."
{ $url "http://factorcode.org" }
{ $subsection "tutorial-overview" }
{ $subsection "tutorial-syntax" }
{ $subsection "tutorial-stack" }
{ $subsection "tutorial-postfix" }
{ $subsection "tutorial-colon-def" }
{ $subsection "tutorial-stack-effects" }
{ $subsection "tutorial-input" }
{ $subsection "tutorial-shuffle" }
{ $subsection "tutorial-squared" }
{ $subsection "tutorial-shuffle-again" }
{ $subsection "tutorial-see" }
{ $subsection "tutorial-branches" }
{ $subsection "tutorial-combinators" }
{ $subsection "tutorial-sequences" }
{ $subsection "tutorial-seq-combinators" }
{ $subsection "tutorial-rationals" }
{ $subsection "tutorial-oop" }
{ $subsection "tutorial-classes" }
{ $subsection "tutorial-library" }
{ $subsection "tutorial-more" } ;

: tutorial "tutorial" help ;

: <tutorial-button>
    "Factor tutorial" "tutorial" <link> simple-object terpri ;
