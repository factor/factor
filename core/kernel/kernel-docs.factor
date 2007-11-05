USING: generic help.markup help.syntax math memory
namespaces sequences kernel.private layouts sorting classes
kernel.private vectors combinators quotations strings words
assocs arrays ;
IN: kernel

ARTICLE: "shuffle-words" "Shuffle words"
"Shuffle words rearrange items at the top of the data stack. They control the flow of data between words that perform actions."
$nl
"Removing stack elements:"
{ $subsection drop }
{ $subsection 2drop }
{ $subsection 3drop }
{ $subsection nip }
{ $subsection 2nip }
"Duplicating stack elements:"
{ $subsection dup }
{ $subsection 2dup }
{ $subsection 3dup }
{ $subsection dupd }
{ $subsection over }
{ $subsection pick }
{ $subsection tuck }
"Permuting stack elements:"
{ $subsection swap }
{ $subsection swapd }
{ $subsection rot }
{ $subsection -rot }
{ $subsection roll }
{ $subsection -roll }
"Sometimes an additional storage area is needed to hold objects. The " { $emphasis "retain stack" } " is an auxilliary stack for this purpose. Objects can be moved between the data and retain stacks using the following two words:"
{ $subsection >r }
{ $subsection r> }
"The top of the data stack is ``hidden'' between " { $link >r } " and " { $link r> } ":"
{ $example "1 2 3 >r .s r>" "2\n1" }
"Words must not leave objects on the retain stack, nor expect values to be there on entry. The retain stack is for local storage within a word only, and occurrences of " { $link >r } " and " { $link r> } " must be balanced inside a single quotation. One exception is the following trick involving " { $link if } "; values may be pushed on the retain stack before the condition value is computed, as long as both branches of the " { $link if } " pop the values off the retain stack before returning:"
{ $code
    ": foo ( m ? n -- m+n/n )"
    "    >r [ r> + ] [ drop r> ] if ; ! This is OK"
} ;

ARTICLE: "basic-combinators" "Basic combinators"
"The following pair of words invoke words and quotations reflectively:"
{ $subsection call }
{ $subsection execute }
"These words are used to implement " { $emphasis "combinators" } ", which are words that take code from the stack. Note that combinator definitions must be followed by the " { $link POSTPONE: inline } " declaration in order to compile in the optimizing compiler; for example:"
{ $code
    ": keep ( x quot -- x | quot: x -- )"
    "    over >r call r> ; inline"
}
"Word inlining is documented in " { $link "declarations" } "."
$nl
"There are some words that combine shuffle words with " { $link call } ". They are useful for implementing higher-level combinators."
{ $subsection slip }
{ $subsection 2slip }
{ $subsection keep }
{ $subsection 2keep }
{ $subsection 3keep }
{ $subsection 2apply }
"A pair of utility words built from " { $link 2apply } ":"
{ $subsection both? }
{ $subsection either? }
"A looping combinator:"
{ $subsection while }
"Quotations can be composed using efficient quotation-specific operations:"
{ $subsection curry }
{ $subsection 2curry }
{ $subsection 3curry }
{ $subsection curry* }
{ $subsection compose }
{ $subsection 3compose }
"Quotations also implement the sequence protocol, and can be manipulated with sequence words; see " { $link "quotations" } "."
{ $see-also "combinators" } ;

ARTICLE: "booleans" "Booleans"
"In Factor, any object that is not " { $link f } " has a true value, and " { $link f } " has a false value. The " { $link t } " object is the canonical true value."
{ $subsection f }
{ $subsection t }
"The " { $link f } " object is the unique instance of the " { $link f } " class; the two are distinct objects. The latter is also a parsing word which adds the " { $link f } " object to the parse tree at parse time. To refer to the class itself you must use " { $link POSTPONE: POSTPONE: } " or " { $link POSTPONE: \ } " to prevent the parsing word from executing."
$nl
"Here is the " { $link f } " object:"
{ $example "f ." "f" }
"Here is the " { $link f } " class:"
{ $example "\\ f ." "POSTPONE: f" }
"They are not equal:"
{ $example "f \\ f = ." "f" }
"Here is an array containing the " { $link f } " object:"
{ $example "{ f } ." "{ f }" }
"Here is an array containing the " { $link f } " class:"
{ $example "{ POSTPONE: f } ." "{ POSTPONE: f }" }
"The " { $link f } " object is an instance of the " { $link f } " class:"
{ $example "f class ." "POSTPONE: f" }
"The " { $link f } " class is an instance of " { $link word } ":"
{ $example "\\ f class ." "word" }
"On the other hand, " { $link t } " is just a word, and there is no class which it is a unique instance of."
{ $example "t \\ t eq? ." "t" }
"Many words which search collections confuse the case of no element being present with an element being found equal to " { $link f } ". If this distinction is imporant, there is usually an alternative word which can be used; for example, compare " { $link at } " with " { $link at* } "."
$nl
"A tuple cannot delegate to " { $link f } " at all, since a delegate of " { $link f } " actually denotes that no delegate is set. See " { $link set-delegate } "." ;

