USING: generic help.markup help.syntax math memory
namespaces sequences kernel.private layouts classes
kernel.private vectors combinators quotations strings words
assocs arrays math.order ;
IN: kernel

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
HELP: 2over                          $shuffle ;
HELP: pick  ( x y z -- x y z x )     $shuffle ;
HELP: swap  ( x y -- y x )           $shuffle ;
HELP: spin                           $shuffle ;
HELP: roll                           $shuffle ;
HELP: -roll                          $shuffle ;

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

HELP: build
{ $values { "n" integer } }
{ $description "The current build number. Factor increments this number whenever a new boot image is created." } ;

HELP: hashcode*
{ $values { "depth" integer } { "obj" object } { "code" fixnum } }
{ $contract "Outputs the hashcode of an object. The hashcode operation must satisfy the following properties:"
{ $list
    { "If two objects are equal under " { $link = } ", they must have equal hashcodes." }
    { "If the hashcode of an object depends on the values of its slots, the hashcode of the slots must be computed recursively by calling " { $link hashcode* } " with a " { $snippet "level" } " parameter decremented by one. This avoids excessive work while still computing well-distributed hashcodes. The " { $link recursive-hashcode } " combinator can help with implementing this logic," }
    { "The hashcode should be a " { $link fixnum } ", however returning a " { $link bignum } " will not cause any problems other than potential performance degradation." }
    { "The hashcode is only permitted to change between two invocations if the object or one of its slot values was mutated." }
}
"If mutable objects are used as hashtable keys, they must not be mutated in such a way that their hashcode changes. Doing so will violate bucket sorting invariants and result in undefined behavior. See " { $link "hashtables.keys" } " for details." } ;

HELP: hashcode
{ $values { "obj" object } { "code" fixnum } }
{ $description "Computes the hashcode of an object with a default hashing depth. See " { $link hashcode* } " for the hashcode contract." } ;

{ hashcode hashcode* } related-words

HELP: =
{ $values { "obj1" object } { "obj2" object } { "?" "a boolean" } }
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
{ $values { "obj1" object } { "obj2" object } { "?" "a boolean" } }
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
{ $values { "?" "a generalized boolean" } { "true" object } { "false" object } { "true/false" "one two input objects" } }
{ $description "Chooses between two values depending on the boolean value of " { $snippet "cond" } "." } ;

HELP: >boolean
{ $values { "obj" "a generalized boolean" } { "?" "a boolean" } }
{ $description "Convert a generalized boolean into a boolean. That is, " { $link f } " retains its value, whereas anything else becomes " { $link t } "." } ;

HELP: not
{ $values { "obj" "a generalized boolean" } { "?" "a boolean" } }
{ $description "For " { $link f } " outputs " { $link t } " and for anything else outputs " { $link f } "." }
{ $notes "This word implements boolean not, so applying it to integers will not yield useful results (all integers have a true value). Bitwise not is the " { $link bitnot } " word." } ;

HELP: and
{ $values { "obj1" "a generalized boolean" } { "obj2" "a generalized boolean" } { "?" "a generalized boolean" } }
{ $description "If both inputs are true, outputs " { $snippet "obj2" } ". otherwise outputs " { $link f } "." }
{ $notes "This word implements boolean and, so applying it to integers will not yield useful results (all integers have a true value). Bitwise and is the " { $link bitand } " word." }
{ $examples
    "Usually only the boolean value of the result is used, however you can also explicitly rely on the behavior that if both inputs are true, the second is output:"
    { $example "USING: kernel prettyprint ;" "t f and ." "f" }
    { $example "USING: kernel prettyprint ;" "t 7 and ." "7" }
    { $example "USING: kernel prettyprint ;" "\"hi\" 12.0 and ." "12.0" }
} ;

