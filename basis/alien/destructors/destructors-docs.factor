IN: alien.destructors
USING: help.markup help.syntax alien destructors ;

HELP: DESTRUCTOR:
{ $syntax "DESTRUCTOR: word" }
{ $description "Defines four things:"
  { $list
    { "a tuple named " { $snippet "word" } " with a single slot holding a " { $link c-ptr } }
    { "a " { $link dispose } " method on the tuple which calls " { $snippet "word" } " with the " { $link c-ptr } }
    { "a pair of words, " { $snippet "&word" } " and " { $snippet "|word" } ", which call " { $link &dispose } " and " { $link |dispose } " with a new instance of the tuple" }
  }
  "The " { $snippet "word" } " must be defined in the current vocabulary, and must have stack effect " { $snippet "( c-ptr -- )" } "."
}
{ $examples
  "Suppose you are writing a binding to the GLib library, which as a " { $snippet "g_object_unref" } " function. Then you can define the function and destructor like so,"
  { $code
    "FUNCTION: void g_object_unref ( gpointer object )"
    "DESTRUCTOR: g_object_unref"
  }
  "Now, memory management becomes easier:"
  { $code
    "[ g_new_foo &g_object_unref ... ] with-destructors"
  }
} ;

ARTICLE: "alien.destructors" "Alien destructors"
"The " { $vocab-link "alien.destructors" } " vocabulary defines a utility parsing word for defining new disposable classes."
{ $subsections POSTPONE: DESTRUCTOR: } ;

ABOUT: "alien.destructors"
