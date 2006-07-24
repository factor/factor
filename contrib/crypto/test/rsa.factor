USING: kernel math test namespaces crypto ;

[ 123456789 ] [ 128 generate-rsa-keypair 123456789 over rsa-encrypt swap rsa-decrypt ] unit-test
[ 123456789 ] [ 129 generate-rsa-keypair 123456789 over rsa-encrypt swap rsa-decrypt ] unit-test
[ 123456789 ] [ 130 generate-rsa-keypair 123456789 over rsa-encrypt swap rsa-decrypt ] unit-test


