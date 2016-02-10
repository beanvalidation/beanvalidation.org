---
title: Support groups translation when cascading operations
layout: default
author: Emmanuel Bernard
comments: true
---

[Link to JIRA ticket][jira]  

## Problem

We want to address the following problems:

1. upon `@Valid`, translate a given group request to another group
2. choose a given group upon method validation

Step 2. is handled by `@MethodValidated` and described in the method validation triggering section.

## Solution

There has been some thinking into reusing `@Valid` for group translation but the common trend
is to keep them separate. If you think otherwise, please discuss in the beanvalidation development
mailing list. We are interested in your feedback.

We have also contemplated the idea of merging this feature with the annotation used to trigger
method validation. Since method validation also hosts a validation mode, we decided to keep
them separated.

> Question: should we embed one in the other or use both as elements of
> orthogonal concern?
> for example `@MethodValidated(mode=PARAMETERS) @ConvertGroup(from=Default.class, to=Basic.class)`

The proposition is as followed.

When an element is annotated with `@Valid`, validation is propagated. Groups are passed as
is to the nested elements unless the `@ConvertGroup` annotation is used.

If the group expected to be passed to the nested element validation is defined
as the `from` attribute of a `@ConvertGroup` annotation, the group used to effectively
validate the nested element is the corresponding group defined in the `to` attribute.

The first rule matching is used. If a rule is found matching, subsequent rules are no longer
evaluated. In particular, if a set of `@ConvertGroup` definition chains groups A to B
and B to C, the group A will be converted to B and not to C.

> Question: are these rules making sense?

    /**
     * During cascading convert group <code>from</code> to
     * to group <code>to</code>
     *
     * @author Emmanuel Bernard <emmanuel@hibernate.org>
     */
    public @interface ConvertGroup {
        Class<?> from();
        Class<?> to();

        public @interface List {
            ConvertGroup[] value();
        }
    }

Alternative proposal:


    /**
     * During cascading convert group <code>from</code> of
     * a given index to group <code>to</code> with the same
     * index.
     *
     * @author Emmanuel Bernard <emmanuel@hibernate.org>
     */
    public @interface ConvertGroup {
        Class<?>[] from();
        Class<?>[] to();
    }

## Examples

    public class User {
        @Valid
        @ConvertGroup.List( {
            @ConvertGroup(from=Default.class, to=BasicPostal.class),
            @ConvertGroup(from=Complete.class, to=FullPostal.class)
        } )
        Set<Address> getAddresses() { ... }
    }

    // vs

    public class User {
        @Valid
        @ConvertGroup(
            from={Default.class, Complete.class},
            to={BasicPostal.class, FullPostal.class}
        )
        Set<Address> getAddresses() { ... }
    }

## Questions and todos

> Question, what should the annotation name be:
>
> - `@ConvertGroup`
> - `@TanslateGroup`
> - ?

> Open question: can one define a class-level `@ConvertGroup` that would be applied
> to all @Valid of a given bean?  
> My gut feeling is that it is not necessary as one use group conversion to
> convert the group in one context (the main bean) to a group in
> another context (the associated bean). I don't see a reason to have the
> same context across associated beans?  
> Am I missing a use case?

TODO: describe and study how the group sequence resolution affects / is affected
by the group conversion.

TODO: think about rules that validate the same object twice but with different
groups (X =gA-to-gB-> Y -gB-to-gA-> X). I imagine that the non circularity
rule we have is either OK or need to be changed to take the validated group
into consideration. The tuple instance+group is the unique identifier.

[jira]: https://hibernate.onjira.com/browse/BVAL-208
