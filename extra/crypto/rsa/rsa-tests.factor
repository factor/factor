USING: kernel math namespaces crypto.rsa tools.test ;
IN: crypto.rsa.tests

{ 123456789 } [ 128 generate-rsa-keypair 123456789 over rsa-encrypt swap rsa-decrypt ] unit-test
{ 123456789 } [ 129 generate-rsa-keypair 123456789 over rsa-encrypt swap rsa-decrypt ] unit-test
{ 123456789 } [ 130 generate-rsa-keypair 123456789 over rsa-encrypt swap rsa-decrypt ] unit-test
{ 123 } [ 3233 2753 17 <rsa> 123 over rsa-encrypt swap rsa-decrypt ] unit-test
