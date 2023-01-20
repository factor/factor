! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io.standard-paths io.standard-paths.macosx tools.test ;

{ "/System/Library/CoreServices/Finder.app" }
[ "com.apple.finder" find-native-bundle ] unit-test
