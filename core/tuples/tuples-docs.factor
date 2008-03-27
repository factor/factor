USING: generic help.markup help.syntax kernel
tuples.private classes slots quotations words arrays
generic.standard sequences definitions compiler.units ;
IN: tuples

ARTICLE: "tuple-constructors" "Constructors"
"Tuples are created by calling one of two words:"
{ $subsection construct-empty }
{ $subsection construct-boa }
"By convention, construction logic is encapsulated in a word named after the tuple class surrounded in angle brackets; for example, the constructor word for a " { $snippet "point" } " class might be named " { $snippet "<point>" } "."
$nl
"A shortcut for defining BOA constructors:"
{ $subsection POSTPONE: C: }
"Examples of constructors:"
{ $code
    "TUPLE: color red green blue alpha ;"
    ""
    "C: <rgba> rgba"
    ": <rgba> color construct-boa ; ! identical to above"
    ""
    ": <rgb> f <rgba> ;"
    ""
    ": <color> construct-empty ;"
    ": <color> f f f f <rgba> ; ! identical to above"
} ;

ARTICLE: "tuple-delegation" "Tuple delegation"
"If a generic word having the " { $link standard-combination } " method combination is called on a tuple for which it does not have an applicable method, the method call is forwarded to the tuple's " { $emphasis "delegate" } ". If no delegate is set, a " { $link no-method } " error is thrown."
{ $subsection delegate }
{ $subsection set-delegate }
"A tuple's delegate should either be another tuple, or " { $link f } ", indicating no delegate is set. Delegation from a tuple to an object of some other type is not fully supported and should be used with caution."
$nl
"Factor uses delegation in place of implementation inheritance, but it is not a direct substitute; in particular, the semantics differ in that a delegated method call receives the delegate on the stack, not the original object."
$nl
"A pair of words examine delegation chains:"
{ $subsection delegates }
{ $subsection is? }
"An example:"
{ $example
    "TUPLE: ellipse center radius ;"
    "TUPLE: colored color ;"
    "{ 0 0 } 10 <ellipse> \"my-ellipse\" set"
    "{ 1 0 0 } <colored> \"my-shape\" set"
    "\"my-ellipse\" get \"my-shape\" get set-delegate"
    "\"my-shape\" get dup color>> swap center>> .s"
    "{ 0 0 }\n{ 1 0 0 }"
} ;

ARTICLE: "tuple-introspection" "Tuple introspection"
"In addition to the slot reader and writer words which " { $link POSTPONE: TUPLE: } " defines for every tuple class, it is possible to construct and take apart entire tuples in a generic way."
{ $subsection >tuple }
{ $subsection tuple>array }
{ $subsection tuple-slots }
"Tuple classes can also be defined at run time:"
{ $subsection define-tuple-class }
{ $see-also "slots" "mirrors" } ;

ARTICLE: "tuple-examples" "Tuple examples"
"An example:"
{ $code "TUPLE: employee name salary position ;" }
"This defines a class word named " { $snippet "employee" } ", a predicate " { $snippet "employee?" } ", and the following slot accessors:"
{ $table
    { "Reader" "Writer" "Setter" "Changer" }
    { { $snippet "name>>" }    { $snippet "(>>name)" }    { $snippet ">>name" }    { $snippet "change-name" }    }
    { { $snippet "salary>>" } { $snippet "(>>salary)" } { $snippet ">>salary" } { $snippet "change-salary" } }
    { { $snippet "position>>" }   { $snippet "(>>position)" }   { $snippet ">>position" }   { $snippet "change-position" }   }
}
"We can define a constructor which makes an empty employee:"
{ $code ": <employee> ( -- employee )"
    "    employee construct-empty ;" }
"Or we may wish the default constructor to always give employees a starting salary:"
{ $code
    ": <employee> ( -- employee )"
    "    employee construct-empty"
    "        40000 >>salary ;"
}
"We can define more refined constructors:"
{ $code
    ": <manager> ( -- manager )"
    "    <employee> \"project manager\" >>position ;" }
"An alternative strategy is to define the most general BOA constructor first:"
{ $code
    ": <employee> ( name position -- person )"
    "    40000 employee construct-boa ;"
}
"Now we can define more specific constructors:"
{ $code
    ": <manager> ( name -- person )"
    "    \"manager\" <person> ;" }
"An example using reader words:"
{ $code
    "TUPLE: check to amount number ;"
    ""
    "SYMBOL: checks"
    ""
    ": <check> ( to amount -- check )"
    "    checks counter check construct-boa ;"
    ""
    ": biweekly-paycheck ( employee -- check )"
    "    dup name>> swap salary>> 26 / <check> ;"
}
"An example of using a changer:"
{ $code
    ": positions"
    "    {"
    "        \"junior programmer\""
    "        \"senior programmer\""
    "        \"project manager\""
    "        \"department manager\""
    "        \"executive\""
    "        \"CTO\""
    "        \"CEO\""
    "        \"enterprise Java world dictator\""
    "    } ;"
    ""
    ": next-position ( role -- newrole )"
    "    positions [ index 1+ ] keep nth ;"
    ""
    ": promote ( person -- person )"
    "    [ 1.2 * ] change-salary"
    "    [ next-position ] change-position ;"
} ;

