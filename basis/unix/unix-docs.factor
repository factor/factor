USING: help.markup help.syntax kernel quotations ;
IN: unix

HELP: unix-system-call
{ $values { "quot" quotation } }
{ $description "Calls a Unix function that returns one result: a nonnegative integer or non-null pointer on success, and a negative integer or null pointer on failure. Retries failures with EINTR using the original arguments. Other failures throw a unix-system-call-error containing the arguments, error number, and called word." }
{ $notes "Use only when retrying is valid for that function. Do not use for close, interrupted event-loop waits with deadlines, or functions such as getgrnam_r that return error numbers directly. A successful partial read or write is returned to the caller, not repeated." } ;

HELP: unix-system-call-allow-eintr
{ $values { "quot" quotation } }
{ $description "Calls a Unix function once using the same return convention as unix-system-call. Returns the result on success or EINTR, consuming the original arguments in either case. Other failures throw unix-system-call-error. It never retries the operation." }
{ $notes "Suitable for close on supported Unix platforms and for kevent changelist submissions, where an EINTR result does not mean the operation should be replayed." } ;

{ unix-system-call unix-system-call-allow-eintr } related-words
