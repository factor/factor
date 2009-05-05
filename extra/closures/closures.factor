USING: fry namespaces kernel sequences parser ;
IN: closures
: delayed-bind ( quot -- quot' ) '[ namespace [ _ bind ] curry ] ;
SYNTAX: C[ parse-quotation delayed-bind over push-all ;