ARTICLE: "tuples" "Tuples"
"Tuples are user-defined classes composed of named slots."
{ $subsection "tuple-examples" }
"A parsing word defines tuple classes:"
{ $subsection POSTPONE: TUPLE: }
"For each tuple class, several words are defined. First, there is the class word, a class predicate, and accessor words for each slot."
$nl
"The class word is used for defining methods on the tuple class; it has the same name as the tuple class. The predicate is named " { $snippet { $emphasis "name" } "?" } ". Tuple slots are accessed via accessor words:"
{ $subsection "accessors" }
"Initially, no specific words are defined for constructing new instances of the tuple. Constructors must be defined explicitly:"
{ $subsection "tuple-constructors" }
"Further topics:"
{ $subsection "tuple-delegation" }
{ $subsection "tuple-introspection" }
"Tuple literal syntax is documented in " { $link "syntax-tuples" } "." ;

ABOUT: "tuples"

HELP: delegate
{ $values { "obj" object } { "delegate" object } }
{ $description "Returns an object's delegate, or " { $link f } " if no delegate is set." }
{ $notes "A direct consequence of this behavior is that an object may not have a delegate of " { $link f } "." } ;

HELP: set-delegate
{ $values { "delegate" object } { "tuple" tuple } }
{ $description "Sets a tuple's delegate. Method calls not handled by the tuple's class will now be passed on to the delegate." } ;

HELP: tuple=
{ $values { "tuple1" tuple } { "tuple2" tuple } { "?" "a boolean" } }
{ $description "Low-level tuple equality test. User code should use " { $link = } " instead." }
{ $warning "This word is in the " { $vocab-link "tuples.private" } " vocabulary because it does not do any type checking. Passing values which are not tuples can result in memory corruption." } ;

HELP: permutation
{ $values { "seq1" sequence } { "seq2" sequence } { "permutation" "a sequence whose elements are integers or " { $link f } } }
{ $description "Outputs a permutation for taking " { $snippet "seq1" } " to " { $snippet "seq2" } "." } ;

HELP: reshape-tuple
{ $values { "oldtuple" tuple } { "permutation" "a sequence whose elements are integers or " { $link f } } { "newtuple" tuple } }
{ $description "Permutes the slots of a tuple. If a tuple class is redefined at runtime, this word is called on every instance to change its shape to conform to the new layout." } ;

HELP: reshape-tuples
{ $values { "class" tuple-class } { "newslots" "a sequence of strings" } }
{ $description "Changes the shape of every instance of " { $snippet "class" } " for a new slot layout." } ;

HELP: removed-slots
{ $values { "class" tuple-class } { "newslots" "a sequence of strings" } { "seq" "a sequence of strings" } }
{ $description "Outputs the sequence of existing tuple slot names not in " { $snippet "newslots" } "." } ;

HELP: forget-slots
{ $values { "class" tuple-class } { "newslots" "a sequence of strings" } }
{ $description "Forgets accessor words for existing tuple slots which are not in " { $snippet "newslots" } "." } ;

HELP: tuple
{ $class-description "The class of tuples. This class is further partitioned into disjoint subclasses; each tuple shape defined by " { $link POSTPONE: TUPLE: } " is a new class."
$nl
"Tuple classes have additional word properties:"
{ $list
    { { $snippet "\"constructor\"" } " - a word for creating instances of this tuple class" }
    { { $snippet "\"predicate\"" } " - a quotation which tests if the top of the stack is an instance of this tuple class" }
    { { $snippet "\"slots\"" } " - a sequence of " { $link slot-spec } " instances" }
    { { $snippet "\"slot-names\"" } " - a sequence of strings naming the tuple's slots" }
    { { $snippet "\"tuple-size\"" } " - the number of slots" }
} } ;

HELP: define-tuple-predicate
{ $values { "class" tuple-class } }
{ $description "Defines a predicate word that tests if the top of the stack is an instance of " { $snippet "class" } ". This will only work if " { $snippet "class" } " is a tuple class." }
$low-level-note ;

HELP: redefine-tuple-class
{ $values { "class" class } { "superclass" class } { "slots" "a sequence of strings" } }
{ $description "If the new slot layout differs from the existing one, updates all existing instances of this tuple class, and forgets any slot accessor words which are no longer needed."
$nl
"If the class is not a tuple class word, this word does nothing." }
$low-level-note ;

HELP: tuple-slots
{ $values { "tuple" tuple } { "seq" sequence } }
{ $description "Pushes a sequence of tuple slot values, not including the tuple class word and delegate." } ;

