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

* A note about code examples

Factor words are separated out into multiple ``vocabularies''. Each code
example given here is preceeded with a series of declarations, such as
the following:

   USE: math
   USE: streams

When entering code at the interactive interpreter loop, most
vocabularies are already in the search path, and the USE: declarations
can be omitted. However, in a source file they must all be specified, by convention at the beginning of the file.

* Control flow

Control flow rests on two basic concepts: recursion, and branching.
Words with compound definitions may refer to themselves, and there is
exactly one primitive for performing conditional execution:

    USE: combinators

    1 10 < [ "1 is less than 10." print ] [ "whoa!" print ] ifte
    ==> 1 is less than 10.

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

    USE: lists

    3 [ 1 2 3 4 ] contains?
    ==> [ 3 4 ]
    5 [ 1 2 3 4 ] contains?
    ==> f

It recurses down the list, until it reaches the end, in which case the
outer ifte's 'false' branch is executed.

A quick overview of the words used here, along with their stack effects:

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

    USE: math
    USE: prettyprint

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

    USE: lists
    USE: math
    USE: stack

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

Writing >r foo r> is analogous to '[ foo ] dip' in Joy. Occurrences of
>r and r> must be balanced within a single word definition.

Linked list deconstruction:

uncons ( [ x | y ] -- x y )

* Variables

Factor supports a notion of ``variables''. Whereas the stack is used for
transient, intermediate values, variables are used for more permanent
data.

Variables are retreived and stored using the 'get' and 'set' words. For
example:

    USE: math
    USE: namespaces
    USE: prettyprint

    "~" get .
    ==> "/home/slava"

    5 "x" set
    "x" get 2 * .
    ==> 10

The set of available variables is determined using ``dynamic scope''.
A ``namespace'' is a set of variable name/value pairs. Namespaces can be
pushed onto the ``name stack'', and later popped. The 'get' word
searches all namespaces on the namestack in turn. The 'set' word stores
a variable value into the namespace at the top of the name stack.

While it is possible to push/pop the namestack directly using the words
>n and n>, most of the time using the 'bind' combinator is more
desirable.

Good examples of namespace use are found in the I/O system.

Factor provides two sets of words for working with I/O streams: words
whose stream operand is specified on the stack (freadln, fwrite,
fprint...) and words that use the standard input/output stream (read,
write, print...).

An I/O stream is a namespace with a slot for each I/O operation. I/O
operations taking an explicit stream operand are all defined as follows:

: freadln ( stream -- string )
    [ "freadln" get call ] bind ;

: fwrite ( string stream -- )
    [ "fwrite" get call ] bind ;

: fclose ( stream -- )
    [ "fclose" get call ] bind ;

( ... et cetera )

The second set of I/O operations, whose stream is the implicit 'standard
input/output' stream, are defined as follows:

: read ( -- string )
    "stdio" get freadln ;

: write ( string -- )
    "stdio" get fwrite ;

( ... et cetera )

In the global namespace, the 'stdio' variable corresponds to a stream
whose operations read/write from the standard file descriptors 0 and 1.

However, the 'with-stream' combinator provides a way to rebind the
standard input/output stream for the duration of the execution of a
single quotation. The following example writes the source of a word
definition to a file named 'definition.txt':

    USE: prettyprint
    USE: streams

    "definition.txt" <filebw> [ "with-stream" see ] with-stream

The 'with-stream' word is implemented by pushing a new namespace on the
namestack, setting the 'stdio' variable therein, and execution the given
quotation.

