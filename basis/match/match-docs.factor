! Copyright (C) 2006 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax namespaces assocs
kernel combinators ;
IN: match

HELP: match
{ $values { "value1" object } { "value2" object } { "bindings" assoc }
}
{ $description "Pattern match " { $snippet "value1" } " against " { $snippet "value2" } ". These values can be any Factor value, including sequences and tuples. The values can contain pattern variables, which are symbols that begin with '?'. The result is a hashtable of the bindings, mapping the pattern variables from one sequence to the equivalent value in the other sequence. The " { $link _ } " symbol can be used to ignore the value at that point in the pattern for the match." }
{ $examples
    { $unchecked-example "USE: match" "MATCH-VARS: ?a ?b ;\n{ ?a { 2 ?b } 5 } { 1 { 2 3 } _ } match ." "H{ { ?a 1 } { ?b 3 } }" }
}
{ $see-also match-cond POSTPONE: MATCH-VARS: replace-patterns match-replace } ;

HELP: match-cond
{ $values { "assoc" "a sequence of pairs" } }
{ $description "Calls the second quotation in the first pair whose first sequence yields a successful " { $link match } " against the top of the stack. The second quotation, when called, has the hashtable returned from the " { $link match } " call bound as the top namespace so the match variables can be used to retrieve the values. A single quotation will always yield a true value. To have a fallthrough match clause use the " { $link _ } " match variable." }
{ $errors "Throws a " { $link no-match-cond } " error if none of the test quotations yield a true value." }
{ $examples
    { $code
        "USE: match" "MATCH-VARS: ?value ;\n{ increment 346126 } {\n  { { increment ?value } [ ?value do-something ] }\n  { { decrement ?value } [ ?value do-something-else ] }\n  { _ [ no-match-found ] }\n} match-cond" }
}
{ $see-also match POSTPONE: MATCH-VARS: replace-patterns match-replace } ;

HELP: MATCH-VARS:
{ $syntax "MATCH-VARS: var ... ;" }
{ $values { "var" "a match variable name beginning with '?'" } }
{ $description "Creates a symbol that can be used in " { $link match } " and " { $link match-cond } " for binding values in the matched sequence. The symbol name is created as a word that is defined to get the value of the symbol out of the current namespace. This can be used in " { $link match-cond } " to retrive the values in the quotation body." }
{ $examples
    { $code "USE: match" "MATCH-VARS: ?value ;\n{ increment 346126 } {\n  { { increment ?value } [ ?value do-something ] }\n  { { decrement ?value } [ ?value do-something-else ] }\n  { _ [ no-match-found ] }\n} match-cond" }
}
{ $see-also match match-cond replace-patterns match-replace } ;

HELP: replace-patterns
{ $values { "object" object } { "result" object } }
{ $description "Copy the object, replacing each occurrence of a pattern matching variable with the actual value of that variable." }
{ $see-also match-cond POSTPONE: MATCH-VARS: match-replace } ;

HELP: match-replace
{ $values { "object" object } { "pattern1" object } { "pattern2" object } { "result" object } }
{ $description "Matches the " { $snippet "object" } " against " { $snippet "pattern1" } ". The pattern match variables in " { $snippet "pattern1" } " are assigned the values from the matching " { $snippet "object" } ". These are then replaced into the " { $snippet "pattern2" } " pattern match variables." }
{ $examples
  { $example
      "USING: match prettyprint ;"
      "IN: scratchpad"
      "MATCH-VARS: ?a ?b ;"
      "{ 1 2 } { ?a ?b } { ?b ?a } match-replace ."
      "{ 2 1 }"
  }
}
{ $see-also match-cond POSTPONE: MATCH-VARS: } ;

ARTICLE: "match" "Pattern matching"
"The " { $vocab-link "match" } " vocabulary implements ML-style pattern matching."
$nl
"Variables used for pattern matching must be explicitly defined first:"
{ $subsections POSTPONE: MATCH-VARS: }
"A basic pattern match:"
{ $subsections match }
"A conditional form analogous to " { $link cond } ":"
{ $subsections match-cond }
"Pattern replacement:"
{ $subsections match-replace } ;

ABOUT: "match"
