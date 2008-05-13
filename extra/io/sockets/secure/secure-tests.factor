IN: io.sockets.secure.tests
USING: io.sockets.secure tools.test ;

\ <ssl-config> must-infer
{ 1 0 } [ [ ] with-ssl-context ] must-infer-as
