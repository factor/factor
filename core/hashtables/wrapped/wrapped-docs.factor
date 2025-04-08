! Copyright (C)2023 Raghu Ranganathan.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs help.markup help.syntax kernel ;
IN: hashtables.wrapped

HELP: wrap-key
{ $values
    { "key" object } { "wrapped-hash" object }
    { "wrapped-key" object }
}
{ $description "An object that wraps a key and provides a different hashcode implementation." } ;

HELP: wrapped-hashtable
{ $class-description "A hashtable that uses wrapped keys to provide a different hashcode implementation." } ;

ARTICLE: "hashtables.wrapped" "Wrapped Hashtable protocol"
"The " { $vocab-link "hashtables.wrapped" } " describes a protocol for defining hashtables that "
"use custom hashing algorithms."
$nl
"To create a custom wrapped hashtable, you must define a wrapper for your keys (usually a tuple class)."
" For this wrapper, you have to define the following generics:"
{ $list
 { { $link hashcode* } " for your wrapper, which will contain the hashing algorithm you want to use. " }
 { { $link wrap-key } " which is effectively a constructor for wrapping keys." }
 { { $link equal? } " to check for equality of keys." }
}
$nl
"The key wrapper must implement " { $link underlying>> } " to retrieve the original key."

"Other relevant generics are " { $link clone } " and " { $link new-assoc } "."
$nl
"Examples of wrapped hastable objects can be seen in:"
{ $list 
  { $vocab-link "hashtables.identity" }
  { $vocab-link "hashtables.sequences" }
  { $vocab-link "hashtables.numbers" }
}
;

ABOUT: "hashtables.wrapped"
