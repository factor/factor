THE CONCATENATIVE LANGUAGE FACTOR

* Introduction

Factor supports various data types; atomic types include numbers of
various kinds, strings of characters, and booleans. Compound data types
include lists consisting of cons cells, vectors, and string buffers.

Factor encourages programming in a functional style where new objects
are returned and input parameters remain unmodified, but does not
enforce this. No manifest type declarations are necessary, and all data
types use exactly one slot each on the stack (unlike, say, FORTH).

The internal representation of a Factor program is a linked list. Linked
lists that are to be executed are referred to as ``quotations.'' The
interpreter iterates the list, executing words, and pushing all other
types of objects on the data stack. A word is a unique data type because
it can be executed. Words come in two varieties: primitive and compound.
Primitive words have an implementation coded in the host language (C or
Java). Compound words are executed by invoking the interpreter
recursively on their definition, which is also a linked list.

* Control flow

Control flow rests on two basic concepts: recursion, and branching.
Words with compound definitions may refer to themselves, and there is
exactly one primitive for performing conditional execution:

    1 10 < [ "10 is less than 1." print ] [ "whoa!" print ] ifte
    ==> 10 is less than 1.

Here is an example of a word that uses these two concepts:

: contains? ( element list -- remainder )
    #! If the proper list contains the element, push the
    #! remainder of the list, starting from the cell whose car
    #! is elem. Otherwise push f.
    dup [
        2dup car = [ nip ] [ cdr contains? ] ifte
    ] [
        2drop f
    ] ifte ;

An example:

    3 [ 1 2 3 4 ] contains?
    ==> [ 3 4 ]
    5 [ 1 2 3 4 ] contains?
    ==> f

It recurses down the list, until it reaches the end, in which case the
outer ifte's 'false' branch is executed.

A quick overview of the words used here:

Shuffle words:

dup ( x -- x x )
nip ( x y -- y )
2dup ( x y -- x y x y )
2drop ( x y -- )

Linked list deconstruction:

car ( [ x | y ] -- x )
cdr ( [ x | y ] -- y ) - push the "tail" of a list.

Equality:

= ( x y -- ? )

More complicated control flow constructs, such as loops and higher order
functions, are usually built with the help of another primitive that
simply executes a quotation at the top of the stack, removing it from
the stack:

    [ 2 2 + . ] call
    ==> 4

Here is an example of a word that applies a quotation to each element of
a list. Note that it uses 'call' to execute the given quotation:

: each ( list quotation -- )
    #! Push each element of a proper list in turn, and apply a
    #! quotation to each element.
    #!
    #! In order to compile, the quotation must consume one more
    #! value than it produces.
    over [
        >r uncons r> tuck >r >r call r> r> each
    ] [
        2drop
    ] ifte ;

An example:

    [ 1 2 3 4 ] [ dup * . ] each
    ==> 1
        4
	9
	16

A quick overview of the words used here:

Printing top of stack:

. ( x -- ) print top of stack in a form that is valid Factor syntax.

Shuffle words:

over ( x y -- x y x )
tuck ( x y -- y x y )
>r ( x -- r:x ) - move top of data stack to/from 'extra hand'.
r> ( r:x -- x )

Writing >r foo r> is analogous to [ foo ] in Joy. Occurrences of >r and
r> must be balanced within a single word definition.

Linked list deconstruction:

uncons ( [ x | y ] -- x y )

* Variables

* Continuations

* Reflection

