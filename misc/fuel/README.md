FUEL, Factor's Ultimate Emacs Library
-------------------------------------

FUEL provides a complete environment for your Factor coding pleasure
inside Emacs, including source code edition and interaction with a
Factor listener instance running within Emacs.

FUEL was started by Jose A Ortega as an extension to Eduardo Cavazos'
original factor.el code. Eduardo is also responsible of naming the
beast.

# Installation

FUEL can be installed from [MELPA](http://melpa.milkbox.net/).

Alternatively, FUEL comes bundled with Factor's distribution.
The folder misc/fuel can be added to your load path:

    (add-to-list 'load-path "<path/to/factor/installation>/misc/fuel")

The factor-mode major mode provides basic fontification and indentation
without connecting to a running Factor image:

    (require 'factor-mode)

The fuel-mode minor mode provides interaction with a running Factor instance:

    (require 'fuel-mode)

To use FUEL, you must set `fuel-factor-root-dir` to the root directory
of your Factor installation:

    (setq fuel-factor-root-dir "<path/to/factor/installation>")

# Basic usage
## Running the listener

If you're using the default Factor binary and images locations inside
the Factor's source tree, that should be enough to start using FUEL.
Editing any file with the extension `.factor` will put you in
factor-mode; try `C-hm` for a summary of available commands.

To start the listener, try `M-x run-factor`.

By default, FUEL will try to use the binary and image files in the
factor installation directory. You can customize them with:

    (setq fuel-listener-factor-binary <full path to factor>)
    (setq fuel-listener-factor-image <full path to factor image>)

Many aspects of the environment can be customized:
`M-x customize-group fuel` will show you how many.

### Faster listener startup

On startup, `run-factor` loads the fuel vocabulary, which can take a
while. If you want to speedup the load process, type `save` in the
listener prompt just after invoking `run-factor`. This will save a
Factor image (overwriting the current one) with all the needed
vocabs.

Alternatively, you can add the following line to your
`.factor-boot-rc` file:

    "fuel" require

This will ensure that the image generated while bootstrapping
Factor contains fuel and the vocabularies it depends on.

### Connecting to a running Factor

`run-factor` starts a new factor listener process managed by Emacs.
If you prefer to start Factor externally, you can also connect
remotely from Emacs. Here's how to proceed:

- In the factor listener, run FUEL: `"fuel" run`. This will start a server
listener in port 9000.
- Switch to Emacs and issue the command `M-x connect-to-factor`.

That's it; you should be up and running. See the help for
`connect-to-factor` for how to use a different port.

### Vocabulary creation

FUEL offers a basic interface to Factor's scaffolding utilities.
To create a new vocabulary directory and associated files:

    M-x fuel-scaffold-vocab

and when in a vocab file, to create a docs file with boilerplate
for each word:

    M-x fuel-scaffold-help

# Quick key reference

  Triple chords ending in a single letter <x> accept also C-<x> (e.g.
  C-c C-e C-r is the same as C-c C-e r).

### In factor source files:

Commands in parenthesis can be invoked interactively with
M-x <command>, not necessarily in a factor buffer.

    |--------------------+------------------------------------------------------------|
    | C-c C-z            | switch to listener (run-factor)                            |
    | C-c C-o            | cycle between code, tests and docs files                   |
    | C-c C-t            | run the unit tests for a vocabulary                        |
    | C-c C-r            | switch to listener and refresh all loaded vocabs           |
    | C-c C-s            | switch to other factor buffer (fuel-switch-to-buffer)      |
    | C-x 4 s            | switch to other factor buffer in other window              |
    | C-x 5 s            | switch to other factor buffer in other frame               |
    |--------------------+------------------------------------------------------------|
    | M-.                | edit word at point in Emacs (fuel-edit-word)               |
    | M-,                | go back to where M-. was last invoked                      |
    | M-TAB              | complete word at point                                     |
    | C-c C-e u          | update USING: line (fuel-update-usings)                    |
    | C-c C-e v          | edit vocabulary (fuel-edit-vocabulary)                     |
    | C-c C-e w          | edit word (fuel-edit-word-at-point)                        |
    | C-c C-e d          | edit word's doc (C-u M-x fuel-edit-word-doc-at-point)      |
    | C-c C-e l          | load vocabs in USING: form                                 |
    |--------------------+------------------------------------------------------------|
    | C-c C-e r          | eval region                                                |
    | C-M-r, C-c C-e e   | eval region, extending it to definition boundaries         |
    | C-M-x, C-c C-e x   | eval definition around point                               |
    | C-c C-k, C-c C-e k | run file (fuel-run-file)                                   |
    |--------------------+------------------------------------------------------------|
    | C-c C-d a          | toggle autodoc mode (fuel-autodoc-mode)                    |
    | C-c C-d d          | help for word at point (fuel-help)                         |
    | C-c C-d e          | show stack effect of current sexp (with prefix, region)    |
    | C-c C-d p          | find words containing given substring (fuel-apropos)       |
    | C-c C-d v          | show words in current file (with prefix, ask for vocab)    |
    |--------------------+------------------------------------------------------------|
    | C-c M-<            | show callers of word or vocabulary at point                |
    |                    | (fuel-show-callers, fuel-vocab-usage)                      |
    | C-c M->            | show callees of word or vocabulary at point                |
    |                    | (fuel-show-callees, fuel-vocab-uses)                       |
    |--------------------+------------------------------------------------------------|
    | C-c C-x s          | extract innermost sexp (up to point) as a separate word    |
    |                    | (fuel-refactor-extract-sexp)                               |
    | C-c C-x r          | extract region as a separate word                          |
    |                    | (fuel-refactor-extract-region)                             |
    | C-c C-x v          | extract region as a separate vocabulary                    |
    |                    | (fuel-refactor-extract-vocab)                              |
    | C-c C-x i          | replace word by its definition (fuel-refactor-inline-word) |
    | C-c C-x w          | rename all uses of a word (fuel-refactor-rename-word)      |
    | C-c C-x a          | extract region as a separate ARTICLE: form                 |
    | C-c C-x g          | convert current word definition into GENERIC + method      |
    |                    | (fuel-refactor-make-generic)                               |
    |--------------------+------------------------------------------------------------|

### In the listener:

    |---------+----------------------------------------------------------|
    | TAB     | complete word at point                                   |
    | M-.     | edit word at point in Emacs                              |
    | C-c C-r | refresh all loaded vocabs                                |
    | C-c C-a | toggle autodoc mode                                      |
    | C-c C-p | find words containing given substring (M-x fuel-apropos) |
    | C-c C-s | toggle stack mode                                        |
    | C-c C-v | edit vocabulary                                          |
    | C-c C-w | help for word at point                                   |
    | C-c C-k | run file                                                 |
    |---------+----------------------------------------------------------|

### In the debugger (it pops up upon eval/compilation errors):

    |---------+-------------------------------------|
    | g       | go to error                         |
    | <digit> | invoke nth restart                  |
    | w/e/l   | invoke :warnings, :errors, :linkage |
    | q       | bury buffer                         |
    |---------+-------------------------------------|

### In the help browser:

    |-----------+----------------------------------------------------------|
    | h         | help for word at point                                   |
    | v         | help for a vocabulary                                    |
    | a         | find words containing given substring (M-x fuel-apropos) |
    | e         | edit current article                                     |
    | b a       | bookmark current page                                    |
    | b b       | display bookmarks                                        |
    | b d       | delete bookmark at point                                 |
    | n/p       | next/previous page                                       |
    | l         | previous page                                            |
    | SPC/S-SPC | scroll up/down                                           |
    | TAB/S-TAB | next/previous link                                       |
    | k         | kill current page and go to previous or next             |
    | r         | refresh page                                             |
    | c         | clean browsing history                                   |
    | M-.       | edit word at point in Emacs                              |
    | C-c C-z   | switch to listener                                       |
    | q         | bury buffer                                              |
    |-----------+----------------------------------------------------------|

### In crossref buffers

    |-----------------+-----------------------------|
    | TAB/BACKTAB     | navigate links              |
    | RET/mouse click | follow link                 |
    | h               | show help for word at point |
    | q               | bury buffer                 |
    |-----------------+-----------------------------|
