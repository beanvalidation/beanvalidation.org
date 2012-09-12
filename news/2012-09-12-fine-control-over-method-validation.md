---
title: Fine control over method validation in Bean Validation... or not!
author: Emmanuel Bernard
layout: news
tags: [feedback-needed]
---
I need your feedback on whether or not you need fine controls on method
validation.

## Some context

Bean Validation 1.1 introduces the idea of method validation. When
the method is called, parameters and return value can be validated.
The constraints are of course defined as Bean Validation constraint
annotations.

I am working on the chapter describing how interceptor technologies like
CDI, EJB, Spring, Guice, AspectJ should integrate it.

We have decided to convert most of the
recommendations into mandatory rules. In particular, methods annotated
with constraints should be validated by the integration technology
by default.

Early in the design we have introduced an annotation `@MethodValidated`
that lets you control a few things:

- which group should be used for validation (defaulting to `Default`)
- what part should be validated: parameters, return value, both or none

This annotation made sense when validation was not on by default but I am
now questioning its usefulness.

**I have a bunch of questions for you**. I tried to keep them short and to
the point so feel free to answer them one by one. They also go from easy
to more convoluted. Are you up for the challenge?

Note that I have added a bonus question in the end.

## What's your use case for disabling method validation?

Why would you want to disable method validation on a given method or a
given class?

    public class UserService {
        @MethodValidated(validationMode=NONE)
        public void createUser(
            @NotEmpty @Email String email,
            @Valid Address address ) {
            ...
        }
    }


If you have a use case, would it be fulfilled with the `@MethodValidated`
annotation as described?

## What's your use case for changing the default group?

`@MethodValidated(groups=Heavy.class)` let's you change validation from
the `Default` group to the group of your choice - in this case `Heavy`.

Provided that we will offer support for group translation when cascading
<http://beanvalidation.org/proposals/BVAL-208/>

    public class UserService {
        public void createUser(
            @NotEmpty @Email String email,
            @Valid @ConvertGroup(from=Default.class, to=BasicPostal.class)
            Address address ) {
            ...
        }
    }

do we really need the ability do decide which group to use to validate a
given method? What would be the use case?

To me it seems that it could makes sense to validate one group over
another based on:

- some environmental consideration
  say a newbie user has more constraints on how it enters data
  than an advanced user hence different groups
- the caller
  say a branch of the code wants to apply different rules than
  an other

In both case, it does not make sense to define the group via an
annotation on the method to be validated.
This would need to be a rather container specific behavior to let people
inject the right group for the right context.

## When would you want to only validate parameters or return values?

`@MethodValidated.validationMode` let's you validate both method
parameters as well as return value, or either one of them or none at all.

    @MethodValidated(validationMode=PARAMETERS)
    public class UserService {
        @Valid
        public User createUser(
            @NotEmpty @Email String email,
            @Valid Address address ) {
            ...
        }
    }

Do you have a use case in mind for such need?

## What inheritance rules make sense for `@MethodValidated`?

Assuming we have `@MethodValidated`, we need to define the overriding
rules.

We could decide that `@MethodValided` must be placed on the method to be
validated (no overriding rule), or we could try and add some or all of
the following rules:

1. `@MethodValidated` definitions on a method overrides the ones on a class
2. `@MethodValidated` definition on a subclass overrides the ones on superclasses

Here is an example

    //example of rule 1
    @MethodValidated(validationMode=PARAMETERS)
    public class UserService {
        @MethodValidated(validationMode=BOTH)
        @Valid
        public User createUser(
            @NotEmpty @Email String email,
            @Valid Address address ) {
            ...
        }
    }

Interfaces make things harder as there would be no magic rule to decide
which definition has precedence over another in case of conflict.

We could consider that methods of a class implementing an interface
inherit the interface hosted `@MethodValidated` definition (unless overridden).
And in case two interfaces define the same method, overriding the
`@MethodValidated` definition would be mandatory.

I can live with rule 1, I can support rule 2. but I feel that the rules
related to interfaces make things quite complex and not especially
readable. Plus I don't see why you would want to add `@MethodValidated`
on an interface. Not surprising as I don't see why one would do it on a
class method anyways ;)

What do you make of that?

## You are a convinced @MethodValidated fan? What about the name?

We have never found a good name for this annotation anyways. If you
like and want this annotation, how should it be named?

Yep that's the bonus question, sorry.

## Conclusion

I realize that it must look like I am having a `@MethodValidated`
mid-life crisis but better now than later :D
