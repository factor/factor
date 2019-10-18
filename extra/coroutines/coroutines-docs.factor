! Copyright (C) 2005 Chris Double, 2007 Clemens Hofreither, 2008 James Cash.
USING: help.markup help.syntax kernel ;
IN: coroutines

HELP: cocreate
{ $values { "quot" { $quotation ( value -- ) } } { "co" coroutine } }
{ $description "Create a new coroutine which will execute the quotation when resumed. The quotation will have an initial value (received from " { $link coresume } ") on the stack when first resumed.\n\nCoroutines should never terminate normally by \"falling off\" the end of the quotation; instead, they should call " { $link coterminate } "." }
;

HELP: coresume
{ $values { "v" object } { "co" coroutine } { "result" object } }
{ $description "Resume a coroutine with v as the first item on the stack. The result placed on the stack is the value of the topmost argument on the stack when " { $link coyield } " is called within the coroutine." }
{ $see-also *coresume coresume* }
;

HELP: *coresume
{ $values { "co" coroutine } { "result" object } }
{ $description "Variant of " { $link coresume } " that passes a default value of " { $link f } " to the coroutine." }
{ $see-also coresume coresume* }
;

HELP: coresume*
{ $values { "v" object } { "co" coroutine } }
{ $description "Variant of " { $link coresume } " that discards the result of the coroutine invocation." }
{ $see-also coresume *coresume }
;

HELP: coyield
{ $values { "v" object } { "result" object } }
{ $description "Suspend the current coroutine, leaving the value v on the stack when control is passed to the " { $link coresume } " caller. When this coroutine is later resumed, result will contain the value passed to " { $link coyield } "." }
{ $see-also *coyield coyield* coterminate }
;

HELP: *coyield
{ $values { "v" object } }
{ $description "Variant of " { $link coyield } " that returns a default value of " { $link f } " to the caller." }
{ $see-also coyield coyield* }
;

HELP: coyield*
{ $values { "v" object } }
{ $description "Variant of " { $link coyield } " that discards the value passed in via " { $link coresume } "." }
{ $see-also coyield *coyield }
;

HELP: coterminate
{ $values { "v" object } }
{ $description "Terminate the current coroutine, leaving the value v on the stack when control is passed to the " { $link coresume } " caller. Resuming a terminated coroutine is a no-op." }
{ $see-also coyield coreset }
;

HELP: coreset
{ $values { "v" object } }
{ $description "Reset the current coroutine, leaving the value v on the stack when control is passed to the " { $link coresume } " caller. When the coroutine is resumed, it will continue at the beginning of the coroutine." }
{ $see-also coyield coterminate }
;

HELP: current-coro
{ $description "Variable which contains the currently executing coroutine, or " { $link f } " if none is executing. User code should treat this variable as read-only." }
{ $see-also cocreate coresume coyield }
;