HELP: or
{ $values { "obj1" "a generalized boolean" } { "obj2" "a generalized boolean" } { "?" "a generalized boolean" } }
{ $description "If both inputs are false, outputs " { $link f } ". otherwise outputs the first of " { $snippet "obj1" } " and " { $snippet "obj2" } " which is true." }
{ $notes "This word implements boolean inclusive or, so applying it to integers will not yield useful results (all integers have a true value). Bitwise inclusive or is the " { $link bitor } " word." }
{ $examples
    "Usually only the boolean value of the result is used, however you can also explicitly rely on the behavior that the result will be the first true input:"
    { $example "USING: kernel prettyprint ;" "t f or ." "t" }
    { $example "USING: kernel prettyprint ;" "\"hi\" 12.0 or ." "\"hi\"" }
} ;

HELP: xor
{ $values { "obj1" "a generalized boolean" } { "obj2" "a generalized boolean" } { "?" "a generalized boolean" } }
{ $description "If exactly one input is false, outputs the other input. Otherwise outputs " { $link f } "." }
{ $notes "This word implements boolean exclusive or, so applying it to integers will not yield useful results (all integers have a true value). Bitwise exclusive or is the " { $link bitxor } " word." } ;

HELP: both?
{ $values { "quot" { $quotation "( obj -- ? )" } } { "x" object } { "y" object } { "?" "a boolean" } }
{ $description "Tests if the quotation yields a true value when applied to both " { $snippet "x" } " and " { $snippet "y" } "." }
{ $examples
    { $example "USING: kernel math prettyprint ;" "3 5 [ odd? ] both? ." "t" }
    { $example "USING: kernel math prettyprint ;" "12 7 [ even? ] both? ." "f" }
} ;

HELP: either?
{ $values { "quot" { $quotation "( obj -- ? )" } } { "x" object } { "y" object } { "?" "a boolean" } }
{ $description "Tests if the quotation yields a true value when applied to either " { $snippet "x" } " or " { $snippet "y" } "." }
{ $examples
    { $example "USING: kernel math prettyprint ;" "3 6 [ odd? ] either? ." "t" }
    { $example "USING: kernel math prettyprint ;" "5 7 [ even? ] either? ." "f" }
} ;

HELP: call
{ $values { "callable" callable } }
{ $description "Calls a quotation. Words which " { $link call } " an input parameter must be declared " { $link POSTPONE: inline } " so that a caller which passes in a literal quotation can have a static stack effect." }
{ $examples
    "The following two lines are equivalent:"
    { $code "2 [ 2 + 3 * ] call" "2 2 + 3 *" }
} ;

