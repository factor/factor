USING: alien arrays classes combinators heaps help.markup help.syntax
kernel.private layouts math quotations sequences system threads words ;
IN: kernel

HELP: OBJ-CURRENT-THREAD
{ $description "Contains a reference to the running " { $link thread } " instance." } ;

HELP: JIT-PUSH-LITERAL
{ $description "JIT code template for pushing literals unto the datastack." } ;

HELP: OBJ-SAMPLE-CALLSTACKS
{ $description "A " { $link sequence } " that contains all call frames that is being captured during sampling profiling. See the " { $vocab-link "tools.profiler.sampling" } " vocab." } ;

HELP: OBJ-SLEEP-QUEUE
{ $description "A " { $link min-heap } " containing sleeping threads." }
{ $see-also sleep-queue } ;

HELP: OBJ-UNDEFINED
{ $description "Default definition for undefined words" } ;

HELP: WIN-EXCEPTION-HANDLER
{ $description "This special object is an " { $link alien } " containing a pointer to the processes global exception handler. Only applicable on " { $link windows } "." } ;

HELP: eq?
{ $values { "obj1" object } { "obj2" object } { "?" boolean } }
{ $description "Tests if two references point at the same object." } ;

HELP: drop  $shuffle ;
HELP: 2drop $shuffle ;
HELP: 3drop $shuffle ;
HELP: 4drop $shuffle ;
HELP: dup   $shuffle ;
HELP: 2dup  $shuffle ;
HELP: 3dup  $shuffle ;
HELP: 4dup  $shuffle ;
HELP: nip   $shuffle ;
HELP: nipd  $shuffle ;
HELP: 2nip  $shuffle ;
HELP: 2nipd $shuffle ;
HELP: 3nip  $shuffle ;
HELP: 3nipd $shuffle ;
HELP: 4nip  $shuffle ;
HELP: 5nip  $shuffle ;
HELP: over  $shuffle ;
HELP: overd $shuffle ;
HELP: 2over $shuffle ;
HELP: pick  $shuffle ;
HELP: pickd $shuffle ;
HELP: reach $shuffle ;
HELP: swap  $shuffle ;
HELP: spin  $shuffle ;
HELP: 4spin $shuffle ;
HELP: roll  $shuffle ;
HELP: -roll $shuffle ;
HELP: tuck  $shuffle ;
HELP: rot   $shuffle ;
HELP: -rot  $shuffle ;
HELP: rotd  $shuffle ;
HELP: -rotd $shuffle ;
HELP: dupd  $shuffle ;
HELP: swapd $shuffle ;

HELP: callstack>array
{ $values { "callstack" callstack } { "array" array } }
{ $description "Converts the callstack to an array containing groups of three elements. The array is in reverse order so that the innermost frame comes first." } ;

HELP: get-datastack
{ $values { "array" array } }
{ $description "Outputs an array containing a copy of the data stack contents right before the call to this word, with the top of the stack at the end of the array." } ;

HELP: set-datastack
{ $values { "array" array } }
{ $description "Replaces the data stack contents with a copy of an array. The end of the array becomes the top of the stack." } ;

HELP: get-retainstack
{ $values { "array" array } }
{ $description "Outputs an array containing a copy of the retain stack contents right before the call to this word, with the top of the stack at the end of the array." } ;

HELP: set-retainstack
{ $values { "array" array } }
{ $description "Replaces the retain stack contents with a copy of an array. The end of the array becomes the top of the stack." } ;

HELP: get-callstack
{ $values { "callstack" callstack } }
{ $description "Outputs a copy of the call stack contents, with the top of the stack at the end of the vector. The stack frame of the caller word is " { $emphasis "not" } " included. Each group of three elements in the callstack is frame:"
  { $list
    "The first element is the executing word or quotation."
    "The second element is the executing quotation."
    "The third element is the offset in the executing quotation, or -1 if the offset can't be determined."
  }
} ;

HELP: set-callstack
{ $values { "callstack" callstack } }
{ $description "Replaces the call stack contents. Control flow is transferred immediately to the innermost frame of the new call stack." } ;

HELP: clear
{ $description "Clears the data stack." } ;

HELP: build
{ $values { "n" integer } }
{ $description "The current build number. Factor increments this number whenever a new boot image is created." } ;

HELP: leaf-signal-handler
{ $description "A word called by the VM when a VM error occurs." } ;

HELP: hashcode*
{ $values { "depth" integer } { "obj" object } { "code" fixnum } }
{ $contract "Outputs the hashcode of an object. The hashcode operation must satisfy the following properties:"
{ $list
    { "If two objects are equal under " { $link = } ", they must have equal hashcodes." }
    { "The hashcode is only permitted to change between two invocations if the object or one of its slot values was mutated." }
}
"If mutable objects are used as hashtable keys, they must not be mutated in such a way that their hashcode changes. Doing so will violate bucket sorting invariants and result in undefined behavior. See " { $link "hashtables.keys" } " for details." } ;

HELP: hashcode
{ $values { "obj" object } { "code" fixnum } }
{ $description "Computes the hashcode of an object with a default hashing depth. See " { $link hashcode* } " for the hashcode contract." } ;

HELP: recursive-hashcode
{ $values { "n" integer } { "obj" object } { "quot" { $quotation ( n obj -- code ) } } { "code" integer } }
{ $description "A combinator used to implement methods for the " { $link hashcode* } " generic word. If " { $snippet "n" } " is less than or equal to zero, outputs 0, otherwise calls the quotation." } ;

HELP: identity-hashcode
{ $values { "obj" object } { "code" fixnum } }
{ $description "Outputs the identity hashcode of an object. The identity hashcode is not guaranteed to be unique, however it will not change during the object's lifetime." } ;

{ hashcode hashcode* identity-hashcode } related-words

HELP: =
{ $values { "obj1" object } { "obj2" object } { "?" boolean } }
{ $description
    "Tests if two objects are equal. If " { $snippet "obj1" } " and " { $snippet "obj2" } " point to the same object, outputs " { $link t } ". Otherwise, calls the " { $link equal? } " generic word."
}
{ $examples
    { $example "USING: kernel prettyprint ;" "5 5 = ." "t" }
    { $example "USING: kernel prettyprint ;" "5 005 = ." "t" }
    { $example "USING: kernel prettyprint ;" "5 5.0 = ." "f" }
    { $example "USING: arrays kernel prettyprint ;" "{ \"a\" \"b\" } \"a\" \"b\" 2array = ." "t" }
    { $example "USING: arrays kernel prettyprint ;" "{ \"a\" \"b\" } [ \"a\" \"b\" ] = ." "f" }
} ;

HELP: equal?
{ $values { "obj1" object } { "obj2" object } { "?" boolean } }
{ $contract
    "Tests if two objects are equal."
    $nl
    "User code should call " { $link = } " instead; that word first tests the case where the objects are " { $link eq? } ", and so by extension, methods defined on " { $link equal? } " assume they are never called on " { $link eq? } " objects."
    $nl
    "Method definitions should ensure that this is an equality relation, modulo the assumption that the two objects are not " { $link eq? } ". That is, for any three non-" { $link eq? } " objects " { $snippet "a" } ", " { $snippet "b" } " and " { $snippet "c" } ", we must have:"
    { $list
        { { $snippet "a = b" } " implies " { $snippet "b = a" } }
        { { $snippet "a = b" } " and " { $snippet "b = c" } " implies " { $snippet "a = c" } }
    }
    "If a class defines a custom equality comparison test, it should also define a compatible method for the " { $link hashcode* } " generic word."
}
{ $examples
    "An example demonstrating why this word should only be used to define methods on, and never called directly:"
    { $example "USING: kernel prettyprint ;" "5 5 equal? ." "f" }
    "Using " { $link = } " gives the expected behavior:"
    { $example "USING: kernel prettyprint ;" "5 5 = ." "t" }
} ;

HELP: identity-tuple
{ $class-description "A class defining an " { $link equal? } " method which always returns f." }
{ $examples
    "To define a tuple class such that two instances are only equal if they are both the same instance, inherit from the " { $link identity-tuple } " class. This class defines a method on " { $link equal? } " which always returns " { $link f } ". Since " { $link = } " handles the case where the two objects are " { $link eq? } ", this method will never be called with two " { $link eq? } " objects, so such a definition is valid:"
    { $code "TUPLE: foo < identity-tuple ;" }
    "By calling " { $link = } " on instances of " { $snippet "foo" } " we get the results we expect:"
    { $unchecked-example "T{ foo } dup = ." "t" }
    { $unchecked-example "T{ foo } dup clone = ." "f" }
} ;

