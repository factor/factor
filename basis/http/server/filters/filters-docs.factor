USING: help.markup help.syntax http.server http.server.filters ;
IN: http.server.filters+docs

HELP: filter-responder
{ $class-description "The class of filter responders. This class is intended to be subclassed." } ;

ARTICLE: "http.server.filters" "HTTP responder filters"
"The " { $vocab-link "http.server.filters" } " vocabulary implements the common pattern where one responder wraps another, doing some processing before calling the wrapped responder."
{ $subsections filter-responder }
"To use it, simply subclass " { $link filter-responder } ", and call " { $link POSTPONE: call-next-method } " from your " { $link call-responder* } " method to pass control to the wrapped responder." ;

ABOUT: "http.server.filters"
