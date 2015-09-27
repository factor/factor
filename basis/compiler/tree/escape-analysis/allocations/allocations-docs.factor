USING: compiler.tree disjoint-sets help.markup help.syntax ;
IN: compiler.tree.escape-analysis.allocations

HELP: allocations
{ $var-description "A map from values to one of the following:"
  { $list
    "f -- initial status, assigned to values we have not seen yet; may potentially become an allocation later"
    "a sequence of values -- potentially unboxed tuple allocations"
    "t -- not allocated in this procedure, can never be unboxed"
  }
} ;

HELP: compute-escaping-allocations
{ $description "Compute which tuples escape" } ;

HELP: escaping-values
{ $var-description "We track escaping values with a " { $link disjoint-set } "." } ;

HELP: slot-access
{ $var-description "We track slot access to connect constructor inputs with accessor outputs." } ;

HELP: value-classes
{ $var-description "A map from values to classes. Only for " { $link #introduce } " outputs." } ;

ARTICLE: "compiler.tree.escape-analysis.allocations" "Tracking memory allocations"
"Tracks memory allocations and unboxes those which can be determined never escapes." ;

ABOUT: "compiler.tree.escape-analysis.allocations"
