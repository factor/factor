! Copyright (C) 2014 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel namespaces sequences ;
IN: yaml.config

! Configuration
! The following are libyaml's emitter configuration options
SYMBOL: emitter-canonical
SYMBOL: emitter-indent
SYMBOL: emitter-width
SYMBOL: emitter-unicode
SYMBOL: emitter-line-break

! Set this value to keep libyaml's default
SYMBOL: +libyaml-default+

{
    emitter-canonical
    emitter-indent
    emitter-width
    emitter-line-break
} [ +libyaml-default+ swap set-global ] each
! But Factor is unicode-friendly by default
t emitter-unicode set-global

SYMBOL: implicit-tags
t implicit-tags set-global

SYMBOL: implicit-start
SYMBOL: implicit-end
t implicit-start set-global
t implicit-end set-global

! By default, give the simplest representation of the document
SYMBOL: merge
SYMBOL: value
t merge set-global
t value set-global
