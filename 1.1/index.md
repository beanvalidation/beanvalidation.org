---
title: Bean Validation 1.1 (JSR 349) official drafts
layout: default
author: Emmanuel Bernard
---

# #{page.title}

This pages contains the official drafts published for Bean Validation 1.1.

## Specification Drafts

* [Bean Validation 1.1 latest working snapshot](/latest-draft/spec)
* [Bean Validation 1.1.0.Beta1  - Public Review Draft 1](spec/1.1.0.beta1/) + [JavaDocs](http://docs.jboss.org/hibernate/beanvalidation/spec/1.1/api)
* [Bean Validation 1.1.0.Alpha1 - Early Draft 1](spec/1.1.0.alpha1/)  

All changes are marked with a different
color. <span style="background-color:#DDFFDD;">Green for additions</span>, 
<span style="background-color:#FFFFDD;">yellow for changes</span> and 
<span style="text-decoration: line-through;background-color: #FFDDDD;">struck through red for removals</span>
. This will help you see what has changed precisely.

## Changes

The main area of work for this revision are:

- openness of the specification and its process
- method-level validation (validation of parameters or return values)
- dependency injection for Bean Validation components
- integration with Context and Dependency Injection (CDI)
- group conversion

## Feedback

Do you have feedback? Talk to us:

- on our [mailing list][mailing list]
- in our [issue tracker][issues]
- or on the Bean Validation [forum][forum]

If you want to go to the next step and contribute, send us an email to the mailing list and read
[how to contribute](/contribute).


[spec]: spec/
[issues]: /issues
[forum]: https://forum.hibernate.org/viewforum.php?f=26
[mailing list]: https://lists.jboss.org/mailman/listinfo/beanvalidation-dev
