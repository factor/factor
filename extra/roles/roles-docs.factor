! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: classes.mixin help.markup help.syntax kernel roles ;
IN: roles

HELP: ROLE:
{ $syntax "ROLE: name slots... ;
ROLE: name < role slots... ;
ROLE: name <{ roles... } slots... ;" }
{ $description "Defines a new " { $link role } ". " { $link tuple } " classes which inherit this role will contain the specified " { $snippet "slots" } " as well as the slots associated with the optional inherited " { $snippet "roles" } "."
$nl
"Slot specifiers take one of the following three forms:"
{ $list
    { { $snippet "name" } " - a slot which can hold any object, with no attributes" }
    { { $snippet "{ name attributes... }" } " - a slot which can hold any object, with optional attributes" }
    { { $snippet "{ name class attributes... }" } " - a slot specialized to a specific class, with optional attributes" }
}
"Slot attributes are lists of slot attribute specifiers followed by values; a slot attribute specifier is one of " { $link initial: } " or " { $link read-only } ". See " { $link "tuple-declarations" } " for details." } ;

HELP: ROLE-TUPLE:
{ $syntax "ROLE-TUPLE: name slots ;
ROLE-TUPLE: name < estate slots ;
ROLE-TUPLE: name <{ estates... } slots... ;" }
{ $description "Defines a new " { $link tuple } " class."
$nl
"The list of inherited " { $snippet "estates" } " is optional; a single tuple superclass and/or a set of " { $link role } "s can be specified. If no superclass is provided, it defaults to " { $link tuple } "."
$nl
"Slot specifiers take one of the following three forms:"
{ $list
    { { $snippet "name" } " - a slot which can hold any object, with no attributes" }
    { { $snippet "{ name attributes... }" } " - a slot which can hold any object, with optional attributes" }
    { { $snippet "{ name class attributes... }" } " - a slot specialized to a specific class, with optional attributes" }
}
"Slot attributes are lists of slot attribute specifiers followed by values; a slot attribute specifier is one of " { $link initial: } " or " { $link read-only } ". See " { $link "tuple-declarations" } " for details." } ;

{
    POSTPONE: ROLE:
    POSTPONE: ROLE-TUPLE:
} related-words

HELP: role
{ $class-description "The superclass of all role classes. A " { $snippet "role" } " is a " { $link mixin-class } " that includes a set of slot definitions that can be added to " { $link tuple } " classes alongside other " { $snippet "role" } "s." } ;

HELP: multiple-inheritance-attempted
{ $class-description "This error is thrown if a " { $link POSTPONE: ROLE-TUPLE: } " definition attempts to inherit more than one " { $link tuple } " class." } ;

HELP: role-slot-overlap
{ $class-description "This error is thrown if a " { $link POSTPONE: ROLE-TUPLE: } " or " { $link POSTPONE: ROLE: } " definition attempts to inherit a set of " { $link role } "s in which more than one attempts to define the same slot." } ;

ARTICLE: "roles" "Roles"
"The " { $vocab-link "roles" } " vocabulary provides a form of tuple interface that can be implemented by concrete tuple classes. A " { $link role } " definition is a mixin class that also prescribes a set of tuple slots. Roles are not tuple classes by themselves and cannot be instantiated by " { $link new } ". The vocabulary extends " { $link POSTPONE: ROLE-TUPLE: } " syntax to allow concrete tuple types to declare membership to one or more roles, automatically including their prescribed slots." $nl
"The role superclass:"
{ $subsections role }
"Syntax for making a new role:"
{ $subsection POSTPONE: ROLE: }
"Syntax for making tuples that use roles:"
{ $subsection POSTPONE: ROLE-TUPLE: }
"Errors with roles:"
{ $subsections multiple-inheritance-attempted role-slot-overlap } ;

ABOUT: "roles"
