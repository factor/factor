USING: namespaces parser ;
IN: vocabs.loader.test.a

<< global [ "count-me" inc ] bind >>

: v-l-t-a-hello 4 ;

: byebye v-l-t-a-hello ;

[ this is an error
