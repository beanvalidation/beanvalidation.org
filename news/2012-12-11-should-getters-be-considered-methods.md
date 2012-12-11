---
title: Should getters be considered methods
author: Emmanuel Bernard
layout: news
tags: [feedback]
---
The expert group is agonizing on a specific issue. We need your
feedback. Should getters be considered _regular_ methods and thus be validated
when called?

## The problem

Existing applications put Bean Validation constraints on properties
(ie getters). If we enable validations when getters are called, some
applications might fail and Bean Validation would not be backward
compatible. Besides, it is unlikely that you want to validate genuine getters
when they are called. These are state, not operations for the most part.

First off what does it mean to be a getter. A method is a getter if:

- its name starts with `is`, has no parameter and its return type is `Boolean`
- or its name starts with `get` and has not parameter

If in your service (say a CDI bean), you have an action method with
no parameter and starting with `get`, and if you have added constraints
to validate the return value upon method call, we cannot differentiate
this action method from a genuine getter.

We have several solutions to work around the problem and we would like
to know which one you prefer.

## Solutions

We can use a few levers to work around the issue:

- ask you to enable method validation explicitly
- offer a coarse or fine grained solution to change the default behavior

### Solution 1: enable method validation out of the box

If method validation is enabled out of the box then the sensible default is
to exclude getters from method validation.

This approach is friendly out of the box and will work as expected most of
the time (except for action methods with no parameter, starting with `get`
and with constraints on the return value).

The downside of this approach is that in this very specific case where
an action method is also a getter, method validation would be disabled
out of the box and a manual intervention would be necessary.

You can change the default approach in two ways:

#### Solution 1.a: global flag

Use a global flag to disable method validation entirely or ask for getters
to be validated upon call. You would use `validation.xml` for that:

    <method-validation mode="INCLUDE_GETTERS"/>

There is no way to change the behavior for a specific (set of) class.

#### Solution 1.b: fine grained flag

An alternative solution is to change method validation behavior in a
much more fine-grained approach:

- set the default approach globally
  in `validation.xml`
- set or override the setting for a given package (including sub-packages?)
  via `@ValidateOnCall` as a package annotation (or `validation.xml`)
- set or override the setting for a given class
  via `@ValidateOnCall` as a type annotation (or `validation.xml`)
- set or override the setting for a given method
  via `@ValidateOnCall` as a method annotation (or `validation.xml`)

A `@ValidateOnCall` annotation can be overridden in `validation.xml` like we do for
constraints declarations.

    public class AwesomeService {
        // not a getter - validated by default
        @NotNull Currency provideMainCurrency(@ISO @NotNull String country) { ... }

        // not a getter - validated by default
        @NotNull Currency getAlternativeCurrencies(@ISO @NotNull String country) { ... }

        // getter - must use @ValidateOnCall to activate
        @ValidateOnCall(mode=INCLUDE_GETTERS)
        @NotNull getAllCurrencies() { ... }
    }

Note that, we could put `@ValidateOnCall(mode=INCLUDE_GETTERS)` on the package
of service classes

    @ValidateOnCall(mode=INCLUDE_GETTERS)
    package com.acme.gladiator.action;

In this case, `getAllCurrencies()` does not need to be annotated with `@ValidateOnCall`.

### Solution 2: disable method validation out of the box

In this situation, a user wanting to enable method validation needs to both:

- add the constraints on methods
- add the flag to enable method validation

The method validation flag would both allow it to be enabled and decide if getters
should be considered.

This approach is the least surprise approach as nothing is happening that you
have not explicitly asked for. The drawback is that it requires a manual intervention to enable
method validation in a given archive which is not groovy.

#### Solution 2.a: global flag

For all archives using method validation, a `META-INF/validation.xml` file must
be added. The file would contain the explicit setting:

    <method-validation mode="INCLUDE_GETTER"/>

There is no way to change the behavior for a specific (set of) classes.

#### Solution 2.b: fine grained flag

As described in the previous section, we could enable method validation at
the package, class and method level using either a `@ValidateOnCall` annotation
or via the `validation.xml`. In this approach, `validation.xml` is not mandatory
to enable method validation provided that you use `@ValidateOnCall` in your code.

## So what's your favorite?

My personal favorite is to enable non-getter method validation out of the
box and offer fine-grained options to override the behavior. That's solution
1.b. My reasoning is the following:

- I want ease of use and method validation enabled by default
- actions methods named like a getter, with no parameter and constraints
  on its return value will be rare - return value constraint are less common
  than parameter methods

Some in the expert group do prefer solution 2.a or 2.b.

What's your take? And why do you prefer this approach?
