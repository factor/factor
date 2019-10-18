USING: help.markup help.syntax kernel tools.deploy.config ;
IN: tools.deploy.shaker

HELP: (deploy)
{ $values
  { "final-image" object }
  { "vocab-manifest-out" object }
  { "vocab" object }
  { "config" object }
}
{ $description "Does the actual work of a deployment in the slave stage2 image." } ;

HELP: remain-compiled
{ $values { "old" "?" } { "new" "?" } }
{ $description "Quotations which were formerly compiled must remain compiled." } ;

HELP: strip-c-io
{ $description "On all platforms, if " { $link deploy-io } " is 1, we strip out C streams. On Unix, if deploy-io is 3, we strip out C streams as well. On Windows, even if deploy-io is 3, C streams are still used for the console, so don't strip it there." } ;

HELP: strip-default-methods
{ $description "In a development image, each generic has its own default method. This gives better error messages for runtime type errors, but takes up space. For deployment we merge them all together." } ;
