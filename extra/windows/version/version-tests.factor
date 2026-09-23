USING: kernel sequences tools.test windows.version ;
IN: windows.version.tests

{ t } [ "kernel32.dll" file-version [ "." subseq-of? ] [ f ] if* ] unit-test