HELP: clone
{ $values { "obj" object } { "cloned" "a new object" } }
{ $contract "Outputs a new object equal to the given object. This is not guaranteed to actually copy the object; it does nothing with immutable objects, and does not copy words either. However, sequences and tuples can be cloned to obtain a shallow copy of the original." } ;

HELP: ?
{ $values { "?" boolean } { "true" object } { "false" object } { "true/false" object } }
{ $description "Chooses between two values depending on the boolean value of " { $snippet "?" } "." }
{ $examples
    { $example
        "USING: io kernel math ;"
        "3 4 < \"3 is smaller than 4\" \"3 is not smaller than 4\" ? print"
        "3 is smaller than 4"
    }
    { $example
        "USING: io kernel math ;"
        "4 3 < \"4 is smaller than 3\" \"4 is not smaller than 3\" ? print"
        "4 is not smaller than 3"
    }
} ;

HELP: boolean
{ $class-description "A union of the " { $link POSTPONE: t } " and " { $link POSTPONE: f } " classes." } ;

HELP: >boolean
{ $values { "obj" "a generalized boolean" } { "?" boolean } }
{ $description "Convert a generalized boolean into a boolean. That is, " { $link f } " retains its value, whereas anything else becomes " { $link t } "." } ;

HELP: not
{ $values { "obj" "a generalized boolean" } { "?" boolean } }
{ $description "For " { $link f } " outputs " { $link t } " and for anything else outputs " { $link f } "." }
{ $notes "This word implements boolean not, so applying it to integers will not yield useful results (all integers have a true value). Bitwise not is the " { $link bitnot } " word." } ;

HELP: and
{ $values { "obj1" "a generalized boolean" } { "obj2" "a generalized boolean" } { "obj2/f" "a generalized boolean" } }
{ $description "If both inputs are true, outputs " { $snippet "obj2" } ". Otherwise outputs " { $link f } "." }
{ $notes "This word implements boolean and, so applying it to integers will not yield useful results (all integers have a true value). Bitwise and is the " { $link bitand } " word." }
{ $examples
    "Usually only the boolean value of the result is used, however you can also explicitly rely on the behavior that if both inputs are true, the second is output:"
    { $example "USING: kernel prettyprint ;" "t f and ." "f" }
    { $example "USING: kernel prettyprint ;" "t 7 and ." "7" }
    { $example "USING: kernel prettyprint ;" "\"hi\" 12.0 and ." "12.0" }
} ;

HELP: and*
{ $values { "obj1" "a generalized boolean" } { "obj2" "a generalized boolean" } { "obj1/f" "a generalized boolean" } }
{ $description "If both inputs are true, outputs " { $snippet "obj1" } ". Otherwise outputs " { $link f } "." }
{ $notes "This word implements boolean and, so applying it to integers will not yield useful results (all integers have a true value). Bitwise and is the " { $link bitand } " word." }
{ $examples
    "Usually only the boolean value of the result is used, however you can also explicitly rely on the behavior that if both inputs are true, the first is output:"
    { $example "USING: kernel prettyprint ;" "t f and* ." "f" }
    { $example "USING: kernel prettyprint ;" "t 7 and* ." "t" }
    { $example "USING: kernel prettyprint ;" "\"hi\" 12.0 and* ." "\"hi\"" }
} ;

{ and and* } related-words

HELP: or
{ $values { "obj1" "a generalized boolean" } { "obj2" "a generalized boolean" } { "obj1/obj2" "a generalized boolean" } }
{ $description "If both inputs are false, outputs " { $link f } ". Otherwise outputs the first of " { $snippet "obj1" } " and " { $snippet "obj2" } " which is true." }
{ $notes "This word implements boolean inclusive or, so applying it to integers will not yield useful results (all integers have a true value). Bitwise inclusive or is the " { $link bitor } " word." }
{ $examples
    "Usually only the boolean value of the result is used, however you can also explicitly rely on the behavior that the result will be the first true input:"
    { $example "USING: kernel prettyprint ;" "t f or ." "t" }
    { $example "USING: kernel prettyprint ;" "\"hi\" 12.0 or ." "\"hi\"" }
} ;

HELP: or*
{ $values { "obj1" "a generalized boolean" } { "obj2" "a generalized boolean" } { "obj2/obj1" "a generalized boolean" } }
{ $description "If both inputs are false, outputs " { $link f } ". Otherwise outputs the first of " { $snippet "obj2" } " and " { $snippet "obj1" } " which is true." }
{ $notes "This word implements boolean inclusive or, so applying it to integers will not yield useful results (all integers have a true value). Bitwise inclusive or is the " { $link bitor } " word." }
{ $examples
    "Usually only the boolean value of the result is used, however you can also explicitly rely on the behavior that the result will be the last true input:"
    { $example "USING: kernel prettyprint ;" "t f or* ." "t" }
    { $example "USING: kernel prettyprint ;" "\"hi\" 12.0 or* ." "12.0" }
} ;

HELP: or?
{ $values
    { "obj1" "a generalized boolean" }
    { "obj2" "a generalized boolean" }
    { "obj2/obj1" "a generalized boolean" }
    { "second?" "boolean" }
}
{ $description "A version of " { $link or } " which prefers to return second argument instead of the first. The output " { $snippet "second?" } " tells you which object was returned." }
{ $examples
    "Prefers the second argument:"
    { $example "USING: arrays kernel prettyprint ;"
        "f 3 or? 2array ."
        "{ 3 t }"
    }
    "Will also return the first:"
    { $example "USING: arrays kernel prettyprint ;"
        "3 f or? 2array ."
        "{ 3 f }"
    }
    "Can return false:"
    { $example "USING: arrays kernel prettyprint ;"
        "f f or? 2array ."
        "{ f f }"
    }
} ;

{ or or* or? } related-words

HELP: xor
{ $values { "obj1" "a generalized boolean" } { "obj2" "a generalized boolean" } { "obj1/obj2/f" "a generalized boolean" } }
{ $description "If exactly one input is false, outputs the other input. Otherwise outputs " { $link f } "." }
{ $notes "This word implements boolean exclusive or, so applying it to integers will not yield useful results (all integers have a true value). Bitwise exclusive or is the " { $link bitxor } " word." } ;

HELP: both?
{ $values { "x" object } { "y" object } { "quot" { $quotation ( ... obj -- ... ? ) } } { "?" boolean } }
{ $description "Tests if the quotation yields a true value when applied to both " { $snippet "x" } " and " { $snippet "y" } "." }
{ $examples
    { $example "USING: kernel math prettyprint ;" "3 5 [ odd? ] both? ." "t" }
    { $example "USING: kernel math prettyprint ;" "12 7 [ even? ] both? ." "f" }
} ;

HELP: either?
{ $values { "x" object } { "y" object } { "quot" { $quotation ( ... obj -- ... ? ) } } { "?" "a generalized boolean" } }
{ $description "Applies the quotation to both " { $snippet "x" } " and " { $snippet "y" } ", and then returns the first result that is not " { $link f } "." }
{ $examples
    { $example "USING: kernel math prettyprint ;" "3 6 [ odd? ] either? ." "t" }
    { $example "USING: kernel math prettyprint ;" "5 7 [ even? ] either? ." "f" }
} ;

