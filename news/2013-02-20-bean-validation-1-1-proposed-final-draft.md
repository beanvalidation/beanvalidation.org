---
title: Bean Validation 1.1 CR1 - Proposed Final Draft
author: Emmanuel Bernard
layout: news
tags: [release]
---
Our Proposed Final Draft has been officially handed over to the JCP last night.

After a frantic month of work culminating with two weeks of monomaniac focus, we
are finally handing over the Bean Validation 1.1 Proposed Final Draft to the
JCP. Of course everything is open source so you can get it too:

- [the spec][spec]
- [the JavaDoc][javadoc]
- and the API JAR: maven coordinates [javax.validation:validation-api:1.1.0.CR1][maven]

## What's new in Bean Validation 1.1?

The specification
[highlights very well](http://beanvalidation.org/1.1/spec/1.1.0.cr1/#whatsnew)
the main features of this version but to summarize them:

- work done entirely in the open
- support for dependency injection and better integration with CDI
- support for method and constructor validation
- support for group conversion when cascading
- support for EL based message interpolation

## What's different between Beta 4 and CR 1?

We did a lot of polishing and nailed a lot of remaining corner cases. Here is a
few of the tasks we worked on:

- rework of the JavaDoc
- move to `@SupportValidationTarget` on `ConstraintValidator` instead of the
  additional `@CrossParameterConstraint` on the constraint to mark a constraint
  as cross-parameter
- many more examples in the specification
- improve node creation logic when nodes are added programmatically
- improve the creation logic of custom nodes when using the programmatic API of
  `ConstraintViolationBuilder` in a `ConstraintValidator`

And of course many hours rereading the specification to find holes and fix them.

## Review

Hibernate Validator 5.0.0.CR1 and the TCK should be here any minute. Help us
make this spec as good as possible by reviewing it and opening issues where it
itches you.

You can [access the specification here][spec].
All changes are marked with a different
color. <span style="background-color:#DDFFDD;">Green for additions</span>, 
<span style="background-color:#FFFFDD;">yellow for changes</span>.
This will help you see what has changed precisely.

Please send us your remarks and comments:

- on our [mailing list][mailing list]
- in our [issue tracker][issues]
- or on the Bean Validation [forum][forum]

Many many thanks to my partners in crime Hardy and Gunnar that worked around the
clock with me to deliver this proposed final draft right on time but with no
compromise on quality.

[contribute]: /contribute/
[spec]: /1.1/spec/1.1.0.cr1/?utm_source=blog&utm_medium=web&utm_content=spec&utm_campaign=1_1_cr1
[javadoc]: http://docs.jboss.org/hibernate/beanvalidation/spec/1.1/api/
[maven]: https://repository.jboss.org/nexus/content/groups/public-jboss/javax/validation/validation-api/1.1.0.CR1/
[issues]: /issues
[forum]: https://forum.hibernate.org/viewforum.php?f=26
[mailing list]: https://lists.jboss.org/mailman/listinfo/beanvalidation-dev