ARTICLE: "conditionals" "Conditionals and logic"
"The basic conditionals:"
{ $subsection if }
{ $subsection when }
{ $subsection unless }
"Forms abstracting a common stack shuffle pattern:"
{ $subsection if* }
{ $subsection when* }
{ $subsection unless* }
"Another form abstracting a common stack shuffle pattern:"
{ $subsection ?if }
"Sometimes instead of branching, you just need to pick one of two values:"
{ $subsection ? }
"Forms which abstract away common patterns involving multiple nested branches:"
{ $subsection cond }
{ $subsection case }
"There are some logical operations on booleans:"
{ $subsection >boolean }
{ $subsection not }
{ $subsection and }
{ $subsection or }
{ $subsection xor }
{ $see-also "booleans" "bitwise-arithmetic" both? either? } ;

ARTICLE: "equality" "Equality and comparison testing"
"There are two distinct notions of ``sameness'' when it comes to objects. You can test if two references point to the same object, or you can test if two objects are equal in some sense, usually by being instances of the same class, and having equal slot values. Both notions of equality are equality relations in the mathematical sense."
{ $subsection eq? }
{ $subsection = }
"Some types of objects also have an intrinsic order allowing sorting using " { $link natural-sort } ":"
{ $subsection <=> }
{ $subsection compare }
"An object can be cloned; the clone has distinct identity but equal value:"
{ $subsection clone } ;

! Defined in handbook.factor
ABOUT: "dataflow"

HELP: version
{ $values { "str" string } }
{ $description "Outputs the version number of the current Factor instance." } ;

HELP: eq? ( obj1 obj2 -- ? )
{ $values { "obj1" object } { "obj2" object } { "?" "a boolean" } }
{ $description "Tests if two references point at the same object." } ;

HELP: drop  ( x -- )                 $shuffle ;
HELP: 2drop ( x y -- )               $shuffle ;
HELP: 3drop ( x y z -- )             $shuffle ;
HELP: dup   ( x -- x x )             $shuffle ;
HELP: 2dup  ( x y -- x y x y )       $shuffle ;
HELP: 3dup  ( x y z -- x y z x y z ) $shuffle ;
HELP: rot   ( x y z -- y z x )       $shuffle ;
HELP: -rot  ( x y z -- z x y )       $shuffle ;
HELP: dupd  ( x y -- x x y )         $shuffle ;
HELP: swapd ( x y z -- y x z )       $shuffle ;
HELP: nip   ( x y -- y )             $shuffle ;
HELP: 2nip  ( x y z -- z )           $shuffle ;
HELP: tuck  ( x y -- y x y )         $shuffle ;
HELP: over  ( x y -- x y x )         $shuffle ;
HELP: pick  ( x y z -- x y z x )     $shuffle ;
HELP: swap  ( x y -- y x )           $shuffle ;
HELP: roll                           $shuffle ;
HELP: -roll                          $shuffle ;

HELP: >r ( x -- )
{ $values { "x" object } } { $description "Moves the top of the data stack to the retain stack." } ;

HELP: r> ( -- x )
{ $values { "x" object } } { $description "Moves the top of the retain stack to the data stack." } ;

HELP: datastack ( -- ds )
{ $values { "ds" array } }
{ $description "Outputs an array containing a copy of the data stack contents right before the call to this word, with the top of the stack at the end of the array." } ;

