USING: calendar io io-internals kernel math namespaces
nonblocking-io prettyprint quotations sequences ;
IN: libs-io

: bit-set? ( m n -- ? ) [ bitand ] keep = ; 
: set-bit ( m bit -- n ) bitor ;
: clear-bit ( m bit -- n ) bitnot bitand ;

