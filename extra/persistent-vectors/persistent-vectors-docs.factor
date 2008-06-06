USING: help.markup help.syntax kernel math sequences ;
IN: persistent-vectors

HELP: new-nth
{ $values { "val" object } { "i" integer } { "seq" sequence } }
{ $contract "Persistent analogue of " { $link set-nth } ". Outputs a new sequence with the " { $snippet "i" } "th element replaced by " { $snippet "val" } "." }
{ $notes "This operation runs in " { $snippet "O(log_32 n)" } " time on " { $link persistent-vector } " instances and " { $snippet "O(n)" } " time on all other sequences." } ;

HELP: ppush
{ $values { "val" object } { "i" integer } { "seq" sequence } }
{ $contract "Persistent analogue of " { $link push } ". Outputs a new sequence with all elements of " { $snippet "seq" } " together with " { $snippet "val" } " added at the end." }
{ $notes "This operation runs in amortized " { $snippet "O(1)" } " time on " { $link persistent-vector } " instances and " { $snippet "O(n)" } " time on all other sequences." } ;

HELP: ppop
{ $values { "val" object } { "i" integer } { "seq" sequence } }
{ $contract "Persistent analogue of " { $link pop } ". Outputs a new sequence with all elements of " { $snippet "seq" } " except for the final element." }
{ $notes "This operation runs in amortized " { $snippet "O(1)" } " time on " { $link persistent-vector } " instances and " { $snippet "O(n)" } " time on all other sequences." } ;

HELP: PV{
{ $syntax "elements... }" }
{ $description "Parses a literal " { $link persistent-vector } "." } ;

HELP: >persistent-vector
{ $values { "seq" sequence } { "pvec" persistent-vector } }
{ $description "Creates a " { $link persistent-vector } " with the same elements as " { $snippet "seq" } "." } ;

HELP: persistent-vector
{ $class-description "The class of persistent vectors." } ;

HELP: pempty
{ $values { "pvec" persistent-vector } }
{ $description "Outputs an empty " { $link persistent-vector } "." } ;

ARTICLE: "persistent-vectors" "Persistent vectors"
"A " { $emphasis "persistent vector" } " differs from an ordinary vector (" { $link "vectors" } ") in that it is immutable, and all operations yield new persistent vectors instead of modifying inputs. Unlike immutable operations on ordinary sequences, persistent vector operations are efficient and run in sub-linear time."
$nl
"The class of persistent vectors:"
{ $subsection persistent-vector }
"Persistent vectors support the immutable sequence protocol, namely as " { $link length } " and " { $link nth } ", and so can be used with most sequence words (" { $link "sequences" } ")."
$nl
"In addition to standard sequence operations, persistent vectors implement efficient operations specific to them. They run in sub-linear time on persistent vectors, and degrate to linear-time algorithms on ordinary sequences:"
{ $subsection new-nth }
{ $subsection ppush }
{ $subsection ppop }
"The empty persistent vector, used for building up all other persistent vectors:"
{ $subsection pempty }
"Converting a sequence into a persistent vector:"
{ $subsection >persistent-vector }
"Persistent vectors have a literal syntax:"
{ $subsection POSTPONE: PV{ }
"This implementation of persistent vectors is based on the " { $snippet "clojure.lang.PersistentVector" } " class from Rich Hickey's Clojure language for the JVM (" { $url "http://clojure.org" } ")." ;

ABOUT: "persistent-vectors"