HELP: set-datastack ( ds -- )
{ $values { "ds" array } }
{ $description "Replaces the data stack contents with a copy of an array. The end of the array becomes the top of the stack." } ;

HELP: retainstack ( -- rs )
{ $values { "rs" array } }
{ $description "Outputs an array containing a copy of the retain stack contents right before the call to this word, with the top of the stack at the end of the array." } ;

HELP: set-retainstack ( rs -- )
{ $values { "rs" array } }
{ $description "Replaces the retain stack contents with a copy of an array. The end of the array becomes the top of the stack." } ;

HELP: callstack ( -- cs )
{ $values { "cs" callstack } }
{ $description "Outputs a copy of the call stack contents, with the top of the stack at the end of the vector. The stack frame of the caller word is " { $emphasis "not" } " included." } ;

HELP: set-callstack ( cs -- )
{ $values { "cs" callstack } }
{ $description "Replaces the call stack contents. The end of the vector becomes the top of the stack. Control flow is transferred immediately to the new call stack." } ;

HELP: clear
{ $description "Clears the data stack." } ;

HELP: hashcode*
{ $values { "depth" integer } { "obj" object } { "code" fixnum } }
{ $contract "Outputs the hashcode of an object. The hashcode operation must satisfy the following properties:"
{ $list
    { "if two objects are equal under " { $link = } ", they must have equal hashcodes" }
    { "if the hashcode of an object depends on the values of its slots, the hashcode of the slots must be computed recursively by calling " { $link hashcode* } " with a " { $snippet "level" } " parameter decremented by one. This avoids excessive work while still computing well-distributed hashcodes. The " { $link recursive-hashcode } " combinator can help with implementing this logic" }
    { "the hashcode should be a " { $link fixnum } ", however returning a " { $link bignum } " will not cause any problems other than potential performance degradation."
    "the hashcode is only permitted to change between two invocations if the object was mutated in some way" }
}
"If mutable objects are used as hashtable keys, they must not be mutated in such a way that their hashcode changes. Doing so will violate bucket sorting invariants and result in undefined behavior." } ;

HELP: hashcode
{ $values { "obj" object } { "code" fixnum } }
{ $description "Computes the hashcode of an object with a default hashing depth. See " { $link hashcode* } " for the hashcode contract." } ;

{ hashcode hashcode* } related-words

HELP: =
{ $values { "obj1" object } { "obj2" object } { "?" "a boolean" } }
{ $description
    "Tests if two objects are equal. If " { $snippet "obj1" } " and " { $snippet "obj2" } " point to the same object, outputs " { $link t } ". Otherwise, calls the " { $link equal? } " generic word."
} ;

HELP: equal?
{ $values { "obj1" object } { "obj2" object } { "?" "a boolean" } }
{ $contract
    "Tests if two objects are equal."
    $nl
    "Method definitions should ensure that this is an equality relation:"
    { $list
        { $snippet "a = a" }
        { { $snippet "a = b" } " implies " { $snippet "b = a" } }
        { { $snippet "a = b" } " and " { $snippet "b = c" } " implies " { $snippet "a = c" } }
    }
    "While user code can define methods for this generic word, it should not call it directly, since it does not handle the case where the two references point to the same object."
}
{ $examples
    "The most common reason for defining a method for this generic word to ensure that instances of a specific tuple class are only ever equal to themselves, overriding the default implementation which checks slot values for equality."
    { $code "TUPLE: foo ;" "M: foo equal? 2drop f ;" }
    "Note that with the above definition, calling " { $link equal? } " directly will give unexpected results:"
    { $unchecked-example "T{ foo } dup equal? ." "f" }
    { $unchecked-example "T{ foo } dup clone equal? ." "f" }
    "As documented above, " { $link = } " should be called instead:"
    { $unchecked-example "T{ foo } dup = ." "t" }
    { $unchecked-example "T{ foo } dup clone = ." "f" }
} ;

HELP: <=>
{ $values { "obj1" object } { "obj2" object } { "n" real } }
{ $contract
    "Compares two objects using an intrinsic partial order, for example, the natural order for real numbers and lexicographic order for strings."
    $nl
    "The output value is one of the following:"
    { $list
        { "positive - indicating that " { $snippet "obj1" } " follows " { $snippet "obj2" } }
        { "zero - indicating that " { $snippet "obj1" } " is equal to " { $snippet "obj2" } }
        { "negative - indicating that " { $snippet "obj1" } " precedes " { $snippet "obj2" } }
    }
    "The default implementation treats the two objects as sequences, and recursively compares their elements. So no extra work is required to compare sequences lexicographically."
} ;

