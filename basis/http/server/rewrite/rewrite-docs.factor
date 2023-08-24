IN: http.server.rewrite
USING: help.syntax help.markup http.server ;

HELP: rewrite
{ $class-description "The class of directory rewrite responders. The slots are as follows:"
{ $slots
  { "default" "the responder to call if no file name is provided." }
  { "child" "the responder to call if a file name is provided." }
  { "param" "the name of a request parameter which will store the first path component of the file name passed to the responder." }
} } ;

HELP: <rewrite>
{ $values { "rewrite" rewrite } }
{ $description "Creates a new " { $link rewrite } " responder." }
{ $examples
  { $code
    "<rewrite>"
    "    <display-post-action> >>default"
    "    <display-comment-action> >>child"
    "    \"comment_id\" >>param"
  }
} ;

HELP: vhost-rewrite
{ $class-description "The class of virtual host rewrite responders. The slots are as follows:"
{ $slots
  { "default" "the responder to call if no host name prefix is provided." }
  { "child" " the responder to call if a host name prefix is provided." }
  { "param" "the name of a request parameter which will store the first host name component of the host name passed to the responder." }
  { "suffix" "the domain name suffix which will be chopped off the end of the request's host name in order to produce the parameter." }
} } ;

HELP: <vhost-rewrite>
{ $values { "vhost-rewrite" vhost-rewrite } }
{ $description "Creates a new " { $link vhost-rewrite } " responder." }
{ $examples
  { $code
    "<vhost-rewrite>"
    "    <show-blogs-action> >>default"
    "    <display-blog-action> >>child"
    "    \"blog_id\" >>param"
    "    \"blogs.vegan.net\" >>suffix"
  }
} ;

ARTICLE: "http.server.rewrite.overview" "Rewrite responder overview"
"Rewrite responders take the file name and turn it into a request parameter named by the " { $slot "param" } " slot before delegating to a child responder. If a file name is provided, it calls the responder in the " { $slot "child" } " slot. If no file name is provided, they call the default responder in the " { $slot "default" } " slot."
$nl
"For example, suppose you want to have the following website schema:"
{ $list
{ { $snippet "/posts/" } " - show a list of posts" }
{ { $snippet "/posts/factor_language" } " - show thread with ID " { $snippet "factor_language" } }
{ { $snippet "/posts/factor_language/1" } " - show first comment in the thread with ID " { $snippet "factor_language" } }
{ { $snippet "/animals" } ", ... - a bunch of other actions" } }
"One way to achieve this would be to have a nesting of responders as follows:"
{ $list
{ "A dispatcher at the top level" }
  { "A " { $link rewrite } " as a child of the dispatcher under the name " { $snippet "posts" } ". The rewrite has the " { $slot "param" } " slot set to, say, " { $snippet "post_id" } ". The " { $slot "default" } " slot is set to a Furnace action which displays a list of posts." }
  { "The child slot is set to a second " { $link rewrite } " instance, with " { $snippet "param" } " set to " { $snippet "comment_id" } ", the " { $slot "default" } " slot set to an action which displays a post identified by the " { $snippet "post_id" } " parameter, and the " { $snippet "child" } " slot set to an action which displays the comment identified by the " { $snippet "comment_id" } " parameter." } }
"Note that parameters can be extracted from the request using the " { $link param } " word, but most of the time you want to use " { $vocab-link "furnace.actions" } " instead." ;

ARTICLE: "http.server.rewrite" "URL rewrite responders"
"The " { $vocab-link "http.server.rewrite" } " vocabulary defines two responder types which can help make website URLs more human-friendly."
{ $subsections "http.server.rewrite.overview" }
"Directory rewrite responders:"
{ $subsections
    rewrite
    <rewrite>
}
"Virtual host rewrite responders -- these chop off the value in the " { $snippet "suffix" } " slot from the tail of the host name, and use the rest as the parameter value:"
{ $subsections
    vhost-rewrite
    <vhost-rewrite>
} ;

ABOUT: "http.server.rewrite"
