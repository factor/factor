USING: namespaces parser ;
IN: vocabs.loader.test.a

<< global [ "count-me" inc ] with-variables >>

: v-l-t-a-hello ( -- a ) 4 ;

: byebye ( -- a ) v-l-t-a-hello ;

[ this is an error
