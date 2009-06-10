USING: assocs io.pathnames fry namespaces namespaces.private kernel sequences parser hashtables ;
IN: closures
SYMBOL: |

! Selective Binding
: delayed-bind-with ( vars quot -- quot' ) '[ _ dup [ get ] map zip >hashtable [ _ bind ] curry ] ;
SYNTAX: C[ | parse-until parse-quotation delayed-bind-with over push-all ;
! Common ones
SYNTAX: DIR[ parse-quotation { current-directory } swap delayed-bind-with over push-all ;

! Namespace Binding
: bind-to-namespace ( quot -- quot' ) '[ namespace [ _ bind ] curry ] ;
SYNTAX: NS[ parse-quotation bind-to-namespace over push-all ;