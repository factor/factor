USING: arrays assocs classes classes.tuple.private
compiler.units growable help.markup help.syntax kernel math
sbufs sequences slots strings vectors words ;
IN: classes.tuple

ARTICLE: "slot-read-only-declaration" "Read-only slots"
"By default, all slots are writable. If a slot is explicitly declared " { $link read-only } ", then no writer method is generated for the slot, and the only way to set it to a value other than its initial value is to construct an instance of the tuple with " { $link boa } ", passing the initial value for the read-only slot on the stack; the common idiom of calling " { $link new } " and then immediately filling in slot values with setter words will not work with read-only slots." ;

ARTICLE: "slot-class-declaration" "Slot class declarations"
"Class declaration is optional, and the default value is " { $link object } ", the class of all objects. If a more specific class is declared, then the object system maintains an invariant that the value of the slot must always be an instance of the class, even during construction. This invariant is enforced at a number of locations:"
{ $list
    { "Writer words (" { $link "accessors" } ") throw an error if the new value does not satisfy the class predicate." }
    { "The " { $link new } " word fills in slots with their initial values; the (per-class) initial values are required to satisfy the class predicate." }
    { "The " { $link boa } " word ensures that the values on the stack satisfy the class predicate." }
    { { $link "mirrors" } " ensure that the value passed to " { $link set-at } " satisfies the class predicate." }
    { "The " { $link slots>tuple } " and " { $link >tuple } " words ensure that the values in the sequence satisfy the correct class predicates." }
    { { $link "tuple-redefinition" } " fills in new slots with initial values and ensures that changes to existing declarations result in incompatible values being replaced with the initial value of their respective slots." }
}
{ $subsections "slot-class-coercion" }
"The " { $link "maybes" } " are a useful way to specify class for an optional slot." ;

ARTICLE: "slot-class-coercion" "Coercive slot declarations"
"If the class of a slot is declared to be one of " { $link fixnum } " or " { $link float } ", then rather than testing values with the class predicate, writer words coerce values to the relevant type with " { $link >fixnum } " or " { $link >float } ". This may still result in error, but permits a wider range of values than a class predicate test. It also results in a possible loss of precision; for example, storing a large integer into a " { $link fixnum } " slot will silently overflow and discard high bits, and storing a ratio into a " { $link float } " slot may lose precision if the ratio is one which cannot be represented exactly with floating-point."
$nl
"This feature is mostly intended as an optimization for low-level code designed to avoid integer overflow, or where floating point precision is sufficient. Most code needs to work transparently with large integers, and thus should avoid the coercion behavior by using " { $link integer } " and " { $link real } " in place of " { $link fixnum } " and " { $link float } "." ;

ARTICLE: "tuple-declarations" "Tuple slot declarations"
"The slot specifier syntax of the " { $link POSTPONE: TUPLE: } " parsing word understands the following slot attributes:"
{ $list
    "class declaration: values must satisfy the class predicate"
    { "whether a slot is read only or not (" { $link read-only } ")" }
    { "an initial value (" { $link initial: } ")" }
}
{ $subsections
    "slot-read-only-declaration"
    "slot-class-declaration"
    "slot-initial-values"
} ;

ARTICLE: "parameterized-constructors" "Parameterized constructors"
"A " { $emphasis "parameterized constructor" } " is a word which directly or indirectly calls " { $link new } " or " { $link boa } ", but instead of passing a literal class symbol, it takes the class symbol as an input from the stack."
$nl
"Parameterized constructors are useful in many situations, in particular with subclassing. For example, consider the following code:"
{ $code
    "TUPLE: vehicle max-speed occupants ;"
    ""
    ": add-occupant ( person vehicle -- ) occupants>> push ;"
    ""
    "TUPLE: car < vehicle engine ;"
    ": <car> ( max-speed engine -- car )"
    "    car new"
    "        V{ } clone >>occupants"
    "        swap >>engine"
    "        swap >>max-speed ;"
    ""
    "TUPLE: aeroplane < vehicle max-altitude ;"
    ": <aeroplane> ( max-speed max-altitude -- aeroplane )"
    "    aeroplane new"
    "        V{ } clone >>occupants"
    "        swap >>max-altitude"
    "        swap >>max-speed ;"
}
"The two constructors depend on the implementation of " { $snippet "vehicle" } " because they are responsible for initializing the " { $snippet "occupants" } " slot to an empty vector. If this slot is changed to contain a hashtable instead, there will be two places instead of one. A better approach is to use a parameterized constructor for vehicles:"
{ $code
    "TUPLE: vehicle max-speed occupants ;"
    ""
    ": add-occupant ( person vehicle -- ) occupants>> push ;"
    ""
    ": new-vehicle ( class -- vehicle )"
    "    new"
    "        V{ } clone >>occupants ;"
    ""
    "TUPLE: car < vehicle engine ;"
    ": <car> ( max-speed engine -- car )"
    "    car new-vehicle"
    "        swap >>engine"
    "        swap >>max-speed ;"
    ""
    "TUPLE: aeroplane < vehicle max-altitude ;"
    ": <aeroplane> ( max-speed max-altitude -- aeroplane )"
    "    aeroplane new-vehicle"
    "        swap >>max-altitude"
    "        swap >>max-speed ;"
}
"The naming convention for parameterized constructors is " { $snippet "new-" { $emphasis "class" } } "." ;

