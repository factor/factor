USING: assocs io.pathnames fry namespaces kernel sequences parser ;
IN: closures
SYMBOL: |
: delayed-bind-with ( vars quot -- quot' ) '[ _ dup [ get ] map zip [ _ bind ] curry ] ;
SYNTAX: C[ | parse-until parse-quotation delayed-bind-with over push-all ;
! Common ones
SYNTAX: DIR[ parse-quotation { current-directory } swap delayed-bind-with over push-all ;