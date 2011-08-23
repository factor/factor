! Copyright (C) 2008, 2010 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar system io.files io.pathnames namespaces kernel
accessors assocs ;
IN: mason.config

! (Optional) Location for build directories
SYMBOL: builds-dir

builds-dir get-global [
    home "builds" append-path builds-dir set-global
] unless

! Who sends build report e-mails.
SYMBOL: builder-from

! Who receives build report e-mails.
SYMBOL: builder-recipients

! (Optional) CPU architecture to build for.
SYMBOL: target-cpu

target-cpu get-global [ cpu target-cpu set-global ] unless

! (Optional) OS to build for.
SYMBOL: target-os

target-os get-global [ os target-os set-global ] unless

! Keep test-log around?
SYMBOL: builder-debug

! URL for counter notifications.
SYMBOL: counter-url

counter-url [ "http://builds.factorcode.org/counter" ] initialize

! URL for status notifications.
SYMBOL: status-url

status-url [ "http://builds.factorcode.org/status-update" ] initialize

! Password for status notifications.
SYMBOL: status-secret

SYMBOL: upload-docs?

! The below are only needed if upload-docs? is true.

! Host to upload docs to
SYMBOL: docs-host

! Username to log in.
SYMBOL: docs-username

! Directory to upload docs to.
SYMBOL: docs-directory

! URL to notify server about new docs
SYMBOL: docs-update-url

docs-update-url [ "http://builds.factorcode.org/docs-update" ] initialize

! Boolean. Do we release binaries and update the clean branch?
SYMBOL: upload-to-factorcode?

! The below are only needed if upload-to-factorcode? is true.

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

! Upload timeout
SYMBOL: upload-timeout
1 hours upload-timeout set-global

! Optional: override ssh and scp command names
SYMBOL: scp-command
scp-command [ "scp" ] initialize

SYMBOL: ssh-command
ssh-command [ "ssh" ] initialize
