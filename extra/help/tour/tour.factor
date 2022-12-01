! Copyright (C) 2022 Raghu Ranganathan and Andrea Ferreti.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays command-line help help.markup help.syntax
help.vocabs io kernel math math.factorials math.functions
namespaces parser prettyprint ranges see sequences stack-checker
vocabs.loader ;
IN: help.tour


ARTICLE: "tour-concatenative" "Concatenative Languages" 
Factor is a { $emphasis concatenative } programming language in the spirit of Forth. What does this mean?

To understand concatenative programming, imagine a world where every value is a function, and the only operation 
allowed is function composition. Since function composition is so pervasive, it is implicit, and functions can be literally 
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
few elements on the stack (e.g., { $snippet "swap" } , that exchanges the top two elements on the stack), then it becomes possible to 
refer to values down the stack, but the farther the value is down the stack, the harder it becomes to refer to it.

So, functions are encouraged to stay small and only refer to the top two or three elements on the stack. In a sense, 
there is no distinction between local and global variables, but values can be more or less local depending on their 
distance from the top of the stack.

Notice that if every function takes the state of the whole world and returns the next state, its input is never used 
anymore. So, even though it is convenient to think of pure functions as receiving a stack as input and outputting a stack,
the semantics of the language can be implemented more efficiently by mutating a single stack.

{ $heading "Up Next" }
{ $link "tour-stack" }
;

ARTICLE: "tour-stack" "Playing with the stack"

Let us start looking what Factor actually feels like. Our first words will be literals, like { $snippet "3" } , { $snippet "12.58" } or 
{ $snippet "\"Chuck Norris\"" } . Literals can be thought as functions that push themselves on the stack. Try writing { $snippet "5" } in the listener and 
then press enter to confirm. You will see that the stack, initially empty, now looks like

{ $code "5" }
$nl
You can enter more than one number, separated by spaces, like { $snippet "7 3 1" } , and get

{ $code "5
7
3
1"
}
$nl
(the interface shows the top of the stack on the bottom). What about operations? If you write { $snippet "+" } , you will run the 
{ $snippet "+" } function, which pops the two topmost elements and pushes their sum, leaving us with

{ $code "5
7
4"
}
$nl
You can put additional inputs in a single line, so for instance { $snippet "- *" } will leave the single number { $snippet "15" } on the stack (do you see why?).

The function { $snippet "." } (a period or a dot) prints the item at the top of the stack, while popping it out of the stack, leaving the stack empty.

If we write everything on one line, our program so far looks like

{ $code "5 7 3 1 + - * ."
}
$nl
which shows Factor's peculiar way of doing arithmetic by putting the arguments first and the operator last - a 
convention which is called Reverse Polish Notation (RPN). Notice that 
RPN requires no parenthesis, unlike the polish notation of Lisps where 
the operator comes first, and RPN requires no precedence rules, unlike the infix notation
used in most programming languages and in everyday arithmetic. For instance in any Lisp, the same 
computation would be written as

{ $code "(* 5 (- 7 (+ 3 1)))"
}
$nl
and in familiar infix notation

{ $code "(7 - (3 + 1)) * 5"
}
$nl
Also notice that we have been able to split our computation onto many lines or combine it onto fewer lines rather arbitrarily, and that each line made sense in itself.

{ $heading "Up Next" }
{ $link "tour-first-word" }
;

ARTICLE: "tour-first-word" "Defining our first word" 

We will now define our first function. Factor has slightly odd naming of functions: since functions are read from left 
to right, they are simply called **words**, and this is what we'll call them from now on. Modules in Factor define 
words in terms of previous words and these sets of words are then called **vocabularies**.

Suppose we want to compute the factorial. To start with a concrete example, we'll compute the factorial of { $snippet "10" }
, so we start by writing { $snippet "10" }  on the stack. Now, the factorial is the product of the numbers from { 
$snippet "1" }  to { $snippet "10" } , so we should produce such a list of numbers first.

