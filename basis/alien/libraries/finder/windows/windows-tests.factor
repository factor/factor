USING: alien.libraries.finder sequences tools.test ;

{ t } [ "kernel32" find-library "kernel32.dll" subseq-of? ] unit-test
