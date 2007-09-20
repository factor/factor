USING: kernel io strings sequences namespaces math parser crypto.hmac tools.test ;
IN: temporary

[ "\u0092\u0094rz68\u00bb\u001c\u0013\u00f4\u008e\u00f8\u0015\u008b\u00fc\u009d" ] [ 16 11 <string> "Hi There" string>md5-hmac >string ] unit-test
[ "u\u000cx>j\u00b0\u00b5\u0003\u00ea\u00a8n1\n]\u00b78" ] [ "Jefe" "what do ya want for nothing?" string>md5-hmac >string ] unit-test
[ "V\u00be4R\u001d\u0014L\u0088\u00db\u00b8\u00c73\u00f0\u00e8\u00b3\u00f6" ] [ 16 HEX: aa <string> 50 HEX: dd <string> string>md5-hmac >string ] unit-test

[ "g[\u000b:\eM\u00dfN\u0012Hr\u00dal/c+\u00fe\u00d9W\u00e9" ] [ 16 11 <string> "Hi There" string>sha1-hmac >string ] unit-test
[ "\u00ef\u00fc\u00dfj\u00e5\u00eb/\u00a2\u00d2t\u0016\u00d5\u00f1\u0084\u00df\u009c%\u009a|y" ] [ "Jefe" "what do ya want for nothing?" string>sha1-hmac >string ] unit-test
[ "\u00d70YM\u0016~5\u00d5\u0095o\u00d8\0=\r\u00b3\u00d3\u00f4m\u00c7\u00bb" ] [ 16 HEX: aa <string> 50 HEX: dd <string> string>sha1-hmac >string ] unit-test