{ <=> compare natural-sort sort-keys sort-values } related-words

HELP: compare
{ $values { "obj1" object } { "obj2" object } { "quot" "a quotation with stack effect " { $snippet "( obj -- newobj )" } } { "n" integer } }
{ $description "Compares the results of applying the quotation to both objects via " { $link <=> } "." }
{ $examples
    { $example "\"hello\" \"hi\" [ length ] compare ." "3" }
} ;

HELP: clone
{ $values { "obj" object } { "cloned" "a new object" } }
{ $contract "Outputs a new object equal to the given object. This is not guaranteed to actually copy the object; it does nothing with immutable objects, and does not copy words either. However, sequences and tuples can be cloned to obtain a shallow copy of the original." } ;

HELP: type ( object -- n )
{ $values { "object" object } { "n" "a type number" } }
{ $description "Outputs an object's type number, between zero and one less than " { $link num-types } ". This is implementation detail and user code should call " { $link class } " instead." } ;

{ type tag type>class } related-words

HELP: ? ( ? true false -- true/false )
{ $values { "?" "a generalized boolean" } { "true" object } { "false" object } { "true/false" "one two input objects" } }
{ $description "Chooses between two values depending on the boolean value of " { $snippet "cond" } "." } ;

HELP: >boolean
{ $values { "obj" "a generalized boolean" } { "?" "a boolean" } }
{ $description "Convert a generalized boolean into a boolean. That is, " { $link f } " retains its value, whereas anything else becomes " { $link t } "." } ;

HELP: not ( obj -- ? )
{ $values { "obj" "a generalized boolean" } { "?" "a boolean" } }
{ $description "For " { $link f } " outputs " { $link t } " and for anything else outputs " { $link f } "." }
{ $notes "This word implements boolean not, so applying it to integers will not yield useful results (all integers have a true value). Bitwise not is the " { $link bitnot } " word." } ;

HELP: and
{ $values { "obj1" "a generalized boolean" } { "obj2" "a generalized boolean" } { "?" "a generalized boolean" } }
{ $description "If both inputs are true, outputs " { $snippet "obj2" } ". otherwise outputs " { $link f } "." }
{ $notes "This word implements boolean and, so applying it to integers will not yield useful results (all integers have a true value). Bitwise and is the " { $link bitand } " word." }
{ $examples
    "Usually only the boolean value of the result is used, however you can also explicitly rely on the behavior that if both inputs are true, the second is output:"
    { $example "t f and ." "f" }
    { $example "t 7 and ." "7" }
    { $example "\"hi\" 12.0 and ." "12.0" }
} ;

HELP: or
{ $values { "obj1" "a generalized boolean" } { "obj2" "a generalized boolean" } { "?" "a generalized boolean" } }
{ $description "If both inputs are false, outputs " { $link f } ". otherwise outputs the first of " { $snippet "obj1" } " and " { $snippet "obj2" } " which is true." }
{ $notes "This word implements boolean inclusive or, so applying it to integers will not yield useful results (all integers have a true value). Bitwise inclusive or is the " { $link bitor } " word." }
{ $examples
    "Usually only the boolean value of the result is used, however you can also explicitly rely on the behavior that the result will be the first true input:"
    { $example "t f or ." "t" }
    { $example "\"hi\" 12.0 or ." "\"hi\"" }
} ;

HELP: xor
{ $values { "obj1" "a generalized boolean" } { "obj2" "a generalized boolean" } { "?" "a generalized boolean" } }
{ $description "Tests if at exactly one object is not " { $link f } "." }
{ $notes "This word implements boolean exclusive or, so applying it to integers will not yield useful results (all integers have a true value). Bitwise exclusive or is the " { $link bitxor } " word." } ;

HELP: both?
{ $values { "quot" "a quotation with stack effect " { $snippet "( obj -- ? )" } } { "x" object } { "y" object } { "?" "a boolean" } }
{ $description "Tests if the quotation yields a true value when applied to both " { $snippet "x" } " and " { $snippet "y" } "." }
{ $examples
    { $example "3 5 [ odd? ] both? ." "t" }
    { $example "12 7 [ even? ] both? ." "f" }
} ;

