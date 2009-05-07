USING: fry namespaces kernel sequences parser ;
IN: closures
: delayed-bind ( quot -- quot' ) '[ namestack [ set-namestack @ ] curry ] ;
SYNTAX: C[ parse-quotation delayed-bind over push-all ;