{ call POSTPONE: call( } related-words

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
{ $values { "quot" { $quotation "( x -- ... )" } } { "x" object } }
{ $description "Call a quotation with a value on the stack, restoring the value when the quotation returns." }
{ $examples
    { $example "USING: arrays kernel prettyprint ;" "2 \"greetings\" [ <array> ] keep 2array ." "{ { \"greetings\" \"greetings\" } \"greetings\" }" }
} ;

HELP: 2keep
{ $values { "quot" { $quotation "( x y -- ... )" } } { "x" object } { "y" object } }
{ $description "Call a quotation with two values on the stack, restoring the values when the quotation returns." } ;

HELP: 3keep
{ $values { "quot" { $quotation "( x y z -- ... )" } } { "x" object } { "y" object } { "z" object } }
{ $description "Call a quotation with three values on the stack, restoring the values when the quotation returns." } ;

HELP: bi
{ $values { "x" object } { "p" { $quotation "( x -- ... )" } } { "q" { $quotation "( x -- ... )" } } }
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
{ $values { "x" object } { "y" object } { "p" { $quotation "( x y -- ... )" } } { "q" { $quotation "( x y -- ... )" } } }
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
{ $values { "x" object } { "y" object } { "z" object } { "p" { $quotation "( x y z -- ... )" } } { "q" { $quotation "( x y z -- ... )" } } }
{ $description "Applies " { $snippet "p" } " to the three input values, then applies " { $snippet "q" } " to the three input values." }
{ $examples
    "If " { $snippet "[ p ]" } " and " { $snippet "[ q ]" } " have stack effect " { $snippet "( x y z -- )" } ", then the following two lines are equivalent:"
    { $code
        "[ p ] [ q ] 3bi"
        "3dup p q"
    }
    "If " { $snippet "[ p ]" } " and " { $snippet "[ q ]" } " have stack effect " { $snippet "( x y z -- w )" } ", then the following two lines are equivalent:"
    { $code
        "[ p ] [ q ] 3bi"
        "3dup p -roll q"
    }
    "In general, the following two lines are equivalent:"
    { $code
        "[ p ] [ q ] 3bi"
        "[ p ] 3keep q"
    }
} ;

HELP: tri
{ $values { "x" object } { "p" { $quotation "( x -- ... )" } } { "q" { $quotation "( x -- ... )" } } { "r" { $quotation "( x -- ... )" } } }
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
{ $values { "x" object } { "y" object } { "p" { $quotation "( x y -- ... )" } } { "q" { $quotation "( x y -- ... )" } } { "r" { $quotation "( x y -- ... )" } } }
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
{ $values { "x" object } { "y" object } { "z" object } { "p" { $quotation "( x y z -- ... )" } } { "q" { $quotation "( x y z -- ... )" } } { "r" { $quotation "( x y z -- ... )" } } }
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
{ $values { "x" object } { "y" object } { "p" { $quotation "( x -- ... )" } } { "q" { $quotation "( y -- ... )" } } }
{ $description "Applies " { $snippet "p" } " to " { $snippet "x" } ", then applies " { $snippet "q" } " to " { $snippet "y" } "." }
{ $examples
    "The following two lines are equivalent:"
    { $code
        "[ p ] [ q ] bi*"
        "[ p ] dip q"
    }
} ;

HELP: 2bi*
{ $values { "w" object } { "x" object } { "y" object } { "z" object } { "p" { $quotation "( w x -- ... )" } } { "q" { $quotation "( y z -- ... )" } } }
{ $description "Applies " { $snippet "p" } " to " { $snippet "w" } " and " { $snippet "x" } ", then applies " { $snippet "q" } " to " { $snippet "y" } " and " { $snippet "z" } "." }
{ $examples
    "The following two lines are equivalent:"
    { $code
        "[ p ] [ q ] 2bi*"
        "[ p ] 2dip q"
    }
} ;

HELP: 2tri*
{ $values { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "p" { $quotation "( u v -- ... )" } } { "q" { $quotation "( w x -- ... )" } } { "r" { $quotation "( y z -- ... )" } } }
{ $description "Applies " { $snippet "p" } " to " { $snippet "u" } " and " { $snippet "v" } ", then applies " { $snippet "q" } " to " { $snippet "w" } " and " { $snippet "x" } ", and finally applies " { $snippet "r" } " to " { $snippet "y" } " and " { $snippet "z" } "." }
{ $examples
    "The following two lines are equivalent:"
    { $code
        "[ p ] [ q ] [ r ] 2tri*"
        "[ [ p ] 2dip q ] 2dip r"
    }
} ;

HELP: tri*
{ $values { "x" object } { "y" object } { "z" object } { "p" { $quotation "( x -- ... )" } } { "q" { $quotation "( y -- ... )" } } { "r" { $quotation "( z -- ... )" } } }
{ $description "Applies " { $snippet "p" } " to " { $snippet "x" } ", then applies " { $snippet "q" } " to " { $snippet "y" } ", and finally applies " { $snippet "r" } " to " { $snippet "z" } "." }
{ $examples
    "The following two lines are equivalent:"
    { $code
        "[ p ] [ q ] [ r ] tri*"
        "[ [ p ] dip q ] dip r"
    }
} ;

HELP: bi@
{ $values { "x" object } { "y" object } { "quot" { $quotation "( obj -- ... )" } } }
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
{ $values { "w" object } { "x" object } { "y" object } { "z" object } { "quot" { $quotation "( obj1 obj2 -- ... )" } } }
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
{ $values { "x" object } { "y" object } { "z" object } { "quot" { $quotation "( obj -- ... )" } } }
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
{ $values { "u" object } { "v" object } { "w" object } { "x" object } { "y" object } { "z" object } { "quot" { $quotation "( obj1 obj2 -- ... )" } } }
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
{ $values { "x" object } { "p" { $quotation "( x -- ... )" } } { "q" { $quotation "( x -- ... )" } } { "p'" { $snippet "[ x p ]" } } { "q'" { $snippet "[ x q ]" } } }
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
  { "p" { $quotation "( x -- ... )" } }
  { "q" { $quotation "( x -- ... )" } }
  { "r" { $quotation "( x -- ... )" } }
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
{ $values { "x" object } { "y" object } { "p" { $quotation "( x -- ... )" } } { "q" { $quotation "( y -- ... )" } } { "p'" { $snippet "[ x p ]" } } { "q'" { $snippet "[ y q ]" } } }
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
  { "p" { $quotation "( x -- ... )" } }
  { "q" { $quotation "( y -- ... )" } }
  { "r" { $quotation "( z -- ... )" } }
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
{ $values { "x" object } { "y" object } { "q" { $quotation "( obj -- ... )" } } { "p'" { $snippet "[ x q ]" } } { "q'" { $snippet "[ y q ]" } } }
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
  { "q" { $quotation "( obj -- ... )" } }
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
"The " { $snippet "cond" } " value is removed from the stack before either quotation is called." } ;

