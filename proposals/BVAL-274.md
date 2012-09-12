---
title: Improve metadata API to be more friendly towards method interceptor integrators
layout: default
author: Emmanuel Bernard
---

# #{page.title}

[Link to JIRA ticket][jira]  

## Problem

I was looking at how to compute whether or not method interception needs
to occur via on the metadata API.

The validation of method-level constraints comprises the following steps:

- Intercept the method call to be validated
- Validate the parameter values provided by the method caller using Validator#validateParameters() or Validator#validateConstructorParameters().
- If this validation yields a non-empty set of constraint violations, throw a ConstraintViolationException wrapping the violations. Otherwise proceed with the actual method invocation.
- Validate the result returned by the invoked method using Validator#validateReturnValue() or Validator#validateConstructorReturnValue().
- If this validation yields a non-empty set of constraint violations, throw a ConstraintViolationException wrapping the violations. Otherwise return the invocation result to the method caller.

I realised that we have a cumbersome API to detect whether or not
calling Bean Validation.

    public boolean interceptMethod(Class<?> type, Method method) {
        BeanDescriptor bean = validator.getConstraintsForClass( type );
        MethodDescriptor methodDescriptor = bean.getConstraintsForMethod( method.getName(), method.getParameterTypes() );
        return methodDescriptor != null;
    }
    
    public boolean validateMethodParametersWithFullNavigation(Class<?> type, Method method) {
        BeanDescriptor bean = validator.getConstraintsForClass( type );
        MethodDescriptor methodDescriptor = bean.getConstraintsForMethod( method.getName(), method.getParameterTypes() );
        if ( methodDescriptor != null ) {
            boolean validate = false;
            for (ParameterDescriptor paramDescriptor : methodDescriptor.getParameterDescriptors()) {
                validate = paramDescriptor.hasConstraints() || paramDescriptor.isCascaded();
                if (validate) {
                    break;
                }
            }
            return validate;
        }
        else {
            return false;
        }
    }
    
    public boolean validateReturnValueWithFullNavigation(Class<?> type, Method method) {
        BeanDescriptor bean = validator.getConstraintsForClass( type );
        MethodDescriptor methodDescriptor = bean.getConstraintsForMethod( method.getName(), method.getParameterTypes() );
        if ( methodDescriptor != null ) {
            boolean validate = false;
            ReturnValueDescriptor returnValue = methodDescriptor.getReturnValueDescriptor();
            if ( returnValue!=null ) {
                return returnValue.isCascaded() || returnValue.hasConstraints();
            }
            else {
                return false;
            }
        }
        else {
            return false;
        }
    }

`interceptMethod` is used to decide whether or not we intercept the method
at all. it can be used to disable the interceptor entirely.

`validateMethodParametersWithFullNavigation` is used to decide whether
or not we need to call `validator.validateParameters()`. If no violation
is found, we goa nd execute the method.

After the method returns, we call
`validateReturnValueWithFullNavigation` to decide whether or not to
validate return value.

There is of course the equivalent for constructor validation.

## Proposal

What I am proposing is to add two aggregate methods to
`MethodDescriptor` and `ConstructorDescriptor`.

    /**
     * Returns true if method parameters are constrained either:
     * - because of a constraint on at least one of the parameters
     * - because of a cascade on at least one of the parameters (via {@code @Valid})
     * - because of at least a cross-parameter constraint
     */
    boolean isConstrainedOnParameters();

    /**
     * Returns true if the method return value is constrained either:
     * - because of a constraint on the return value
     * - because validation is cascaded on the return value (via {@code @Valid})
     */
    boolean isConstrainedOnReturnValue();

The implementation would then become

    public boolean validateMethodParametersWithMethodDescriptorShortcuts(Class<?> type, Method method) {
        BeanDescriptor bean = validator.getConstraintsForClass( type );
        MethodDescriptor methodDescriptor = bean.getConstraintsForMethod( method.getName(), method.getParameterTypes() );
        if ( methodDescriptor != null ) {
            return methodDescriptor.isConstrainedOnParameters();
        }
        else {
            return false;
        }
    }
    
    public boolean validateMethodReturnValueWithMethodDescriptorShortcuts(Class<?> type, Method method) {
        BeanDescriptor bean = validator.getConstraintsForClass( type );
        MethodDescriptor methodDescriptor = bean.getConstraintsForMethod( method.getName(), method.getParameterTypes() );
        if ( methodDescriptor != null ) {
            return methodDescriptor.isConstrainedOnReturnValue();
        }
        else {
            return false;
        }
    }

Of course the lookup of `BeanDescriptor` and `MethodDescriptor` only has
to be done once. The methods result is also likely being cached by the
interceptor being placed and these calls are probably only happening at
initialization time.

An alternative solution is to use the fluent API to find constraints

    public boolean validateMethodParametersWithFindConstraintAPI(Class<?> type, Method method) {
        BeanDescriptor bean = validator.getConstraintsForClass( type );
        MethodDescriptor methodDescriptor = bean.getConstraintsForMethod( method.getName(), method.getParameterTypes() );
        if ( methodDescriptor != null ) {
            return methodDescriptor.findConstraints().declaredOn( ElementType.PARAMETER ).hasConstraints();
        }
        else {
            return false;
        }
    }

But it's not 100% in line with the `findConstraints()` API: it should only return constraints
that are on the element. Plus what is returned by the API is 
`ConstraintDescriptor` which cannot differentiate where it comes from (parameter or method).

## Implementation notes

Specify that `ElementDescriptor.hasConstraints()` does not return true for a `MethodDescriptor`
when:

- method parameters are constrained
- cross-parameter constraints are declared on the method
[jira]: https://hibernate.onjira.com/browse/BVAL-274