ARTICLE: "tuple-constructors" "Tuple constructors"
"Tuples are created by calling one of two constructor primitives:"
{ $subsections
    new
    boa
}
"A shortcut for defining BOA constructors:"
{ $subsections POSTPONE: C: }
"By convention, construction logic is encapsulated in a word named after the tuple class surrounded in angle brackets; for example, the constructor word for a " { $snippet "point" } " class might be named " { $snippet "<point>" } "."
$nl
"Constructors play a part in enforcing the invariant that slot values must always match slot declarations. The " { $link new } " word fills in the tuple with initial values, and " { $link boa } " ensures that the values on the stack match the corresponding slot declarations. See " { $link "tuple-declarations" } "."
$nl
"All tuple construction should be done through constructor words, and construction primitives should be encapsulated and never called outside of the vocabulary where the class is defined, because this encourages looser coupling. For example, a constructor word could be changed to use memoization instead of always constructing a new instance, or it could be changed to construct a different class, without breaking callers."
$nl
"Examples of constructors:"
{ $code
    "TUPLE: color"
    "{ red integer }"
    "{ green integer }"
    "{ blue integer }"
    "{ alpha integer initial: 1 } ;"
    ""
    "! The following two are equivalent"
    "C: <rgba> color"
    ": <rgba> color boa ;"
    ""
    "! We can define constructors which call other constructors"
    ": <rgb> ( r g b -- color ) 1 <rgba> ;"
    ""
    "! The following two are equivalent; note the initial value"
    ": <color> ( -- color ) color new ;"
    ": <color> ( -- color ) 0 0 0 1 <rgba> ;"
    "! Run-time error"
    "\"not a number\" 2 3 4 color boa"
}
{ $subsections "parameterized-constructors" } ;

ARTICLE: "tuple-inheritance-example" "Tuple subclassing example"
"Rectangles, parallelograms and circles are all shapes. We support two operations on shapes:"
{ $list
    "Computing the area"
    "Computing the perimeter"
}
"Rectangles and parallelograms use the same algorithm for computing the area, whereas they use different algorithms for computing perimeter. Also, rectangles and parallelograms both have " { $snippet "width" } " and " { $snippet "height" } " slots. We can exploit this with subclassing:"
{ $code
    "USING: accessors kernel math math.constants math.functions ;"
    "GENERIC: area ( shape -- n )"
    "GENERIC: perimeter ( shape -- n )"
    ""
    "TUPLE: shape ;"
    ""
    "TUPLE: circle < shape radius ;"
    "M: circle area radius>> sq pi * ;"
    "M: circle perimeter radius>> 2 * pi * ;"
    ""
    "TUPLE: quad < shape width height ;"
    "M: quad area [ width>> ] [ height>> ] bi * ;"
    ""
    "TUPLE: rectangle < quad ;"
    "M: rectangle perimeter [ width>> 2 * ] [ height>> 2 * ] bi + ;"
    ""
    ": hypot ( a b -- c ) [ sq ] bi@ + sqrt ;"
    ""
    "TUPLE: parallelogram < quad skew ;"
    "M: parallelogram perimeter"
    "    [ width>> 2 * ] [ [ height>> ] [ skew>> ] bi hypot 2 * ] bi + ;"
} ;

