USING: alien.libraries.finder sequences tools.test ;

{ t } [ "kernel32.dll" "kernel32" find-library subseq? ] unit-test
