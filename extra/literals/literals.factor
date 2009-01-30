! (c) Joe Groff, see license for details
USING: continuations kernel parser words quotations ;
IN: literals

: $ scan-word [ execute ] curry with-datastack ; parsing
: $[ \ ] parse-until >quotation with-datastack ; parsing
