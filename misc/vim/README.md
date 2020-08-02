Vim support for Factor
======================

This directory contains various support files that make editing Factor code
more pleasant in Vim.

## Installation

The file-layout exactly matches the Vim runtime structure,
so you can install them by copying the contents of this directory
into `~/.vim/` or the equivalent path on other platforms
(open Vim and type `:help 'runtimepath'` for details).

## File organization

The current set of files is as follows:

* ftdetect/factor.vim - Teach Vim when to load Factor support files.
* ftplugin/factor.vim - Teach Vim to follow the Factor Coding Style guidelines.
* ftplugin/factor-docs.vim - Teach Vim about documentation style differences.
* plugin/factor.vim - Teach Vim some commands for navigating Factor source code. See below.
* syntax/factor.vim - Teach Vim about highlighting Factor source code syntax.
  * syntax/factor/generated.vim - Syntax highlighting lessons generated from a Factor VM.

## Commands

The `plugin/factor.vim` file implements the following commands for navigating Factor source.

### :FactorVocab factor.vocab.name

Opens the source file implementing the `factor.vocab.name` vocabulary.

### :NewFactorVocab factor.vocab.name

Creates a new factor vocabulary under the working vocabulary root.

### :FactorVocabImpl

Opens the main implementation file for the current vocabulary
(name.factor).  The keyboard shortcut `<Leader>fi` is bound to this command.

### :FactorVocabDocs

Opens the documentation file for the current vocabulary
(name-docs.factor).  The keyboard shortcut `<Leader>fd` is bound to this command.

### :FactorVocabTests

Opens the unit test file for the current vocabulary
(name-tests.factor).  The keyboard shortcut `<Leader>ft` is bound to this command.

## Configuration

In order for the `:FactorVocab` command to work, you'll need to set some variables in your vimrc file.

### g:FactorRoot

This variable should be set to the root of your Factor
installation. The default value is `~/factor`.

### g:FactorVocabRoots

This variable should be set to a list of Factor vocabulary roots.
The paths may be either relative to g:FactorRoot or absolute paths.
The default value is `["core", "basis", "extra", "work"]`.

### g:FactorNewVocabRoot

This variable should be set to the vocabulary root in which
vocabularies created with NewFactorVocab should be created.
The default value is `work`.

## Note

The `syntax/factor/generated.vim` syntax highlighting file
is automatically generated
to include the names of all the vocabularies Factor knows about.
To regenerate it manually, run the following code in the listener:

    "editors.vim.generate-syntax" run

or run it from the command line:

    factor -run=editors.vim.generate-syntax
