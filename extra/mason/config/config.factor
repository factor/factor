! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: system io.files namespaces kernel accessors ;
IN: mason.config

! (Optional) Location for build directories
SYMBOL: builds-dir

builds-dir get-global [
    home "builds" append-path builds-dir set-global
] unless

! Who sends build reports.
SYMBOL: builder-from

! Who receives build reports.
SYMBOL: builder-recipients

! (Optional) CPU architecture to build for.
SYMBOL: target-cpu

target-cpu get-global [
    cpu name>> target-cpu set-global
] unless

! (Optional) OS to build for.
SYMBOL: target-os

target-os get-global [
    os name>> target-os set-global
] unless

! Keep test-log around?
SYMBOL: builder-debug

! Boolean. Do we release binaries and update the clean branch?
SYMBOL: upload-to-factorcode

! The below are only needed if upload-to-factorcode is true.

! Host with clean git repo.
SYMBOL: branch-host

! Username to log in.
SYMBOL: branch-username

! Directory with git repo.
SYMBOL: branch-directory

! Host to upload clean image to.
SYMBOL: image-host

! Username to log in.
SYMBOL: image-username

! Directory with clean images.
SYMBOL: image-directory

! Host to upload binary package to.
SYMBOL: upload-host

! Username to log in.
SYMBOL: upload-username

! Directory with binary packages.
SYMBOL: upload-directory
