! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel ;
IN: unix.signals

HELP: add-signal-handler
{ $values
    { "handler" { $quotation ( -- ) } } { "sig" "a signal number" }
}
{ $description "Adds a signal handler for " { $snippet "sig" } ". If " { $snippet "sig" } " is raised, the signal handler will be run in a freshly-spawned Factor thread concurrently with any already established signal handlers for " { $snippet "sig" } ". Signal constants are available in the " { $vocab-link "libc" } " vocabulary." }
{ $notes "Only certain signals can be handled. See " { $link "unix.signals:allowed-signals" } " for more information. The handler quotation will be run in its own freshly-spawned thread." } ;

HELP: remove-signal-handler
{ $values
    { "handler" { $quotation ( -- ) } } { "sig" "a signal handler" }
}
{ $description "Removes a signal handler for " { $snippet "sig" } ". " { $snippet "handler" } " must be the same quotation object that was passed to " { $link add-signal-handler } ". Signal constants are available in the " { $vocab-link "libc" } " vocabulary." } ;

{ add-signal-handler remove-signal-handler } related-words

ARTICLE: "unix.signals:allowed-signals" "Signals that can be handled by Factor"
"The following signals can be handled by Factor programs:"
{ $list "SIGWINCH" "SIGCONT" "SIGURG" "SIGIO" "SIGPROF" "SIGALRM" "SIGVTALRM" "SIGINFO (if available on the host platform)" "SIGUSR1" }
"Synchronous signals such as SIGILL, SIGFPE, SIGBUS, and SIGSEGV are handled by the Factor implementation and reported as exceptions when appropriate. SIGUSR2 is used by Factor internally. SIGINT and SIGQUIT are used by Factor to pause the VM and enter into the low-level debugger (like the " { $link die } " word); they cannot yet be handled reliably by Factor code." ;

ARTICLE: "unix.signals" "Signal handlers"
"The " { $vocab-link "unix.signals" } " vocabulary allows Factor applications to handle a limited subset of Unix signals."
{ $subsection "unix.signals:allowed-signals" }
"Factor signal handlers are composable. Adding a signal handler does not replace signal handlers installed by other libraries. Individual signal handlers are added and removed independently with the following words:"
{ $subsections add-signal-handler remove-signal-handler }
;

ABOUT: "unix.signals"
