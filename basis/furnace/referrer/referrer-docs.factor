USING: furnace.utilities help.markup help.syntax ;
IN: furnace.referrer

HELP: <check-form-submissions>
{ $values
    { "responder" "a responder" }
    { "responder'" "a responder" }
}
{ $description "Wraps the responder in a filter responder which ensures that form submissions originate from a page on the same server. Any submissions which do not are sent back with a 403 error." } ;

ARTICLE: "furnace.referrer" "Form submission referrer checking"
"The " { $vocab-link "furnace.referrer" } " implements a simple security measure which can be used to thwart cross-site scripting attacks."
{ $subsections <check-form-submissions> }
"Explicit referrer checking:"
{ $subsections
    referrer
    same-host?
} ;

ABOUT: "furnace.referrer"
