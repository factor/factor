USING: help.markup help.syntax ;
IN: classes.mixin

ARTICLE: "mixins" "Mixin classes"
"An object is an instance of a union class if it is an instance of one of its members. In this respect, mixin classes are identical to union classes. However, new classes can be made into instances of a mixin class after the original definition of the mixin."
{ $subsection POSTPONE: MIXIN: }
{ $subsection POSTPONE: INSTANCE: }
{ $subsection define-mixin-class }
{ $subsection add-mixin-instance }
"The set of mixin classes is a class:"
{ $subsection mixin-class }
{ $subsection mixin-class? } ;

ABOUT: "mixins"
