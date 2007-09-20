USING: kernel math namespaces crypto.rsa tools.test ;

[ 123456789 ] [ 128 generate-rsa-keypair 123456789 over rsa-encrypt swap rsa-decrypt ] unit-test
[ 123456789 ] [ 129 generate-rsa-keypair 123456789 over rsa-encrypt swap rsa-decrypt ] unit-test
[ 123456789 ] [ 130 generate-rsa-keypair 123456789 over rsa-encrypt swap rsa-decrypt ] unit-test
[ 123 ] [ 17 2753 3233 <rsa> 123 over rsa-encrypt swap rsa-decrypt ] unit-test