HELP: when
{ $values { "?" "a generalized boolean" } { "true" quotation } }
{ $description "If " { $snippet "cond" } " is not " { $link f } ", calls the " { $snippet "true" } " quotation."
$nl
"The " { $snippet "cond" } " value is removed from the stack before the quotation is called." } ;

HELP: unless
{ $values { "?" "a generalized boolean" } { "false" quotation } }
{ $description "If " { $snippet "cond" } " is " { $link f } ", calls the " { $snippet "false" } " quotation."
$nl
"The " { $snippet "cond" } " value is removed from the stack before the quotation is called." } ;

HELP: if*
{ $values { "?" "a generalized boolean" } { "true" { $quotation "( cond -- ... )" } } { "false" quotation } }
{ $description "Alternative conditional form that preserves the " { $snippet "cond" } " value if it is true."
$nl
"If the condition is true, it is retained on the stack before the " { $snippet "true" } " quotation is called. Otherwise, the condition is removed from the stack and the " { $snippet "false" } " quotation is called."
$nl
"The following two lines are equivalent:"
{ $code "X [ Y ] [ Z ] if*" "X dup [ Y ] [ drop Z ] if" } } ;

HELP: when*
{ $values { "?" "a generalized boolean" } { "true" { $quotation "( cond -- ... )" } } }
{ $description "Variant of " { $link if* } " with no false quotation."
$nl
"The following two lines are equivalent:"
{ $code "X [ Y ] when*" "X dup [ Y ] [ drop ] if" } } ;

HELP: unless*
{ $values { "?" "a generalized boolean" } { "false" "a quotation " } }
{ $description "Variant of " { $link if* } " with no true quotation." }
{ $notes
"The following two lines are equivalent:"
{ $code "X [ Y ] unless*" "X dup [ ] [ drop Y ] if" } } ;

HELP: ?if
{ $values { "default" object } { "cond" "a generalized boolean" } { "true" { $quotation "( cond -- ... )" } } { "false" { $quotation "( default -- ... )" } } }
{ $description "If the condition is " { $link f } ", the " { $snippet "false" } " quotation is called with the " { $snippet "default" } " value on the stack. Otherwise, the " { $snippet "true" } " quotation is called with the condition on the stack." }
{ $notes
"The following two lines are equivalent:"
{ $code "[ X ] [ Y ] ?if" "dup [ nip X ] [ drop Y ] if" }
"The following two lines are equivalent:"
{ $code "[ ] [ ] ?if" "swap or" } } ;

HELP: die
{ $description "Starts the front-end processor (FEP), which is a low-level debugger which can inspect memory addresses and the like. The FEP is also entered when a critical error occurs." }
{ $notes
    "The term FEP originates from the Lisp machines of old. According to the Jargon File,"
    $nl
    { $strong "fepped out" } " /fept owt/ " { $emphasis "adj." }  " The Symbolics 3600 LISP Machine has a Front-End Processor called a `FEP' (compare sense 2 of box). When the main processor gets wedged, the FEP takes control of the keyboard and screen. Such a machine is said to have `fepped out' or `dropped into the fep'." 
    $nl
    { $url "http://www.jargon.net/jargonfile/f/feppedout.html" }
} ;

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

