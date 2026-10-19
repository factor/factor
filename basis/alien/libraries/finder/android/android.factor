USING: alien.libraries.finder kernel sequences system ;
IN: alien.libraries.finder.android

! Android's linker namespace resolves public system libraries and the native
! libraries packaged with the application. Supplying the soname preserves
! those namespace checks instead of scanning inaccessible system directories.
M: android find-library* "lib" prepend ".so" append ;
