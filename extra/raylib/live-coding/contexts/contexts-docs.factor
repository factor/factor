USING: help.markup help.syntax kernel quotations ;
IN: raylib.live-coding.contexts

HELP: current-context
{ $values { "context" "a native context snapshot, or f" } }
{ $description "Captures the current native OpenGL context and the display or surfaces needed to restore it. The snapshot borrows the context; it does not extend its lifetime." } ;

HELP: make-context-current
{ $values { "context" "a native context snapshot, or f" } }
{ $description "Restores a context snapshot. Passing f releases the current context. On Unix this also clears any loaded GTK context cache." } ;

HELP: with-context-restored
{ $values { "context" "a native context snapshot, or f" } { "quot" quotation } }
{ $description "Releases the current context, calls the quotation, and restores the supplied context even if the quotation throws. The context must remain alive throughout the call." } ;

HELP: with-saved-context
{ $values { "quot" quotation } }
{ $description "Captures the current context and calls the quotation with it released, restoring it on both normal and exceptional return." } ;
