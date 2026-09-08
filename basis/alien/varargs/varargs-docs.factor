USING: alien.c-types alien.varargs help.markup help.syntax kernel quotations ;
IN: alien.varargs

HELP: va-cursor
{ $class-description "A borrowed position in an ARM64 C variable argument list. A variadic callback receives a cursor after its named parameters. An ordinary callback with a " { $link va_list } " parameter receives a cursor in that parameter's position." }
{ $warning "The cursor and every copy expire when the callback returns or exits exceptionally. Only the callback's current execution and Factor thread may read or forward it. An outer callback can resume reading its cursor after a nested callback returns." } ;

HELP: va-arg
{ $values { "cursor" va-cursor } { "c-type" "a literal C type" } { "value" object } }
{ $description "Reads the next argument and advances the cursor. The declared type undergoes the same default argument promotions as an outgoing variadic FFI call: small integers, booleans, and enums with narrow underlying integer types become " { $link int } ", " { $link float } " becomes " { $link double } ", and Apple ARM64 small floating-point types become double. Outgoing values are converted to their declared source type before promotion, including integer narrowing and binary32 rounding. Incoming values use the promoted type's ordinary boxer, so a promoted boolean or narrow enum is returned as an integer. Aggregates and vectors retain their types. Aggregate values own their storage and can outlive the callback." }
{ $warning "The calling C API must establish the argument types and count, for example through a count, a format string, or a sentinel. The cursor cannot detect a wrong type or the end of the argument list. Reading with the wrong type or past the end has the same invalid-memory consequences as C's va_arg." }
{ $errors "Throws " { $link expired-va-list } " if the cursor's callback has ended or another callback or Factor thread tries to use it." } ;

HELP: va-copy
{ $values { "cursor" va-cursor } { "copy" va-cursor } }
{ $description "Copies the current position. Reading either cursor does not advance the other. The copy borrows the same argument storage and expires with the same callback." }
{ $errors "Throws " { $link expired-va-list } " when the source cursor cannot be used." } ;

HELP: va_list
{ $description "The native ARM64 va_list parameter type. On Linux this is a structure containing stack and register-save pointers and offsets; on macOS and Windows it is a pointer. Use this type for C functions such as vsnprintf and callbacks that receive an existing va_list." }
{ $notes "A callback parameter is boxed as a borrowed " { $link va-cursor } ". Passing a cursor to C materializes an independent native list position. C may consume that temporary position without advancing the Factor cursor, so the same cursor can be forwarded more than once."
"This vocabulary preserves the historical void* representation on other architectures; cursor reading and native-list conversion are implemented for ARM64 only." } ;

HELP: expired-va-list
{ $error-description "A variable argument cursor was used after its callback ended, while a different callback was active, or from another Factor thread." } ;

HELP: with-va-scope
{ $values { "quot" quotation } }
{ $description "Compiler support for callback lifetime management. Executes a callback's parameter boxing, body, and return conversion within one variable argument lifetime, then expires every cursor created in that lifetime. The cleanup runs on exceptional exits as well." } ;

ARTICLE: "alien.varargs" "ARM64 variable argument lists"
"The " { $vocab-link "alien.varargs" } " vocabulary reads and forwards variable arguments received from C. It supports macOS, Linux, and Windows ARM64 argument-list layouts."
{ $subsections va-cursor va-arg va-copy va_list }
"The argument cursor contains a position, not a description of the remaining arguments. Use the C API's declared protocol to choose each type and determine when to stop." ;

ABOUT: "alien.varargs"
