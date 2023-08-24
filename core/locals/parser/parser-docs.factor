USING: help.markup help.syntax locals.types quotations strings
vocabs.parser ;
IN: locals.parser

HELP: in-lambda?
{ $var-description { $link t } " if we're currently parsing a lambda with lexical variables." } ;

HELP: parse-def
{ $values
  { "name/paren" string }
  { "def" multi-def }
}
{ $description "Parses the lexical variable bindings following a " { $link POSTPONE: :> } " token." } ;

HELP: with-lambda-scope
{ $values { "assoc" "local variables" } { "reader-quot" quotation } { "quot" quotation } }
{ $description "Runs the quotation in a lambda scope. That means that any local variables are available for lookup in the " { $link manifest } ", but are cleaned up after the quotation finishes." } ;

ARTICLE: "locals.parser" "Utility words used by locals parsing words"
"Words for parsing local words."
$nl
"Words for parsing variable assignments:"
{ $subsections parse-def parse-multi-def parse-single-def }
"Parsers for word and method definitions:"
{ $subsections (::) (M::) } ;

ABOUT: "locals.parser"
