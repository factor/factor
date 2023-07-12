# Contributing to Factor

The Factor monorepo contains almost all libraries developed in Factor alongside the Factor distribution.
Contributions of any form are welcome.

Contributing to Factor requires a bleeding-edge build. You can clone the repository and run `./build.sh update` to get one.

If you have any questions beyond the scope of this document, feel free to ask the [community.](https://www.concatenative.org/wiki/view/Factor/Community)

# Bug reports
If you have found a bug in the Factor distribution,
- Kindly search the [existing issues](https://github.com/factor/factor/issues?q=is%3Aissue) for dupes. Check the closed issues as well, since regression can happen.
- Always file bugs with a platform name and architecture, since issues may be constrained to one.
- For bugs, always add a code sample, and a reproducible test case.
  - Always paste the text of the snippet and the text from the error that Factor produces. Screenshots are useful, but text is important.
  - If the text cannot feasibly fit in a github issue, use the [Factor pastebin](https://paste.factorcode.org/) or a GitHub gist to host your code.
- If you are adding a feature request, detail on how the feature should be implemented, and add links to existing libraries or papers that will aid with implementing the feature.

# Submitting a patch
- Commits must always have vocabulary names prefixed to them. The commit history has many good examples of this.
- All contributions to Factor are mandatorily under the BSD license. In new vocabularies, you must add a comment stating the same. You can use your real name or your GitHub nickname. See [this](https://github.com/factor/factor/blob/master/core/alien/alien.factor) for an example.
- Do not submit features without creating a feature request first.
- The repository is structured as follows:
  - `basis`: Vocabularies which are well-tested, well-documented, and have a wide variety of uses.
  - `core`: The set of libraries which are most integral for compiling and boostrapping Factor. **Do not modify core unless it is absolutely necessary.** You will need to re-bootstrap to check your changes.
  - `extra`: Vocabularies which are in beta. May be unstable or broken. This is where most contributions start.
  - `misc`: Code which is not written in Factor, but holds significance to Factor users. Some editor-specific plugins reside here.
  - `vm`: Factor C++ VM files.
  - `work`: Store your personal work here. You cannot contribute changes made to work, as it is reserved for the user.
- Style guidelines are as follows:
  - Factor code is written in small definitions that reference smaller definitions. Keep words as small as possible by factoring out core parts.
  - Use 4 spaces of indentation if your definitions take multiple lines.
  - Apart from these guidelines, follow the style of the file you are editing.
- `<PRIVATE` blocks are highly recommended for helper words. They are a leaky abstraction, but they make the documentation tidier.
- Always run `lint` and `help.lint` on your changes before submitting them.
