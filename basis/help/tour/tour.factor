! Copyright (C) 2022 Raghu Ranganathan and Andrea Ferreti.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types arrays assocs command-line continuations
editors help help.markup help.syntax help.vocabs inspector io
io.directories io.files io.files.types kernel lexer math
math.factorials math.functions math.primes memory namespaces
parser prettyprint ranges see sequences stack-checker strings
threads tools.crossref tools.test tools.time ui.gadgets.panes
ui.tools.deploy vocabs vocabs.loader vocabs.refresh words
io.servers http io.sockets io.launcher channels 
concurrency.distributed channels.remote help.cookbook
splitting.private ;
IN: help.tour

ARTICLE: "tour-concatenative" "Concatenative Languages"
Factor is a { $emphasis concatenative } programming language in the spirit of Forth. What is a concatenative language?

To understand concatenative programming, imagine a world where every value is a function, and the only operation
allowed is function composition. Since function composition is so pervasive, it is implicit, and functions can be 
juxtaposed in order to compose them. So if { $snippet "f" } and { $snippet "g" } are two functions, their composition is just { $snippet "f g" } (unlike in 
mathematical notation, functions are read from left to right, so this means first execute { $snippet "f" } , then execute { $snippet "g" } ).

This requires some explanation, since we know functions often have multiple inputs and outputs, and it is not always 
the case that the output of { $snippet "f" } matches the input of { $snippet "g" } . For instance, { $snippet "g" } may need access to values computed by earlier 
functions. But the only thing that { $snippet "g" } can see is the output of { $snippet "f" } , so the output of { $snippet "f" } is the whole state of the 
world as far as { $snippet "g" } is concerned. To make this work, functions have to thread the global state, passing it to each other.

There are various ways this global state can be encoded. The most naive would use a hashmap that maps variable names 
to their values. This turns out to be too flexible: if every function can access any piece of global state, there is 
little control on what functions can do, little encapsulation, and ultimately programs become an unstructured mess of 
routines mutating global variables.

It works well in practice to represent the state of the world as a stack. Functions can only refer to the topmost 
element of the stack, so that elements below it are effectively out of scope. If a few primitives are given to manipulate a 
few elements on the stack (e.g., { $link swap } , that exchanges the top two elements on the stack), then it becomes possible to 
refer to values down the stack, but the farther the value is down the stack, the harder it becomes to refer to it.

So, functions are encouraged to stay small and only refer to the top two or three elements on the stack. In a sense, 
there is no distinction between local and global variables, but values can be more or less local depending on their 
distance from the top of the stack.

Notice that if every function takes the state of the whole world and returns the next state, its input is never used 
anymore. So, even though it is convenient to think of pure functions as receiving a stack as input and outputting a stack,
the semantics of the language can be implemented more efficiently by mutating a single stack.
;

ARTICLE: "tour-stack" "Playing with the stack"

Let us start looking what Factor actually feels like. Our first words will be literals, like { $snippet "3" } , { $snippet "12.58" } or 
{ $snippet "\"Chuck Norris\"" } . Literals can be thought as functions that push themselves on the stack. Try writing { $snippet "5" } in the listener and 
then press enter to confirm. You will see that the stack, initially empty, now looks like

{ $code "5" }

You can enter more than one number, separated by spaces, like { $snippet "7 3 1" } , and get

{ $code "5
7
3
1"
}

(the interface shows the top of the stack on the bottom). What about operations? If you write { $snippet "+" } , you will run the 
{ $snippet "+" } function, which pops the two topmost elements and pushes their sum, leaving us with
{ $code "5
7
4"
}
You can put additional inputs in a single line, so for instance { $snippet "- *" } will leave the single number { $snippet "15" } on the stack (do you see why?).

You may end up pushing many values to the stack, or end up with an incorrect result. You can then clear the stack with the
keystroke { $snippet "Alt+Shift+K" } on Linux/Windows or { $snippet "Cmd+Shift+K" } on MacOS.

The function { $snippet "." } (a period or a dot) prints the item at the top of the stack, while popping it out of the stack, leaving the stack empty.

If we write everything on one line, our program so far looks like

{ $code "5 7 3 1 + - * ." }

which shows Factor's peculiar way of doing arithmetic by putting the arguments first and the operator last - a 
convention which is called Reverse Polish Notation (RPN). Notice that 
RPN requires no parenthesis, unlike the polish notation of Lisps where 
the operator comes first, and RPN requires no precedence rules, unlike the infix notation
used in most programming languages and in everyday arithmetic. For instance in any Lisp, the same 
computation would be written as

{ $code "(* 5 (- 7 (+ 3 1)))" }

and in familiar infix notation

{ $code "(7 - (3 + 1)) * 5" }

Also notice that we have been able to split our computation onto many lines or combine it onto fewer lines rather arbitrarily, and that each line made sense in itself.
;

ARTICLE: "tour-first-word" "Defining our first word"

We will now define our first function. Factor has slightly odd naming of functions: since functions are read from left 
to right, they are simply called { $strong "words" } , and this is what we'll call them from now on. Modules in Factor define 
words in terms of previous words and these sets of words are then called { $strong "vocabularies" } .

Suppose we want to compute the factorial. To start with a concrete example, we'll compute the factorial of { $snippet "10" }
, so we start by writing { $snippet "10" }  on the stack. Now, the factorial is the product of the numbers from { 
$snippet "1" }  to { $snippet "10" } , so we should produce such a list of numbers first.

The word to produce a range is called { $link [a..b] }  (tokenization is trivial in Factor because words are 
always separated by spaces, so this allows you to use any combination of non-whitespace characters as the name of a word; 
there are no semantics to the { $snippet "[" } , the { $snippet ".." }  and the { $snippet "]" }  in { $link [a..b] }  
since it is just a token like { $snippet "foo" }  or { $snippet "bar" } ).

The range we want starts with { $snippet "1" } , so we can use the simpler word { $link [1..b] }  that assumes the 
range starts at { $snippet "1" }  and only expects the value at the top of the range to be on the stack. If you write { 
$link [1..b] }  in the listener, Factor will prompt you with a choice, because the word { $link [1..b] }  is 
not imported by default. Factor is able to suggest you import the { $vocab-link "ranges" }  vocabulary, so choose that 
option and proceed.

You should now have on your stack a rather opaque structure which looks like

{ $code "T{ range f 1 10 1 }" }

This is because our range functions are lazy and only create the range when we attempt to use it. To confirm that we 
actually created the list of numbers from { $snippet "1" }  to { $snippet "10" } , we convert the lazy response on the 
stack into an array using the word { $link >array } . Enter that word and your stack should now look like

{ $code "{ 1 2 3 4 5 6 7 8 9 10 }" }

which is promising!

Next, we want to take the product of those numbers. In many functional languages, this could be done with a function 
called reduce or fold. Let's look for one. Pressing { $snippet "F1" }  in the listener will open a contextual help system
, where you can search for { $link reduce } . It turns out that { $link reduce }  is actually the word we are 
looking for, but at this point it may not be obvious how to use it.

Try writing { $snippet "1 [ * ] reduce" }  and look at the output: it is indeed the factorial of { $snippet "10" } . 
Now, { $link reduce }  usually takes three arguments: a sequence (and we had one on the stack), a starting value i
(this is the { $snippet "1" }  we put on the stack next) and a binary operation. This must certainly be the { $link * } 
, but what about those square brackets around the { $link * } ?

If we had written just { $link * } , Factor would have tried to apply multiplication to the topmost two elements 
on the stack, which is not what we wanted. What we need is a way to get a word onto the stack without applying it. 
Keeping to our textual metaphor, this mechanism is called a { $strong "quotation" } . To quote one or more words, you just surround them 
with { $link POSTPONE: [ }  and { $link POSTPONE: ] }  (leaving spaces!). What you get is an anonymous function, which can be
shuffled around, manipulated and called.

Let's type the word { $link drop }  into the listener to empty the stack, and try writing what we have done so 
far in a single line: { $snippet "10 [1..b] 1 [ * ] reduce" } . This will leave { $snippet "3628800" }  on the stack as 
expected.

We now want to define a word for factorial that can be used whenever we want a factorial. We will call our word { $snippet "fact" }
"(" although { $snippet "!" }  is customarily used as the symbol for factorial, in Factor { $snippet "!" }  
is the word used for comments ")" . To define it, we first need to use the word { $link POSTPONE: : } . Then we put the name of 
the word being defined, then the { $strong "stack effects" }  and finally the body, ending with the { $link POSTPONE: ; }  word:

{ $code ": fact ( n -- n! ) [1..b] 1 [ * ] reduce ;" }