The word to produce a range is called { $link [a..b] }  (tokenization is trivial in Factor because words are 
always separated by spaces, so this allows you to use any combination of non-whitespace characters as the name of a word; 
there are no semantics to the { $snippet "[" } , the { $snippet "," }  and the { $snippet "]" }  in { $link [a..b] }  
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
Keeping to our textual metaphor, this mechanism is called **quotation**. To quote one or more words, you just surround them 
by { $snippet "[" }  and { $snippet "]" }  (leaving spaces!). What you get is akin to an anonymous function in other 
languages.

Let's type the word { $link drop }  into the listener to empty the stack, and try writing what we have done so 
far in a single line: { $snippet "10 [1..b] 1 [ * ] reduce" } . This will leave { $snippet "3628800" }  on the stack as 
expected.

We now want to define a word for factorial that can be used whenever we want a factorial. We will call our word { $snippet "fact" }
"(" although { $snippet "!" }  is customarily used as the symbol for factorial, in Factor { $snippet "!" }  
is the word used for comments ")" . To define it, we first need to use the word { $snippet ":" } . Then we put the name of 
the word being defined, then the **stack effects** and finally the body, ending with the { $snippet ";" }  word:

{ $code ": fact ( n -- n! ) [1..b] 1 [ * ] reduce ;" }

What are stack effects? In our case it is the { $snippet "( n -- n! )" } . Stack effects are how you document the 
inputs from the stack and outputs to the stack for your word. You can use any identifier to name the stack elements, here we 
use { $snippet "n" } . Factor will perform a consistency check that the number of inputs and outputs you specify agrees 
with what the body does.

If you try to write

{ $code ": fact ( m n -- ..b ) [1..b] 1 [ * ] reduce ;" }

Factor will signal an error that the 2 inputs "(" { $snippet "m" }  and { $snippet "n" } ) are not consistent with the 
body of the word. To restore the previous correct definition press { $snippet "Ctrl+P" }  two times to get back to the 
previous input and then enter it.

We can think at the stack effects in definitions both as a documentation tool and as a very simple type system, which 
nevertheless does catch a few errors.

In any case, you have succesfully defined your first word: if you write { $snippet "10 fact" }  in the listener you 
can prove it.

Notice that the { $snippet "1 [ * ] reduce" }  part of the definition sort of makes sense on its own, being the product of a sequence. The nice thing about a concatenative language is that we can just factor this part out and write

{ $code ": prod ( {x1,...,xn} -- x1*...*xn ) 1 [ * ] reduce ;
: fact ( n -- n! ) [1..b] prod ;" }

Our definitions have become simpler and there was no need to pass parameters, rename local variables, or do anything 
else that would have been necessary to refactor our function in most languages.

Of course, Factor already has a word for the factorial (actually there is a whole { $vocab-link "math.factorials" }  
vocabulary, including many variants of the usual factorial) and a word for the product "(" { $link product }  in the 
{ $vocab-link "sequences" }  vocabulary), but as it often happens introductory examples overlap with the standard library.

{ $heading "Up Next" }
{ $link "tour-parsing-words" }
;

ARTICLE: "tour-parsing-words" "Parsing Words"
If you've been paying close attention so far, you realize I've lied to you. I said each word acts on the stack in order
, but there a few words like { $snippet "[" } , { $snippet "]" } , { $snippet ":" } and { $snippet ";" } that don't seem to follow this rule.

These are **parsing words** and they behave differently from simpler words like { $snippet "5" } , { $link [1..b] } or { $link drop } . We will cover 
these in more detail when we talk about metaprogramming, but for now it is enough to know that parsing words are special.

They are not defined using the { $snippet ":" } word, but with the word { $snippet "SYNTAX:" } instead. When a parsing words is encountered, it 
can interact with the parser using a well-defined API to influence how successive words are parsed. For instance { $snippet ":" } 
asks for the next tokens from the parsers until { $snippet ";" } is found and tries to compile that stream of tokens into a word 
definition.

A common use of parsing words is to define literals. For instance { $snippet "{" } is a parsing word that starts an array 
definition and is terminated by { $snippet "} " } . Everything in-between is part of the array. An example of array that we have seen before is 
{ $snippet "{ 1 2 3 4 5 6 7 8 9 10 } " } .

There are also literals for hashmaps, { $snippet "H{ { \"Perl\" \"Larry Wall\" } { \"Factor\" \"Slava Pestov\" } { \"Scala\" \"Martin Odersky\" } } " }
, and byte arrays, { $snippet "B{ 1 14 18 23 } " } .

Other uses of parsing word include the module system, the object-oriented features of Factor, enums, memoized functions
, privacy modifiers and more. In theory, even { $snippet "SYNTAX:" } can be defined in terms of itself, although of course the 
system has to be bootstrapped somehow.

{ $heading "Up Next" }
{ $link "tour-stack-shuffling" }
;

ARTICLE: "tour-stack-shuffling" "Stack Shuffling"
Now that you know the basics of Factor, you may want to start assembling more complex words. This may sometimes 
require you to use variables that are not on top of the stack, or to use variables more than once. There are a few words that 
can be used to help with this. I mention them now since you need to be aware of them, but I warn you that using too many 
of these words to manipulate the stack will cause your code to quickly become harder to read and write. Stack shuffling 
requires mentally simulating moving values on a stack, which is not a natural way to program. In the next section we'll 
see a much more effective way to handle most needs.

Here is a list of the most common shuffling words together with their effect on the stack. Try them in the listener to 
get a feel for how they manipulate the stack using the listener.
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

