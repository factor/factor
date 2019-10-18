USING: classes help.markup help.syntax ;
IN: stack-checker.dependencies

HELP: +conditional+
{ $description "Word that indicates that the dependency is a conditional dependency." } ;

HELP: +effect+
{ $description "Word that indicates that the dependency is an effect dependency." } ;

HELP: +definition+
{ $description "Word that indicates that the dependency is a definition dependency. It is a dependency among two words in which one word depends on the definition of the another. For example, if two words are defined as " { $snippet ": o ( -- ) i ;" } " and " { $snippet ": i ( -- ) ; inline" } ", then 'o' has a definition dependency to 'i' because 'i' is inline. If the definition of 'i' changes 'o' must be recompiled." } ;

HELP: add-depends-on-class
{ $values { "classoid" classoid } }
{ $description "Adds a " { $link +conditional+ } " dependency from the word to the classes mentioned in the classoid." } ;

HELP: conditional-dependencies
{ $var-description "The current word's conditional dependency checks." } ;

HELP: dependencies
{ $var-description "Words that the current quotation depends on." } ;

HELP: depends-on-class-predicate
{ $class-description "Objectifies a dependency on a class predicate." } ;

HELP: depends-on-flushable
{ $class-description "Conditional dependency on a " { $link \ flushable } " word. The dependency becomes unsatisfied if the word no longer is flushable." } ;

HELP: generic-dependencies
{ $var-description "Generic words that the current quotation depends on." } ;

ARTICLE: "stack-checker.dependencies" "Definition Dependency Management"
"This vocab manages dependency data during stack checking of words. All dependencies are divided into three types representing how words can depend on other words:"
{ $subsections
  +definition+
  +effect+
  +conditional+
}
"The type of the dependency determines when a word that depends on another word that is recompiled itself has to be recompiled. For example if word a has a " { $link +definition+ } " dependency on word b, and b's definition is changed, then a must be recompiled. Another dependency type is " { $link +effect+ } " which means that word depends on the stack effect of another word. It is a weaker form of dependency than +definition+. A words definition can change without its stack effect changing, but it it's stack effect is changing it implies that its definition is also changed."
$nl
"The third dependency type, +conditional+ encodes a conditional dependency between a word and other word which is usually a class. A condition object, kept in the word property \"dependency-checks\" evaluates if the condition is satisfied or not. If it isn't satisfied, then the word is recompiled. The types of condition objects are:"
{ $subsections
  depends-on-class-predicate
  depends-on-final
  depends-on-flushable
  depends-on-instance-predicate
  depends-on-method
  depends-on-next-method
  depends-on-tuple-layout
}
"The main benefit of using these condition checks is to ensure that if a word is changed, it doesn't cause 'cascading' recompilations."
$nl
"During stack checking, state to build dependency data is kept in the following variables:"
{ $subsections
  conditional-dependencies
  dependencies
  generic-dependencies
}
"Words for adding various types of dependencies:"
{ $subsections
  add-depends-on-c-type
  add-depends-on-class
  add-depends-on-class-predicate
  add-depends-on-final
  add-depends-on-flushable
  add-depends-on-generic
  add-depends-on-instance-predicate
  add-depends-on-method
  add-depends-on-next-method
  add-depends-on-tuple-layout
} ;



ABOUT: "stack-checker.dependencies"