{ tuple-slots tuple>array } related-words

HELP: define-tuple-slots
{ $values { "class" tuple-class } { "slots" "a sequence of strings" } }
{ $description "Defines slot accessor and mutator words for the tuple." }
$low-level-note ;

HELP: check-tuple
{ $values { "class" class } }
{ $description "Throws a " { $link check-tuple } " error if " { $snippet "word" } " is not a tuple class word." }
{ $error-description "Thrown if " { $link POSTPONE: C: } " is called with a word which does not name a tuple class." } ;

HELP: define-tuple-class
{ $values { "class" word } { "superclass" class } { "slots" "a sequence of strings" } }
{ $description "Defines a tuple class inheriting from " { $snippet "superclass" } " with slots named by " { $snippet "slots" } ". This is the run time equivalent of " { $link POSTPONE: TUPLE: } "." }
{ $notes "This word must be called from inside " { $link with-compilation-unit } "." }
{ $side-effects "class" } ;

{ tuple-class define-tuple-class POSTPONE: TUPLE: } related-words

HELP: delegates
{ $values { "obj" object } { "seq" sequence } }
{ $description "Outputs the delegation chain of an object. The first element of " { $snippet "seq" } " is " { $snippet "obj" } " itself. If " { $snippet "obj" } " is " { $link f } ", an empty sequence is output." } ;

HELP: is?
{ $values { "obj" object } { "quot" "a quotation with stack effect " { $snippet "( obj -- ? )" } } { "?" "a boolean" } }
{ $description "Tests if the object or one of its delegates satisfies the predicate quotation."
$nl
"Class membership test predicates only test if an object is a direct instance of that class. Sometimes, you need to check delegates, since this gives a clearer picture of what operations the object supports." } ;

HELP: >tuple
{ $values { "seq" sequence } { "tuple" tuple } }
{ $description "Creates a tuple with slot values taken from a sequence. The first element of the sequence must be a tuple class word, the second a delegate, and the remainder the declared slots."
$nl
"If the sequence has too many elements, they are ignored, and if it has too few, the remaining slots in the tuple are set to " { $link f } "." }
{ $errors "Throws an error if the first element of the sequence is not a tuple class word." } ;

HELP: tuple>array ( tuple -- array )
{ $values { "tuple" tuple } { "array" array } }
{ $description "Outputs an array having the tuple's slots as elements. The first element is the tuple class word and the second is the delegate; the remainder are declared slots." } ;

HELP: <tuple> ( layout -- tuple )
{ $values { "layout" tuple-layout } { "tuple" tuple } }
{ $description "Low-level tuple constructor. User code should never call this directly, and instead use " { $link construct-empty } "." } ;

HELP: <tuple-boa> ( ... layout -- tuple )
{ $values { "..." "values" } { "layout" tuple-layout } { "tuple" tuple } }
{ $description "Low-level tuple constructor. User code should never call this directly, and instead use " { $link construct-boa } "." } ;

HELP: construct-empty
{ $values { "class" tuple-class } { "tuple" tuple } }
{ $description "Creates a new instance of " { $snippet "class" } " with all slots initially set to " { $link f } "." }
{ $examples
    { $example
        "USING: kernel prettyprint ;"
        "TUPLE: employee number name department ;"
        "employee construct-empty ."
        "T{ employee f f f f }"
    }
} ;

HELP: construct
{ $values { "..." "slot values" } { "slots" "a sequence of setter words" } { "class" tuple-class } { "tuple" tuple } }
{ $description "Creates a new instance of " { $snippet "class" } ", storing consecutive stack values into the slots of the new tuple using setter words in " { $snippet "slots" } ". The top-most stack element is stored in the right-most slot." }
{ $examples
    "We can define a class:"
    { $code "TUPLE: color red green blue alpha ;" }
    "Together with two constructors:"
    { $code
        ": <rgb> ( r g b -- color )"
        "    { set-color-red set-color-green set-color-blue }"
        "    color construct ;"
        ""
        ": <rgba> ( r g b a -- color )"
        "    { set-color-red set-color-green set-color-blue set-color-alpha }"
        "    color construct ;"
    }
    "The last definition is actually equivalent to the following:"
    { $code ": <rgba> ( r g b a -- color ) rgba construct-boa ;" }
    "Which can be abbreviated further:"
    { $code "C: <rgba> color" }
} ;

HELP: construct-boa
{ $values { "..." "slot values" } { "class" tuple-class } { "tuple" tuple } }
{ $description "Creates a new instance of " { $snippet "class" } " and fill in the slots from the stack, with the top-most stack element being stored in the right-most slot." }
{ $notes "The " { $snippet "-boa" } " suffix is shorthand for ``by order of arguments'', and ``BOA constructor'' is a pun on ``boa constrictor''." } ;
