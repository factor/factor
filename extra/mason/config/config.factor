! Copyright (C) 2008, 2011 Eduardo Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: calendar io.pathnames kernel namespaces system ;
IN: mason.config

! (Optional) Location for build directories
SYMBOL: builds-dir

builds-dir [ "~/builds" ] initialize

! Who sends build report e-mails.
SYMBOL: builder-from

! Who receives build report e-mails.
SYMBOL: builder-recipients

! (Optional) CPU architecture to build for.
SYMBOL: target-cpu

target-cpu [ cpu ] initialize

! (Optional) OS to build for.
SYMBOL: target-os

target-os [ os ] initialize

! (Optional) Architecture variant suffix.
SYMBOL: target-variant

! (Optional) Additional bootstrap flags.
SYMBOL: boot-flags

! Keep test-log around?
SYMBOL: builder-debug

! URL for counter notifications.
SYMBOL: counter-url

counter-url [ "https://builds.factorcode.org/counter" ] initialize

! URL for status notifications.
SYMBOL: status-url

status-url [ "https://builds.factorcode.org/status-update" ] initialize

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

docs-update-url [ "https://builds.factorcode.org/docs-update" ] initialize

! Boolean. Do we upload package binaries?
SYMBOL: upload-package?

! Host to upload binary package to.
SYMBOL: package-host

! Username to log in.
SYMBOL: package-username

! Directory with binary packages.
SYMBOL: package-directory

! Boolean. Do we update the clean branch?
SYMBOL: update-clean-branch?

! The below are only needed if update-clean-branch? is true.

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

! Upload timeout
SYMBOL: upload-timeout
1 hours upload-timeout set-global

! Optional: override ssh and scp command names
SYMBOL: scp-command
scp-command [ "scp" ] initialize

SYMBOL: ssh-command
ssh-command [ "ssh" ] initialize

! Notary command-line arguments
SYMBOL: notary-args

! Location of DLLs to copy
SYMBOL: dll-root
dll-root [ "resource:" ] initialize
