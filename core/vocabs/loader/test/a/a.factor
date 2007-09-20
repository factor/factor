USING: namespaces parser ;
IN: vocabs.loader.test.a

: COUNT-ME global [ "count-me" inc ] bind ; parsing

COUNT-ME

: v-l-t-a-hello 4 ;

: byebye v-l-t-a-hello ;

[ this is an error
