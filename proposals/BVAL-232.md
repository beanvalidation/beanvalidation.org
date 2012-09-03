---
title: Support cross-parameter constraints
layout: default
author: Emmanuel Bernard
---

# #{page.title}

[Link to JIRA ticket][jira]  

## Problem

Decide how to express cross parameter constraints in method validation
and how the constraint validation contract looks like.

Note that this is a follow up on [this discussion][previous proposal].

## Solution

### Cross parameter validation and return value

Do we agree that validating both the parameters and the return value in a single
constraint validator is not a use case we want to cover?
To me that would be awkward to support it as we would need to execute the method
to validate it.

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

#### Constraint coder class

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

#### User code

    class AccountService {
        //cross param constraints
        @CheckRetypedPasswordParameter
        //return value constraints 
        @Valid @NotNull
        User createUser(@NotEmpty String username, @Email String email, String password, String retypedPassword);
    }

### What is the cross parameter constraint validator contract?

There has been two leading proposals. the others are described in the
[previous proposal][previous proposal].

#### Generic approach

    interface CrossParameterConstraintValidator<A extends Annotations> {
        void initialize(...) { ... }
        boolean isValid(Object[] parameterValues, ConstraintValidatorContext context);
    }

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

#### Discussions

I think we must put the generic approach in because that's the only way to write non
method specific cross parameter constraints. Two examples of such constraints are

- script based constraints
- generic password retype checks based on the parameter indexes
  `@AreEqual(indexes={2,3}, message="Passwords must be identical")`

So the remaining question is do we also support the type-safe approach in parallel?
I am inclined to think yes. We can do it on the same `CrossParameterConstraintValidator`
implementation:


    class CheckRetypedPasswordValidator implements
            CrossParameterConstraintValidator<CheckRetypedPasswordParameter> {
        void initialize(...) { ... }

        boolean isValid(Object[] parameterValues, ConstraintValidatorContext context);

        boolean isValid(String username, String email, String password, String retypedPassword,
                        ConstraintValidatorContext context) {
            ...
        }
    }

If the method validated has a matching signature, we use it, otherwise we use the generic
method.

Do we keep the generic `isValid` method on the interface, thus forcing people to implement
it? Or is that an optional non constrained contract?
I am tempted to think that forcing is a better approach (the implementation can raise an
exception). Thoughts?

[jira]: https://hibernate.onjira.com/browse/BVAL-232
[previous proposal]: /proposals/BVAL-241/#cross_parameter
