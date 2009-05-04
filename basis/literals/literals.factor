! (c) Joe Groff, see license for details
USING: accessors continuations kernel parser words quotations
combinators.smart vectors sequences ;
IN: literals

SYNTAX: $ scan-word [ def>> call ] curry with-datastack >vector ;
SYNTAX: $[ parse-quotation with-datastack >vector ;
SYNTAX: ${ \ } [ [ ?execute ] { } map-as ] parse-literal ;