What is a stack effect? In our case it is { $snippet "( n -- n! )" } . Stack effects are how you document the 
inputs from the stack and outputs to the stack for your word. You can use any identifier to name the stack elements, here we 
use { $snippet "n" } . Factor will perform a consistency check that the number of inputs and outputs you specify agrees 
with what the body does.

If you try to write

{ $code ": fact ( m n -- ..b ) [1..b] 1 [ * ] reduce ;" }

Factor will signal an error that the 2 inputs { $snippet "m" }  and { $snippet "n" } are not consistent with the 
body of the word. To restore the previous correct definition press { $snippet "Ctrl+P" }  two times to get back to the 
previous input and then enter it.

The stack effects in definitions  act both as a documentation tool and as a very simple type system, which helps to catch a few errors.

In any case, you have succesfully defined your first word: if you write { $snippet "10 fact" }  in the listener you 
can prove it.

Notice that the { $snippet "1 [ * ] reduce" }  part of the definition sort of makes sense on its own, being the product of a sequence. The nice thing about a concatenative language is that we can just factor this part out and write

{ $code ": prod ( {x1,...,xn} -- x1*...*xn ) 1 [ * ] reduce ;

: fact ( n -- n! ) [1..b] prod ;" }

Our definitions have become simpler and there was no need to pass parameters, rename local variables, or do anything 
else that would have been necessary to refactor our function in most languages.

Of course, Factor already has a word for calculating factorial (there is a whole { $vocab-link "math.factorials" }  
vocabulary, including many variants of the usual factorial) and a word for calculating product " (" { $link product }  in the 
{ $vocab-link "sequences" }  vocabulary), but as it often happens, introductory examples overlap with the standard library.
;

ARTICLE: "tour-parsing-words" "Parsing Words"
If you've been paying close attention so far, you will realize that you have been lied to. { $emphasis "Most" } words act on the stack in order
, but there a few words like { $link POSTPONE: [ } , { $link POSTPONE: ] } , { $link POSTPONE: : } and { $link POSTPONE: ; } that don't seem to follow this rule.

These are { $strong "parsing words" }  and they behave differently from ordinary words like { $snippet "5" } , { $link [1..b] } or { $link drop } . We will cover 
these in more detail when we talk about metaprogramming, but for now it is enough to know that parsing words are special.

They are not defined using the { $link POSTPONE: : } word, but with the word { $link POSTPONE: SYNTAX: } instead. When a parsing words is encountered, it 
can interact with the parser using a well-defined API to influence how successive words are parsed. For instance { $link POSTPONE: : } 
asks for the next token from the parser until { $link POSTPONE: ; } is found and tries to compile that stream of tokens into a word 
definition.

A common use of parsing words is to define literals. For instance { $link POSTPONE: { } is a parsing word that starts an array 
definition and is terminated by { $link POSTPONE: } } . Everything in-between is part of the array. An example of array that we have seen before is 
{ $snippet "{ 1 2 3 4 5 6 7 8 9 10 } " } .

There are also literals for hashmaps, { $snippet "H{ { \"Perl\" \"Larry Wall\" } { \"Factor\" \"Slava Pestov\" } { \"Scala\" \"Martin Odersky\" } } " }
, and byte arrays, { $snippet "B{ 1 14 18 23 } " } .

Other uses of parsing words include the module system, the object-oriented features of Factor, enums, memoized functions
, privacy modifiers and more. In theory, even { $link POSTPONE: SYNTAX: } can be defined in terms of itself, but the 
system has to be bootstrapped somehow.

;

ARTICLE: "tour-stack-shuffling" "Stack Shuffling"
Now that you know the basics of Factor, you may want to start assembling more complex words. This may sometimes 
require you to use variables that are not on top of the stack, or to use variables more than once. There are a few words that 
can be used to help with this. I mention them now since you need to be aware of them, but I warn you that using too many 
of these words to manipulate the stack will cause your code to quickly become harder to read and write. Stack shuffling 
requires mentally simulating moving values on a stack, which is not a natural way to program. In the next section we'll 
see a much more effective way to handle most needs.

Here is a list of the most common shuffling words together with their effect on the stack. Try them in the listener to 
get a feel for how they manipulate the stack.

{ $subsections
  dup
  drop
  swap
  over
  dupd
  swapd
  nip
  rot
  -rot
  2dup
}

For a deeper look at stack shuffling, see the { $link "cookbook-colon-defs" } .
;

ARTICLE: "tour-combinators" "Combinators"

Although the words mentioned in the previous paragraph are occasionally useful (especially the simpler { $link dup } , { $link drop }  
and { $link swap } ), you should write code that does as little stack shuffling as possible. This requires practice getting the 
function arguments in the right order. Nevertheless, there are certain common patterns of needed stack manipulation that 
are better abstracted away into their own words.

Suppose we want to define a word to determine whether a given number { $snippet "n" }  is prime. A simple algorithm is to test each 
number from { $snippet "2" }  to the square root of { $snippet "n" }  and see whether it is a divisor of { $snippet "n" } . In this case, { $snippet "n" }  is used in two places: as an upper bound for the sequence, and as the number to test for divisibility.

