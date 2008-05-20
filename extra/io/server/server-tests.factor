IN: io.server.tests
USING: tools.test io.server io.server.private kernel ;

{ 2 0 } [ [ ] server-loop ] must-infer-as
{ 2 0 } [ [ ] with-connection ] must-infer-as
{ 1 0 } [ [ ] swap datagram-loop ] must-infer-as
{ 2 0 } [ [ ] with-datagrams ] must-infer-as