ARTICLE: "tuple-inheritance-anti-example" "When not to use tuple subclassing"
"Tuple subclassing should only be used for " { $emphasis "is-a" } " relationships; for example, a car " { $emphasis "is a" } " vehicle, and a circle " { $emphasis "is a" } " shape."
{ $heading "Anti-pattern #1: subclassing for has-a" }
"Subclassing should not be used for " { $emphasis "has-a" } " relationships. For example, if a shape " { $emphasis "has a" } " color, then " { $snippet "shape" } " should not subclass " { $snippet "color" } ". Using tuple subclassing in inappropriate situations leads to code which is more brittle and less flexible than it should be."
$nl
"For example, suppose that " { $snippet "shape" } " inherits from " { $snippet "color" } ":"
{ $code
    "TUPLE: color r g b ;"
    "TUPLE: shape < color ... ;"
}
"Now, the implementation of " { $snippet "shape" } " depends on a specific representation of colors as RGB colors. If a new generic color protocol is devised which also allows HSB and YUV colors to be used, the shape class will not be able to take advantage of them without changes. A better approach is to store the color in a slot:"
{ $code
    "TUPLE: rgb-color r g b ;"
    "TUPLE: hsv-color h s v ;"
    "..."
    "TUPLE: shape color ... ;"
}
"The " { $vocab-link "delegate" } " library provides a language abstraction for expressing has-a relationships."
{ $heading "Anti-pattern #2: subclassing for implementation sharing only" }
"Tuple subclassing purely for sharing implementations of methods is not a good idea either. If a class " { $snippet "A" } " is a subclass of a class " { $snippet "B" } ", then instances of " { $snippet "A" } " should be usable anywhere that an instance of " { $snippet "B" } " is. If this property does not hold, then subclassing should not be used."
$nl
"There are two alternatives which are preferred to subclassing in this case. The first is " { $link "mixins" } "."
$nl
"The second is to use ad-hoc slot polymorphism. If two classes define a slot with the same name, then code which uses " { $link "accessors" } " can operate on instances of both objects, assuming the values stored in that slot implement a common protocol. This allows code to be shared without creating contrived relationships between classes."
{ $heading "Anti-pattern #3: subclassing to override a method definition" }
"While method overriding is a very powerful tool, improper use can cause tight coupling of code and lead to difficulty in testing and refactoring. Subclassing should not be used as a means of \"monkey patching\" methods to fix bugs and add features. Only subclass from classes which were designed to be inherited from, and when writing classes of your own which are intended to be subclassed, clearly document what subclasses may and may not do. This includes construction policy; document whether subclasses should use " { $link new } ", " { $link boa } ", or a custom parameterized constructor."
{ $see-also "parameterized-constructors" } ;

ARTICLE: "tuple-subclassing" "Tuple subclassing"
"Tuple subclassing can be used to express natural relationships between classes at the language level. For example, every car " { $emphasis "is a" } " vehicle, so if the " { $snippet "car" } " class subclasses the " { $snippet "vehicle" } " class, it can " { $emphasis "inherit" } " the slots and methods of " { $snippet "vehicle" } "."
$nl
"To define one tuple class as a subclass of another, use the optional superclass parameter to " { $link POSTPONE: TUPLE: } ":"
{ $code
    "TUPLE: subclass < superclass ... ;"
}
{ $subsections
    "tuple-inheritance-example"
    "tuple-inheritance-anti-example"
}
"Declaring a tuple class final prohibits other classes from subclassing it:"
{ $subsections POSTPONE: final }
{ $see-also "call-next-method" "parameterized-constructors" "unions" "mixins" "maybes" } ;

ARTICLE: "tuple-introspection" "Tuple introspection"
"In addition to the slot reader and writer words which " { $link POSTPONE: TUPLE: } " defines for every tuple class, it is possible to construct and take apart entire tuples in a generic way."
{ $subsections
    >tuple
    tuple>array
    tuple-slots
    slots>tuple
}
"Tuples can be compared for slot equality even if the tuple class overrides " { $link equal? } ":"
{ $subsections tuple= }
"Tuple classes can also be defined at run time:"
{ $subsections define-tuple-class }
{ $see-also "slots" "mirrors" } ;

