---
title: Bean Validation 1.1 Beta 3 - the last line
author: Emmanuel Bernard
layout: news
tags: [release]
---
With two months since the last release and more than 38 (non trivial)
issues behind us, we felt that it was a good time to release a new version.
We are less than 20 days from the proposed final draft so feedback time and
polishing are going into overdrive.

Expect a reference implementation and a much improved TCK aligned with this
version in the next few days.

## What's new

There are too many improvements so let's pick three.

### Enable / disable method validation

We worked a lot on method validation and in particular how you can control
whether or not a method or constructor is being validated. You can use
`@ValidateExecutable` and the XML `validated-executables` element in
`validation.xml` to do that.

### Message interpolation with UEL

We have also greatly enhanced message interpolation. You can now use the unified
expression language inside your messages. This elegantly solves a lot of feature
requests we had in this area like:

- the ability to put the validated value in the message
- the ability to format numbers, dates etc according to the locale

Here is an example from `@DecimalMin`. It uses the min boundary `value`, the
`inclusive` parameter in an EL and use a formaatter to display the erroneous
value:

    ${formatter.format("%1$2f", validatedValue} is incorrect ; must be greater than ${inclusive == true ? 'or equal to ' : ''}{value}

Which will be interpolated into

    324.32 is incorrect ; must be greater than or equal to 500

### Generic and cross-parameter constraints

Finally we have introduce the ability to make constraints both generic and
cross-parameter aware. This is useful for constraints like `@ScriptAssert` that
are very flexible.

## Review

Please, please, please go and review the specification and tell us if something
needs to be fixed.

You can [access the specification here][draft].
All changes are marked with a different
color. <span style="background-color:#DDFFDD;">Green for additions</span>, 
<span style="background-color:#FFFFDD;">yellow for changes</span> and 
<span style="text-decoration: line-through;background-color: #FFDDDD;">struck through red for removals</span>
. This will help you see what has changed precisely.

Please send us your remarks and comments:

- on our [mailing list][mailing list]
- in our [issue tracker][issues]
- or on the Bean Validation [forum][forum]

If you want to go to the next step and contribute, send us an email to
the mailing list and read [how to contribute][contribute].

[contribute]: /contribute/
[draft]: /1.1/spec/1.1.0.beta3/?utm_source=blog&utm_medium=web&utm_content=spec&utm_campaign=1_1_beta3
[issues]: /issues
[forum]: https://discourse.hibernate.org/c/bean-validation
[mailing list]: https://lists.jboss.org/mailman/listinfo/beanvalidation-dev
