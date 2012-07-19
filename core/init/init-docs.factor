USING: help.markup help.syntax quotations strings ;
IN: init

HELP: boot
{ $description "Called on startup as part of the boot quotation to initialize the runtime and prepare it for running user code." } ;

{ boot startup-quot set-startup-quot } related-words

HELP: startup-quot
{ $values { "quot" quotation } }
{ $description "Outputs the initial quotation called by the VM on startup." } ;

HELP: set-startup-quot
{ $values { "quot" quotation } }
{ $description "Sets the initial quotation called by the VM on startup. This quotation must begin with a call to " { $link boot } ". The image must be saved for changes to the boot quotation to take effect." }
{ $notes "The " { $link "tools.deploy" } " tool uses this word." } ;

HELP: startup-hooks
{ $var-description "An association list mapping string identifiers to quotations to be run on startup." } ;

HELP: shutdown-hooks
{ $var-description "An association list mapping string identifiers to quotations to be run on shutdown." } ;

HELP: do-startup-hooks
{ $description "Calls all initialization hook quotations." } ;

HELP: do-shutdown-hooks
{ $description "Calls all shutdown hook quotations." } ;

HELP: add-startup-hook
{ $values { "quot" quotation } { "name" string } }
{ $description "Registers a startup hook. The hook will always run when Factor is started. If the hook was not already defined, this word also calls it immediately." } ;

{ startup-hooks do-startup-hooks add-startup-hook add-shutdown-hook do-shutdown-hooks shutdown-hooks } related-words

ARTICLE: "init" "Initialization and startup"
"When Factor starts, the first thing it does is call a word:"
{ $subsections boot }
"Next, initialization hooks are called:"
{ $subsections do-startup-hooks }
"Initialization hooks can be defined:"
{ $subsections add-startup-hook }
"Corresponding shutdown hooks may also be defined:"
{ $subsections add-shutdown-hook }
"The boot quotation can be changed:"
{ $subsections
    startup-quot
    set-startup-quot
}
"When quitting Factor, shutdown hooks are called:"
{ $subsection do-shutdown-hooks } ;

ABOUT: "init"
