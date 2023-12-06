# Contributing to Factor

The Factor monorepo contains almost all libraries developed in Factor alongside the Factor distribution.
Contributions of any form are welcome.

Contributing to Factor requires a bleeding-edge build. You can clone the repository and follow the [build steps](README.md#building-factor-from-source) to start working on Factor.

If you have any questions beyond the scope of this document, feel free to ask the [community.](https://www.concatenative.org/wiki/view/Factor/Community)

# Bug reports
If you have found a bug in the Factor distribution,
- Kindly search the [existing issues](https://github.com/factor/factor/issues?q=is%3Aissue) for dupes. Check the closed issues as well, since regression can happen.
- Always file bugs with a platform name and architecture, since issues may be constrained to one.
- For bugs, always add a code sample, and a reproducible test case.
  - Always paste the text of the snippet and the text from the error that Factor produces. Screenshots are useful, but text is important.
  - If the text cannot feasibly fit in a github issue, use the [Factor pastebin](https://paste.factorcode.org/) or a GitHub gist to host your code.
- If you are adding a feature request, provide details on how the feature should be implemented and add links to existing libraries or papers that will aid with implementing the feature.

# Submitting a patch
- Commits must always have vocabulary names prefixed to them. The commit history has many good examples of this.
- All contributions to Factor are mandatorily under the [BSD license](LICENSE.txt). In new vocabularies, you must add a comment stating the same. You can use your real name or your GitHub nickname.
  See [this](https://github.com/factor/factor/blob/master/core/alien/alien.factor) for an example.
  - If you are fixing a bug, then you can add your name to the copyright section of the vocabulary, adding the current year if necessary.
  - If you make substantial changes and want to be included in bugfixes and future direction for the vocabulary, add you name to the vocabulary's AUTHORS.txt as well.
- Do not submit features without creating a feature request first.
- The repository is structured as follows:
  - `basis`: Vocabularies which are well-tested, well-documented, and have a wide variety of uses in Factor code.
  - `core`: The set of libraries which are most integral for compiling and bootstrapping Factor. **Do not modify core unless it is absolutely necessary.** You will need to re-bootstrap to check your changes.
  - `extra`: Vocabularies which are in beta, or do not necessarily belong in the other vocabularies.
    - These vocabularies may be unstable or broken.
    - Most new vocabulary contributions start.
    - Notably, `extra/webapps` contains the code for the [Concatenative Wiki](https://concatenative.org), [Factor pastebin](https://paste.factorcode.org),
      [Planet Factor](https://planet.factorcode.org) and many others. You can contribute to them from here.
  - `misc`: Code which is not written in Factor, but holds significance to Factor users. Some editor-specific plugins reside here.
  - `vm`: Factor C++ VM files.
  - `work`: Store your personal work here. You cannot contribute changes made to work, as it is reserved for the user.
- Style guidelines are as follows:
  - Factor code is written in small definitions that reference smaller definitions. Keep words as small as possible by factoring out core parts.
  - Use 4 spaces of indentation if your definitions take multiple lines.
  - Apart from these guidelines, follow the style of the file you are editing.
- If you are making changes to `basis` or `core`, performing the required changes to documentation is mandatory. You can use the words in
  [tools.scaffold](https://docs.factorcode.org/content/article-tools.scaffold.html) to generate the basic structure.
  - Some words are referenced in other standalone articles. It is highly recommended to mention those in a comment above your word's documentation,
    so that the documentation stays consistent on all referenced pages.
- `<PRIVATE` blocks are highly recommended for helper words. They are a leaky abstraction, but they make the documentation tidier.
- Always run `lint` and `help.lint` on your changes before submitting them.
