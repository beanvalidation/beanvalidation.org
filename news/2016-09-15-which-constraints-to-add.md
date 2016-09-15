---
title: Feedback needed - Which constraints should be added?
author: Gunnar Morling
layout: news
tags: [feedback]
---

The work on Bean Validation 2.0 is in full swing and there is an issue where we could benefit from your help.

Recently we have been discussing whether any new constraints [should be added](http://lists.jboss.org/pipermail/beanvalidation-dev/2016-August/001000.html) to the specification or not.
Traditionally, Bean Validation stayed on the conservative side of things in this regard.
It defined only some generically applicable and widely useful constraints in the specification itself, e.g. `@NotNull`, `@Size` or `@Pattern`.

Now Marco Molteni did a very interesting analysis on the constraints which are actually used in real world projects by [running an analysis](http://lists.jboss.org/pipermail/beanvalidation-dev/2016-August/001000.html) of open source projects hosted on GitHub.
Only a specific type of project is hosted there usually (mostly libraries, as opposed to actual end user facing applications),
so the numbers should be taken with a grain of salt. But nevertheless they are very interesting.

Marco's analysis shows that besides the BV-defined constraints `@NotEmpty` and `@NotBlank` - both defined by the reference implementation Hibernate validator - are very frequently used and thus are potential candidates for inclusion into Bean Validation 2.0.
The former asserts that the annotated string, collection, map or array is neither null nor empty, the latter validates that the annotated string is neither null nor empty, stripping leading/trailing whitespace.

Another candidate may be `@Email`; but validation of e-mail addresses is a surprisingly complex business, with different people having different ideas and expectations of how a valid (or invalid) e-mail address should look like (take a look at the [examples on Wikipedia](https://en.wikipedia.org/wiki/Email_address#Examples) to get an idea).
Hence I feel this is not something we should aim for in the specification.

To add some further data points, we created the following survey on constraints to be added potentially.
Getting back many answers to this poll will help us to form a better understanding of what you, the users out there, really need.
If you would like to see support for other constraints not mentioned in the survey, you can add them via the free-text field in the last question.
These may be custom constraints defined by a Bean Validation provider, a third-party library or in your own projects which you see yourself using very frequently.

Taking the survey will take you only a minute, so give it a go. Thanks a lot for your help!

<iframe src="https://docs.google.com/forms/d/e/1FAIpQLScR9o9p2GlrmhrtSinp2D9PY8gN4C-AOA-bjm8bwXkX_4H1Sw/viewform?embedded=true" width="760" height="500" frameborder="0" marginheight="0" marginwidth="0">Loading...</iframe>
