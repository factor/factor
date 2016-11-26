USING: help.markup help.syntax ;
IN: stack-checker.dependencies

HELP: +definition+
{ $class-description "Word that indicates that the dependency is a definition dependency. It is a dependency among two words in which one word depends on the definition of the another. For example, if two words are defined as " { $snippet ": o ( -- ) i ;" } " and " { $snippet ": i ( -- ) ; inline" } ", then 'o' has a definition dependency to 'i' because 'i' is inline. If the definition of 'i' changes 'o' must be recompiled." } ;

HELP: dependencies
{ $var-description "Words that the current quotation depends on." } ;

ARTICLE: "stack-checker.dependencies" "Definition Dependency Management"
"This vocab manages dependency data during stack checking of words. All dependencies are divided into three types:"
{ $subsections
  +conditional+
  +definition+
  +effect+
}
"Temporary state:"
{ $subsections
  conditional-dependencies
  dependencies
  generic-dependencies
} ;

ABOUT: "stack-checker.dependencies"
