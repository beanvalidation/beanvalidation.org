---
title: Feedback wanted - What would YOU like to see in Bean Validation 2.0?
author: Gunnar Morling
layout: news
tags: [feedback-needed]
---

How time flies by: It's almost three years since we [called Bean Validation 1.1 done](http://beanvalidation.org/news/2013/05/02/bean-validation-1-1-is-a-spec/) and promised ourselves to refrain from future specification work. Well, for a while at least :)

Since then Bean Validation has been used in many, many applications to ensure sanity of data.
It is integrated with and used by a huge amount of technologies, be it other Java standards (e.g. CDI, JPA, JAX-RS)
or 3rd party stacks and frameworks such as Spring, Vaadin, GWT and many more.
The main contribution of Bean Validation 1.1 - the declarative validation of method-level constraints - was quickly adopted by these technologies,
making it a breeze to write expressive API contracts which are automatically validated.

## Evolving the Bean Validation API

Unfortunately, though, an API isn't like good wine and becomes better and better just by getting older.

The Java world continued to evolve, most notably with the release of Java 8 in 2014,
bringing many new language features such as lambda expressions, type annotations, method literals, repeatable annotations etc.
Naturally, this raises the question how Bean Validation could benefit from these new constructs to make validation even more powerful and expressive.

And indeed several of the Java 8 additions are a great fit for the purposes of declarative validation.
To give just one example, let's consider the requirement of applying constraints to the elements of a collections.
This has been a [long-standing feature request](https://hibernate.atlassian.net/browse/BVAL-202), but we could never find a way to solve it generically in an acceptable manner.
So for instance the following doesn't work:

    @Email
    List<String> emails;

Apparently it's the author's wish to ensure that the `emails` list only contains Strings which are valid e-mail addresses.
Unfortunately, this doesn't work as expected, though. A constraint always applies to the annotated element,
and there is no constraint validator which would apply the `@Email` constraint to a `List`.

Some hoped it could be expressed like so:

    @ListConstraint(@Email)
    List<String> emails;

This looks nice, but it's not possible to write a generic `@ListConstraint` annotation in Java.
Annotation members may only be of *specific* annotation types, so one would need a `@ListConstraint` for each single constraint type.

Moving forward to Java 8, we now have a perfect tool at our disposal to solve this issue: [type annotations](https://docs.oracle.com/javase/tutorial/java/annotations/type_annotations.html).
By annotating the `String` type parameter, it becomes clear that the author's intent is to specify that the `@Email` constraint is to be applied to the elements of the list, not the list itself:

    List<@Email String> emails;

Java 8 provides the required APIs to retrieve the constraint annotations from type parameter and apply the validation accordingly.

That's just one case where Bean Validation would greatly benefit from Java 8 features.
And there are many other examples as you can see in the reference implementation [Hibernate Validator](http://hibernate.org/validator/) which already
comes with [proprietary Java 8 support](http://in.relation.to/2014/10/23/hibernate-validator-520-alpha-1-with-java-8-support-and-a-51-maintenance-release/) as of version 5.2, thanks to a great Google Summer of Code contribution.

## Your feedback is needed!

To cut a long story short, it's about time to get back to the drawing board and get out a new revision of the Bean Validation spec.
Its main feature for sure would be leveraging Java 8 concepts such as type annotations and repeatable annotations.

But we are also eager to hear about your experiences with the API and what additions you wish for most.
This might be things already existing as proprietary API in the reference implementation (such as the [API for programmatic constraint declaration](http://docs.jboss.org/hibernate/validator/5.2/reference/en-US/html_single/#section-programmatic-api))
but also stuff that's neither in the spec nor in Hibernate Validator.
We've compiled a [list of issues](https://hibernate.atlassian.net/issues/?jql=project%20%3D%20BVAL%20AND%20fixVersion%20%3D%202.0%20ORDER%20BY%20priority%20DESC) we consider for inclusion.

As we are quite time-constrained, we for sure won't be able to address all if these issues.
Hence if there is a feature close to your heart which you'd really love to see in the spec, be sure to speak up and let us know.

At the moment we are about to prototype some ideas in the reference implementation and write up some proposals for potential spec changes.
To get the ball rolling, we just [recently released](http://in.relation.to/2016/01/18/hibernate-validator-530-alpha1-out/) the first preview of Hibernate Validator 5.3 which provides support for dynamically declared constraint payloads, a feature that may potentially end up in the spec.

So if you ever wanted to contribute to a Java Specification Request - be it just by voting for issues, opening new feature requests or actually working on the specification, its reference implementation and the test compatability kit (TCK) - then this is the perfect time.
To get the discussion started, either drop a comment below, shoot a message to the [Bean Valdiation mailing list](https://lists.jboss.org/mailman/listinfo/beanvalidation-dev) or
comment on specific issues in [the tracker](https://hibernate.atlassian.net/projects/BVAL/summary).

We are looking forward to hearing from you!
