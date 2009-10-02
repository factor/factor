USING: help.markup help.syntax kernel math sequences ;
IN: persistent.vectors

HELP: PV{
{ $syntax "PV{ elements... }" }
{ $description "Parses a literal " { $link persistent-vector } "." } ;

HELP: >persistent-vector
{ $values { "seq" sequence } { "pvec" persistent-vector } }
{ $description "Creates a " { $link persistent-vector } " with the same elements as " { $snippet "seq" } "." } ;

HELP: persistent-vector
{ $class-description "The class of persistent vectors." } ;

ARTICLE: "persistent.vectors" "Persistent vectors"
"A " { $emphasis "persistent vector" } " differs from an ordinary vector (" { $link "vectors" } ") in that it is immutable, and all operations yield new persistent vectors instead of modifying inputs. Unlike immutable operations on ordinary sequences, persistent vector operations are efficient and run in sub-linear time."
$nl
"The class of persistent vectors:"
{ $subsections persistent-vector }
"Converting a sequence into a persistent vector:"
{ $subsections >persistent-vector }
"Persistent vectors have a literal syntax:"
{ $subsections POSTPONE: PV{ }
"The empty persistent vector, written " { $snippet "PV{ }" } ", is used for building up all other persistent vectors."
$nl
"This implementation of persistent vectors is based on the " { $snippet "clojure.lang.PersistentVector" } " class from Rich Hickey's Clojure language for the JVM (" { $url "http://clojure.org" } ")." ;

ABOUT: "persistent.vectors"
