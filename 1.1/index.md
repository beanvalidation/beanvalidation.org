---
title: Bean Validation 1.1 (JSR 349)
layout: default
author: Emmanuel Bernard
---

# #{page.title}

Want the specification? [Get it here](/1.1/spec/).
Want the reference implementation? [Get Hibernate Validator](http://validator.hibernate.org).

## What is new since 1.0

This version of the specification focused on the following main topics:

- openness of the specification and its process
- method-level validation (validation of parameters or return values)
- dependency injection for Bean Validation components
- integration with Context and Dependency Injection (CDI)
- group conversion
- error message interpolation using EL expressions

For more information, check out the [full list of goals and changes](/1.1/changes/).

## Read the specification

You can find the [full specification](/1.1/spec/) or browse the
[API JavaDocs](http://docs.jboss.org/hibernate/beanvalidation/spec/1.1/api/).

## Get the reference implementation

Hibernate Validator is the reference implementation for Bean Validation.
Download the known compliant version [Hibernate Validator 5.0.1.Final][hibernate-validator].

## Technology Compatibility Kit

Download the latest Technology Compatibility Kit (TCK) version
[1.1.1.Final](http://sourceforge.net/projects/hibernate/files/beanvalidation-tck/1.1.1.Final)
and read the corresponding [TCK documentation](http://docs.jboss.org/hibernate/beanvalidation/tck/1.1/reference/html_single/).

## Feedback

Do you have feedback? Talk to us:

- on our [mailing list][mailing list]
- in our [issue tracker][issues]
- or on the Bean Validation [forum][forum]

If you want to go to the next step and contribute, read [how to contribute](/contribute).

## History

If you are interested in the various drafts that led to Bean Validation 1.1, check
out the [history page](/1.1/history/).

[spec]: spec/
[issues]: /issues
[forum]: https://forum.hibernate.org/viewforum.php?f=26
[mailing list]: https://lists.jboss.org/mailman/listinfo/beanvalidation-dev
[hibernate-validator]: http://sourceforge.net/projects/hibernate/files/hibernate-validator/5.0.1.Final/
