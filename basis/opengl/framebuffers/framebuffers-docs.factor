USING: help.markup help.syntax math opengl.gl quotations ;
IN: opengl.framebuffers

HELP: gen-framebuffer
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glGenFramebuffers } " to handle the common case of generating a single framebuffer ID." } ;

HELP: gen-renderbuffer
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glGenRenderbuffers } " to handle the common case of generating a single render buffer ID." } ;

HELP: delete-framebuffer
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glDeleteFramebuffers } " to handle the common case of deleting a single framebuffer ID." } ;

HELP: delete-renderbuffer
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glDeleteRenderbuffers } " to handle the common case of deleting a single render buffer ID." } ;

{ gen-framebuffer delete-framebuffer } related-words
{ gen-renderbuffer delete-renderbuffer } related-words

HELP: framebuffer-incomplete?
{ $values { "status/f" "The framebuffer error code, or " { $snippet "f" } " if the framebuffer is render-complete." } }
{ $description "Checks the framebuffer currently bound by " { $link glBindFramebuffer } " or " { $link with-framebuffer } " to see if it is incomplete, i.e., it is not ready to be rendered to." } ;

HELP: check-framebuffer
{ $description "Checks the framebuffer currently bound by " { $link glBindFramebuffer } " or " { $link with-framebuffer } " with " { $link framebuffer-incomplete? } ", and throws a descriptive error if the framebuffer is incomplete." } ;

HELP: with-framebuffer
{ $values { "id" "The id of a framebuffer object." } { "quot" quotation } }
{ $description "Binds framebuffer " { $snippet "id" } " for drawing in the dynamic extent of " { $snippet "quot" } ", restoring the window framebuffer when finished." } ;

ABOUT: "gl-utilities"
