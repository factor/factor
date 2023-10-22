# ✨ Contributing to Factor 🚀

The Factor monorepo is like a treasure chest filled with all the amazing libraries developed in Factor! Contributions of any shape or size are warmly welcome 🎉

🚀 To contribute to Factor, you'll need to have the latest, cutting-edge build. Just clone the repository and follow the [build steps](README.md#building-factor-from-source) to embark on your Factor journey 🚀

🤔 If you have questions beyond the realms of this document, don't hesitate to ask the [community](https://www.concatenative.org/wiki/view/Factor/Community). They're your friendly guides through this Factor adventure!

## 🐞 Bug Reports 🐞

If you've stumbled upon a bug in the Factor distribution, here's what to do:

🔍 First, take a peek at the [existing issues](https://github.com/factor/factor/issues?q=is%3Aissue) to avoid duplicates. Check the closed issues too, as sometimes regressions can sneak in.

🔬 When reporting bugs, don't forget to include your platform name and architecture, as issues can be sneaky and specific.

📜 For bugs, always attach a code sample and a test case that can reproduce the issue.
  - Copy and paste the snippet text along with the error message produced by Factor. Screenshots are cool, but text is the hero!
  - If your text is too big for a GitHub issue, give the [Factor pastebin](https://paste.factorcode.org/) or a GitHub gist a visit to host your code.

## 🪄 Submitting a Patch 🪄

When you're ready to work your magic and submit a patch:

📜 All commits should be prefixed with vocabulary names. The commit history has plenty of good examples of this.

📜 Every contribution to Factor must be under the [BSD license](LICENSE.txt). In new vocabularies, don't forget to add a comment declaring this. You can use your real name or your GitHub nickname. Check out [this example](https://github.com/factor/factor/blob/master/core/alien/alien.factor).

🚀 Don't unleash new features without creating a feature request first. Let's keep things organized!

📦 The repository is divided like a well-organized bookshelf:
  - `basis`: Home to well-tested, well-documented vocabularies with a wide range of uses.
  - `core`: The heart of Factor, essential for compiling and bootstrapping. Handle with care, modifications are a serious business! You might need to re-bootstrap to test your changes.
  - `extra`: Beta land! Vocabularies that may be a bit wild and untamed. This is where most contributions begin their journey.
  - `misc`: Code not written in Factor, but cherished by Factor users. A few editor-specific plugins reside here.
  - `vm`: Home to Factor's C++ VM files.
  - `work`: Your personal playground! You can't contribute changes from here, it's all for you!

🎨 Style guidelines are our map on this adventure:
  - Factor code is written in small definitions that reference even smaller definitions. Keep words as small as possible by factoring out the core parts.
  - If your definitions span multiple lines, use 4 spaces for indentation.
  - Other than that, follow the style of the file you're editing.

📃 If you're making changes to `basis` or `core`, don't forget to update the documentation. You can use the words in [tools.scaffold](https://docs.factorcode.org/content/article-tools.scaffold.html) to build the foundation.

✨ Some words are referenced in other standalone articles. It's a good practice to mention those in a comment above your word's documentation to keep everything consistent.

🤫 `<PRIVATE` blocks are like secret hideouts for helper words. They're a bit of a leaky abstraction, but they make the documentation look clean and tidy.

🔍 Before submitting your changes, always run `lint` and `help.lint` to make sure everything is sparkling.

Now go forth, Factor explorer, and let's make the Factor world even more fantastic! 🌟💫