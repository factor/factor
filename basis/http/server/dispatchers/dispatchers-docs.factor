! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: classes help.markup help.syntax ;
IN: http.server.dispatchers

HELP: new-dispatcher
{ $values { "class" class } { "dispatcher" dispatcher } }
{ $description "Creates a new instance of a subclass of " { $link dispatcher } "." } ;

HELP: dispatcher
{ $class-description "The class of dispatchers. May be subclassed, in which case subclasses should be constructed by calling " { $link new-dispatcher } "." } ;

HELP: <dispatcher>
{ $values { "dispatcher" dispatcher } }
{ $description "Creates a new pathname dispatcher." } ;

HELP: vhost-dispatcher
{ $class-description "The class of virtual host dispatchers." } ;

HELP: <vhost-dispatcher>
{ $values { "dispatcher" vhost-dispatcher } }
{ $description "Creates a new virtual host dispatcher." } ;

HELP: add-responder
{ $values
    { "dispatcher" dispatcher } { "responder" "a responder" } { "path" "a pathname string or hostname" } }
{ $description "Adds a responder to a dispatcher." }
{ $notes "The " { $snippet "path" } " parameter is interpreted differently depending on the dispatcher type." }
{ $side-effects "dispatcher" } ;

ARTICLE: "http.server.dispatchers.example" "HTTP dispatcher examples"
{ $heading "Simple pathname dispatcher" }
{ $code
    "<dispatcher>
    <new-action> \"new\" add-responder
    <edit-action> \"edit\" add-responder
    <delete-action> \"delete\" add-responder
    <list-action> \"\" add-responder
main-responder set-global"
}
"In the above example, visiting any URL other than " { $snippet "/new" } ", " { $snippet "/edit" } ", " { $snippet "/delete" } ", or " { $snippet "/" } " will result in a 404 error."
{ $heading "Another pathname dispatcher" }
"On the other hand, suppose we wanted to route all unrecognized paths to a “view” action:"
{ $code
    "<dispatcher>
    <new-action> \"new\" add-responder
    <edit-action> \"edit\" add-responder
    <delete-action> \"delete\" add-responder
    <view-action> >>default
main-responder set-global"
}
"The " { $slot "default" } " slot holds a responder to which all unrecognized paths are sent to."
{ $heading "Dispatcher subclassing example" }
{ $code
    "TUPLE: golf-courses < dispatcher ;

: <golf-courses> ( -- golf-courses )
    golf-courses new-dispatcher ;

<golf-courses>
    <new-action> \"new\" add-responder
    <edit-action> \"edit\" add-responder
    <delete-action> \"delete\" add-responder
    <list-action> \"\" add-responder
main-responder set-global"
}
"The action templates can now emit links to responder-relative URLs prefixed by " { $snippet "$golf-courses/" } "."
{ $heading "Virtual hosting example" }
{ $code
    "<vhost-dispatcher>
    <casino> \"concatenative-casino.com\" add-responder
    <dating> \"raptor-dating.com\" add-responder
main-responder set-global"
}
"Note that the virtual host dispatcher strips off a " { $snippet "www." } " prefix, so " { $snippet "www.concatenative-casino.com" } " would be routed to the " { $snippet "<casino>" } " responder instead of receiving a 404." ;

ARTICLE: "http.server.dispatchers" "HTTP dispatchers and virtual hosting"
"The " { $vocab-link "http.server.dispatchers" } " vocabulary implements two responders which route HTTP requests to one or more child responders."
{ $subsections "http.server.dispatchers.example" }
"Pathname dispatchers implement a directory hierarchy where each subdirectory is its own responder:"
{ $subsections
    dispatcher
    <dispatcher>
}
"Virtual host dispatchers dispatch each virtual host to a different responder:"
{ $subsections
    vhost-dispatcher
    <vhost-dispatcher>
}
"Adding responders to dispatchers:"
{ $subsections add-responder }
"The " { $slot "default" } " slot holds a responder which receives all unrecognized URLs. By default, it responds with 404 messages." ;

ABOUT: "http.server.dispatchers"