HELP: either?
{ $values { "quot" "a quotation with stack effect " { $snippet "( obj -- ? )" } } { "x" object } { "y" object } { "?" "a boolean" } }
{ $description "Tests if the quotation yields a true value when applied to either " { $snippet "x" } " or " { $snippet "y" } "." }
{ $examples
    { $example "3 6 [ odd? ] either? ." "t" }
    { $example "5 7 [ even? ] either? ." "f" }
} ;

HELP: call ( quot -- )
{ $values { "quot" callable } }
{ $description "Calls a quotation."
$nl
"Under the covers, pushes the current call frame on the call stack, and set the call frame to the given quotation." }
{ $examples
    "The following two lines are equivalent:"
    { $code "2 [ 2 + 3 * ] call" "2 2 + 3 *" }
} ;

HELP: call-clear ( quot -- )
{ $values { "quot" callable } }
{ $description "Calls a quotation with an empty call stack. If the quotation returns, Factor will exit.." }
{ $notes "Used to implement " { $link "threads" } "." } ;

HELP: slip
{ $values { "quot" quotation } { "x" object } }
{ $description "Calls a quotation while hiding the top of the stack." } ;

HELP: 2slip
{ $values { "quot" quotation } { "x" object } { "y" object } }
{ $description "Calls a quotation while hiding the top two stack elements." } ;

HELP: 3slip
{ $values { "quot" quotation } { "x" object } { "y" object } { "z" object } }
{ $description "Calls a quotation while hiding the top three stack elements." } ;

HELP: keep
{ $values { "quot" "a quotation with stack effect " { $snippet "( x -- )" } } { "x" object } }
{ $description "Call a quotation with a value on the stack, restoring the value when the quotation returns." } ;

HELP: 2keep
{ $values { "quot" "a quotation with stack effect " { $snippet "( x y -- )" } } { "x" object } { "y" object } }
{ $description "Call a quotation with two values on the stack, restoring the values when the quotation returns." } ;

HELP: 3keep
{ $values { "quot" "a quotation with stack effect " { $snippet "( x y -- )" } } { "x" object } { "y" object } { "z" object } }
{ $description "Call a quotation with three values on the stack, restoring the values when the quotation returns." } ;

HELP: 2apply
{ $values { "quot" "a quotation with stack effect " { $snippet "( obj -- )" } } { "x" object } { "y" object } }
{ $description "Applies the quotation to " { $snippet "x" } ", then to " { $snippet "y" } "." } ;

HELP: if ( cond true false -- )
{ $values { "cond" "a generalized boolean" } { "true" quotation } { "false" quotation } }
{ $description "If " { $snippet "cond" } " is " { $link f } ", calls the " { $snippet "false" } " quotation. Otherwise calls the " { $snippet "true" } " quotation."
$nl
"The " { $snippet "cond" } " value is removed from the stack before either quotation is called." } ;

HELP: when
{ $values { "cond" "a generalized boolean" } { "true" quotation } }
{ $description "If " { $snippet "cond" } " is not " { $link f } ", calls the " { $snippet "true" } " quotation."
$nl
"The " { $snippet "cond" } " value is removed from the stack before the quotation is called." } ;

HELP: unless
{ $values { "cond" "a generalized boolean" } { "false" quotation } }
{ $description "If " { $snippet "cond" } " is " { $link f } ", calls the " { $snippet "false" } " quotation."
$nl
"The " { $snippet "cond" } " value is removed from the stack before the quotation is called." } ;

HELP: if*
{ $values { "cond" "a generalized boolean" } { "true" "a quotation with stack effect " { $snippet "( cond -- )" } } { "false" quotation } }
{ $description "Alternative conditional form that preserves the " { $snippet "cond" } " value if it is true."
$nl
"If the condition is true, it is retained on the stack before the " { $snippet "true" } " quotation is called. Otherwise, the condition is removed from the stack and the " { $snippet "false" } " quotation is called."
$nl
"The following two lines are equivalent:"
{ $code "X [ Y ] [ Z ] if*" "X dup [ Y ] [ drop Z ] if" } } ;

