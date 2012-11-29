---
title: Determine whether or not getters should be considered when validating methods on interception
layout: default
author: Emmanuel Bernard
comments: true
---

# #{page.title}

[Link to JIRA ticket][jira]  

## Problem

Getters are the vehicle for properties which are handled in Bean Validation 1.0.
Should we also consider getter calls as regular methods. There are pros and cons for 
both approaches. Let's list them

## Pros

A getter is a method: for the sake of consistency and least surprise, we should
consider getters when methods are validated.

Action methods starting with `get` would be considered getters and excluded from
method validation.

Components subject to method validation (CDI components) are typically not the ones
hosting properties - though see below in cons.

## Cons

Applications with existing constrained properties might fail due to validation happening
at previously unexpected times (ie when getters are called).

Most `getProperty` / `isProperty` methods are getters 80%/20% rule.

While the problem might not be acute for CDI and its currently limited interception
capabilities, technologies like AspectJ will intercept and validate getters in
a much broader area.

Also, there are some thinking about making JPA entities actual CDI beans in which
case all getter calls could be intercepted. This is coming from the rich entity camp.
While not considered for EE 7, that might very well come in the future.

## Customization mechanisms

Because the choice is not clear, the consensus is that some customization 
mechanism should be available, either:

- as proprietary extensions
- as spec defined

Due to the usefulness and the usage impact with other specification integrations
I think we should standardize it in the specification.

### Assuming getters are not considered methods to be validated by default

We could offer the following options:

- a global flag to enable getter validation  
  I fail to see the use case ATM, idea?
- a per method or per class flag `@ValidateOnCall(GETTER)`  
  that would require to define class inheritance rules on this annotation
  as well as method inheritance

### Assuming getters are considered methods to be validated by default

We could offer the following options:

- a global flag to disable getter validation  
  we would use a global flag to disable JPA entity getter validations for example
- a per method or per class flag `@ValidateOnCall(GETTER)`  
  that would require to define class inheritance rules on this annotation
  as well as method inheritance

### Assuming method validation has to be activated

We could envision to force all components expecting method validation to be
annotated either at the method or class level.

    @ValidateOnCall({GETTERS, METHODS})
    public class AddressService {
        public void addAddress(
            @NotNull @Valid User user, @Valid @NotNull Address address) {
            ...
        }
    }

That would require to define class inheritance rules on this annotation
as well as method inheritance.

If we go that way, we might even imagine more features down the road like
`@ValidateOnCall(OBJECT)` to validate the whole object upon specific
method calls.
That would make the JAX-RS integration more "standard" but would force
people to explicitly mark components that ought to be method constrained
which we agreed was not the best outcome:

- verboseness - constraints declared and metadata annotation used
- easy to forget

### Against @ValidateOnCall

Gunnar is on the side of not introducing `@ValidateOnCall` as it can be simulated
by groups:

    public static class Foo {
    
       //doesn't get validated during method validation of Default group
       @NotNull(groups=AllConstraints.class)
       private String getBar() { ... }
    
       //does get validated during method validation
       @NotNull
       private String getBaz() { ... }
    }
    
    //use this e.g. to validate upon entity persisting
    public interface AllConstraints extends Default {}

My problem with this approach is its verboseness and the fact that
teams might want to preemptively use this verbose pattern "just in
case".

[jira]: https://hibernate.onjira.com/browse/BVAL-327
