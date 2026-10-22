USING: assocs help.markup help.syntax sequences strings ;
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

HELP: staging-profiles
{ $values { "profiles" sequence } }
{ $description "Returns common deployment staging profiles: the default deployment configuration with every combination of UI, Unicode and help enabled or disabled." } ;

HELP: make-staging-images
{ $description "Prebuilds common deployment staging images for the current platform and architecture. Uses the normal deployment defaults for math, threads and native I/O, varying UI, Unicode and help. Creates the boot image if needed and skips cached staging images. The eight profiles require eleven staging images including shared prefixes. Other configurations continue to build on demand." }
{ $examples { $code "USE: tools.deploy.backend" "make-staging-images" } } ;
