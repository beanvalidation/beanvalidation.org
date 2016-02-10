---
title: Support cross-parameter constraints
layout: default
author: Emmanuel Bernard
comments: true
---

[Link to JIRA ticket][jira]  

## Problem

Decide how to express cross parameter constraints in method validation
and how the constraint validation contract looks like.

Note that this is a follow up on [this discussion][previous proposal].

## Solution

### Cross parameter validation and return value

The group agrees not to support cross validation of both parameters and return
value in a single constraint validator.

### Where to host cross-parameter constraints

We use the method as host to the return value constraints and possibly `@Valid`.
That is unfortunately also the natural place for cross parameter constraints.

I cannot think of another place to put them. There is also no easy way to add a
visual cue and differentiate a regular constraint from a cross param constraint
except by its meta annotation. We would rely on the user adding a visual cue in
the constraint name. Which kind of cue? Put `param` in the constraint name?

Any one can think of a better approach?

#### Bean Validation class

    @interface CrossParameterConstraint {
        public Class<? extends CrossParameterConstraintValidator<?>>[] validatedBy();
    }

    interface CrossParameterConstraintValidator<A extends Annotation> {
        void initialize(A constraintAnnotation);
        [...]
    }

> Question: does these different annotations/interfaces affect the metadata API?
>
> Question: can the same constraint annotation be annotated by both
> `@Constraint` and `@CrossParameterConstraint`: `@ScriptAssert` is a good candidate
> Note: how does composition plays into this?

The main problem I can see is that it is not possible to differentiate return value
constraints from cross-parameter constraints. I'm inclined to not allow it.

#### Constraint implementor code

    @CrossParameterConstraint(validatedBy=CheckRetypedPasswordValidator.class)
    @interface  CheckRetypedPasswordParameter {
        String message() default "...";
        Class<?>[] groups() default {};
        class<? extends Payload>[] payload();
    }

    class CheckRetypedPasswordValidator implements
            CrossParameterConstraintValidator<CheckRetypedPasswordParameter> {
        ...
    }

#### Constraint user code

    class AccountService {
        //cross param constraints
        @CheckRetypedPasswordParameter
        //return value constraints
        @Valid @NotNull
        User createUser(@NotEmpty String username, @Email String email, String password, String retypedPassword);
    }

### What is the cross parameter constraint validator contract?

There has been two leading proposals. The others are described in the
[previous proposal][previous proposal].

#### Generic approach

    interface CrossParameterConstraintValidator<A extends Annotations> {
        void initialize(...) { ... }
        boolean isValid(Object[] parameterValues, ConstraintValidatorContext context);
    }


A given constraint **cannot host more than one of these generic `CrossParameterConstraintValidator`
implementation** or we would not be able to choose which one to use.

#### Type-safe approach (with annotation processors)

A more type-safe approach is to reuse the parameters signature of the method to match.
While the Java compiler cannot discover problems, both an annotation processor and the bean validation provider at runtime
can detect inconsistent contracts and raise respectively compilation errors and deployment time exception.

    class CheckRetypedPasswordValidator implements
            CrossParameterConstraintValidator<CheckRetypedPasswordParameter> {
        void initialize(...) { ... }
        boolean isValid(String username, String email, String password, String retypedPassword,
                        ConstraintValidatorContext context) {
            ...
        }
    }

The goal of the type-safe constraint is to raise an error if the method signature changes.
It means that **we cannot have both the generic method signature and a type-safe signature
for the same constraint** or we would lose the type-safety mechanism.

To keep options opened, we need to split the **cross parameter constraint validator in two
interfaces**:

- `CrossParameterConstraintValidator` hosting the `initialize` contract
- `GenericCrossParameterConstraintValidator` hosting the generic `isValid` method

> Should we allow several type-safe method for a given validator or even for
> a given constraint?

There is no good argument one way or the other as of today.

> What would be the rules to decide if a method matches?

There are two approaches:

- use exact matches (parameter types and numbers)
- use the more sophisticated JLS rules around method overloading selection

The later is definitely cleaner but the rules are not trivial to understand
and implement. On the other hand, that's idiomatic Java.
Do generics complicate the picture?

##### DIY type-safe approach

We can offer a `TypesafeCrossParameterConstraintValidator` abstract class that
needs to be extended and that will host the type-safe `isValid` method.
The generic `isValid` method would be implemented by `TypesafeCrossParameterConstraintValidator`
and implement the method selection.

An alternative proposal would be to add a helper method to select the most specific
type-safe method. Such a method could be hosted on `CrossParameterConstraintValidator`
or on the context object.

The alternative approach lets each bv provider implement the method selection logic.
However it asks more work from the constraint violation developer.

#### ConstraintViolation and Metadata API

> How to represent cross parameter constraints in `Constraintviolation`?

> What should `getInvalidValue()`/`getLeafBean()` return?

This is not 100% intuitive but we could return the `Object[]` of
parameters when `getInvalidValue()` is called.

> What should `getPropertyPath()` return?

We likely need to introduce a `ParametersDescriptor` that would
represent this particular case. That seems the most natural approach.

> Should the constraint violation report return the parameters being tested?

Today, cross-parameter constraints (or should it be constraint validators)
do not return the actual parameters being considered in violation.

I imagine we could have a way to return parameter indexes as part of the
`ConstraintViolation` or the `ParametersDescriptor`.

But do we want such a feature? And if yes, should it be statically defined or dynamically
defined. And if static, should it be hosted on the cross parameters
constraint or the cross parameters constraint validator implementation?

One vehicle would be a tailored constraint violation builder that can add parameter
index(es). Alternative options are:

- have `isValid` return the parameter indexes
- add a constract to `CrossParameterConstraintViolation` returning the parameter indexes involved

#### Discussions

I think we must put the generic approach in because that's the only way to write non
method specific cross parameter constraints. Two examples of such constraints are

- script based constraints
- generic password retype checks based on the parameter indexes
  `@AreEqual(indexes={2,3}, message="Passwords must be identical")`

So the remaining question is do we also support the type-safe approach in parallel?
There is debate in the expert group and many questions remain opened.
I think we should pursue the idea though and decide whether to include it or not at
a later stage.

In terms of todo and priority, I think we should:

1. explore the idea of returning the parameter indexes involved
2. start with the generic approach and put that in the spec
3. add the type-safe approach as a proposal in the spec

[jira]: https://hibernate.onjira.com/browse/BVAL-232
[previous proposal]: /proposals/BVAL-241/#cross_parameter
