! Copyright (C) 2023 Jean-Marc Lugrin.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: classes.prettyprinter

ARTICLE: "classes.prettyprinter" "Print the hierarchy of a class"
{ $vocab-link "classes.prettyprinter" } " supports the printing of the class hierarchy to the listener or to any text stream." $nl
"The class name and vocab name are clickable, a P indicates that the classs is PRIVATE." $nl 
"See " { $link hierarchy. } "."
;

HELP: hierarchy.
{ $values { "class" "a class, use " { $snippet "tuple" } " to print the whole hierarchy" }  }
{ $description "Print the class hierarchy layout on the output stream, with the name of its vocabulary." }
{ $errors "Throws an error if " { $snippet "class" } " is not a class." }
{ $examples
    { $unchecked-example "tuple hierarchy." }  
    { $unchecked-example " \"GADGETS.TXT\" utf8 [ gadget hierarchy. ] with-file-writer" } 
}
;

HELP: class-hierarchy
{ $values { "hash" "An " { $snippet "hashtable" } " mapping classes to list of children" }  }
{ $description "Extract the hierarchy of all classes in the form of an hashtable" 
    "with the class as the key and a vector of all children class in alphabetic order as a child." }
{ $notes { "This is made public for other tools that want to explore the class hierarch." } }
;

HELP: not-a-class-error
{ $description "Throws a " { $link not-a-class-error } "." }
{ $error-description "Thrown by " { $link hierarchy. } " if the parameter is not a class." } 
;

ABOUT: "classes.prettyprinter"