ARTICLE: "tuple-examples" "Tuple examples"
"An example:"
{ $code "TUPLE: employee name position salary ;" }
"This defines a class word named " { $snippet "employee" } ", a predicate " { $snippet "employee?" } ", and the following slot accessors:"
{ $table
    { { $strong "Reader" } { $strong "Writer" } { $strong "Setter" } { $strong "Changer" } }
    { { $snippet "name>>" } { $snippet "name<<" } { $snippet ">>name" } { $snippet "change-name" } }
    { { $snippet "position>>" } { $snippet "position<<" } { $snippet ">>position" } { $snippet "change-position" } }
    { { $snippet "salary>>" } { $snippet "salary<<" } { $snippet ">>salary" } { $snippet "change-salary" } }
}
"We can define a constructor which makes an empty employee:"
{ $code
    ": <employee> ( -- employee )"
    "    employee new ;"
}
"Or we may wish the default constructor to always give employees a starting salary:"
{ $code
    ": <employee> ( -- employee )"
    "    employee new"
    "        40000 >>salary ;"
}
"We can define more refined constructors:"
{ $code
    ": <manager> ( -- manager )"
    "    <employee> \"project manager\" >>position ;" }
"An alternative strategy is to define the most general BOA constructor first:"
{ $code
    ": <employee> ( name position -- employee )"
    "    40000 employee boa ;"
}
"Now we can define more specific constructors:"
{ $code
    ": <manager> ( name -- employee )"
    "    \"manager\" <employee> ;" }
"An example using reader words:"
{ $code
    "TUPLE: check to amount number ;"
    ""
    "SYMBOL: checks"
    ""
    ": <check> ( to amount -- check )"
    "    checks counter check boa ;"
    ""
    ": biweekly-paycheck ( employee -- check )"
    "    [ name>> ] [ salary>> 26 / ] bi <check> ;"
}
"An example of using a changer:"
{ $code
    ": positions ( -- seq )"
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
    "    positions [ index 1 + ] keep nth ;"
    ""
    ": promote ( employee -- employee )"
    "    [ 1.2 * ] change-salary"
    "    [ next-position ] change-position ;"
}
"An example using subclassing can be found in " { $link "tuple-inheritance-example" } "." ;

ARTICLE: "tuple-redefinition" "Tuple redefinition"
"In the following, the " { $emphasis "direct slots" } " of a tuple class refers to the slot names specified in the " { $link POSTPONE: TUPLE: } " form defining the tuple class, and the " { $emphasis "effective slots" } " refers to the concatenation of the direct slots together with slots defined on superclasses."
$nl
"When the " { $emphasis "effective slots" } " of a tuple class change, all instances of the class, including subclasses, are updated."
$nl
"There are three ways in which the list of effective slots may change:"
{ $list
    "Adding or removing direct slots of the class"
    "Adding or removing direct slots of a superclass of the class"
    "Changing the inheritance hierarchy by changing the superclass of a class"
    "Declarations changing on existing slots"
}
"In all cases, the new effective slots are compared with the old effective slots, and each instance is updated as follows:"
{ $list
    "If any slots were removed, the values are removed from the instance and are lost forever."
    "If any slots were added, the instance gains these slots, all set to their initial values."
    "If any slots are permuted, their values in instances do not change; only the layout of the instance changes in memory."
    "If the slot declaration of an existing slot changes, existing values are checked to see if they are still an instance of the required class. Any which are not are replaced by the initial value of that slot."
    "If the number or order of effective slots changes, any BOA constructors are recompiled."
}
"Note that if a slot is moved from a class to its superclass (or vice versa) in the same compilation unit, the value of the slot is preserved in existing instances, because tuple instance update always runs at the end of a compilation unit. However, if it is removed in one compilation unit and added in another, the value in existing instances is lost." ;

ARTICLE: "protocol-slots" "Protocol slots"
"A " { $emphasis "protocol slot" } " is one which is assumed to exist by the implementation of a class, without being defined on the class itself. The burden is on subclasses (or mixin instances) to provide this slot."
$nl
"Protocol slots are defined using a parsing word:"
{ $subsections POSTPONE: SLOT: }
"Protocol slots are used where the implementation of a superclass needs to assume that each subclass defines certain slots, however the slots of each subclass are potentially declared with different class specializers, thus preventing the slots from being defined in the superclass."
$nl
"For example, the " { $link growable } " mixin provides an implementation of the sequence protocol which wraps an underlying sequence, resizing it as necessary when elements are added beyond the length of the sequence. It assumes that the concrete mixin instances define two slots, " { $snippet "length" } " and " { $snippet "underlying" } ". These slots are defined as protocol slots: " { $snippet "SLOT: length" } " and " { $snippet "SLOT: underlying" } ". "
"An alternate approach would be to define " { $link growable } " as a tuple class with these two slots, and have other classes subclass it as required. However, this rules out subclasses defining these slots with custom type declarations."
$nl
"For example, compare the definitions of the " { $link sbuf } " class,"
{ $code
    "TUPLE: sbuf"
    "{ underlying string }"
    "{ length array-capacity } ;"
    ""
    "INSTANCE: sbuf growable"
}
"with that of the " { $link vector } " class:"
{ $code
    "TUPLE: vector"
    "{ underlying array }"
    "{ length array-capacity } ;"
    ""
    "INSTANCE: vector growable"
} ;

