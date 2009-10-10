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

HELP: init-hooks
{ $var-description "An association list mapping string identifiers to quotations to be run on startup." } ;

HELP: do-init-hooks
{ $description "Calls all initialization hook quotations." } ;

HELP: add-init-hook
{ $values { "quot" quotation } { "name" string } }
{ $description "Registers a startup hook. The hook will always run when Factor is started. If the hook was not already defined, this word also calls it immediately." } ;

{ init-hooks do-init-hooks add-init-hook } related-words

ARTICLE: "init" "Initialization and startup"
"When Factor starts, the first thing it does is call a word:"
{ $subsections boot }
"Next, initialization hooks are called:"
{ $subsections do-init-hooks }
"Initialization hooks can be defined:"
{ $subsections add-init-hook }
"The boot quotation can be changed:"
{ $subsections
    boot-quot
    set-boot-quot
} ;

ABOUT: "init"
