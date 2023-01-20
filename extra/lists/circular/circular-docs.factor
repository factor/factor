! Copyright (C) 2022 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays circular help.markup help.syntax lists lists.lazy ;
IN: lists.circular

ABOUT: "lists.circular"

ARTICLE: "lists.circular" "Circular lists"
"The " { $vocab-link "lists.circular" } " vocabulary implements virtually infinite linked lists based on the " { $link circular } " sequences. These are especially useful when used lazily (" { $vocab-link "lists.lazy" } "), see " { $link ltake } ", just don't call " { $link llength } "." ;
