---
title: Bean Validation 2.0 - A new JSR is born!
author: Gunnar Morling
layout: news
tags: [news]
---

Today I've got some great news to share with you: a new revision of the Bean Validation spec is about to be kicked off!

Over the last weeks, we've been busy with preparing a proposal for this JSR and I've submitted it to the JCP (Java Community Process) last week.
You can find the proposal for "JSR 380: Bean Validation 2.0" on [jcp.org](https://jcp.org/en/jsr/detail?id=380).

In the following, let's take a look at what we think should be part of Bean Validation 2.0 and what we've planned as the next steps.

## Looking back...

Bean Validation 1.0 and 1.1 (JSRs 303/349) saw a huge adoption by the Java community and are integrated with a wide range of technologies, be it other Java standards (e.g. CDI, JPA, JAX-RS)
or 3rd party libraries and frameworks such as Spring, Vaadin and many, many more.

The main contribution of Bean Validation 1.1 - the declarative validation of method-level constraints - has been integrated into techs such as CDI and Spring,
making it a breeze to write expressive API contracts with constraints which are automatically validated upon execution.

Bean Validation 1.1 has been finalized [three years ago](http://beanvalidation.org/news/2013/05/02/bean-validation-1-1-is-a-spec/) and Java continued to evolve since then.
Java 8 - released in 2014 - brings many very interesting language features to the table, but also adds a new time and date API and much more.

## ...and forward

So it's about time that Bean Validation supports new JDK types such as `LocalTime` or `Optional`, but also takes advantage of new (language) features such as type annotations, repeatable annotations, reflective parameter name retrieval, lambda expressions etc.

To give just one example, let's consider the requirement of applying constraints to the elements of a specific collection.
This has been a [long-standing feature request](https://hibernate.atlassian.net/browse/BVAL-202), but we could never find a way to solve it generically in an acceptable manner.

Java 8 finally provides the perfect tool to solve this issue: [type annotations](https://docs.oracle.com/javase/tutorial/java/annotations/type_annotations.html).
Annotating type parameters of collections is a very intuitive way to apply constraints to collection elements (and not the entire collection itself):

    List<@Email String> emails;

Java 8 provides the required APIs to retrieve the constraint annotation from the type parameter and apply the validation accordingly.

But it doesn't stop there.
Repeatable annotation types will make it less verbose to specify several constraints of the same type one and the same element.
Reflective parameter name retrieval will provide better validation messages out of the box when validating constraints on method parameters.
Lambda expressions might be a useful vehicle to express small ad-hoc validation routines.

## What else?

While we envision supporting and leveraging Java 8 as the "main theme" of Bean Validation 2.0, we hope to address some other issues, too.
E.g. there may be support for more customized payloads of constraint violations.
Also a builder API for constraint violation exceptions might be useful.
As would an API for validating an object graph assuming a list of changes to be applied.
Check out the [JSR 380 proposal](https://jcp.org/en/jsr/detail?id=380) for some more ideas we have.

While the baseline for Bean Validation 2.0 will be Java 8, we'll also be tracking the ongoing work for Java 9 and work towards making Bean Validation ready for Java 9 and its module system as far as possible.

As the time-line of Bean Validation 2.0 is quite compact, we are very eager to hear from you, the community of users, and learn what would be the things most useful to you.
For sure we won't be able to address all potential ideas out there. So if there are features close to your heart which you'd really love to see in the spec, be sure to speak up and let us know.

## What's next?

As per [the rules](https://jcp.org/en/procedures/jcp2#3.3) of the Java Community Process, the Bean Validation 2.0 JSR is currently up for review by the JCP executive committee.
After that, there will be an approval ballot and we will hopefully be ready to go and kick off the work on actual spec changes, prototyping new features in the reference implementation and so on.

So if you ever wanted to contribute to a Java Specification Request - be it just by voting for issues, opening new feature requests or actually working on the specification, its reference implementation and the test compatability kit (TCK) - then this is the perfect time.
If you are a member of the JCP, you also can [join the expert group](https://jcp.org/en/jsr/egnom?id=380), we'd be very happy to have you aboard.

Whether EG member or not, in order to get the discussion on this JSR proposal started, just drop a comment below, post to the [feedback forum](https://forum.hibernate.org/viewforum.php?f=26), shoot a message to the [Bean Validation mailing list](https://lists.jboss.org/mailman/listinfo/beanvalidation-dev) or
comment on specific issues in [the tracker](https://hibernate.atlassian.net/projects/BVAL/summary).

We are looking forward to hearing from you and get Bean Validation 2.0 rolling!