HELP: when*
{ $values { "cond" "a generalized boolean" } { "true" "a quotation with stack effect " { $snippet "( cond -- )" } } }
{ $description "Variant of " { $link if* } " with no false quotation."
$nl
"The following two lines are equivalent:"
{ $code "X [ Y ] when*" "X dup [ Y ] [ drop ] if" } } ;

HELP: unless*
{ $values { "cond" "a generalized boolean" } { "false" "a quotation " } }
{ $description "Variant of " { $link if* } " with no true quotation."
$nl
"The following two lines are equivalent:"
{ $code "X [ Y ] unless*" "X dup [ ] [ drop Y ] if" } } ;

HELP: ?if
{ $values { "default" object } { "cond" "a generalized boolean" } { "true" "a quotation with stack effect " { $snippet "( cond -- )" } } { "false" "a quotation with stack effect " { $snippet "( default -- )" } } }
{ $description "If the condition is " { $link f } ", the " { $snippet "false" } " quotation is called with the " { $snippet "default" } " value on the stack. Otherwise, the " { $snippet "true" } " quotation is called with the condition on the stack."
$nl
"The following two lines are equivalent:"
{ $code "[ X ] [ Y ] ?if" "dup [ nip X ] [ drop Y ] if" } } ;

HELP: die
{ $description "Starts the front-end processor (FEP), which is a low-level debugger which can inspect memory addresses and the like. The FEP is also entered when a critical error occurs." } ;

HELP: (clone) ( obj -- newobj )
{ $values { "obj" object } { "newobj" "a shallow copy" } }
{ $description "Outputs a byte-by-byte copy of the given object. User code should call " { $link clone } " instead." } ;

HELP: declare
{ $values { "spec" "an array of class words" } }
{ $description "Declares that the elements at the top of the stack are instances of the classes in " { $snippet "spec" } "." }
{ $warning "The compiler blindly trusts declarations, and false declarations can lead to crashes, memory corruption and other undesirable behavior." }
{ $examples
    "The optimizer cannot do anything with the below code:"
    { $code "2 + 10 *" }
    "However, if we declare that the top of the stack is a " { $link float } ", then type checks and generic dispatch are eliminated, and the compiler can use unsafe intrinsics:"
    { $code "{ float } declare 2 + 10 *" }
} ;

HELP: tag ( object -- n )
{ $values { "object" object } { "n" "a tag number" } }
{ $description "Outputs an object's tag number, between zero and one less than " { $link num-tags } ". This is implementation detail and user code should call " { $link class } " instead." } ;

HELP: getenv ( n -- obj )
{ $values { "n" "a non-negative integer" } { "obj" object } }
{ $description "Reads an object from the Factor VM's environment table. User code never has to read the environment table directly; instead, use one of the callers of this word." } ;

HELP: setenv ( obj n -- )
{ $values { "n" "a non-negative integer" } { "obj" object } }
{ $description "Writes an object to the Factor VM's environment table. User code never has to write to the environment table directly; instead, use one of the callers of this word." } ;

HELP: object
{ $class-description
    "The class of all objects. If a generic word defines a method specializing on this class, the method is used as a fallback, if no other applicable method is found. For instance:"
    { $code "GENERIC: enclose" "M: number enclose 1array ;" "M: object enclose ;" }
} ;

HELP: null
{ $class-description
    "The canonical empty class with no instances."
} ;

HELP: general-t
{ $class-description
    "The class of all objects not equal to " { $link f } "."
}
{ $examples
    "Here is an implementation of " { $link if } " using generic words:"
    { $code
        "GENERIC# my-if 2 ( ? true false -- )"
        "M: f my-if 2nip call ;"
        "M: general-t my-if drop nip call ;"
    }
} ;

HELP: most
{ $values { "x" object } { "y" object } { "quot" "a quotation with stack effect " { $snippet "( x y -- ? )" } } { "z" "either " { $snippet "x" } " or " { $snippet "y" } } }
{ $description "If the quotation yields a true value when applied to " { $snippet "x" } " and " { $snippet "y" } ", outputs " { $snippet "x" } ", otherwise outputs " { $snippet "y" } "." } ;

