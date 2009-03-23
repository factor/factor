! (c) Joe Groff, see license for details
USING: accessors continuations kernel parser words quotations vectors ;
IN: literals

SYNTAX: $ scan-word [ def>> call ] curry with-datastack >vector ;
SYNTAX: $[ parse-quotation with-datastack >vector ;