The word { $link bi }  applies two different quotations to the single element on the stack above them, and this is precisely 
what we need. For instance { $snippet "5 [ 2 * ] [ 3 + ] bi" }  yields
{ $code "
10
8
" }

{ $link bi }  applies the quotation { $snippet "[ 2 * ]" }  to the value { $snippet "5" }  and then the quotation { $snippet "[ 3 + ]" }  to the value { $snippet "5" }  leaving us 
with { $snippet "10" }  and then { $snippet "8" }  on the stack. Without { $link bi } , we would have to first { $link dup }  { $snippet "5" } , then multiply, and then { $link swap }  the 
result of the multiplication with the second { $snippet "5" } , so we could do the addition

{ $code "
5 dup 2 * swap 3 +
" }

You can see that { $link bi }  replaces a common pattern of { $link dup } , then calculate, then { $link swap }  and calculate again.

To continue our prime example, we need a way to make a range starting from { $snippet "2" } . We can define our own word for this { $snippet "[2..b]" } , using the { $link [a..b] } word:

{ $code "
: [2..b] ( n -- {2,...,n} ) 2 swap [a..b] ; inline
" }

What's up with that { $snippet "inline" }  word? This is one of the modifiers we can use after defining a word, another one being 
{ $snippet "recursive" } . This will allow us to have the definition of a short word inlined wherever it is used, rather than incurring 
a function call.

Try our new { $snippet "[2..b]" }  word and see that it works:

{ $code "
6 [2..b] >array .
" }

Using { $snippet "[2..b]" }  to produce the range of numbers from { $snippet "2" }  to the square root of an { $snippet "n" }  that is already on the stack is 
easy: { $snippet "sqrt floor [2..b]" }  (technically { $link floor }  isn't necessary here, as { $link [a..b] }  works for non-integer bounds). Let's try 
that out

{ $code "
16 sqrt [2..b] >array .
" }

Now, we need a word to test for divisibility. A quick search in the online help shows that { $link divisor? }  is the word we 
want. It will help to have the arguments for testing divisibility in the other direction, so we define { $snippet "multiple?" } ":"

{ $code "
: multiple? ( a b -- ? ) swap divisor? ; inline
" }

We can verify that both of these return { $link t } .

{ $code "
9 3 divisor? .
3 9 multiple? .
" }

Since we're going to use { $link bi } in our { $snippet "prime?" }  definition, we need a second quotation. Our second 
quotation needs to test for a value in the range being a divisor of { $snippet "n" }  - in other words we need to partially apply the word  { $snippet "multiple?" } . This can be done with the word { $link curry } , like this: { $snippet "[ multiple? ] curry" } .

Finally, once we have the range of potential divisors and the test function on the stack, we can test whether any 
element satisfied divisibility with { $link any? }  and then negate that answer with { $link not } . Our full definition of { $snippet "prime" }  looks like

{ $code "
: prime? ( n -- ? )
    [ sqrt [2..b] ] [ [ multiple? ] curry ] bi any? not ;
" }

Altough the definition of { $snippet "prime" }  is complicated, the stack shuffling is minimal and is only used in the small helper 
functions, which are simpler to reason about than { $snippet "prime?" } .

Notice that { $snippet "prime?" }  uses two levels of quotation nesting since { $link bi }  operates on two quotations, and our second 
quotation contains the word { $link curry } , which also operates on a quotation. In general, Factor words tend to be rather shallow, 
using one level of nesting for each higher-order function, unlike Lisps or more generally languages based on the lambda 
calculus, which use one level of nesting for each function, higher-order or not.

{ $link bi } and its relative { $link tri } are a small subset of the shuffle words you will use in Factor. You should also become familiar with 
{ $link bi } , { $link tri } , and { $link bi@ } by reading about them in the online help and trying them out in the listener.

;

ARTICLE: "tour-vocabularies" "Vocabularies"

It is now time to start writing your functions in files and learn how to import them in the listener. Factor organizes 
words into nested namespaces called { $strong "vocabularies" } . You can import all names from a vocabulary with the word { $link POSTPONE: USE: } . 
In fact, you may have seen something like

{ $code "USE: ranges" }

when you asked the listener to import the word { $link [1..b] } for you. You can also use more than one vocabulary at a time 
with the word { $link  POSTPONE: USING: } , which is followed by a list of vocabularies and terminated by { $link POSTPONE: ; } , like

{ $code "USING: ranges sequences ;" }

Finally, you define the vocabulary where your definitions are stored with the word { $link POSTPONE: IN: } . If you search the online 
help for a word you have defined so far, like { $link prime? } , you will see that your definitions have been grouped under the 
default { $vocab-link "scratchpad" } vocabulary. By the way, this shows that the online help automatically collects information about your 
own words, which is a very useful feature.

There are a few more words, like { $link POSTPONE: QUALIFIED: } , { $link POSTPONE: FROM: } , { $link POSTPONE: EXCLUDE: } and { $link POSTPONE: RENAME: } , that allow more fine-grained control 
over the imports, but { $link POSTPONE: USING: } is the most common.

On disk, vocabularies are stored under a few root directories, much like with the classpath in JVM languages. By 
default, the system starts looking up into the directories { $snippet "basis" } , { $snippet "core" } , { $snippet "extra" } , { $snippet "work" } under the Factor home. You can 
add more, both at runtime with the word { $link add-vocab-root } , and by creating a configuration file { $snippet ".factor-rc" } , but for now 
we will store our vocabularies under the { $snippet "work" } directory, which is reserved for the user.

Generate a template for a vocabulary writing

{ $code "USE: tools.scaffold
\"github.tutorial\" scaffold-work" }

You will find a file { $snippet "work/github/tutorial/tutorial.factor" } containing an empty vocabulary. Factor integrates with 
many editors, so you can try { $snippet "\"github.tutorial\" edit" } ": " this will prompt you to choose your favourite editor, and use that 
editor to open the newly created vocabulary.

You can add the definitions of the previous paragraph, so that it looks like

{ $code "
! Copyright (C) 2014 Andrea Ferretti.
! See https://factorcode.org/license.txt for BSD license.
USING: ;
IN: github.tutorial

: [2..b] ( n -- {2,...,n} ) 2 swap [a..b] ; inline

: multiple? ( a b -- ? ) swap divisor? ; inline

: prime? ( n -- ? )
    [ sqrt [2..b] ] [ [ multiple? ] curry ] bi any? not ;
" }

Since the vocabulary was already loaded when you scaffolded it, we need a way to refresh it from disk. You can do this 
with { $snippet "\"github.tutorial\" refresh" } . There is also a { $link refresh-all } word, with a shortcut { $snippet "F2" } .

You will be prompted a few times to use vocabularies, since your { $link POSTPONE: USING: } statement is empty. After having accepted 
all of them, Factor suggests you a new header with all the needed imports:

{ $code "
USING: kernel math.functions ranges sequences ;
IN: github.tutorial
" }

Now that you have some words in your vocabulary, you can edit, say, the { $snippet "multiple?" } word with { $snippet "\\ multiple? edit" } . You 
will find your editor open on the relevant line of the right file. This also works for words in the Factor distribution, 
although it may be a bad idea to modify them.

This { $link POSTPONE: \ } word requires a little explanation. It works like a sort of escape, allowing us to put a reference to the 
next word on the stack, without executing it. This is exactly what we need, because { $link edit } is a word that takes words 
themselves as arguments. This mechanism is similar to quotations, but while a quotation creates a new anonymous function, 
here we are directly refering to the word { $snippet "multiple?" } .

Back to our task, you may notice that the words { $snippet "[2..b]" } and { $snippet "multiple?" } are just helper functions that you may not 
want to expose directly. To hide them from view, you can wrap them in a private block like this

{ $code "
<PRIVATE

: [2..b] ( n -- {2,...,n} ) 2 swap [a..b] ; inline

: multiple? ( a b -- ? ) swap divisor? ; inline

PRIVATE>
" }

After making this change and refreshed the vocabulary, you will see that the listener is not able to refer to words 
like { $snippet "[2..b]" } anymore. The { $link POSTPONE: <PRIVATE } word works by putting all definitions in the private block under a different 
vocabulary, in our case { $snippet "github.tutorial.private" } .

You can have more than one { $link POSTPONE: <PRIVATE } block in a vocabulary, so feel free to organize them as you find necessary.

It is still possible to refer to words in private vocabularies, as you can confirm by searching for { $snippet "[2..b]" } in the 
browser, but of course this is discouraged, since people do not guarantee any API stability for private words. Words 
under { $snippet "github.tutorial" } can refer to words in { $snippet "github.tutorial.private" } directly, like { $link prime? } does.

;

ARTICLE: "tour-tests-docs" "Tests and Documentation"

This is a good time to start writing some unit tests. You can create a skeleton with
{ $code "
\"github.tutorial\" scaffold-tests
" }
You will find a generated file under { $snippet "work/github/tutorial/tutorial-tests.factor" } , that you can open with 
{ $snippet "\"github.tutorial\" edit-tests" } . Notice the line

{ $code "
USING: tools.test github.tutorial ;
" }
that imports the unit testing module as well as your own. We will only test the public { $snippet "prime?" }  function.

Tests are written using the { $link POSTPONE: unit-test }  word, which expects two quotations: the first one containing the expected 
outputs, and the second one containing the words to run in order to get that output. Add these lines to 
{ $snippet "github.tutorial-tests" } ":"

{ $code "
{ t } [ 2 prime? ] unit-test
{ t } [ 13 prime? ] unit-test
{ t } [ 29 prime? ] unit-test
{ f } [ 15 prime? ] unit-test
{ f } [ 377 prime? ] unit-test
{ f } [ 1 prime? ] unit-test
{ t } [ 20750750228539 prime? ] unit-test
" }

You can now run the tests with { $snippet "\"github.tutorial\" test" } . You will see that we have actually made a mistake, and 
pressing { $snippet "F3" }  will show more details. It seems that our assertions fails for { $snippet "2" } .

In fact, if you manually try to run our functions for { $snippet "2" } , you will see that our definition of { $snippet "[2..b]" }  returns { $snippet "{ 2 }" }  
for { $snippet "2 sqrt" } , due to the fact that the square root of two is less than two, so we get a descending interval. Try making a 
fix so that the tests now pass.

There are a few more words to test errors and inference of stack effects. Using { $link POSTPONE: unit-test }  suffices for now, but later on 
you may want to check the main documentation on { $link "tools.test" } .

We can also add some documentation to our vocabulary. Autogenerated documentation is always available for user-defined 
words (even in the listener), but we can write some useful comments manually, or even add custom articles that will 
appear in the online help. Predictably, we start with { $snippet "\"github.tutorial\" scaffold-docs" }  and 
{ $snippet "\"github.tutorial\" edit-docs" } .

The generated file { $snippet "work/github/tutorial-docs.factor" }  imports { $vocab-link "help.markup" } and { $vocab-link "help.syntax" } . These two vocabularies 
define words to generate documentation. The actual help page is generated by the { $link POSTPONE: HELP: }  parsing word.

The arguments to { $link POSTPONE: HELP: }  are nested array of the form { $snippet "{ $directive content... }" } . In particular, you see here the 
directives { $link $values } and { $link $description } , but a few more exist, such as { $link $errors } , { $link $examples }  and { $link $see-also } .

Notice that the type of the output { $snippet "?" }  has been inferred to be boolean. Change the first lines to look like

{ $code "
USING: help.markup help.syntax kernel math ;
IN: github.tutorial

HELP: prime?
{ $values
    { \"n\" fixnum }
    { \"?\" boolean }
}
{ $description \"Tests if n is prime. n is assumed to be a positive integer.\" } ;
" }

and refresh the { $snippet "github.tutorial" }  vocabulary. If you now look at the help for { $snippet "prime?" } , for instance with 
{ $snippet "\\ prime? help" } , you will see the updated documentation.

You can also render the directives in the listener for quicker feedback. For instance, try writing

{ $code "
{ $values
    { \"n\" integer }
    { \"?\" boolean }
} print-content
" }

The help markup contains a lot of possible directives, and you can use them to write stand-alone articles in the help 
system. Have a look at some more with { $snippet "\"element-types\" help" } .
;

ARTICLE: "tour-objects" "The Object System"

Although it is not apparent from what we have said so far, Factor has object-oriented features, and many core words 
are actually method invocations. To better understand how objects behave in Factor, a quote is in order:
$nl
{ $emphasis "\"I invented the term Object-Oriented and I can tell you I did not have C++ in mind.\"
  -Alan Kay" }
$nl
The term object-oriented has as many different meanings as people using it. One point of view - which was actually 
central to the work of Alan Kay - is that it is about late binding of function names. In Smalltalk, the language where this 
concept was born, people do not talk about calling a method, but rather sending a message to an object. It is up to the 
object to decide how to respond to this message, and the caller should not know about the implementation. For instance, 
one can send the message { $link map } both to an array and a vector, but internally the operation will be handled 
differently.

The binding of the message name to the method implementation is dynamic, and this is regarded as the core strength of 
objects. As a result, fairly complex systems can evolve from the cooperation of independent objects that do not mess with 
each other's internals.

To be fair, Factor is very different from Smalltalk, but still there is the concept of classes, and generic words can 
defined having different implementations on different classes.

Some classes are builtin in Factor, such as { $link string } , { $link boolean } , { $link fixnum } or { $link word } . Next, the most common way to 
define a class is as a { $strong "tuple" } . Tuples are defined with the { $link POSTPONE: TUPLE: } parsing word, followed by the tuple name and the 
fields of the class that we want to define, which are called { $strong "slots" }  in Factor parlance.

Let us define a class for movies:

{ $code "
TUPLE: movie title director actors ;
" }

This also generates setters { $snippet ">>title" } , { $snippet ">>director" } and { $snippet ">>actors" } and getters { $snippet "title>>" } , { $snippet "director>>" } and { $snippet "actors>>" } . 
For instance, we can create a new movie with

{ $code "
movie new
    \"The prestige\" >>title
    \"Christopher Nolan\" >>director
    { \"Hugh Jackman\" \"Christian Bale\" \"Scarlett Johansson\" } >>actors
" }

We can also shorten this to

{ $code "
\"The prestige\" \"Christopher Nolan\"
{ \"Hugh Jackman\" \"Christian Bale\" \"Scarlett Johansson\" }
movie boa
" }

The word { $link boa } stands for 'by-order-of-arguments'. It is a constructor that fills the slots of the tuple with the 
items on the stack in order. { $snippet "movie boa" } is called a { $strong "boa constructor" } , a pun on the Boa Constrictor. It is customary to 
define a most common constructor called { $snippet "<movie>" } , which in our case could be simply

{ $code "
: <movie> ( title director actors -- movie ) movie boa ;
" }
In fact, boa constructor are so common, that the above line can be shortened to

{ $code "
C: <movie> movie
" }

In other cases, you may want to use some defaults, or compute some fields.

The functional minded will be worried about the mutability of tuples. Actually, slots can be declared to be " read-only "
with { $snippet "{ slot-name read-only } " } . In this case, the field setter will not be generated, and the value must be set a the 
beginning with a boa constructor. Other valid slot modifiers are { $link POSTPONE: initial: } - to declare a default value - and a class word
, such as { $snippet "integer" } , to restrict the values that can be inserted.

As an example, we define another tuple class for rock bands

{ $code "
TUPLE: band
    { keyboards string read-only }
    { guitar string read-only }
    { bass string read-only }
    { drums string read-only } ;

: <band> ( keyboards guitar bass drums -- band ) band boa ;
" }

together with one instance

{ $code "
\"Richard Wright\" \"David Gilmour\" \"Roger Waters\" \"Nick Mason\" <band>
" }

Now, of course everyone knows that the star in a movie is the first actor, while in a rock band it is the bass player. 
To encode this, we first define a { $strong "generic word" } 

{ $code "
GENERIC: star ( item -- star )
" }

As you can see, it is declared with the parsing word { $link POSTPONE: GENERIC: } and declares its stack effects but it has no 
implementation right now, hence no need for the closing { $link POSTPONE: ; } . Generic words are used to perform dynamic dispatch. We can define 
implementations for various classes using the word { $link POSTPONE: M: }

{ $code "
M: movie star actors>> first ;

M: band star bass>> ;
" }

If you write { $snippet "star ." } two times, you can see the different effect of calling a generic word on instances of different 
classes.

Builtin and tuple classes are not all that there is to the object system: more classes can be defined with set 
operations like { $link POSTPONE: UNION: } and { $link POSTPONE: INTERSECTION: } . Another way to define a class is as a { $strong "mixin" } .

Mixins are defined with the { $link POSTPONE: MIXIN: } word, and existing classes can be added to the mixin like so:

{ $code "
INSTANCE: class mixin
" }

Methods defined on the mixin will then be available on all classes that belong to the mixin. If you are familiar with 
Haskell typeclasses, you will recognize a resemblance, although Haskell enforces at compile time that instance of 
typeclasses implement certain functions, while in Factor this is informally specified in documentation.

Two important examples of mixins are { $link sequence } and { $link assoc } . The former defines a protocol that is available to all 
concrete sequences, such as strings, linked lists or arrays, while the latter defines a protocol for associative arrays, 
such as hashtables or association lists.

This enables all sequences in Factor to be acted upon with a common set of words, while differing in implementation 
and minimizing code repetition (because only few primitives are needed, and other operations are defined for the { $link sequence }
 class). The most common operations you will use on sequences are { $link map } , { $link filter } and { $link reduce } , but there are many more 
- as you can see with { $snippet "\"sequences\" help" } .
;

ARTICLE: "tour-tools" "Learning the Tools"

A big part of the productivity of Factor comes from the deep integration of the language and libraries with the tools around 
them, which are embodied in the listener. Many functions of the listener can be used programmatically, and vice versa.
You have seen some examples of this:

{ $list
  { "The help is navigable online, but you can also invoke it with " { $link help } " and print help items with " { $link print-content } " ; " }
  { "The " { $snippet "F2" } " shortcut or the words " { $link refresh } " and " { $link refresh-all } " can be used to refresh vocabularies from disk while continuing working in the listener;" }
  { "The " { $link edit } " word gives you editor integration, but you can also click on file names in the help pages for vocabularies to open them." }
}

The refresh is an efficient mechanism. Whenever a word is redefined, words that depend on it are recompiled against the new 
definition. You can check by yourself doing

{ $code "
: inc ( x -- y ) 1 + ;
: inc-print ( x -- ) inc . ;

5 inc-print
" }

and then

{ $code "
: inc ( x -- y ) 2 + ;

5 inc-print
" }

This allows you to keep a listener open, improve your definitions, periodically save your definitions to a file 
and refresh to view your changes, without ever having to reload Factor.

You can also save the state of your current session with the word { $link save-image } and later restore it by starting Factor with

{ $code "
./factor -i=path-to-image
" }

In fact, Factor is image-based and only uses files when loading and refreshing vocabularies.

The power of the listener does not end here. Elements of the stack can be inspected by clicking on them, or by calling the 
word { $link inspector } . For instance try writing

{ $code "
TUPLE: trilogy first second third ;

: <trilogy> ( first second third -- trilogy ) trilogy boa ;

\"A new hope\" \"The Empire strikes back\" \"Return of the Jedi\" <trilogy>
\"George Lucas\" 2array
" }

You will get an item that looks like

{ $code "
{ ~trilogy~ \"George Lucas\" }
" }

on the stack. Try clicking on it: you will be able to see the slots of the array. You can inspect a slot shown in the inspector by double clicking on it. This is extremely useful for interactive prototyping. Special objects can customize the inspector 
by implementing the { $link content-gadget } method.

There is another inspector for errors. Whenever an error arises, it can be inspected with { $snippet "F3" } . This allows you to investigate 
exceptions, bad stack effect declarations and so on. The debugger allows you to step into code, both forwards and 
backwards, and you should take a moment to get some familiarity with it. You can also trigger the debugger manually, by 
entering some code in the listener and pressing { $snippet "Ctrl+w" } .

The listener has provisions for benchmarking code. As an example, here is an intentionally inefficient Fibonacci:

{ $code "
DEFER: fib-rec
: fib ( n -- f(n) ) dup 2 < [ ] [ fib-rec ] if ;
: fib-rec ( n -- f(n) ) [ 1 - fib ] [ 2 - fib ] bi + ;
" }

(notice the use of { $link POSTPONE: DEFER: } to define two mutually " recursive " words). You can benchmark the running time writing { $snippet "40 fib" }  
and then pressing Ctrl+t instead of Enter. You will get timing information, as well as other statistics. Programmatically
, you can use the { $link time } word on a quotation to do the same.

You can also add watches on words, to print inputs and outputs on entry and exit. Try writing

{ $code "
\\ fib watch
" }

and then run { $snippet "10 fib" }  to see what happens. You can then remove the watch with { $snippet "\\ fib reset" } .

Another useful tool is the { $vocab-link "lint" }  vocabulary. This scans word definitions to find duplicated code that can be factored 
out. As an example, let us define a word to check if a string starts with another one. Create a test vocabulary

{ $code "
\"lintme\" scaffold-work
" }

and add the following definition:

{ $code "
USING: kernel sequences ;
IN: lintme

: startswith? ( str sub -- ? ) dup length swapd head = ;
" }

Load the lint tool with { $snippet "USE: lint" }  and write { $snippet "\"lintme\" lint-vocab" } . You will get a report mentioning that the word sequence 
{ $snippet "length swapd" }  is already used in the word { $link (split) } of { $vocab-link "splitting.private" } , hence it could be factored out.

Modifying the source of a word in the standard library is unadvisable - let alone a private one - but 
in more complex cases the lint tool can help you prevent code duplication. It is not unusual that Factor has a word that does exactly what you want, owing to its massive standard library. It is a good idea to lint your vocabularies from 
time to time, to avoid code duplication and as a good way to discover library words that you may have accidentally redefined
.

Finally, there are a few utilities to inspect words. You can see the definition of a word in the help tool, but a quicker 
way can be { $link see } . Or, vice versa, you may use { $link usage. } to inspect the callers of a given word. Try { $snippet "\\ reverse see" }  and 
{ $snippet "\\ reverse usage." } .
;

ARTICLE: "tour-metaprogramming" "Metaprogramming"

We now venture into the metaprogramming world, and write our first parsing word. By now, you have seen a lot of 
parsing words, such as { $link POSTPONE: [ } . { $link POSTPONE: { } , { $link POSTPONE: H{ } , { $link POSTPONE: USE: } , { $link POSTPONE: IN: } , { $link POSTPONE: <PRIVATE } , { $link POSTPONE: GENERIC: } and so on. Each of those is defined with the 
parsing word { $link POSTPONE: SYNTAX: } and interacts with Factor's parser.

The parser accumulates tokens onto an accumulator vector, unless it finds a parsing word, which is executed immediately.
 Since parsing words execute at compile time, they cannot interact with the stack, but they have access to the 
accumulator vector. Their stack effect must be { $snippet "( accum -- accum )" } . Usually what they do is ask the parser for some more tokens,
 do something with them, and finally push a result on the accumulator vector with the word { $snippet "suffix!" } .

As an example, we will define a literal for DNA sequences. A DNA sequence is a sequence of one of the bases cytosine, 
guanine, adenine and thymine, which we will denote by the letters c, g, a, t. Since there are four possible bases, we 
can encode each with two bits. Let use define a word that operates on characters:

{ $code "
: dna>bits ( token -- bits ) {
    { CHAR: a [ { f f } ] }
    { CHAR: c [ { t t } ] }
    { CHAR: g [ { f t } ] }
    { CHAR: t [ { t f } ] }
} case ;
" }

where the first bit represents whether the basis is a purine or a pyrimidine, and the second one identifies bases that 
pair together.

Our aim is to read a sequence of letters a, c, g, " t " - possibly with spaces - and convert them to a bit array. Factor 
supports bit arrays, and literal bit arrays look like { $snippet "?{ f f t }" } .

Our syntax for DNA will start with { $snippet "DNA{" } and get all tokens until the closing token { $snippet "}" } is found. The intermediate 
tokens will be put into a string, and using our function { $snippet "dna>bits" } we will map this string into a bit array. To read 
tokens, we will use the word { $link parse-tokens } . There are a few higher-level words to interact with the parser, such as { $link parse-until }
and { $link parse-literal } , but we cannot apply them in our case, since the tokens we will find are just sequences of a 
c g t, instead of valid Factor words. Let us start with a simple approximation that just reads tokens between our 
delimiters and outputs the string obtained by concatenation

{ $code "
SYNTAX: DNA{ \"}\" parse-tokens concat suffix! ;
" }

You can test the effect by doing { $snippet "DNA{ a ccg t a g }" } , which should output { $snippet "\"accgtag\"" } . As a second approximation, we 
transform each letter into a boolean pair:

{ $code "
SYNTAX: DNA{ \"}\" parse-tokens concat
    [ dna>bits ] { } map-as suffix! ;
" }

Notice the use of { $link map-as } instead of { $link map } . Since the target collection is not a string, we did not use { $link map } , which 
preserves the type, but { $link map-as } , which take as an additional argument an examplar of the target collection - here { $snippet "{ }" } .
Our " final " version flattens the array of pairs with { $link concat } and finally makes into a bit array:

{ $code "
SYNTAX: DNA{ \"}\" parse-tokens concat
    [ dna>bits ] { } map-as
    concat >bit-array suffix! ;
" }

If you try it with { $snippet "DNA{ a ccg t a g }" } you should get

{ $code "
{ $snippet \"?{ f f t t t t f t t f f f f t }\" }
" }

Let us try an example from the { $url
"https://re.factorcode.org/2014/06/swift-ranges.html" "Re: Factor" } blog,
which adds infix syntax for ranges. Until now, we have used { $link [a..b] } to create a range. We can make a 
syntax that is friendlier to people coming from other languages using { $snippet "..." } as an infix word.

We can use { $link scan-object } to ask the parser for the next parsed object, and { $link unclip-last } to get the top element from 
the accumulator vector. This way, we can define { $snippet "..." } simply with

{ $code "
SYNTAX: ... unclip-last scan-object [a..b] suffix! ;
" }

You can try it with { $snippet "12 ... 18 >array" } .

We only scratched the surface of parsing words; in general, they allow you to perform arbitrary computations at 
compile time, enabling powerful forms of metaprogramming.

In a sense, Factor syntax is completely flat, and parsing words allow you to introduce syntaxes more complex than a 
stream of tokens to be used locally. This lets any programmer expand the language by adding these syntactic features in libraries
. In principle, it would even be possible to have an external language compile to Factor -- say JavaScript -- and embed it 
as a domain-specific language in the boundaries of a { $snippet "<JS ... JS>" } parsing word. Some taste is needed not to abuse too much of 
this to introduce styles that are much too alien in the concatenative world.
;

ARTICLE: "tour-stack-ne" "When the stack is not enough"

Until now we have cheated a bit, and tried to avoid writing examples that would have been too complex to write in 
concatenative style. Truth is, you { $emphasis "will" } find occasions where this is too restrictive. Parsing words can ease some of these restrictions, and Factor comes with a few to handle the most common annoyances.

One thing you may want to do is to actually name local variables. The { $link POSTPONE: :: } word works like { $link POSTPONE: : } , but allows you to 
actually bind the name of stack parameters to variables, so that you can use them multiple times, in the order you want. For 
instance, let us define a word to solve quadratic equations. I will spare you the purely stack-based version, and 
present you a version with locals (this will require the { $vocab-link "locals" } vocabulary):

{ $code "
:: solveq ( a b c -- x )
    b neg
    b b * 4 a c * * - sqrt
    +
    2 a * / ;" }

In this case we have chosen the + sign, but we can do better and output both solutions:

{ $code "
:: solveq ( a b c -- x1 x2 )
    b neg
    b b * 4 a c * * - sqrt
    [ + ] [ - ] 2bi
    [ 2 a * / ] bi@ ;" }

You can check that this definition works with something like { $snippet "2 -16 30 solveq" } , which should output both { $snippet "3.0" } and { $snippet "5.0" } . 
Apart from being written in RPN style, our first version of { $snippet "solveq" } looks exactly the same it would in a language 
with local variables. For the second definition, we apply both the { $link + }  and { $link - }  operations to -b and delta, using the 
combinator { $link 2bi } , and then divide both results by 2a using { $link bi@ } .

There is also support for locals in quotations - using { $link POSTPONE: [| } - and methods - using { $link POSTPONE: M:: } - and one can also create a 
scope where to bind local variables outside definitions using { $link POSTPONE: [let } . Of course, all of these are actually compiled to 
concatenative code with some stack shuffling. I encourage you to browse examples for these words, but bear in mind that 
their usage in practice is actually much less prominent than one would expect - about 1% of Factor's own codebase.

Another common case happens when you need to add values to a quotation in specific places. You can partially apply a quotation using { $link curry } . This assumes that the value you are 
applying should appear leftmost in the quotation; in the other cases you need some stack shuffling. The word { $link with }  is a 
sort of partial application with a hole. It also curries a quotation, but uses the third element on the stack instead 
of the second. Also, the resulting curried quotation will be applied to an element inserting it in the second position.

The example from the documentation probably tells more than the
above sentence -- try writing:

{ $code "1 { 1 2 3 } [ / ] with map" }

Let me take again { $snippet "prime?" } , but this time write it without using helper words:

{ $code "
: prime? ( n -- ? )
    [ sqrt 2 swap [a,b] ] [ [ swap divisor? ] curry ] bi any? not ;" }

Using { $link with }  instead of { $link curry } , this simplifies to

{ $code "
: prime? ( n -- ? )
    2 over sqrt [a,b] [ divisor? ] with any? not ;" }

If you are not able to visualize what is happening, you may want to consider the { $vocab-link "fry" } vocabulary. It defines { $strong "fried quotations" } "; "
these are quotations that have holes in them - marked by { $snippet "_" } - that are filled with values from the stack.

The first quotation is rewritten more simply as

{ $code "
[ '[ 2 _ sqrt [a,b] ] call ]
" }

Here we use a fried quotation - starting with { $link POSTPONE: '[ } - to inject the element on the top of the stack in the second 
position, and then use { $link call } to evaluate the resulting quotation. The second quotation can be rewritten as follows:

{ $code "
[ '[ _ swap divisor? ] ]
" }

so an alternative definition of { $snippet "prime?" } is

{ $code "
: prime? ( n -- ? )
    [ '[ 2 _ sqrt [a,b] ] call ] [ '[ _ swap divisor? ] ] bi any? not ;
" }

Depending on your taste, you may find this version more readable. In this case, the added clarity is probably lost due 
to the fact that the fried quotations are themselves inside quotations, but occasionally their use can do a lot to 
simplify the flow.

Finally, there are times where one just wants to give names to variables that are available inside some scope, and use 
them where necessary. These variables can hold values that are global, or at least not local to a single word. A 
typical example could be the input and output streams, or database connections.

For this purpose, Factor allows you to create { $strong "dynamic variables" }  and bind them in scopes. The first thing is to create a { $strong "symbol" }  
for a variable, say

{ $code "SYMBOL: favorite-language" }
Then one can use the word { $link set }  to bind the variable and { $link get }  to retrieve its values, like

{ $code "\"Factor\" favorite-language set
favorite-language get" }

Scopes are nested, and new scopes can be created with the word { $link with-scope } . Try for instance

{ $code "
: on-the-jvm ( -- )
    [
        \"Scala\" favorite-language set
        favorite-language get .
    ] with-scope ;" }

If you run { $snippet "on-the-jvm" } , { $snippet "\"Scala\"" } will be printed, but after execution, { $snippet "favorite-language get" } will hold { $snippet "\"Factor\"" } as its value.

All the tools that we have seen in this section should only be used when absolutely necessary, as they break concatenativity and make 
words less easy to factor. However, they can greatly increase clarity when needed. Factor has a very practical approach and 
does not shy from offering features that are less pure but nevertheless often useful.
;

ARTICLE: "tour-io" "Input/Output"

We will now leave the tour of the language, and start investigating how to tour the outside world with Factor. This section will begin with basic input and output, and move on to asynchronous, parallel
and distributed I/O.

Factor implements efficient asynchronous input/output facilities, similar to NIO on the JVM or the Node.js I/O system. 
This means that input and output operations are performed in the background, leaving the foreground task free to 
perform work while the disk is spinning or the network is buffering packets. Factor is currently single threaded, but 
asynchrony allows it to be rather performant for applications that are I/O-bound.

All of Factor input/output words are centered on { $strong "streams" } . Streams are lazy sequences which can be read from or written 
to, typical examples being files, network ports or the standard input and output. Factor holds a couple of dynamic 
variables called { $link input-stream } and { $link output-stream } , which are used by most I/O words. These variables can be rebound locally 
using { $link with-input-stream } , { $link with-output-stream } and { $link with-streams } . When you are in the listener, the default streams 
write and read in the listener, but once you deploy your application as an executable, they are usually bound to the 
standard input and output of your console.

The words { $link <file-reader> } and { $link <file-writer> } (or { $link <file-appender> } ) can be used to create a read or write stream to a 
file, given its path and encoding. Putting everything together, we make a simple example of a word that reads each line 
of a file encoded in UTF8, and writes the first letter of the line to the listener.

First, we want a { $snippet "safe-head" } word, that works like { $link head } , but returns its input if the sequence is too short. To do so
, we will use the word { $link recover } , which allows us to declare a try-catch block. It requires two quotations: the first 
one is executed, and on failure, the second one is executed with the error as input. Hence we can define

{ $code "
: safe-head ( seq n -- seq' ) [ head ] [ 2drop ] recover ;" }

This is an impractical example of exceptions, as Factor defines the { $link index-or-length } word, which takes a 
sequence and a number, and returns the minimum between the length of the sequence and the number. This allows us to write simply

{ $code "
: safe-head ( seq n -- seq' ) index-or-length head ;" }

With this definition, we can make a word to read the first character of the first line:

{ $code "
: read-first-letters ( path -- )
    utf8 <file-reader> [
        readln 1 safe-head print
    ] with-input-stream ;" }

Using the helper word { $link with-file-reader } , we can also shorten this to

{ $code "
: read-first-letters ( path -- )
    utf8 [
        readln 1 safe-head print
    ] with-file-reader ;" }

Unfortunately, we are limited to one line. To read more lines, we should chain calls to { $link readln } until one returns { $link f } .
Factor helps us with { $link file-lines } , which lazily iterates over lines. Our " final " definition becomes

{ $code "
: read-first-letters ( path -- )
    utf8 file-lines [ 1 safe-head print ] each ;" }

When the file is small, one can also use { $link file-contents } to read the whole contents of a file in a single string. 
Factor defines many more words for input/output, which cover many more cases, such as binary files or sockets.

We will end this section investigating some words to walk the filesystem. Our aim is a very minimal implementation of the { $snippet "ls" } command.

The word { $link directory-entries } lists the contents of a directory, giving a list of tuple elements, each one having the 
slots { $snippet "name" } and { $snippet "type" } . You can see this by trying { $snippet "\"/home\" directory-entries [ name>> ] map" } . If you inspect the 
directory entries, you will see that the type is either { $link +directory+ } or { $link +regular-file+ } (well, there are symlinks as well, 
but we will ignore them for simplicity). Hence we can define a word that lists files and directories with

{ $code "
: list-files-and-dirs ( path -- files dirs )
    directory-entries [ type>> +regular-file+ = ] partition ;" }

With this, we can define a word { $snippet "ls" } that will print directory contents as follows:

{ $code "
: ls ( path -- )
    list-files-and-dirs
    \"DIRECTORIES:\" print
    \"------------\" print
    [ name>> print ] each
    \"FILES:\" print
    \"------\" print
    [ name>> print ] each ;" }

Try the word on your home directory to see the effects. In the next section, we shall look at how to create an 
executable for our simple program.
;

ARTICLE: "tour-deploy" "Deploying programs"


There are two ways to run Factor programs outside the listener: as scripts, which are interpreted by Factor, or as 
standalone executable compiled for your platform. Both require you to define a vocabulary with an entry point (altough 
there is an even simpler way for scripts), so let's do that first.

Start by creating our { $snippet "ls" } vocabulary with { $snippet "\"ls\" scaffold-work" } and make it look like this:


{ $code "\
! Copyright (C) 2014 Andrea Ferretti.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors command-line io io.directories io.files.types
  kernel namespaces sequences ;
IN: ls

<PRIVATE

: list-files-and-dirs ( path -- files dirs )
    directory-entries [ type>> +regular-file+ = ] partition ;

PRIVATE>

: ls ( path -- )
    list-files-and-dirs
    \"DIRECTORIES:\" print
    \"------------\" print
    [ name>> print ] each
    \"FILES:\" print
    \"------\" print
    [ name>> print ] each ;" }

When we run our vocabulary, we will need to read arguments from the command line. Command-line arguments are stored 
under the { $link command-line } dynamic variable, which holds an array of strings. Hence - forgetting any error checking - we can 
define a word which runs { $snippet "ls" } on the first command-line argument with

{ $code ": ls-run ( -- ) command-line get first ls ;" }

Finally, we use the word { $link POSTPONE: MAIN: } to declare the main word of our vocabulary:

{ $code "MAIN: ls-run" }

Having added those two lines to your vocabulary, you are now ready to run it. The simplest way is to run the 
vocabulary as a script with the { $snippet "-run" } flag passed to Factor. For instance to list the contents of my home I can do

{ $code "$ ./factor -run=ls /home/andrea" }

In order to produce an executable, we must set some options and call the { $snippet "deploy" } word. The simplest way to do this 
graphically is to invoke the { $link deploy-tool } word. If you write { $snippet "\"ls\" deploy-tool" } , you will be presented with a window to 
choose deployment options. For our simple case, we will leave the default options and choose Deploy.

After a little while, you should be presented with an executable that you can run like

{ $code "$ cd ls

$ ./ls /home/andrea" }

Try making the { $snippet "ls" } program more robust by handling missing command-line arguments and non-existent or non-directory 
arguments.
;

ARTICLE: "tour-multithreading" "Multithreading"

As we have said, the Factor runtime is single-threaded, like Node. Still, one can emulate concurrency in a single-threaded
setting by making use of { $strong "coroutines" } . These are essentially cooperative threads, which periodically release 
control with the { $link yield } word, so that the scheduler can decide which coroutine to run next.

Although cooperative threads do not allow to make use of multiple cores, they still have some benefits:
{ $list 
  "input/output operations can avoid blocking the entire runtime, so that one can implement quite performant applications if I/O is the bottleneck;"
  "user interfaces are naturally a multithreaded construct, and they can be implemented in this model, as the listener itself shows;"
  "finally, some problems may just naturally be easier to write making use of the multithreaded constructs."
}

For the cases where one wants to make use of multiple cores, Factor offers the possibility of spawning other processes 
and communicating between them with the use of { $strong "channels" } , as we will see in a later section.

Threads in Factor are created using a quotation and a name, with the { $link spawn } word. Let us use this to print the 
first few lines of Star Wars, one per second, each line being printed inside its own thread. First, we will assign them to a 
dynamic variable:

{ $code "\
SYMBOL: star-wars

\"A long time ago, in a galaxy far, far away....

It is a period of civil war. Rebel
spaceships, striking from a hidden
base, have won their first victory
against the evil Galactic Empire.

During the battle, rebel spies managed
to steal secret plans to the Empire's
ultimate weapon, the DEATH STAR, an
armored space station with enough
power to destroy an entire planet.

Pursued by the Empire's sinister agents,
Princess Leia races home aboard her
starship, custodian of the stolen plans
that can save her people and restore
freedom to the galaxy....\"
\"\n\" split star-wars set
" }

We will spawn 18 threads, each one printing a line. The operation that a thread must run amounts to

{ $code "star-wars get ?nth print" }

Note that dynamic variables are shared between threads, so each one has access to star-wars. This is fine, since it is 
read-only, but the usual caveats about shared memory in a multithreaded settings apply.

Let us define a word for the thread workload

{ $code "
: print-a-line ( i -- )
    star-wars get ?nth print ;" }

If we give the i-th thread the name { $snippet "i" } , our example amounts to

{ $code "
18 [0..b) [
    [ [ print-a-line ] curry ]
    [ number>string ]
    bi spawn
] each" }

Note the use of { $link curry } to send i to the quotation that prints the i-th line. This is almost what we want, but it runs 
too fast. We need to put the thread to sleep for a while. So we { $link clear } the stack that now contains a lot of thread 
objects and look for the { $link sleep } word in the help.

It turns out that { $link sleep } does exactly what we need, but it takes a { $strong "duration" }  object as input. We can create a 
duration of i seconds with... well { $snippet "i seconds" } . So we define

{ $code "
: wait-and-print ( i -- )
    dup seconds sleep print-a-line ;" }

Let us try

{ $code "
18 [0..b) [
    [ [ wait-and-print ] curry ]
    [ number>string ]
    bi spawn
] each" }

Instead of { $link spawn } , we can also use { $link in-thread } which uses a dummy thread name and discards the returned thread, 
simplifying the above to

{ $code "
18 [0..b) [
    [ wait-and-print ] curry in-thread
] each" }

In serious applications threads will be long-running. In order to make them 
cooperate, one can use the { $link yield } word to signal that the thread has done a unit of work, and other threads can gain 
control. You also may want to have a look at other words to { $link stop } , { $link suspend } or { $link resume } threads.
;

ARTICLE: "tour-servers" "Servers and Furnace"

Server applications often use more than one thread. When writing network 
applications, it is common to start a thread for each incoming connection (remember that these are green threads, so they are much 
more lightweight than OS threads).

To simplify this, Factor has the word { $link spawn-server } , which works like { $link spawn } , but in addition repeatedly spawns the 
quotation until it returns { $link f } . This is still a very low-level word: in reality one has to do much more: listen for TCP 
connections on a given port, handle connection limits and so on.

The vocabulary { $vocab-link "io.servers" } allows to write and configure TCP servers. A server is created with the word { $link <threaded-server> } , which requires an encoding as a parameter. Its slots can then be set to configure logging, connection limits, 
ports and so on. The most important slot to fill is { $snippet "handler" } , which contains a quotation that is executed for each 
incoming connection. You can see a simple example of a server with
{ $code "
\"resource:extra/time-server/time-server.factor\" edit-file
" }

We will raise the level of abstraction even more and show how to run a simple HTTP server. First, { $snippet "USE: http.server" } .

An HTTP application is built out of a { $strong "responder" } . A responder is essentially a function from a path and an HTTP 
request to an HTTP response, but more concretely it is anything that implements the method { $snippet "call-responder*" } . Responses are 
instances of the tuple { $link response } , so are usually generated calling { $link <response> } and customizing a few slots. Let us 
write a simple echo responder:

{ $code "TUPLE: echo-responder ;

: <echo-responder> ( -- responder ) echo-responder new ;

M: echo-responder call-responder*
    drop
    <response>
        200 >>code
        \"Document follows\" >>message
        \"text/plain\" >>content-type
        swap concat >>body ;" }

Responders are usually combined to form more complex responders in order to implement routing and other features. In 
our simplistic example, we will use just this one responder, and set it globally with

{ $code "<echo-responder> main-responder set-global" }

Once you have done this, you can start the server with { $snippet "8080 httpd" } . You can then visit { $url "https://localhost:8080/hello/%20/from/%20/factor" }
 in your browser to see your first responder in action. You can then stop the server with { $link stop-server } .

Now, if this was all that Factor offers to write web applications, it would still be rather low level. In reality, web 
applications are usually written using a web framework called { $strong "Furnace" } .

Furnace allows us - among other things - to write more complex actions using a template language. Actually, there are 
two template languages shipped by default, and we will use { $strong "Chloe" } . Furnace allows us to create { $strong "page actions" }  
from Chloe templates, and in order to create a responder we will need to add routing.

Let use first investigate a simple example of routing. To do this, we create a special type of responder called a { $strong "dispatcher" } , that dispatches requests based on path parameters. Let us create a simple dispatcher that will choose 
between our echo responder and a default responder used to serve static files.

{ $code "
dispatcher new-dispatcher
    <echo-responder> \"echo\" add-responder
    \"/home/andrea\" <static> \"home\" add-responder
    main-responder set-global" }

Of course, substitute the path { $snippet "/home/andrea" } with any folder you like. If you start again the server with { $snippet "8080 httpd" }
, you should be able to see both our simple echo responder (under { $snippet "/echo" } ) and the contents of your files (under { $snippet "/home" } ).
 Notice that directory listing is disabled by default, you can only access the content of files.

Now that you know how to do routing, we can write page actions in Chloe. Things are starting to become complicated, so 
we scaffold a vocabulary with { $snippet "\"hello-furnace\" scaffold-work" } . Make it look like this:

{ $code "\
! Copyright (C) 2014 Andrea Ferretti.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions http http.server
  http.server.dispatchers http.server.static kernel sequences ;
IN: hello-furnace


TUPLE: echo-responder ;

: <echo-responder> ( -- responder ) echo-responder new ;

M: echo-responder call-responder*
    drop
    <response>
        200 >>code
        \"Document follows\" >>message
        \"text/plain\" >>content-type
        swap concat >>body ;

TUPLE: hello-dispatcher < dispatcher ;

: <example-responder> ( -- responder )
    hello-dispatcher new-dispatcher
        <echo-responder> \"echo\" add-responder
        \"/home/andrea\" <static> \"home\" add-responder
        <page-action>
            { hello-dispatcher \"greetings\" } >>template
        \"chloe\" add-responder ;" }

Most things are the same as we have done in the listener. The only difference is that we have added a third responder 
in our dispatcher, under { $snippet "chloe" } . This responder is created with a page action. The page action has many slots - say, to 
declare the behaviour of receiving the result of a form - but we only set its template. This is the pair with the 
dispatcher class and the relative path of the template file.

In order for all this to work, create a file { $snippet "work/hello-furnace/greetings.xml" } with a content like

{ $code "<?xml version='1.0' ?>

<t:chloe xmlns:t=\"http://factorcode.org/chloe/1.0\">
    <p>Hello from Chloe</p>
</t:chloe>" }

Reload the { $snippet "hello-furnace" } vocabulary and { $snippet "<example-responder> main-responder set-global" } . You should be able to see 
the results of your efforts under { $url "https://localhost:8080/chloe" } . Notice that there was no need to restart the server, we 
can change the main responder dynamically.

This ends our very brief tour of Furnace. Furnace is much more expansive than the examples shown here,  as it allows for many general web
tasks. You can learn more about it in the { $vocab-link "furnace" } documentation.
;

ARTICLE: "tour-processes" "Processes and Channels"


As discussed earlier, Factor is single-threaded from the point of view of the OS. If we want to make use of multiple cores, we 
need a way to spawn Factor processes and communicate between them. Factor implements two different models of message-passing concurrency: the actor model, which is based on the idea of sending messages asynchronously between threads, and the 
CSP model, based on the use of { $strong "channels" } .

As a warm-up, we will make a simple example of communication between threads in the same process.

{ $code "FROM: concurrency.messaging => send receive ;" }

We can start a thread that will receive a message and print it repeatedly:

{ $code ": print-repeatedly ( -- ) receive . print-repeatedly ;

[ print-repeatedly ] \"printer\" spawn" }

A thread whose quotation starts with { $link receive } and calls itself recursively behaves like an actor in Erlang or Akka. 
We can then use { $link send } to send messages to it. Try { $snippet "\"hello\" over send" } and then { $snippet "\"threading\" over send" } .

Channels are slightly different abstractions, used for instance in Go and in Clojure core.async. They decouple the 
sender and the receiver, and are usually used synchronously. For instance, one side can receive from a channel before some 
other party sends something to it. This just means that the receiving end yields control to the scheduler, which waits 
for a message to be sent before giving control to the receiver again. This feature sometimes makes it easier to 
synchronize multithreaded applications.

Again, we first use a channel to communicate between threads in the same process. As expected, { $snippet "USE: channels" } . You 
can create a channel with { $link <channel> } , write to it with { $link to } and read from it with { $link from } . Note that both operations are 
blocking: { $link to } will block until the value is read in a different thread, and { $link from } will block until a value is available.

We create a channel and give it a name with

{ $code "SYMBOL: ch

<channel> ch set" }

Then we write to it in a separate thread, in order not to block the UI

{ $code "[ \"hello\" ch get to ] in-thread" }

We can then read the value in the UI with

{ $code "ch get from" }

We can also invert the order:

{ $code "[ ch get from . ] in-thread

\"hello\" ch get to" }

This works fine, since we had set the reader first.

Now, for the interesting part: we will start a second Factor instance and communicate via message sending. Factor 
transparently supports sending messages over the network, serializing values with the { $vocab-link "serialize" } vocabulary.

Start another instance of Factor, and run a node server on it. We will use the word { $link <inet4> } , that creates an IPv4 
address from a host and a port, and the { $link <node-server> } constructor

{ $code "USE: concurrency.distributed

f 9000 <inet4> <node-server> start-server" }

Here we have used { $link f } as host, which just stands for localhost. We will also start a thread that keeps a running count 
of the numbers it has received.

{ $code "FROM: concurrency.messaging => send receive ;

: add ( x -- y ) receive + dup . add ;

[ 0 add ] \"adder\" spawn" }

Once we have started the server, we can make a thread available with { $link register-remote-thread } ":"

{ $code "dup name>> register-remote-thread" }

Now we switch to the other instance of Factor. Here we will receive a reference to the remote thread and start sending 
numbers to it. The address of a thread is just the address of its server and the name we have registered the thread with
, so we obtain a reference to our adder thread with

{ $code "f 9000 <inet4> \"adder\" <remote-thread>" }

Now, we reimport { $link send } just to be sure (there is an overlap with a word having the same name in { $vocab-link "io.sockets" } , that we 
have imported)

{ $code "FROM: concurrency.messaging => send receive ;" }

and we can start sending numbers to it. Try { $snippet "3 over send" } , and then { $snippet "8 over send" } - you should see the running total 
printed in the other Factor instance.

What about channels? We go back to our server, and start a channel there, just as above. This time, though, we { $link publish } it to make it available remotely:

{ $code "USING: channels channels.remote ;

<channel> dup publish" }

What you get in return is an id you can use remotely to communicate. For instance, I just got 
{ $snippet "326546621698456955263335657082068225943" } (yes, they really want to be sure it is unique!).

We will wait on this channel, thereby blocking the UI:

{ $code "swap from ." }

In the other Factor instance we use the id to get a reference to the remote channel and write to it

{ $code "\
f 9000 <inet4> 326546621698456955263335657082068225943 <remote-channel>
\"Hello, channels\" over to" }

In the server instance, the message should be printed.

Remote channels and threads are both useful to implement distributed applications and make good use of multicore 
servers. Of course, it remains the question how to start worker nodes in the first place. Here we have done it manually - if 
the set of nodes is fixed, this is actually an option.

Otherwise, one could use the { $vocab-link "io.launcher" } vocabulary to start other Factor instances programmatically.
;

ARTICLE: "tour-where" "Where to go from here?"

We have covered a lot of ground here, and we hope that this has given you a taste of the great things
you can do with Factor. You can now 
work your way through the documentation, and hopefully contribute to Factor yourself.

Let me end with a few tips:

{ $list
{ "when starting to write Factor, it is " { $emphasis "very" } " easy to deal a lot with stack shuffling. Learn the " 
{ $vocab-link "combinators" } " well, and do not fear to throw away your first examples." }
"no definition is too short: aim for one line."
"the help system and the inspector are your best friends."
}
To be fair, we have to mention some drawbacks of Factor:

{ $list
"The community is small. It is difficult to find information about Factor on the internet.
However, you can help with this by posting questions on Stack Overflow under the [factor] tag."
"The concatenative model is very powerful, but also hard to get good at."
"Factor lacks native threads: although the distributed processes make up for it, they incur some cost in serialization."
"Factor does not currently have a package manager. Most prominent packages are part of the main Factor distribution."
}

The Factor source tree is massive, so here's a few vocabularies to get you started off:

{ $list 
  { "We have not talked a lot about errors and exceptions. Learn more in the " { $vocab-link "debugger" } " vocabulary." } 
  { "The " { $vocab-link "macros" } " vocabulary implements a form of compile time metaprogramming less general than parsing words." }
  { "The " { $vocab-link "models" } " vocabulary lets you implement a form of dataflow programming using objects with observable slots." }
  { "The " { $vocab-link "match" } " vocabulary implements ML-style pattern matching." }
  { "The " { $vocab-link "monads" } " vocabulary implements Haskell-style monads." }
}

These vocabularies are a testament to the power and expressivity of Factor, and we hope that they 
help you make something you like. Happy hacking!

{ $code "\
USE: images.http

\"https://factorcode.org/logo.png\" http-image." }
;

ARTICLE: "tour" "Guided tour of Factor"
Factor is a mature, dynamically typed language based on the concatenative paradigm. Getting started with Factor can be daunting 
since the concatenative paradigm is different from most mainstream languages.
This tutorial will:

{ $list 
  "Guide you through the basics of Factor so you can appreciate its simplicity and power."
  "Assume you are an experienced programmer familiar with a functional language"
  "Assume you understand concepts like folding, higher-order functions, and currying"
}

Even though Factor is a niche language, it is mature and has a comprehensive standard library covering tasks from JSON 
serialization to socket programming and HTML templating. It runs in its own optimized VM with very high performance for a dynamically 
typed language. It also has a flexible object system, a Foreign Function Interface to C, and 
asynchronous I/O that works a bit like Node.js, but with a much simpler model for cooperative multithreading.

Factor has a few significant advantages over 
other languages, most arising from the fact that it has essentially no syntax:

{ $list
  "Refactoring is very easy, leading to short and meaningful function definitions"
  "It is extremely succinct, letting the programmer concentrate on what is important instead of boilerplate"
  "It has powerful metaprogramming capabilities, exceeding even those of LISPs"
  "It is ideal for creating DSLs"
  "It integrates easily with powerful tools"
}

A few file paths in the examples may need to be adjusted based on your system.

The first section gives some motivation for the peculiar model of computation of concatenative languages, but feel free 
to skip it if you want to get your feet wet and return to it after some hands on practice with Factor.

{ $heading "The Tour" }
{ $subsections
  "tour-concatenative"
  "tour-stack"
  "tour-first-word"
  "tour-parsing-words"
  "tour-stack-shuffling"
  "tour-combinators"
  "tour-vocabularies"
  "tour-tests-docs"
  "tour-objects"
  "tour-tools"
  "tour-metaprogramming"
  "tour-stack-ne"
  "tour-io"
  "tour-deploy"
  "tour-multithreading"
  "tour-servers"
  "tour-processes"
  "tour-where"
}
;

ABOUT: "tour"
