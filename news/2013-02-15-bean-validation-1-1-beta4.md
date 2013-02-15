---
title: Bean Validation 1.1 Beta 4 - issue smashing edition
author: Emmanuel Bernard
layout: news
tags: [release]
---
Our proposed final draft is due soon but we did one last drop of the
specification and the API jar. We worked all over the board (and the
clock) but the most notable improvements are:

## Improvements on the CDI integration section

We made it much more descriptive of the expected behavior instead of
imposing an implementation pattern.
We have also added the method and constructor interception priority
as defined in the Java EE specification and the interceptor specification
in particular.

Thanks Pete for your help.

## Remove the link between the Node API and the metadata API

This is something we could not make work, so we fall back into a more
redundant but we think cleaner design. We also made the node builder
API easier to use despite the increased number of node types.

    //Cross-parameter constraint on a method
    //mergeAddresses(Map<String,Address> addresses, Map<String,Address> otherAddresses)
    //Build a constraint violation on the default path + "otherAddresses["home"]
    //ie. the Address bean hosted in the "home" key of the "otherAddresses" map parameter
    context.buildConstraintViolationWithTemplate(
            "Map entry home present in both and does not match")
                    .addParameterNode(1)
                    .addBeanNode()
                        .inIterable().atKey("home")
                    .addConstraintViolation();

## Clarification around method validation (metadata, cross-parameter, reports)

We now have an explicit cross-parameter concept materialized in the metadata
API. It makes for a more regular and easier to browse API.
`ConstraintViolation` has also seen some improvements and adaptations to make
it ready for prime - method validation - time.

## Mark a method as (non) validated

We slightly improved `@ValidateExecutable` to be more friendly when
put on a specific method. To force a getter to be validated or to
force a method to not be validated is now more readable.

    public class Operations {
        @ValidateExecutable
        @Status
        public String getStatus() { ... }

        @ValidateExecutable(ExecutableType.NONE)
        public void apply(@Valid Operation operation) { ... }
    }

## Review

Let us know what you think.

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
[draft]: /1.1/spec/1.1.0.beta4/?utm_source=blog&utm_medium=web&utm_content=spec&utm_campaign=1_1_beta4
[issues]: /issues
[forum]: https://forum.hibernate.org/viewforum.php?f=26
[mailing list]: https://lists.jboss.org/mailman/listinfo/beanvalidation-dev
