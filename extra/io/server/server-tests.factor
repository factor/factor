IN: io.server.tests
USING: tools.test io.server io.server.private ;

{ 2 0 } [ [ ] server-loop ] must-infer-as
{ 2 0 } [ [ ] with-connection ] must-infer-as