HELP: most
{ $values { "x" object } { "y" object } { "quot" { $quotation "( x y -- ? )" } } { "z" "either " { $snippet "x" } " or " { $snippet "y" } } }
{ $description "If the quotation yields a true value when applied to " { $snippet "x" } " and " { $snippet "y" } ", outputs " { $snippet "x" } ", otherwise outputs " { $snippet "y" } "." } ;

HELP: curry
{ $values { "obj" object } { "quot" callable } { "curry" curry } }
{ $description "Partial application. Outputs a " { $link callable } " which first pushes " { $snippet "obj" } " and then calls " { $snippet "quot" } "." }
{ $class-description "The class of objects created by " { $link curry } ". These objects print identically to quotations and implement the sequence protocol, however they only use two cells of storage; a reference to the object and a reference to the underlying quotation." }
{ $notes "Even if " { $snippet "obj" } " is a word, it will be pushed as a literal."
$nl
"This operation is efficient and does not copy the quotation." }
{ $examples
    { $example "USING: kernel prettyprint ;" "5 [ . ] curry ." "[ 5 . ]" }
    { $example "USING: kernel prettyprint see ;" "\\ = [ see ] curry ." "[ \\ = see ]" }
    { $example "USING: kernel math prettyprint sequences ;" "{ 1 2 3 } 2 [ - ] curry map ." "{ -1 0 1 }" }
} ;

HELP: 2curry
{ $values { "obj1" object } { "obj2" object } { "quot" callable } { "curry" curry } }
{ $description "Outputs a " { $link callable } " which pushes " { $snippet "obj1" } " and " { $snippet "obj2" } " and then calls " { $snippet "quot" } "." }
{ $notes "This operation is efficient and does not copy the quotation." }
{ $examples
    { $example "USING: kernel math prettyprint ;" "5 4 [ + ] 2curry ." "[ 5 4 + ]" }
} ;

HELP: 3curry
{ $values { "obj1" object } { "obj2" object } { "obj3" object } { "quot" callable } { "curry" curry } }
{ $description "Outputs a " { $link callable } " which pushes " { $snippet "obj1" } ", " { $snippet "obj2" } " and " { $snippet "obj3" } ", and then calls " { $snippet "quot" } "." }
{ $notes "This operation is efficient and does not copy the quotation." } ;

HELP: with
{ $values { "param" object } { "obj" object } { "quot" { $quotation "( param elt -- ... )" } } { "obj" object } { "curry" curry } }
{ $description "Partial application on the left. The following two lines are equivalent:"
    { $code "swap [ swap A ] curry B" }
    { $code "[ A ] with B" }
    
}
{ $notes "This operation is efficient and does not copy the quotation." }
{ $examples
    { $example "USING: kernel math prettyprint sequences ;" "2 { 1 2 3 } [ - ] with map ." "{ 1 0 -1 }" }
} ;

HELP: compose
{ $values { "quot1" callable } { "quot2" callable } { "compose" compose } }
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
{ $values { "quot1" callable } { "quot2" callable } { "compose" compose } }
{ $description "Quotation composition. Outputs a " { $link callable } " which calls " { $snippet "quot2" } " followed by " { $snippet "quot1" } "." }
{ $notes "See " { $link compose } " for details." } ;

{ compose prepose } related-words

HELP: dip
{ $values { "x" object } { "quot" quotation } }
{ $description "Calls " { $snippet "quot" } " with " { $snippet "obj" } " hidden on the retain stack." }
{ $examples
    { $example "USING: arrays kernel math prettyprint ;" "10 20 30 [ / ] dip 2array ." "{ 1/2 30 }" }
} ;

HELP: 2dip
{ $values { "x" object } { "y" object } { "quot" quotation } }
{ $description "Calls " { $snippet "quot" } " with " { $snippet "x" } " and " { $snippet "y" } " hidden on the retain stack." }
{ $notes "The following are equivalent:"
    { $code "[ [ foo bar ] dip ] dip" }
    { $code "[ foo bar ] 2dip" }
} ;

