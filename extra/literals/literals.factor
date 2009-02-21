! (c) Joe Groff, see license for details
USING: accessors continuations kernel parser words quotations vectors ;
IN: literals

: $ scan-word [ def>> call ] curry with-datastack >vector ; parsing
: $[ \ ] parse-until >quotation with-datastack >vector ; parsing
