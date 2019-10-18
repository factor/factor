USING: help.markup help.syntax quotations strings ;
IN: init

HELP: boot
{ $description "Called on startup as part of the boot quotation  to initialize the runtime and prepare it for running user code." } ;

{ boot boot-quot set-boot-quot } related-words

HELP: boot-quot
{ $values { "quot" quotation } }
{ $description "Outputs the initial quotation called by the VM on startup." } ;

HELP: set-boot-quot
{ $values { "quot" quotation } }
{ $description "Sets the initial quotation called by the VM on startup. This quotation must begin with a call to " { $link boot } ". The image must be saved for changes to the boot quotation to take effect." }
{ $notes "The " { $link "tools.deploy" } " tool uses this word." } ;

HELP: startup-hooks
{ $var-description "An association list mapping string identifiers to quotations to be run on startup." } ;

HELP: do-startup-hooks
{ $description "Calls all startup hook quotations." } ;

HELP: add-startup-hook
{ $values { "quot" quotation } { "name" string } }
{ $description "Registers a startup hook, after calling it first." } ;

{ startup-hooks do-startup-hooks add-startup-hook } related-words

ARTICLE: "init" "Initialization and startup"
"When Factor starts, the first thing it does is call a word:"
{ $subsection boot }
"Next, any startup hooks are called:"
{ $subsection do-startup-hooks }
"Startup hooks can be defined:"
{ $subsection add-startup-hook }
"The boot quotation can be changed:"
{ $subsection boot-quot }
{ $subsection set-boot-quot } ;

ABOUT: "init"
