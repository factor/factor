! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: calendar concurrency.conditions help.markup help.syntax ;
IN: concurrency.flags

HELP: flag
{ $class-description "A flag allows one thread to notify another when a condition is satisfied." } ;

HELP: <flag>
{ $values { "flag" flag } }
{ $description "Creates a new flag." } ;

HELP: lower-flag
{ $values { "flag" flag } }
{ $description "Attempts to lower a flag. If the flag has been raised previously, returns immediately, otherwise waits for it to be raised first." } ;

HELP: raise-flag
{ $values { "flag" flag } }
{ $description "Raises a flag, notifying any threads waiting on it. Does nothing if the flag has already been raised." } ;

HELP: wait-for-flag
{ $values { "flag" flag } }
{ $description "Waits for a flag to be raised. If the flag has already been raised, returns immediately." } ;

HELP: wait-for-flag-timeout
{ $values { "flag" flag } { "timeout" duration } }
{ $description "Waits for a flag to be raised or throws a " { $link timed-out-error } " if the flag wasn't raised in time." } ;

ARTICLE: "concurrency.flags" "Flags"
"A " { $emphasis "flag" } " is a condition notification device which can be in one of two states: " { $emphasis "lowered" } " (the initial state) or " { $emphasis "raised" } "."
$nl
"The flag can be raised at any time; raising a raised flag does nothing. Lowering a flag if it has not been raised yet will wait for another thread to raise the flag."
$nl
"Essentially, a flag can be thought of as a counting semaphore where the count never goes above one."
{ $subsections
    flag
    flag?
}
"Waiting for a flag to be raised:"
{ $subsections
    raise-flag
    wait-for-flag
    lower-flag
} ;

ABOUT: "concurrency.flags"
