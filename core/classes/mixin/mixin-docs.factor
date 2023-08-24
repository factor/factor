USING: help.markup help.syntax words compiler.units
classes sequences ;
IN: classes.mixin

ARTICLE: "mixins" "Mixin classes"
"An object is an instance of a union class if it is an instance of one of its members. In this respect, mixin classes are identical to union classes. However, mixin classes have the additional property that they are " { $emphasis "open" } "; new classes can be added to the mixin after the original definition of the mixin."
{ $subsections
    POSTPONE: MIXIN:
    POSTPONE: INSTANCE:
    define-mixin-class
    add-mixin-instance
}
"The set of mixin classes is a class:"
{ $subsections
    mixin-class
    mixin-class?
}
"Mixins are used to defines suites of behavior which are generally useful and can be applied to user-defined classes. For example, the " { $link immutable-sequence } " mixin can be used with user-defined sequences to make them immutable."
{ $see-also "unions" "maybes" "tuple-subclassing" } ;

HELP: mixin-class
{ $class-description "The class of mixin classes." } ;

HELP: define-mixin-class
{ $values { "class" word } }
{ $description "Defines a mixin class. This is the run time equivalent of " { $link POSTPONE: MIXIN: } "." }
{ $notes "This word must be called from inside " { $link with-compilation-unit } "." }
{ $side-effects "class" } ;

HELP: add-mixin-instance
{ $values { "class" class } { "mixin" class } }
{ $description "Defines a class to be an instance of a mixin class. This is the run time equivalent of " { $link POSTPONE: INSTANCE: } "." }
{ $notes "This word must be called from inside " { $link with-compilation-unit } "." }
{ $side-effects "class" } ;

{ mixin-class define-mixin-class add-mixin-instance POSTPONE: MIXIN: POSTPONE: INSTANCE: } related-words

ABOUT: "mixins"
