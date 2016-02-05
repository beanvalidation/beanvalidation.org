---
title: Enforce evaluation of composed constraints stops on first validation error in case of @ReportAsSingleViolation
layout: default
author: Hardy Ferentschik
comments: true
---

[Link to JIRA ticket](https://hibernate.onjira.com/browse/BVAL-259)

## Goals

The BV spec currently says in a note:

> If a composing constraint fails and if the composed constraint is marked as @ReportAsSingleViolation,
> the Bean Validation provider is free to not process the other composing constraints for this composed constraint.

However, this behavior is not enforced. The aim is to mandate this behavior and make it potentially
configurable ([BVAL-220](https://hibernate.onjira.com/browse/BVAL-220))

## Related issues

Let composed constraint return the message of the first failing constraint ([BVAL-261](https://hibernate.onjira.com/browse/BVAL-261)),
eg:

    @ReportAsSingleViolation(messageSource=ByOriginatingConstraint)

## Solutions

### Option 1: Just enforce the behavior which is currently jsut added as a note

### Option 2: Make the behavior configurable

For example:

    @ReportAsSingleViolation(shortCircuit=true)
    @NotNull
    @Constraint(validatedBy=MyValidator)
    public @interface MyConstraint {}
