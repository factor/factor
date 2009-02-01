! (c) Joe Groff, see license for details
USING: continuations kernel parser words quotations vectors ;
IN: literals

: $ scan-word [ execute ] curry with-datastack >vector ; parsing
: $[ \ ] parse-until >quotation with-datastack >vector ; parsing