HELP: 3dip
{ $values { "x" object } { "y" object } { "z" object } { "quot" quotation } }
{ $description "Calls " { $snippet "quot" } " with " { $snippet "x" } ", " { $snippet "y" } " and " { $snippet "z" } " hidden on the retain stack." }
{ $notes "The following are equivalent:"
    { $code "[ [ [ foo bar ] dip ] dip ] dip" }
    { $code "[ foo bar ] 3dip" }
} ;

HELP: 4dip
{ $values { "w" object } { "x" object } { "y" object } { "z" object } { "quot" quotation } }
{ $description "Calls " { $snippet "quot" } " with " { $snippet "w" } ", " { $snippet "x" } ", " { $snippet "y" } " and " { $snippet "z" } " hidden on the retain stack." }
{ $notes "The following are equivalent:"
    { $code "[ [ [ [ foo bar ] dip ] dip ] dip ] dip" }
    { $code "[ foo bar ] 4dip" }
} ;

HELP: while
{ $values { "pred" { $quotation "( -- ? )" } } { "body" "a quotation" } }
{ $description "Calls " { $snippet "body" } " until " { $snippet "pred" } " returns " { $link f } "." } ;

HELP: until
{ $values { "pred" { $quotation "( -- ? )" } } { "body" "a quotation" } }
{ $description "Calls " { $snippet "body" } " until " { $snippet "pred" } " returns " { $link t } "." } ;

HELP: do
{ $values { "pred" { $quotation "( -- ? )" } } { "body" "a quotation" } }
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
{ $subsection while }
{ $subsection until }
"To execute one iteration of a loop, use the following word:"
{ $subsection do }
"This word is intended as a modifier. The normal " { $link while } " loop never executes the body if the predicate returns first on the first iteration. To ensure the body executes at least once, use " { $link do } ":"
{ $code
    "[ P ] [ Q ] do while"
}
"A simpler looping combinator which executes a single quotation until it returns " { $link f } ":"
{ $subsection loop } ;

HELP: assert
{ $values { "got" "the obtained value" } { "expect" "the expected value" } }
{ $description "Throws an " { $link assert } " error." }
{ $error-description "Thrown when a unit test or other assertion fails." } ;

HELP: assert=
{ $values { "a" object } { "b" object } }
{ $description "Throws an " { $link assert } " error if " { $snippet "a" } " does not equal " { $snippet "b" } "." } ;

ARTICLE: "shuffle-words" "Shuffle words"
"Shuffle words rearrange items at the top of the data stack. They control the flow of data between words that perform actions."
$nl
"The " { $link "cleave-combinators" } ", " { $link "spread-combinators" } " and " { $link "apply-combinators" } " are closely related to shuffle words and should be used instead where possible because they can result in clearer code; also, see the advice in " { $link "cookbook-philosophy" } "."
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
{ $subsection 2over }
{ $subsection pick }
{ $subsection tuck }
"Permuting stack elements:"
{ $subsection swap }
{ $subsection swapd }
{ $subsection rot }
{ $subsection -rot }
{ $subsection spin }
{ $subsection roll }
{ $subsection -roll } ;

ARTICLE: "equality" "Equality"
"There are two distinct notions of “sameness” when it comes to objects."
$nl
"You can test if two references point to the same object (" { $emphasis "identity comparison" } "). This is rarely used; it is mostly useful with large, mutable objects where the object identity matters but the value is transient:"
{ $subsection eq? }
"You can test if two objects are equal in a domain-specific sense, usually by being instances of the same class, and having equal slot values (" { $emphasis "value comparison" } "):"
{ $subsection = }
"A third form of equality is provided by " { $link number= } ". It compares numeric value while disregarding types."
$nl
"Custom value comparison methods for use with " { $link = } " can be defined on a generic word:"
{ $subsection equal? }
"Utility class:"
{ $subsection identity-tuple }
"An object can be cloned; the clone has distinct identity but equal value:"
{ $subsection clone } ;

ARTICLE: "assertions" "Assertions"
"Some words to make assertions easier to enforce:"
{ $subsection assert }
{ $subsection assert= } ;