HELP: curry ( obj quot -- curry )
{ $values { "obj" object } { "quot" callable } { "curry" curry } }
{ $description "Partial application. Outputs a " { $link callable } " which first pushes " { $snippet "obj" } " and then calls " { $snippet "quot" } "." }
{ $class-description "The class of objects created by " { $link curry } ". These objects print identically to quotations and implement the sequence protocol, however they only use two cells of storage; a reference to the object and a reference to the underlying quotation." }
{ $notes "Even if " { $snippet "obj" } " is a word, it will be pushed as a literal."
$nl
"This operation is efficient and does not copy the quotation." }
{ $examples
    { $example "5 [ . ] curry ." "[ 5 . ]" }
    { $example "\\ = [ see ] curry ." "[ \\ = see ]" }
    { $example "{ 1 2 3 } 2 [ - ] curry map ." "{ -1 0 1 }" }
} ;

HELP: 2curry
{ $values { "obj1" object } { "obj2" object } { "quot" callable } { "curry" curry } }
{ $description "Outputs a " { $link callable } " which pushes " { $snippet "obj1" } " and " { $snippet "obj2" } " and then calls " { $snippet "quot" } "." }
{ $notes "This operation is efficient and does not copy the quotation." }
{ $examples
    { $example "5 4 [ + ] 2curry ." "[ 5 4 + ]" }
} ;

HELP: 3curry
{ $values { "obj1" object } { "obj2" object } { "obj3" object } { "quot" callable } { "curry" curry } }
{ $description "Outputs a " { $link callable } " which pushes " { $snippet "obj1" } ", " { $snippet "obj2" } " and " { $snippet "obj3" } ", and then calls " { $snippet "quot" } "." }
{ $notes "This operation is efficient and does not copy the quotation." } ;

HELP: curry*
{ $values { "param" object } { "obj" object } { "quot" "a quotation with stack effect " { $snippet "( param elt -- ... )" } } { "obj" object } { "curry" curry } }
{ $description "Partial application on the left. The following two lines are equivalent:"
    { $code "swap [ swap A ] curry B" }
    { $code "[ A ] curry* B" }
    
}
{ $notes "This operation is efficient and does not copy the quotation." }
{ $examples
    { $example "2 { 1 2 3 } [ - ] curry* map ." "{ 1 0 -1 }" }
} ;

HELP: compose
{ $values { "quot1" callable } { "quot2" callable } { "curry" curry } }
{ $description "Quotation composition. Outputs a " { $link callable } " which calls " { $snippet "quot1" } " followed by " { $snippet "quot2" } "." }
{ $notes
    "The following two lines are equivalent:"
    { $code
        "compose call"
        "append call"
    }
    "However, " { $link compose } " runs in constant time, and the compiler is able to compile code which calls composed quotations."
} ;

HELP: 3compose
{ $values { "quot1" callable } { "quot2" callable } { "quot3" callable } { "curry" curry } }
{ $description "Quotation composition. Outputs a " { $link callable } " which calls " { $snippet "quot1" } ", " { $snippet "quot2" } " and then " { $snippet "quot3" } "." }
{ $notes
    "The following two lines are equivalent:"
    { $code
        "3compose call"
        "3append call"
    }
    "However, " { $link 3compose } " runs in constant time, and the compiler is able to compile code which calls composed quotations."
} ;

HELP: while
{ $values { "pred" "a quotation with stack effect " { $snippet "( -- ? )" } } { "quot" "a quotation" } { "tail" "a quotation" } }
{ $description "Repeatedly calls " { $snippet "pred" } ". If it yields " { $link f } ", iteration stops, otherwise " { $snippet "quot" } " is called. After iteration stops, " { $snippet "tail" } " is called." }
{ $notes "In most cases, tail recursion should be used, because it is simpler both in terms of implementation and conceptually. However in some cases this combinator expresses intent better and should be used."
$nl
"Strictly speaking, the " { $snippet "tail" } " is not necessary, since the following are equivalent:"
{ $code
    "[ P ] [ Q ] [ T ] while"
    "[ P ] [ Q ] [ ] while T"
}
"However, depending on the stack effects of " { $snippet "pred" } " and " { $snippet "quot" } ", the " { $snippet "tail" } " quotation might need to be non-empty in order to balance out the stack effect of branches for stack effect inference." } ;
