USING: modules.rpc-server io.servers.connection ;
IN: modules.test-server service
: rpc-hello ( -- str ) "hello world" stop-this-server ;