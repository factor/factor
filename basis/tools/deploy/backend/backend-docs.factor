USING: assocs help.markup help.syntax strings
tools.deploy.backend ;
IN: tools.deploy.backend+docs

HELP: make-deploy-image
{ $values
  { "vm" string }
  { "image" string }
  { "vocab" string }
  { "config" assoc }
  { "manifest" string }
} ;

HELP: make-boot-image
{ $description "If stage1 image doesn't exist, create it." } ;
