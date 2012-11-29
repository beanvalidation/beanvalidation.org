---
title: Provide ability to disable validation and customize groups for method/constructor validation
layout: default
author: Emmanuel Bernard
comments: true
---

# #{page.title}

[Link to JIRA ticket][jira]  

## Problem

Decide which mechanism should be offered to disable method validation and
customize the group used for method validation.
We have discovered that an annotation on the validated method itself does
not solve any of the interesting use case.

## Proposal

There are several angles to let developers customize method validation:

1. leave it specific to each provider (easy way but feeling incomplete)
2. leave it to the interception technology (ie CDI, AspectJ etc), that's just moving the issue around and we need to define it for CDI anyways
3. offer a component customizing the group to validate and whether or not to validate a method
4. We should also offer a way to disable validation entirely in the xml deployment descriptor

I'm inclined to offer 3 and 4 at the moment

Here is a fleshed out proposal (integrated in the specification for feedback).

By default, all constrained methods (that can be intercepted) are validated using the
default group.

You can customize whether or not a method is validated and which group is used via
the `MethodValidationActivator` and `MethodValidationGroupSelector` contracts and providing
implementations to the Bean Validation bootstrap or via the XML deployment descriptor.

    /**
     * Decides if constraints of a given method should be validated
     * 
     * @author Emmanuel Bernard
     */
    interface MethodValidationActivator {
        boolean activateMethodValidation(Method method):
        boolean activateConstructorValidation(Constructor constructor);
    }

    /**
     * Provides the (set of) groups that should be used when validating the
     * given constrained method.
     * 
     * @author Emmanuel Bernard
     */
    interface MethodValidationGroupSelector {
        Class<?>[] selectGroupsForMethod(Method method):
        Class<?>[] selectGroupsForConstructor(Constructor constructor);
    }

> Note: `MethodValidationActivator` and `MethodValidationGroupSelector` are horrible
> names, we need to find different ones

The components `MethodValidationActivator` and `MethodValidationGroupSelector` are accepting
injection points in a container environment (CDI in particular). Implementations must be thread-safe.

Method and constructor validations can be globally disabled via the XML configuration descriptor by
using the `disable-method-validation` element. Likewise, you can disable validation for a specific
method / constructor or for all methods / constructors of a given bean by using the
`disable-method-validation` attribute on the respective elements.

> TODO: should we change the boolean `disable-method-validation` with the following enum based
> `method-validation`: `NONE`, `PARAMETERS`, `RETURN_VALUE`, `ALL`. What would be the use case
> for `PARAMETERS` / `RETURN_VALUE`? We could also use the enum but restrict it to `NONE` and
> `ALL` to plan for the future.

Here are a few use cases :

- choose a different group depending on the caller stack: a batch input might want different validation than a user input
- choose a different group depending on a specific context: if a user is flagged as rogue, enforce more constraints
- disable validations for a given deployment as it is considered a "safe" environment
- disable a specific method validation for development purposes either via a custom
  `MethodValidationGroupSelector` implementation or via the XML deployment descriptor

Context or caller stack implementations can be implemented in a couple of ways:

- use a thread local variable to carry the groups

- use a request scoped CDI component to carry the groups: this component being injected in the
  `MethodValidationGroupSelector` implementation.

> Should we provide in the CDI integration a way to customize the group via an annotation?
> An annotation in the caller stack would set the expected group. This would resurrect the
> `@MethodValidated` annotation but not on the validated method itself.

[jira]: https://hibernate.onjira.com/browse/BVAL-314