{ $heading "Up Next" }
{ $link "tour-combinators" }
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
" } { $link bi }  applies the quotation { $snippet "[ 2 * ]" }  to the value { $snippet "5" }  and then the quotation { $snippet "[ 3 + ]" }  to the value { $snippet "5" }  leaving us 
with { $snippet "10" }  and then { $snippet "8" }  on the stack. Without { $link bi } , we would have to first { $link dup }  { $snippet "5" } , then multiply, and then { $link swap }  the 
result of the multiplication with the second { $snippet "5" } , so we could do the addition
{ $code "
5 dup 2 * swap 3 +
" }
You can see that { $link bi }  replaces a common pattern of { $link dup } , then calculate, then { $link swap }  and calculate again.

To continue our prime example, we need a way to make a range starting from { $snippet "2" } . We can define our own word for this { $snippet "[2..b]" } 
, using the { $link [a..b] } range word we discussed earlier.
{ $code "
: [2..b] ( n -- {2,...,n} ) 2 swap [a..b] ; inline
" }
What's up with that { $snippet "inline" }  word? This is one of the modifiers we can use after defining a word, another one being 
{ $snippet "recursive" } . This will allow us to have the definition of a short word inlined wherever it is used, rather than incurring 
a function call.

Try our new { $snippet "[2..b]" }  word and see that it works
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
want. It will help to have the arguments for testing divisibility in the other direction, so we define { $snippet "multiple?" } 
{ $code "
: multiple? ( a b -- ? ) swap divisor? ; inline
" }
Both of these return { $link t } 
{ $code "
9 3 divisor? .
3 9 multiple? .
" }
If we're going to use { $link bi }  in our { $snippet "prime" }  definition, as we implied above, we need a second quotation. Our second 
quotation needs to test for a value in the range being a divisor of { $snippet "n" }  - in other words we need to partially apply the word  { $snippet "multiple?" } . This can be done with the word { $link curry } , like this: { $snippet "[ multiple? ] curry" } .

Finally, once we have the range of potential divisors and the test function on the stack, we can test whether any 
element satisfied divisibility with { $link any? }  and then negate that answer with { $snippet "not" } . Our full definition of { $snippet "prime" }  looks like
{ $code "
: prime? ( n -- ? ) [ sqrt [2..b] ] [ [ multiple? ] curry ] bi any? not ;
" }
Altough the definition of { $snippet "prime" }  is complicated, the stack shuffling is minimal and is only used in the small helper 
functions, which are simpler to reason about than { $snippet "prime?" } .

Notice that { $snippet "prime?" }  uses two levels of quotation nesting since { $link bi }  operates on two quotations, and our second 
quotation contains the word { $link curry } , which also operates on a quotation. In general, Factor words tend to be rather shallow, 
using one level of nesting for each higher-order function, unlike Lisps or more generally languages based on the lambda 
calculus, which use one level of nesting for each function, higher-order or not.

Many more combinators exists other than { $link bi }  (and its relative { $link tri } ), and you should become acquainted at least with 
{ $link bi } , { $link tri } , and { $link bi@ } by reading about them in the online help and trying them out in the listener.
;

ARTICLE: "tour" "A guided tour of Factor"
Factor is a mature, dynamically typed language based on the concatenative paradigm. Getting started with Factor can be daunting 
since the concatenative paradigm is different from most mainstream languages. This tutorial will guide you through the basics of
Factor so you can appreciate its simplicity and power. I assume you are an experienced programmer familiar with a functional 
language, and I'll assume you understand concepts like folding, higher-order functions, and currying.

Even though Factor is a niche language, it is mature and has a comprehensive standard library covering tasks from JSON 
serialization to socket programming and HTML templating. It runs in its own optimized VM with very high performance for a dynamically 
typed language. It also has a flexible object system, a Foreign Function Interface to C, and 
asynchronous I/O that works a bit like Node.js, but with a much simpler model for cooperative multithreading.

Factor has a few significant advantages over 
other languages, most arising from the fact that it has essentially no syntax:

{ $list
  "refactoring is very easy, leading to short and meaningful function definitions;"
  "it is extremely succinct, letting the programmer concentrate on what is important instead of boilerplate;"
  "it has powerful metaprogramming capabilities, exceeding even those of LISPs;"
  "it is ideal to create DSLs;"
  "it integrates easily with powerful tools."
}

This tutorial is Windows-centric, but everything should work the same on other systems, provided you adjust the file paths in 
the examples.

The first section gives some motivation for the rather peculiar model of computation of concatenative languages, but feel free 
to skip it if you want to get your feet wet and return to it after some hands on practice with Factor.

{ $heading "The Tour" }
{ $subsections
  "tour-concatenative"
  "tour-stack"
  "tour-first-word"
  "tour-parsing-words"
  "tour-stack-shuffling"
}
;

ABOUT: "tour"
