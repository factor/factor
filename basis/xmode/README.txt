This is a Factor port of the jEdit 4.3 syntax highlighting engine
(http://www.jedit.org).

jEdit 1.2, released in late 1998, was the first release to support
syntax highlighting. It featured a small number of hand-coded
"token markers" -- simple incremental parers -- all based on the
original JavaTokenMarker contributed by Tal Davidson.

Around the time of jEdit 1.5 in 1999, Mike Dillon began developing a
jEdit plugin named "XMode". This plugin implemented a generic,
rule-driven token marker which read mode descriptions from XML files.
XMode eventually matured to the point where it could replace the
formerly hand-coded token markers.

With the release of jEdit 2.4, I merged XMode into the core and
eliminated the old hand-coded token markers.

XMode suffers from a somewhat archaic design, and was written at a time
when Java VMs with JIT compilers were relatively uncommon, object
allocation was expensive, and heap space tight. As a result the parser
design is less general than it could be.

Furthermore, the parser has a few bugs which some mode files have come
to depend on:

- If a RULES tag does not define any keywords or rules, then its
  NO_WORD_SEP attribute is ignored.

  The Factor implementation duplicates this behavior.

- if a RULES tag does not have a NO_WORD_SEP attribute, then
  it inherits the value of the NO_WORD_SEP attribute from the previous
  RULES tag.

  The Factor implementation does not duplicate this behavior. If you
  find a mode file which depends on this flaw, please fix it and submit
  the changes to the jEdit project.

- References to non-existent rule sets in IMPORT tags and DELEGATE
  attributes were ignored in jEdit. They raise an error in Factor.

If you wish to contribute a new or improved mode file, please contact
the jEdit project. Updated mode files in jEdit will be periodically
imported into the Factor source tree.