ARTICLE: "tuples" "Tuples"
"Tuples are user-defined classes composed of named slots. They are the central data type of Factor's object system."
{ $subsections "tuple-examples" }
"A parsing word defines tuple classes:"
{ $subsections POSTPONE: TUPLE: }
"For each tuple class, several words are defined, the class word, a class predicate, and accessor words for each slot."
$nl
"The class word is used for defining methods on the tuple class; it has the same name as the tuple class. The predicate is named " { $snippet { $emphasis "name" } "?" } ". Initially, no specific words are defined for constructing new instances of the tuple. Constructors must be defined explicitly, and tuple slots are accessed via automatically-generated accessor words."
{ $subsections
    "accessors"
    "tuple-constructors"
    "tuple-subclassing"
    "tuple-declarations"
    "protocol-slots"
    "tuple-introspection"
}
"Tuple classes can be redefined; this updates existing instances:"
{ $subsections "tuple-redefinition" }
"Tuple literal syntax is documented in " { $link "syntax-tuples" } "." ;

ABOUT: "tuples"

HELP: tuple-class
{ $class-description "The class of tuple class words." }
{ $examples { $example "USING: classes.tuple prettyprint ;" "IN: scratchpad" "TUPLE: name title first last ;" "name tuple-class? ." "t" } } ;

HELP: tuple=
{ $values { "tuple1" tuple } { "tuple2" tuple } { "?" boolean } }
{ $description "Checks if two tuples have equal slot values. This is the default behavior of " { $link = } " on tuples, unless the tuple class subclasses " { $link identity-tuple } " or implements a method on " { $link equal? } ". In cases where equality has been redefined, this word can be used to get the default semantics if needed." } ;

HELP: tuple
{ $class-description "The class of tuples. This class is further partitioned into disjoint subclasses; each tuple shape defined by " { $link POSTPONE: TUPLE: } " is a new class."
$nl
"Tuple classes have additional word properties:"
{ $list
    { { $snippet "\"predicate\"" } " - a quotation which tests if the top of the stack is an instance of this tuple class" }
    { { $snippet "\"slots\"" } " - a sequence of " { $link slot-spec } " instances" }
    { { $snippet "\"layout\"" } " - an array with the tuple size and superclasses encoded in a format amneable to fast method dispatch" }
} } ;

HELP: define-tuple-predicate
{ $values { "class" tuple-class } }
{ $description "Defines a predicate word that tests if the top of the stack is an instance of " { $snippet "class" } ". This will only work if " { $snippet "class" } " is a tuple class." }
$low-level-note ;

HELP: redefine-tuple-class
{ $values { "class" class } { "superclass" class } { "slots" { $sequence string } } }
{ $description "If the new slot layout differs from the existing one, updates all existing instances of this tuple class, and forgets any slot accessor words which are no longer needed."
$nl
"If the class is not a tuple class word, this word does nothing." }
$low-level-note ;

HELP: tuple-slots
{ $values { "tuple" tuple } { "seq" sequence } }
{ $description "Pushes a sequence of tuple slot values, not including the tuple class word." } ;

{ tuple-slots tuple>array } related-words

HELP: define-tuple-slots
{ $values { "class" tuple-class } }
{ $description "Defines slot accessor and mutator words for the tuple." }
$low-level-note ;

HELP: define-tuple-class
{ $values { "class" word } { "superclass" class } { "slots" { $sequence string } } }
{ $description "Defines a tuple class inheriting from " { $snippet "superclass" } " with slots named by " { $snippet "slots" } ". This is the run time equivalent of " { $link POSTPONE: TUPLE: } "." }
{ $notes "This word must be called from inside " { $link with-compilation-unit } "." }
{ $side-effects "class" } ;