HELP: same?
{ $values { "x" object } { "y" object } { "quot" { $quotation ( ... obj -- ... obj' ) } } { "?" boolean } }
{ $description "Applies the quotation to both " { $snippet "x" } " and " { $snippet "y" } ", and then checks if the results are equal." }
{ $examples
    { $example "USING: kernel math prettyprint ;" "4 5 [ 2/ ] same? ." "t" }
    { $example "USING: kernel math prettyprint ;" "3 7 [ sq ] same? ." "f" }
} ;

HELP: execute
{ $values { "word" word } }
{ $description "Executes a word. Words which " { $link execute } " an input parameter must be declared " { $link POSTPONE: inline } " so that a caller which passes in a literal word can have a static stack effect." }
{ $notes "To execute a non-literal word, you can use " { $link POSTPONE: execute( } " to check the stack effect before calling at runtime." }
{ $examples
    { $example "USING: kernel io words ;" "IN: scratchpad" ": twice ( word -- ) dup execute execute ; inline\n: hello ( -- ) \"Hello\" print ;\n\\ hello twice" "Hello\nHello" }
} ;

{ execute POSTPONE: execute( } related-words

HELP: (execute)
{ $values { "word" word } }
{ $description "Executes a word without checking if it is a word first." }
{ $warning "This word is in the " { $vocab-link "kernel.private" } " vocabulary because it is unsafe. Calling with a parameter that is not a word will crash Factor. Use " { $link execute } " instead." } ;

HELP: call
{ $values { "callable" callable } }
{ $description "Calls a quotation. Words which " { $link call } " an input parameter must be declared " { $link POSTPONE: inline } " so that a caller which passes in a literal quotation can have a static stack effect." }
{ $notes "To call a non-literal quotation you can use " { $link POSTPONE: call( } " to check the stack effect before calling at runtime." }
{ $examples
    "The following two lines are equivalent:"
    { $code "2 [ 2 + 3 * ] call" "2 2 + 3 *" }
} ;

{ call POSTPONE: call( } related-words

HELP: keep
{ $values { "x" object } { "quot" { $quotation ( ..a x -- ..b ) } } }
{ $description "Calls a quotation with a value on the stack, restoring the value when the quotation returns." }
{ $examples
    { $example "USING: arrays kernel prettyprint ;" "2 \"greetings\" [ <array> ] keep 2array ." "{ { \"greetings\" \"greetings\" } \"greetings\" }" }
} ;

HELP: 2keep
{ $values { "x" object } { "y" object } { "quot" { $quotation ( ..a x y -- ..b ) } } }
{ $description "Calls a quotation with two values on the stack, restoring the values when the quotation returns." } ;

HELP: 3keep
{ $values { "x" object } { "y" object } { "z" object } { "quot" { $quotation ( ..a x y z -- ..b ) } } }
{ $description "Calls a quotation with three values on the stack, restoring the values when the quotation returns." } ;

HELP: bi
{ $values { "x" object } { "p" { $quotation ( ..a x -- ..b ) } } { "q" { $quotation ( ..c x -- ..d ) } } }
{ $description "Applies " { $snippet "p" } " to " { $snippet "x" } ", then applies " { $snippet "q" } " to " { $snippet "x" } "." }
{ $examples
    "If " { $snippet "[ p ]" } " and " { $snippet "[ q ]" } " have stack effect " { $snippet "( x -- )" } ", then the following two lines are equivalent:"
    { $code
        "[ p ] [ q ] bi"
        "dup p q"
    }
    "If " { $snippet "[ p ]" } " and " { $snippet "[ q ]" } " have stack effect " { $snippet "( x -- y )" } ", then the following two lines are equivalent:"
    { $code
        "[ p ] [ q ] bi"
        "dup p swap q"
    }
    "In general, the following two lines are equivalent:"
    { $code
        "[ p ] [ q ] bi"
        "[ p ] keep q"
    }

} ;

HELP: 2bi
{ $values { "x" object } { "y" object } { "p" { $quotation ( x y -- ... ) } } { "q" { $quotation ( x y -- ... ) } } }
{ $description "Applies " { $snippet "p" } " to the two input values, then applies " { $snippet "q" } " to the two input values." }
{ $examples
    "If " { $snippet "[ p ]" } " and " { $snippet "[ q ]" } " have stack effect " { $snippet "( x y -- )" } ", then the following two lines are equivalent:"
    { $code
        "[ p ] [ q ] 2bi"
        "2dup p q"
    }
    "If " { $snippet "[ p ]" } " and " { $snippet "[ q ]" } " have stack effect " { $snippet "( x y -- z )" } ", then the following two lines are equivalent:"
    { $code
        "[ p ] [ q ] 2bi"
        "2dup p -rot q"
    }
    "In general, the following two lines are equivalent:"
    { $code
        "[ p ] [ q ] 2bi"
        "[ p ] 2keep q"
    }
} ;

HELP: 3bi
{ $values { "x" object } { "y" object } { "z" object } { "p" { $quotation ( x y z -- ... ) } } { "q" { $quotation ( x y z -- ... ) } } }
{ $description "Applies " { $snippet "p" } " to the three input values, then applies " { $snippet "q" } " to the three input values." }
{ $examples
    "If " { $snippet "[ p ]" } " and " { $snippet "[ q ]" } " have stack effect " { $snippet "( x y z -- )" } ", then the following two lines are equivalent:"
    { $code
        "[ p ] [ q ] 3bi"
        "3dup p q"
    }
    "In general, the following two lines are equivalent:"
    { $code
        "[ p ] [ q ] 3bi"
        "[ p ] 3keep q"
    }
} ;

HELP: tri
{ $values { "x" object } { "p" { $quotation ( x -- ... ) } } { "q" { $quotation ( x -- ... ) } } { "r" { $quotation ( x -- ... ) } } }
{ $description "Applies " { $snippet "p" } " to " { $snippet "x" } ", then applies " { $snippet "q" } " to " { $snippet "x" } ", and finally applies " { $snippet "r" } " to " { $snippet "x" } "." }
{ $examples
    "If " { $snippet "[ p ]" } ", " { $snippet "[ q ]" } " and " { $snippet "[ r ]" } " have stack effect " { $snippet "( x -- )" } ", then the following two lines are equivalent:"
    { $code
        "[ p ] [ q ] [ r ] tri"
        "dup p dup q r"
    }
    "If " { $snippet "[ p ]" } ", " { $snippet "[ q ]" } " and " { $snippet "[ r ]" } " have stack effect " { $snippet "( x -- y )" } ", then the following two lines are equivalent:"
    { $code
        "[ p ] [ q ] [ r ] tri"
        "dup p over q rot r"
    }
    "In general, the following two lines are equivalent:"
    { $code
        "[ p ] [ q ] [ r ] tri"
        "[ p ] keep [ q ] keep r"
    }
} ;

HELP: 2tri
{ $values { "x" object } { "y" object } { "p" { $quotation ( x y -- ... ) } } { "q" { $quotation ( x y -- ... ) } } { "r" { $quotation ( x y -- ... ) } } }
{ $description "Applies " { $snippet "p" } " to the two input values, then applies " { $snippet "q" } " to the two input values, and finally applies " { $snippet "r" } " to the two input values." }
{ $examples
    "If " { $snippet "[ p ]" } ", " { $snippet "[ q ]" } " and " { $snippet "[ r ]" } " have stack effect " { $snippet "( x y -- )" } ", then the following two lines are equivalent:"
    { $code
        "[ p ] [ q ] [ r ] 2tri"
        "2dup p 2dup q r"
    }
    "In general, the following two lines are equivalent:"
    { $code
        "[ p ] [ q ] [ r ] 2tri"
        "[ p ] 2keep [ q ] 2keep r"
    }
} ;

HELP: 3tri
{ $values { "x" object } { "y" object } { "z" object } { "p" { $quotation ( x y z -- ... ) } } { "q" { $quotation ( x y z -- ... ) } } { "r" { $quotation ( x y z -- ... ) } } }
{ $description "Applies " { $snippet "p" } " to the three input values, then applies " { $snippet "q" } " to the three input values, and finally applies " { $snippet "r" } " to the three input values." }
{ $examples
    "If " { $snippet "[ p ]" } ", " { $snippet "[ q ]" } " and " { $snippet "[ r ]" } " have stack effect " { $snippet "( x y z -- )" } ", then the following two lines are equivalent:"
    { $code
        "[ p ] [ q ] [ r ] 3tri"
        "3dup p 3dup q r"
    }
    "In general, the following two lines are equivalent:"
    { $code
        "[ p ] [ q ] [ r ] 3tri"
        "[ p ] 3keep [ q ] 3keep r"
    }
} ;


HELP: bi*
{ $values { "x" object } { "y" object } { "p" { $quotation ( x -- ... ) } } { "q" { $quotation ( y -- ... ) } } }
{ $description "Applies " { $snippet "p" } " to " { $snippet "x" } ", then applies " { $snippet "q" } " to " { $snippet "y" } "." }
{ $examples
    "The following two lines are equivalent:"
    { $code
        "[ p ] [ q ] bi*"
        "[ p ] dip q"
    }
} ;

HELP: 2bi*
{ $values { "w" object } { "x" object } { "y" object } { "z" object } { "p" { $quotation ( w x -- ... ) } } { "q" { $quotation ( y z -- ... ) } } }
{ $description "Applies " { $snippet "p" } " to " { $snippet "w" } " and " { $snippet "x" } ", then applies " { $snippet "q" } " to " { $snippet "y" } " and " { $snippet "z" } "." }
{ $examples
    "The following two lines are equivalent:"
    { $code
        "[ p ] [ q ] 2bi*"
        "[ p ] 2dip q"
    }
} ;

HELP: 2tri*
{ $values { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "p" { $quotation ( u v -- ... ) } } { "q" { $quotation ( w x -- ... ) } } { "r" { $quotation ( y z -- ... ) } } }
{ $description "Applies " { $snippet "p" } " to " { $snippet "u" } " and " { $snippet "v" } ", then applies " { $snippet "q" } " to " { $snippet "w" } " and " { $snippet "x" } ", and finally applies " { $snippet "r" } " to " { $snippet "y" } " and " { $snippet "z" } "." }
{ $examples
    "The following two lines are equivalent:"
    { $code
        "[ p ] [ q ] [ r ] 2tri*"
        "[ [ p ] 2dip q ] 2dip r"
    }
} ;

HELP: tri*
{ $values { "x" object } { "y" object } { "z" object } { "p" { $quotation ( x -- ... ) } } { "q" { $quotation ( y -- ... ) } } { "r" { $quotation ( z -- ... ) } } }
{ $description "Applies " { $snippet "p" } " to " { $snippet "x" } ", then applies " { $snippet "q" } " to " { $snippet "y" } ", and finally applies " { $snippet "r" } " to " { $snippet "z" } "." }
{ $examples
    "The following two lines are equivalent:"
    { $code
        "[ p ] [ q ] [ r ] tri*"
        "[ [ p ] dip q ] dip r"
    }
} ;

HELP: bi@
{ $values { "x" object } { "y" object } { "quot" { $quotation ( obj -- ... ) } } }
{ $description "Applies the quotation to " { $snippet "x" } ", then to " { $snippet "y" } "." }
{ $examples
    "The following two lines are equivalent:"
    { $code
        "[ p ] bi@"
        "[ p ] dip p"
    }
    "The following two lines are also equivalent:"
    { $code
        "[ p ] bi@"
        "[ p ] [ p ] bi*"
    }
} ;

HELP: 2bi@
{ $values { "w" object } { "x" object } { "y" object } { "z" object } { "quot" { $quotation ( obj1 obj2 -- ... ) } } }
{ $description "Applies the quotation to " { $snippet "w" } " and " { $snippet "x" } ", then to " { $snippet "y" } " and " { $snippet "z" } "." }
{ $examples
    "The following two lines are equivalent:"
    { $code
        "[ p ] 2bi@"
        "[ p ] 2dip p"
    }
    "The following two lines are also equivalent:"
    { $code
        "[ p ] 2bi@"
        "[ p ] [ p ] 2bi*"
    }
} ;

HELP: tri@
{ $values { "x" object } { "y" object } { "z" object } { "quot" { $quotation ( obj -- ... ) } } }
{ $description "Applies the quotation to " { $snippet "x" } ", then to " { $snippet "y" } ", and finally to " { $snippet "z" } "." }
{ $examples
    "The following two lines are equivalent:"
    { $code
        "[ p ] tri@"
        "[ [ p ] dip p ] dip p"
    }
    "The following two lines are also equivalent:"
    { $code
        "[ p ] tri@"
        "[ p ] [ p ] [ p ] tri*"
    }
} ;

HELP: 2tri@
{ $values { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "quot" { $quotation ( obj1 obj2 -- ... ) } } }
{ $description "Applies the quotation to " { $snippet "u" } " and " { $snippet "v" } ", then to " { $snippet "w" } " and " { $snippet "x" } ", and then to " { $snippet "y" } " and " { $snippet "z" } "." }
{ $examples
    "The following two lines are equivalent:"
    { $code
        "[ p ] 2tri@"
        "[ [ p ] 2dip p ] 2dip p"
    }
    "The following two lines are also equivalent:"
    { $code
        "[ p ] 2tri@"
        "[ p ] [ p ] [ p ] 2tri*"
    }
} ;

HELP: bi-curry
{ $values { "x" object } { "p" { $quotation ( x -- ... ) } } { "q" { $quotation ( x -- ... ) } } { "p'" { $snippet "[ x p ]" } } { "q'" { $snippet "[ x q ]" } } }
{ $description "Partially applies " { $snippet "p" } " and " { $snippet "q" } " to " { $snippet "x" } "." }
{ $notes
  "The following two lines are equivalent:"
  { $code
    "[ p ] [ q ] bi-curry [ call ] bi@"
    "[ p ] [ q ] bi"
  }
  "Higher-arity variants of " { $link bi } " can be built from " { $link bi-curry } ":"
  { $code
    "[ p ] [ q ] bi-curry bi == [ p ] [ q ] 2bi"
    "[ p ] [ q ] bi-curry bi-curry bi == [ p ] [ q ] 3bi"
  }
  "The combination " { $snippet "bi-curry bi*" } " cannot be expressed with the non-currying dataflow combinators alone; it is equivalent to a stack shuffle preceding " { $link 2bi* } ":"
  { $code
    "[ p ] [ q ] bi-curry bi*"
    "[ swap ] keep [ p ] [ q ] 2bi*"
  }
  "To put it another way, " { $snippet "bi-curry bi*" } " handles the case where you have three values " { $snippet "a b c" } " on the stack, and you wish to apply " { $snippet "p" } " to " { $snippet "a c" } " and " { $snippet "q" } " to " { $snippet "b c" } "."
} ;

HELP: tri-curry
{ $values
  { "x" object }
  { "p" { $quotation ( x -- ... ) } }
  { "q" { $quotation ( x -- ... ) } }
  { "r" { $quotation ( x -- ... ) } }
  { "p'" { $snippet "[ x p ]" } }
  { "q'" { $snippet "[ x q ]" } }
  { "r'" { $snippet "[ x r ]" } }
}
{ $description "Partially applies " { $snippet "p" } ", " { $snippet "q" } " and " { $snippet "r" } " to " { $snippet "x" } "." }
{ $notes
  "The following two lines are equivalent:"
  { $code
    "[ p ] [ q ] [ r ] tri-curry [ call ] tri@"
    "[ p ] [ q ] [ r ] tri"
  }
  "Higher-arity variants of " { $link tri } " can be built from " { $link tri-curry } ":"
  { $code
    "[ p ] [ q ] [ r ] tri-curry tri == [ p ] [ q ] [ r ] 2tri"
    "[ p ] [ q ] [ r ] tri-curry tri-curry bi == [ p ] [ q ] [ r ] 3tri"
  }
  "The combination " { $snippet "tri-curry tri*" } " cannot be expressed with the non-currying dataflow combinators alone; it handles the case where you have four values " { $snippet "a b c d" } " on the stack, and you wish to apply " { $snippet "p" } " to " { $snippet "a d" } ", " { $snippet "q" } " to " { $snippet "b d" } " and " { $snippet "r" } " to " { $snippet "c d" } "." } ;

HELP: bi-curry*
{ $values { "x" object } { "y" object } { "p" { $quotation ( x -- ... ) } } { "q" { $quotation ( y -- ... ) } } { "p'" { $snippet "[ x p ]" } } { "q'" { $snippet "[ y q ]" } } }
{ $description "Partially applies " { $snippet "p" } " to " { $snippet "x" } ", and " { $snippet "q" } " to " { $snippet "y" } "." }
{ $notes
  "The following two lines are equivalent:"
  { $code
    "[ p ] [ q ] bi-curry* [ call ] bi@"
    "[ p ] [ q ] bi*"
  }
  "The combination " { $snippet "bi-curry* bi" } " is equivalent to a stack shuffle preceding " { $link 2bi* } ":"
  { $code
    "[ p ] [ q ] bi-curry* bi"
    "[ over ] dip [ p ] [ q ] 2bi*"
  }
  "In other words, " { $snippet "bi-curry* bi" } " handles the case where you have the three values " { $snippet "a b c" } " on the stack, and you wish to apply " { $snippet "p" } " to " { $snippet "a b" } " and " { $snippet "q" } " to " { $snippet "a c" } "."
  $nl
  "The combination " { $snippet "bi-curry* bi*" } " is equivalent to a stack shuffle preceding " { $link 2bi* } ":"
  { $code
    "[ p ] [ q ] bi-curry* bi*"
    "[ swap ] dip [ p ] [ q ] 2bi*"
  }
  "In other words, " { $snippet "bi-curry* bi*" } " handles the case where you have the four values " { $snippet "a b c d" } " on the stack, and you wish to apply " { $snippet "p" } " to " { $snippet "a c" } " and " { $snippet "q" } " to " { $snippet "b d" } "."

} ;

HELP: tri-curry*
{ $values
  { "x" object }
  { "y" object }
  { "z" object }
  { "p" { $quotation ( x -- ... ) } }
  { "q" { $quotation ( y -- ... ) } }
  { "r" { $quotation ( z -- ... ) } }
  { "p'" { $snippet "[ x p ]" } }
  { "q'" { $snippet "[ y q ]" } }
  { "r'" { $snippet "[ z r ]" } }
}
{ $description "Partially applies " { $snippet "p" } " to " { $snippet "x" } ", " { $snippet "q" } " to " { $snippet "y" } " and " { $snippet "r" } " to " { $snippet "z" } "." }
{ $notes
  "The following two lines are equivalent:"
  { $code
    "[ p ] [ q ] [ r ] tri-curry* [ call ] tri@"
    "[ p ] [ q ] [ r ] tri*"
  }
  "The combination " { $snippet "tri-curry* tri" } " is equivalent to a stack shuffle preceding " { $link 2tri* } ":"
  { $code
    "[ p ] [ q ] [ r ] tri-curry* tri"
    "[ [ over ] dip over ] dip [ p ] [ q ] [ r ] 2tri*"
  }
} ;

HELP: bi-curry@
{ $values { "x" object } { "y" object } { "q" { $quotation ( obj -- ... ) } } { "p'" { $snippet "[ x q ]" } } { "q'" { $snippet "[ y q ]" } } }
{ $description "Partially applies " { $snippet "q" } " to " { $snippet "x" } " and " { $snippet "y" } "." }
{ $notes
  "The following two lines are equivalent:"
  { $code
    "[ q ] bi-curry@"
    "[ q ] [ q ] bi-curry*"
  }
} ;

HELP: tri-curry@
{ $values
  { "x" object }
  { "y" object }
  { "z" object }
  { "q" { $quotation ( obj -- ... ) } }
  { "p'" { $snippet "[ x q ]" } }
  { "q'" { $snippet "[ y q ]" } }
  { "r'" { $snippet "[ z q ]" } }
}
{ $description "Partially applies " { $snippet "q" } " to " { $snippet "x" } ", " { $snippet "y" } " and " { $snippet "z" } "." }
{ $notes
  "The following two lines are equivalent:"
  { $code
    "[ q ] tri-curry@"
    "[ q ] [ q ] [ q ] tri-curry*"
  }
} ;

HELP: if
{ $values { "?" "a generalized boolean" } { "true" quotation } { "false" quotation } }
{ $description "If " { $snippet "cond" } " is " { $link f } ", calls the " { $snippet "false" } " quotation. Otherwise calls the " { $snippet "true" } " quotation."
$nl
"The " { $snippet "cond" } " value is removed from the stack before either quotation is called." }
{ $examples
    { $example
        "USING: io kernel math ;"
        "10 3 < [ \"Math is broken\" print ] [ \"Math is good\" print ] if"
        "Math is good"
    }
}
{ $notes { $snippet "if" } " is executed as a primitive when preceded by two literal quotations. The below definition is not executed unless one of its arguments is a non-literal quotation, such as a quotation constructed with " { $link curry } " or " { $link compose } ", or for " { $link "fry" } " or quotations including " { $link "locals" } "." } ;

HELP: when
{ $values { "?" "a generalized boolean" } { "true" quotation } }
{ $description "If " { $snippet "cond" } " is not " { $link f } ", calls the " { $snippet "true" } " quotation."
$nl
"The " { $snippet "cond" } " value is removed from the stack before the quotation is called." }
{ $examples
    { $example
        "USING: kernel math prettyprint ;"
        "-5 dup 0 < [ 3 + ] when ."
        "-2"
    }
} ;

HELP: unless
{ $values { "?" "a generalized boolean" } { "false" quotation } }
{ $description "If " { $snippet "cond" } " is " { $link f } ", calls the " { $snippet "false" } " quotation."
$nl
"The " { $snippet "cond" } " value is removed from the stack before the quotation is called." }
{ $examples
    { $example
        "USING: kernel math prettyprint sequences ;"
        "IN: scratchpad"
        ""
        "CONSTANT: american-cities {"
        "    \"San Francisco\""
        "    \"Los Angeles\""
        "    \"New York\""
        "}"
        ""
        ": add-tax ( price city -- price' )"
        "    american-cities member? [ 1.1 * ] unless ;"
        ""
        "123 \"Ottawa\" add-tax ."
        "135.3"
    }
} ;

HELP: if*
{ $values { "?" "a generalized boolean" } { "true" { $quotation ( ..a ? -- ..b ) } } { "false" { $quotation ( ..a -- ..b ) } } }
{ $description "Alternative conditional form that preserves the " { $snippet "cond" } " value if it is true."
$nl
"If the condition is true, it is retained on the stack before the " { $snippet "true" } " quotation is called. Otherwise, the condition is removed from the stack and the " { $snippet "false" } " quotation is called."
$nl
"The following two lines are equivalent:"
{ $code "X [ Y ] [ Z ] if*" "X dup [ Y ] [ drop Z ] if" } }
{ $examples
    "Notice how in this example, the same value is tested by the conditional, and then used in the true branch; the false branch does not need to drop the value because of how " { $link if* } " works:"
    { $example
        "USING: assocs io kernel math.parser ;"
        "IN: scratchpad"
        ""
        ": curry-price ( meat -- price )
    {
        { \"Beef\" 10 }
        { \"Chicken\" 12 }
        { \"Lamb\" 13 }
    } at ;

: order-curry ( meat -- )
    curry-price [
        \"Your order will be \" write
        number>string write
        \" dollars.\" write
    ] [ \"Invalid order.\" print ] if* ;"
        ""
        "\"Deer\" order-curry"
        "Invalid order."
    }
} ;

HELP: when*
{ $values { "?" "a generalized boolean" } { "true" { $quotation ( ..a ? -- ..a ) } } }
{ $description "Variant of " { $link if* } " with no false quotation."
$nl
"The following two lines are equivalent:"
{ $code "X [ Y ] when*" "X dup [ Y ] [ drop ] if" } } ;

HELP: unless*
{ $values { "?" "a generalized boolean" } { "false" { $quotation ( ..a -- ..a x ) } } { "x" object } }
{ $description "Variant of " { $link if* } " with no true quotation." }
{ $notes
"The following two lines are equivalent:"
{ $code "X [ Y ] unless*" "X dup [ ] [ drop Y ] if" } } ;

HELP: ?call
{ $values
    { "obj/f" { $maybe object } } { "quot" quotation }
    { "obj'/f" { $maybe object } }
}
{ $description "Call the quotation if " { $snippet "obj" } " is not " { $snippet "f" } "." }
{ $examples
    "Example:"
    { $example "USING: kernel math prettyprint ;"
        "5 [ sq ] ?call ."
        "25"
    }
    "Example:"
    { $example "USING: kernel math prettyprint ;"
        "f [ sq ] ?call ."
        "f"
    }
} ;

HELP: ?if
{ $values
    { "default" object } { "cond" object } { "true" object } { "false" object }
}
{ $warning "The old " { $snippet "?if" } " word can be refactored:" { $code "[ .. ] [ .. ] ?if\n\nor? [ .. ] [ .. ] if" } }
{ $description "Calls " { $snippet "cond" } " on the " { $snippet "default" } " object and if " { $snippet "cond" } " outputs a new object then the " { $snippet "true" } " quotation is called with that new object. Otherwise, calls " { $snippet "false" } " with the old object." }
{ $examples
    "Look up an existing word or make an error pair:"
    { $example "USING: arrays definitions kernel math prettyprint sequences vocabs.parser ;"
        "\"+\" [ search ] [ where first ] [ \"not found\" 2array ] ?if ."
        "\"resource:core/math/math.factor\""
    }
    "Try to look up a word that doesn't exist:"
    { $example "USING: arrays definitions kernel math prettyprint sequences vocabs.parser ;"
        "\"+++++\" [ search ] [ where first ] [ \"not found\" 2array ] ?if ."
        "{ \"+++++\" \"not found\" }"
    }
} ;

HELP: ?when
{ $values
    { "default" object } { "cond" { $quotation ( ..a default -- ..a new/f ) } } { "true" { $quotation ( ..a new -- ..a x ) } } { "default/x" { $or { $snippet "default" } { $snippet "x" } } }
}
{ $description "Calls " { $snippet "cond" } " on the " { $snippet "default" } " object and if " { $snippet "cond" } " outputs a new object then the " { $snippet "true" } " quotation is called with that new object. Otherwise, leaves the old object on the stack." }
{ $examples
    "Look up an existing word or make an error pair:"
    { $example "USING: arrays definitions kernel math prettyprint sequences vocabs.parser ;"
        "\"+\" [ search ] [ where first ] ?when ."
        "\"resource:core/math/math.factor\""
    }
    "Try to look up a word that doesn't exist:"
    { $example "USING: arrays definitions kernel math prettyprint sequences vocabs.parser ;"
        "\"+++++\" [ search ] [ where first ] ?when ."
        "\"+++++\""
    }
} ;

HELP: ?unless
{ $values
    { "default" object } { "cond" { $quotation ( ..a default -- ..a new/f ) } } { "false" { $quotation ( ..a default -- ..a x ) } } { "default/x" { $or { $snippet "default" } { $snippet "x" } } }
}
{ $description "Calls " { $snippet "cond" } " on the " { $snippet "default" } " object and if " { $snippet "cond" } " outputs a new object. Otherwise, calls " { $snippet "false" } " with the old object." }
{ $examples
    "Look up an existing word or make an error pair:"
    { $example "USING: arrays definitions kernel math prettyprint sequences vocabs.parser ;"
        "\"+\" [ search ] [ \"not found\" 2array ] ?unless ."
        "+"
    }
    "Try to look up a word that doesn't exist:"
    { $example "USING: arrays definitions kernel math prettyprint sequences vocabs.parser ;"
        "\"+++++\" [ search ] [ \"not found\" 2array ] ?unless ."
        "{ \"+++++\" \"not found\" }"
    }
} ;

{ ?if ?when ?unless } related-words

HELP: 1if
{ $values
    { "x" object } { "pred" quotation } { "true" quotation } { "false" quotation }
}
{ $description "A variant of " { $link if } " that takes a " { $snippet "pred" } " quotation. Calls " { $link 1check } " on the " { $snippet "pred" } " quotation to return a boolean and preserves " { $snippet "x" } " for the " { $snippet "true" } " or " { $snippet "false" } " branches, one of which is called." }
{ $examples
    "Collatz Conjecture calculation:"
    { $example "USING: kernel math prettyprint ;"
        "6 [ even? ] [ 2 / ] [ 3 * 1 + ] 1if ."
        "3"
    }
} ;

HELP: 1when
{ $values
    { "x" object } { "pred" quotation } { "true" quotation }
}
{ $description "A variant of " { $link when } " that takes a " { $snippet "pred" } " quotation. Calls " { $link 1check } " on the " { $snippet "pred" } " quotation to return a boolean and preserves " { $snippet "x" } " for both branches. The " { $snippet "true" } " branch is called conditionally." } ;

HELP: 1unless
{ $values
    { "x" object } { "pred" quotation } { "false" quotation }
}
{ $description "A variant of " { $link when } " that takes a " { $snippet "pred" } " quotation. Calls " { $link 1check } " on the " { $snippet "pred" } " quotation to return a boolean and preserves " { $snippet "x" } " for both branches. The " { $snippet "false" } " branch is called conditionally." } ;

HELP: 2if
{ $values
    { "x" object } { "y" object } { "pred" quotation } { "true" quotation } { "false" quotation }
}
{ $description "A variant of " { $link if } " that takes a " { $snippet "pred" } " quotation. Calls " { $link 2check } " on the " { $snippet "pred" } " quotation to return a boolean and preserves " { $snippet "x" } " and " { $snippet "y" } " for the " { $snippet "true" } " or " { $snippet "false" } " branches, one of which is called." } ;

HELP: 2when
{ $values
    { "x" object } { "y" object } { "pred" quotation } { "true" quotation }
}
{ $description "A variant of " { $link when } " that takes a " { $snippet "pred" } " quotation. Calls " { $link 2check } " on the " { $snippet "pred" } " quotation to return a boolean and preserves " { $snippet "x" } " and " { $snippet "y" } " for both branches. The " { $snippet "true" } " branch is called conditionally." } ;

HELP: 2unless
{ $values
    { "x" object } { "y" object } { "pred" quotation } { "false" quotation }
}
{ $description "A variant of " { $link unless } " that takes a " { $snippet "pred" } " quotation. Calls " { $link 2check } " on the " { $snippet "pred" } " quotation to return a boolean and preserves " { $snippet "x" } " and " { $snippet "y" } " for both branches. The " { $snippet "false" } " branch is called conditionally." } ;

HELP: 3if
{ $values
    { "x" object } { "y" object } { "z" object } { "pred" quotation } { "true" quotation } { "false" quotation }
}
{ $description "A variant of " { $link if } " that takes a " { $snippet "pred" } " quotation. Calls " { $link 3check } " on the " { $snippet "pred" } " quotation to return a boolean and preserves " { $snippet "x" } ", " { $snippet "y" } ", and " { $snippet "z" } " for the " { $snippet "true" } " or " { $snippet "false" } " branches, one of which is called." } ;

HELP: 3when
{ $values
    { "x" object } { "y" object } { "z" object } { "pred" quotation } { "true" quotation }
}
{ $description "A variant of " { $link when } " that takes a " { $snippet "pred" } " quotation. Calls " { $link 3check } " on the " { $snippet "pred" } " quotation to return a boolean and preserves " { $snippet "x" } ", " { $snippet "y" } ", and " { $snippet "z" } " for both branches. The " { $snippet "true" } " branch is called conditionally." } ;

HELP: 3unless
{ $values
    { "x" object } { "y" object } { "z" object } { "pred" quotation } { "false" quotation }
}
{ $description "A variant of " { $link unless } " that takes a " { $snippet "pred" } " quotation. Calls " { $link 3check } " on the " { $snippet "pred" } " quotation to return a boolean and preserves " { $snippet "x" } ", " { $snippet "y" } ", and " { $snippet "z" } " for both branches. The " { $snippet "false" } " branch is called conditionally." } ;

{ 1if 1when 1unless 2if 2when 2unless 3if 3when 3unless } related-words

HELP: 1check
{ $values
    { "x" object } { "quot" quotation }
    { "?" boolean }
}
{ $description "Calls " { $snippet "quot" } " on " { $snippet "x" } " and keeps " { $snippet "x" } " under the boolean result from the " { $snippet "quot" } "."  }
{ $examples
    "True case:"
    { $example "USING: kernel math prettyprint ;"
        "6 [ even? ] 1check [ . ] bi@"
        "6\nt"
    }
    "False case:"
    { $example "USING: kernel math prettyprint ;"
        "6 [ odd? ] 1check [ . ] bi@"
        "6\nf"
    }
} ;

HELP: 1guard
{ $values
    { "x" object } { "quot" quotation }
    { "x/f" object }
}
{ $description "Calls " { $snippet "quot" } " on " { $snippet "x" } " and either keeps " { $snippet "x" } " or replaces it with " { $snippet "f" } "." }
{ $examples
    "True case:"
    { $example "USING: kernel math prettyprint ;"
        "6 [ even? ] 1guard ."
        "6"
    }
    "False case:"
    { $example "USING: kernel math prettyprint ;"
        "5 [ even? ] 1guard ."
        "f"
    }
} ;

HELP: 2check
{ $values
    { "x" object } { "y" object } { "quot" quotation }
    { "?" boolean }
}
{ $description "Calls " { $snippet "quot" } " on " { $snippet "x" } " and " { $snippet "y" } " and keeps those two values under the boolean result from the " { $snippet "quot" } "."  }
{ $examples
    "True case:"
    { $example "USING: kernel math prettyprint ;"
        "3 4 [ + odd? ] 2check [ . ] tri@"
        "3\n4\nt"
    }
    "False case:"
    { $example "USING: kernel math prettyprint ;"
        "3 4 [ + even? ] 2check [ . ] tri@"
        "3\n4\nf"
    }
} ;

HELP: 2guard
{ $values
    { "x" object } { "y" object } { "quot" quotation }
    { "x/f" object } { "y/f" object }
}
{ $description "Calls " { $snippet "quot" } " on " { $snippet "x" } " and " { $snippet "y" } " and either keeps " { $snippet "x" } " and " { $snippet "y" } " or replaces them with " { $snippet "f" } "."  }
{ $examples
    "True case:"
    { $example "USING: kernel math prettyprint ;"
        "3 4 [ + odd? ] 2guard [ . ] bi@"
        "3\n4"
    }
    "False case:"
    { $example "USING: kernel math prettyprint ;"
        "3 4 [ + even? ] 2guard [ . ] bi@"
        "f\nf"
    }
} ;

HELP: 3check
{ $values
    { "x" object } { "y" object } { "z" object } { "quot" quotation }
    { "?" boolean }
}
{ $description "Calls " { $snippet "quot" } " on " { $snippet "x" } ", " { $snippet "y" } ", and " { $snippet "z" } " and keeps those three values under the boolean result from the " { $snippet "quot" } "." }
{ $examples
    "True case:"
    { $example "USING: arrays kernel math prettyprint ;"
        "3 4 5 [ + + even? ] 3check 4array ."
        "{ 3 4 5 t }"
    }
    "False case:"
    { $example "USING: arrays kernel math prettyprint ;"
        "3 4 5 [ + + odd? ] 3check 4array ."
        "{ 3 4 5 f }"
    }
} ;

HELP: 3guard
{ $values
    { "x" object } { "y" object } { "z" object } { "quot" quotation }
    { "x/f" object } { "y/f" object } { "z/f" object }
}
{ $description "Calls " { $snippet "quot" } " on " { $snippet "x" } ", " { $snippet "y" } ", and " { $snippet "z" } " and either keeps " { $snippet "x" } ", " { $snippet "y" } ", and " { $snippet "z" } " or replaces them with " { $snippet "f" } "." }
{ $examples
    "True case:"
    { $example "USING: kernel math prettyprint ;"
        "3 4 5 [ + + even? ] 3guard [ . ] tri@"
        "3\n4\n5"
    }
    "False case:"
    { $example "USING: kernel math prettyprint ;"
        "3 4 5 [ + + odd? ] 3guard [ . ] tri@"
        "f\nf\nf"
    }
} ;

{ 1check 1guard 2check 2guard 3check 3guard } related-words

HELP: die
{ $description "Starts the front-end processor (FEP), which is a low-level debugger which can inspect memory addresses and the like. The FEP is also entered when a critical error occurs." }
{ $notes
    "The term FEP originates from the Lisp machines of old. According to the Jargon File,"
    $nl
    { $strong "fepped out" } " /fept owt/ " { $emphasis "adj." } " The Symbolics 3600 LISP Machine has a Front-End Processor called a `FEP' (compare sense 2 of box). When the main processor gets wedged, the FEP takes control of the keyboard and screen. Such a machine is said to have `fepped out' or `dropped into the fep'."
    $nl
    { $url "http://www.jargon.net/jargonfile/f/feppedout.html" }
} ;

HELP: (clone)
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

HELP: tag
{ $values { "object" object } { "n" "a tag number" } }
{ $description "Outputs an object's tag number, between zero and one less than " { $link num-types } ". This is implementation detail and user code should call " { $link class-of } " instead." } ;

HELP: special-object
{ $values { "n" "a non-negative integer" } { "obj" object } }
{ $description "Reads an object from the Factor VM's special object table. User code never has to read the special object table directly; instead, use one of the callers of this word." } ;

HELP: set-special-object
{ $values { "obj" object } { "n" "a non-negative integer" } }
{ $description "Writes an object to the Factor VM's special object table. User code never has to write to the special object table directly; instead, use one of the callers of this word." } ;

HELP: object
{ $class-description
    "The class of all objects. If a generic word defines a method specializing on this class, the method is used as a fallback, if no other applicable method is found. For instance:"
    { $code "GENERIC: enclose ( number -- array )" "M: number enclose 1array ;" "M: object enclose ;" }
} ;

HELP: null
{ $class-description
    "The canonical empty class with no instances."
}
{ $notes
    "Unlike " { $snippet "null" } " in Java or " { $snippet "NULL" } " in C++, this is not a value signifying empty, or nothing. Use " { $link f } " for this purpose."
} ;

HELP: most
{ $values { "x" object } { "y" object } { "quot" { $quotation ( x y -- ? ) } } { "z" "either " { $snippet "x" } " or " { $snippet "y" } } }
{ $description "If the quotation yields a true value when applied to " { $snippet "x" } " and " { $snippet "y" } ", outputs " { $snippet "x" } ", otherwise outputs " { $snippet "y" } "." } ;

HELP: curry
{ $values { "obj" object } { "quot" callable } { "curry" curried } }
{ $description "Partial application. Outputs a " { $link callable } " which first pushes " { $snippet "obj" } " and then calls " { $snippet "quot" } "." }
{ $notes "Even if " { $snippet "obj" } " is a word, it will be pushed as a literal."
$nl
"This operation is efficient and does not copy the quotation." }
{ $examples
    { $example "USING: kernel prettyprint ;" "5 [ . ] curry ." "[ 5 . ]" }
    { $example "USING: kernel prettyprint see ;" "\\ = [ see ] curry ." "[ \\ = see ]" }
    { $example "USING: kernel math prettyprint sequences ;" "{ 1 2 3 } 2 [ - ] curry map ." "{ -1 0 1 }" }
} ;

HELP: curried
{ $class-description "The class of objects created by " { $link curry } ". These objects print identically to quotations and implement the sequence protocol, however they only use two cells of storage; a reference to the object and a reference to the underlying quotation." } ;

{ curry curried compose prepose composed } related-words

HELP: 2curry
{ $values { "obj1" object } { "obj2" object } { "quot" callable } { "curried" curried } }
{ $description "Outputs a " { $link callable } " which pushes " { $snippet "obj1" } " and " { $snippet "obj2" } " and then calls " { $snippet "quot" } "." }
{ $notes "This operation is efficient and does not copy the quotation." }
{ $examples
    { $example "USING: kernel math prettyprint ;" "5 4 [ + ] 2curry ." "[ 5 4 + ]" }
} ;

HELP: 3curry
{ $values { "obj1" object } { "obj2" object } { "obj3" object } { "quot" callable } { "curried" curried } }
{ $description "Outputs a " { $link callable } " which pushes " { $snippet "obj1" } ", " { $snippet "obj2" } " and " { $snippet "obj3" } ", and then calls " { $snippet "quot" } "." }
{ $notes "This operation is efficient and does not copy the quotation." } ;

HELP: with
{ $values { "param" object } { "obj" object } { "quot" { $quotation ( param elt -- ... ) } } { "curried" curried } }
{ $description "Similar to how " { $link curry } " binds the element below its quotation as its first argument, "
{ $link with } " binds the second element below " { $snippet "quot" } " as the second argument of " { $snippet "quot" } "."
$nl
"In other words, partial application on the left. The following two lines are equivalent:"
    { $code "swap [ swap A ] curry B" }
    { $code "[ A ] with B" }
}
{ $notes "This operation is efficient and does not copy the quotation." }
{ $examples
    { $example "USING: kernel math prettyprint sequences ;" "1 { 1 2 3 } [ / ] with map ." "{ 1 1/2 1/3 }" }
    { $example "USING: kernel math prettyprint sequences ;" "1000 100 5 <iota> [ sq + + ] 2with map ." "{ 1100 1101 1104 1109 1116 }" }
} ;

HELP: 2with
{ $values
  { "param1" object }
  { "param2" object }
  { "obj" object }
  { "quot" { $quotation ( param1 param2 elt -- ... ) } }
  { "curried" curried }
}
{ $description "Partial application on the left of two parameters." } ;

HELP: compose
{ $values { "quot1" callable } { "quot2" callable } { "compose" composed } }
{ $description "Quotation composition. Outputs a " { $link callable } " which calls " { $snippet "quot1" } " followed by " { $snippet "quot2" } "." }
{ $notes
    "The following two lines are equivalent:"
    { $code
        "compose call"
        "append call"
    }
    "However, " { $link compose } " runs in constant time, and the optimizing compiler is able to compile code which calls composed quotations."
} ;

HELP: prepose
{ $values { "quot1" callable } { "quot2" callable } { "composed" composed } }
{ $description "Quotation composition. Outputs a " { $link callable } " which calls " { $snippet "quot2" } " followed by " { $snippet "quot1" } "." }
{ $notes "See " { $link compose } " for details." } ;

HELP: composed
{ $class-description "The class of objects created by " { $link compose } ". These objects print identically to quotations and implement the sequence protocol, however they only use two cells of storage; references to the first and second underlying quotations." } ;

HELP: dip
{ $values { "x" object } { "quot" quotation } }
{ $description "Removes " { $snippet "x" } " from the datastack, calls " { $snippet "quot" } ", and restores " { $snippet "x" } " to the top of the datastack when " { $snippet "quot" } " is finished." }
{ $examples
    { $example "USING: arrays kernel math prettyprint ;" "10 20 30 [ / ] dip 2array ." "{ 1/2 30 }" }
}
{ $notes { $snippet "dip" } " is executed as a primitive when preceded by a literal quotation. The below definition is not executed unless its argument is a non-literal quotation, such as a quotation constructed with " { $link curry } " or " { $link compose } ", or for " { $link "fry" } " or quotations including " { $link "locals" } "." } ;

HELP: 2dip
{ $values { "x" object } { "y" object } { "quot" quotation } }
{ $description "Removes " { $snippet "x" } " and " { $snippet "y" } " from the datastack, calls " { $snippet "quot" } ", and restores the removed objects to the top of the datastack when " { $snippet "quot" } " is finished." }
{ $notes "The following are equivalent:"
    { $code "[ [ foo bar ] dip ] dip" }
    { $code "[ foo bar ] 2dip" }
} ;

HELP: 3dip
{ $values { "x" object } { "y" object } { "z" object } { "quot" quotation } }
{ $description "Removes " { $snippet "x" } ", " { $snippet "y" } ", and " { $snippet "z" } " from the datastack, calls " { $snippet "quot" } ", and restores the removed objects to the top of the datastack when " { $snippet "quot" } " is finished." }
{ $notes "The following are equivalent:"
    { $code "[ [ [ foo bar ] dip ] dip ] dip" }
    { $code "[ foo bar ] 3dip" }
} ;

HELP: 4dip
{ $values { "w" object } { "x" object } { "y" object } { "z" object } { "quot" quotation } }
{ $description "Removes " { $snippet "w" } ", " { $snippet "x" } ", " { $snippet "y" } ", and " { $snippet "z" } " from the datastack, calls " { $snippet "quot" } ", and restores the removed objects to the top of the datastack when " { $snippet "quot" } " is finished." }
{ $notes "The following are equivalent:"
    { $code "[ [ [ [ foo bar ] dip ] dip ] dip ] dip" }
    { $code "[ foo bar ] 4dip" }
} ;

HELP: while
{ $values { "pred" { $quotation ( ..a -- ..b ? ) } } { "body" { $quotation ( ..b -- ..a ) } } }
{ $description "Calls " { $snippet "body" } " until " { $snippet "pred" } " returns " { $link f } "." } ;

HELP: while*
{ $values { "pred" { $quotation ( ..a -- ..b ? ) } } { "body" { $quotation ( ..b ? -- ..a ) } } }
{ $description "Calls " { $snippet "body" } " until " { $snippet "pred" }
  " returns " { $link f } ". The return value of " { $snippet "pred" } " is "
  "kept on the stack." } ;

HELP: until
{ $values { "pred" { $quotation ( ..a -- ..b ? ) } } { "body" { $quotation ( ..b -- ..a ) } } }
{ $description "Calls " { $snippet "body" } " until " { $snippet "pred" } " returns " { $link t } "." } ;

HELP: until*
{ $values { "pred" { $quotation ( ..a -- ..b ? ) } } { "body" { $quotation ( ..b -- ..a ) } } { "?" boolean } }
{ $description "Calls " { $snippet "body" } " until " { $snippet "pred" }
  " returns " { $link t } ". The return value of " { $snippet "pred" } " is "
  "kept on the stack." } ;

HELP: do
{ $values { "pred" { $quotation ( ..a -- ..b ? ) } } { "body" { $quotation ( ..b -- ..a ) } } }
{ $description "Executes one iteration of a " { $link while } " or " { $link until } " loop." } ;

HELP: loop
{ $values
    { "pred" quotation } }
    { $description "Calls the quotation repeatedly until it outputs " { $link f } "." }
{ $examples "Loop until we hit a zero:"
    { $unchecked-example "USING: kernel random math io ; "
    " [ \"hi\" write bl 10 random zero? not ] loop"
    "hi hi hi" }
    "A fun loop:"
    { $example "USING: kernel prettyprint math ; "
    "3 [ dup . 7 + 11 mod dup 3 = not ] loop drop"
    "3\n10\n6\n2\n9\n5\n1\n8\n4\n0\n7" }
} ;

ARTICLE: "looping-combinators" "Looping combinators"
"In most cases, loops should be written using high-level combinators (such as " { $link "sequences-combinators" } ") or tail recursion. However, sometimes, the best way to express intent is with a loop."
{ $subsections
    while
    until
}
"To execute one iteration of a loop, use the following word:"
{ $subsections do }
"This word is intended as a modifier. The normal " { $link while } " loop never executes the body if the predicate returns false on the first iteration. To ensure the body executes at least once, use " { $link do } ":"
{ $code
    "[ P ] [ Q ] do while"
}
"A simpler looping combinator which executes a single quotation until it returns " { $link f } ":"
{ $subsections loop } ;

HELP: assert
{ $values { "got" "the obtained value" } { "expect" "the expected value" } }
{ $description "Throws an " { $link assert } " error." }
{ $error-description "Thrown when a unit test or other assertion fails." } ;

HELP: assert=
{ $values { "a" object } { "b" object } }
{ $description "Throws an " { $link assert } " error if " { $snippet "a" } " does not equal " { $snippet "b" } "." } ;

HELP: become
{ $values { "old" array } { "new" array } }
{ $description "Replaces all references to objects in " { $snippet "old" } " with the corresponding object in " { $snippet "new" } ". This word is used to implement tuple reshaping. See " { $link "tuple-redefinition" } "." } ;

ARTICLE: "callables" "Callables"
"Aside from " { $link "quotations" } ", there are two other callables that efficiently combine computations."
$nl
"Currying an object onto a quotation:"
{ $subsections
    curry
    curried
}
"Composing two quotations:"
{ $subsections
    compose
    composed
} ;

ARTICLE: "shuffle-words" "Shuffle words"
"Shuffle words rearrange items at the top of the data stack as indicated by their stack effects. They provide simple data flow control between words. More complex data flow control is available with the " { $link "dataflow-combinators" } " and with " { $link "locals" } "."
$nl
"Removing stack elements:"
{ $subsections
    drop
    2drop
    3drop
    4drop
    5drop
    nip
    2nip
    3nip
    4nip
    5nip
}
"Duplicating stack elements:"
{ $subsections
    dup
    2dup
    3dup
    over
    2over
    pick
}
"Permuting stack elements:"
{ $subsections
    swap
}
"Duplicating stack elements deep in the stack:"
{ $subsections
    dupd
}
"Permuting stack elements deep in the stack:"
{ $subsections
    swapd
    overd
    rot
    -rot
    spin
    4spin
    rotd
    -rotd
    nipd
    2nipd
    3nipd
} ;

ARTICLE: "equality" "Equality"
"There are two distinct notions of \"sameness\" when it comes to objects."
$nl
"You can test if two references point to the same object (" { $emphasis "identity comparison" } "). This is rarely used; it is mostly useful with large, mutable objects where the object identity matters but the value is transient:"
{ $subsections eq? }
"You can test if two objects are equal in a domain-specific sense, usually by being instances of the same class, and having equal slot values (" { $emphasis "value comparison" } "):"
{ $subsections = }
"A third form of equality is provided by " { $link number= } ". It compares numeric value while disregarding types."
$nl
"Custom value comparison methods for use with " { $link = } " can be defined on a generic word:"
{ $subsections equal? }
"Utility class:"
{ $subsections identity-tuple }
"An object can be cloned; the clone has distinct identity but equal value:"
{ $subsections clone } ;

ARTICLE: "assertions" "Assertions"
"Some words to make assertions easier to enforce:"
{ $subsections
    assert
    assert=
} ;
