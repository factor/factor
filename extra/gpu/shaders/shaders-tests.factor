! (c)2009 Joe Groff bsd license
USING: multiline gpu.shaders gpu.shaders.private tools.test ;
IN: gpu.shaders.tests

{ "ERROR: foo.factor:20: Bad command or filename
INFO: foo.factor:30: The operation completed successfully
NOT:A:LOG:LINE"  }
[ T{ shader { filename "foo.factor" } { line 19 } }
"ERROR: 0:1: Bad command or filename
INFO: 0:11: The operation completed successfully
NOT:A:LOG:LINE" replace-log-line-numbers ] unit-test