{ tuple-class define-tuple-class POSTPONE: TUPLE: } related-words

HELP: >tuple
{ $values { "seq" sequence } { "tuple" tuple } }
{ $description "Creates a tuple with slot values taken from a sequence. The first element of the sequence must be a tuple class word and the remainder the declared slots."
$nl
"If the sequence has too few elements, the remaining slots in the tuple are set to their initial values." }
{ $errors "Throws an error if one of the following occurs:"
    { $list
        "the first element of the sequence is not a tuple class word"
        "the values in the sequence do not satisfy the slot class predicates"
        "the sequence is too long"
    }
} ;

HELP: tuple>array
{ $values { "tuple" tuple } { "array" array } }
{ $description "Outputs an array having the tuple's slots as elements. The first element is the tuple class word and remainder are declared slots." } ;

HELP: initial-values
{ $values { "class" class } { "seq" sequence } }
{ $description "Gets a sequence with the initial value for each tuple slot." } ;

HELP: <tuple>
{ $values { "layout" "a tuple layout array" } { "tuple" tuple } }
{ $description "Low-level tuple constructor. User code should never call this directly, and instead use " { $link new } "." } ;

HELP: <tuple-boa>
{ $values { "slots..." "values" } { "layout" "a tuple layout array" } { "tuple" tuple } }
{ $description "Low-level tuple constructor. User code should never call this directly, and instead use " { $link boa } "." } ;

HELP: new
{ $values { "class" tuple-class } { "tuple" tuple } }
{ $description "Creates a new instance of " { $snippet "class" } " with all slots set to their initial values (see " { $link "tuple-declarations" } ")." }
{ $examples
    { $example
        "USING: kernel prettyprint ;"
        "IN: scratchpad"
        "TUPLE: employee number name department ;"
        "employee new ."
        "T{ employee }"
    }
} ;

HELP: boa
{ $values { "slots..." "slot values" } { "class" tuple-class } { "tuple" tuple } }
{ $description "Creates a new instance of " { $snippet "class" } " and fill in the slots from the stack, with the top-most stack element being stored in the right-most slot." }
{ $notes "The name " { $snippet "boa" } " is shorthand for \"by order of arguments\", and \"BOA constructor\" is a pun on \"boa constrictor\"." }
{ $errors "Throws an error if the slot values do not match class declarations on slots (see " { $link "tuple-declarations" } ")." } ;

HELP: bad-superclass
{ $error-description "Thrown if an attempt is made to subclass a class that is not a tuple class, or a tuple class declared " { $link POSTPONE: final } "." } ;

HELP: ?offset-of-slot
{ $values { "name" string } { "tuple" tuple } { "n/f" { $maybe integer } } }
{ $description "Returns the offset of a tuple slot accessed by " { $snippet "name" } ", or " { $link f } " if no slot with that name." } ;

HELP: offset-of-slot
{ $values { "name" string } { "tuple" tuple } { "n" integer } }
{ $description "Returns the offset of a tuple slot accessed by " { $snippet "name" } "." }
{ $errors "Throws a " { $link no-slot } " error if no slot with that name." } ;

HELP: get-slot-named
{ $values { "name" string } { "tuple" tuple } { "value" object } }
{ $description "Returns the " { $snippet "value" } " stored in a tuple slot accessed by " { $snippet "name" } "." }
{ $errors "Throws a " { $link no-slot } " error if no slot with that name." } ;

HELP: set-slot-named
{ $values { "value" object } { "name" string } { "tuple" tuple } }
{ $description "Stores the " { $snippet "value" } " into a tuple slot accessed by " { $snippet "name" } "." }
{ $errors "Throws a " { $link no-slot } " error if no slot with that name." } ;

HELP: set-slots
{ $values { "assoc" assoc } { "tuple" tuple } }
{ $description "For each " { $snippet "{ key value }" } " pair in " { $snippet "assoc" } ", sets the " { $snippet "key" } " slot in " { $snippet "obj" } " to " { $snippet "value" } "." } ;

HELP: from-slots
{ $values { "assoc" assoc } { "class" tuple-class } { "tuple" tuple } }
{ $description "Creates a new instance of " { $snippet "class" } " with slot values specified by " { $snippet "assoc" } "." } ;
