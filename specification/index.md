---
title: Specification
layout: default
author: Gunnar Morling
---

## Bean Validation 2.0

Bean Validation 2.0 (JSR 380) is currently under development.

It's planned to be part of Java EE 8 (can of course be used with plain Java SE as the previous releases) and will primarly focus on leveraging the language features introduced in Java SE 8 for the purposes of validation.
We'll also address other features further improving usefulness and usability of Bean Validation as requested by the community and as time allows.

### Resources

* [Proposal for JSR 380](https://www.jcp.org/en/jsr/detail?id=380)
* [Latest draft](/latest-draft/spec/)
* Changes to 1.1
  - [HTML diff](/2.0/spec/2.0.0.alpha1/diff/)
  - [Diff without typo fixes done for 1.1](https://github.com/beanvalidation/beanvalidation-spec/compare/2a9d0ce21856386a8bf9a1d9e963ebffc049604a...spec-full) - Asciidoc diff on GitHub based on the [1.1-full-spec-diff](https://github.com/beanvalidation/beanvalidation-spec/tree/1.1-full-spec-diff) branch; recommended for reviewing Bean Validation 2.0 changes
  - [Full diff](https://github.com/beanvalidation/beanvalidation-spec/compare/8916b9637206e20590c131c04ca91a06788b3d37...spec-full) - Asciidoc diff

### Active Proposals

Changes to the specification are usually done via [proposals](/proposals/) for specific issues, investigating different alternatives and approaches.
Feedback welcome!

## Bean Validation 1.1

Bean Validation 1.1 ([JSR 349](https://www.jcp.org/en/jsr/detail?id=349)) was finished in 2013 and is part of Java EE 7.
Its main contributions are method-level validation, integration with CDI, group conversion and some more.
You can learn more about Bean Validation 1.1 [here](/1.1/) (specification text, full change log, API docs etc).

## Bean Validation 1.0

Bean Validation 1.0 (JSR [303](https://www.jcp.org/en/jsr/detail?id=303)) was the first version of Java's standard for object validation.
It was released in 2009 and is part of Java EE 6.
You can learn more about Bean Validation 1.0 [here](/1.0/) (specification text, API docs etc).
