USING: assocs io.pathnames fry namespaces namespaces.private kernel sequences parser hashtables ;
IN: closures
SYMBOL: |

! Selective Binding
: delayed-bind-with ( vars quot -- quot' ) '[ _ dup [ get ] map zip >hashtable [ _ bind ] curry ] ;
SYNTAX: C[ | parse-until parse-quotation delayed-bind-with append! ;
! Common ones
SYNTAX: DIR[ parse-quotation { current-directory } swap delayed-bind-with append! ;

! Namespace Binding
: bind-to-namespace ( quot -- quot' ) '[ namespace [ _ bind ] curry ] ;
SYNTAX: NS[ parse-quotation bind-to-namespace append! ;
