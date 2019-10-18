USING: assocs help.markup help.syntax strings ;
IN: tools.deploy.backend

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
