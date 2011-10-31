---
title: Support for container injection in ConstraintValidator
layout: default
author: Emmanuel Bernard
---

# #{page.title}

[Link to JIRA ticket](https://hibernate.onjira.com/browse/BVAL-238)

## Goal

Provide CDI injection to `ConstraintValidator` implementations.


## Lifecycle

When CDI integration is active, instantiation as well as destruction of `ConstraintValidator` objects 
must be delegated to the CDI container.

Integration should use CDI's BeanManager SPI to obtain non-contextual instances of `ConstratintValidator` onjects.
Usage of the SPI is described at <http://seamframework.org/Documentation/HowDoIDoNoncontextualInjectionForAThirdpartyFramework>

The Bean Validation provider is free to instantiate and destroy `ConstraintValidator` objects at the time of its choosing.
(See open questions).

## Open questions

### Should this be the default behavior and disabled when a custom `ConstraintValidatorFactory` is provided?

The natural integration point is `ConstraintValidatorFactory`. If a custom `ConstraintValidatorFactory`
is provided, it would be hard or impossible to honor CDI behavior as it would have to be done
**after** the factory has created the object.

In OVal, injection is done after object instantiation. Spring Framework offer an inject method. 
Does CDI offer / wants to offer such option?

> The same class mentioned above for CDI instatiation can be used to inject an existing instance. Just skip the call to
> `produce()` and call `inject()`.
>
> Pete Muir, 27 October 2011

Temporary answer is: yes

### Should we specify the lifecycle of `ConstraintValidator` instance?

Today the life cycle of `ConstraintValidator` objects is undefined. 

Should this be defined when CDI integration is activated to always retrieve a 
`ConstraintValidator` instance from CDI right before it is used?
Or should we leave Bean Validation providers free to call CDI for
object instantiation when it pleases?

I'm tempted to believe we should leave it undefined. CDI components
can get injections from more restrictive scopes. For example, this would allow
`ConstraintValidator` instances to get request scoped component injected (eg
to react to some user specific settings). So the time at which `ConstraintValidator`
is requested does not matter much. 


> IMO you should leave it undefined.
>
> Pete Muir, 27 October 2011


### How is CDI `BeanManager` (or equivalent) injected into Bean Validation?

I'm assuming CDI exposes the ability to instantiate and destroy CDI beans via a `BeanManager` interface.

One approach would be to let the container set a `BeanManager` instance

    ValidatorFactory factory = Validation
        .byDefaultProvider()
        .configure()
            .cdiBeanManager(beanManager)
         .buildValidatorFactory();

However that would add a hard dependency between CDI and Bean Validation which is probably not welcomed.

Alternatives are:

- have an untyped version of the above proposal
- offer a generic `Map<String,Object> addObject(String key, Object value)` method on `Configuration`
- make use of a Java EE defined JNDI name to retrieve `BeanManager`


> CDI 1.1 offers programmatic lookup via the CDI class, see EDR1 spec for details. 
<http://docs.jboss.org/cdi/spec/1.1.EDR1/html/spi.html#provider>
>
> Pete Muir, 27 October 2011


I would favor either untyped version with a specific method or with a generic placeholder for a few reasons:

- hard dependency on CDI API is problematic
- JNDI's approach only work in Java EE whereas we could imagine the untyped 
  version working in SE as well

I'm undecided on

    ValidatorFactory factory = Validation
        .byDefaultProvider()
        .configure()
            // T cdiBeanManager(Object beanManager) //raises an exception if that's not a BeanManager
            .cdiBeanManager(beanManager) 
         .buildValidatorFactory();


vs

    ValidatorFactory factory = Validation
        .byDefaultProvider()
        .configure()
            //raises an exception if that's not a BeanManager
            .addObject(Validation.CDI_BEAN_MANAGER, beanManager) // T addObject(String key, Objet value) 
         .buildValidatorFactory();

I however feel chagrined that the nicely typed `Configuration` API requires such untyped approach.
(I don't think introducing CdiBeanManagerFactory solves any issue, is that true?).

> This is essentially what the CDI class offers - but is service provider driven
>
> Pete Muir, 27 October 2011

&nbsp;
> Another idea would be to integrate BV/CDI via a CDI-aware `ConstraintValidatorFactory` to be provided by CDI runtimes:

    ValidatorFactory factory = Validation
        .byDefaultProvider()
        .configure()
            .constraintValidatorFactory( new CdiAwareConstraintValidatorFactory( beanManager ) )
        .buildValidatorFactory();
 
> That way the integration is completely managed by the CDI-side. `Validator` and `ValidatorFactory` are already 
> built-in beans in CDI so this wouldn't add much complexity IMO (and we wouldn't have a circular reference between
> the specs). The CDI runtime would use this factory whenever a `Validator` or `ValidatorFactory` is retrieved.
>
> Gunnar Morling, 31 October 2011

### Make sure the interaction contract between Bean Validation and CDI is well defined

Talk to Pete and review discussions between JPA 2.1 and CDI. An example of interaction is defined 
[on this page](http://seamframework.org/Documentation/HowDoIDoNoncontextualInjectionForAThirdpartyFramework).

### Should we expand the `ConstraintValidatorFactory` contract with a destroy method?

That would allow support for more DI solutions.

Note that `ValidatorFactory` does not have a `close()` method unfortunately :( If we want a close hook:

- implementors of v1 won't support v1.1 APIs (acceptable change I'd venture)
- containers compatible with v1.1 should call `close()`
- users should call `close()`, though we cannot mandate it

> Another idea would be to change the contract of ConstraintValidatorFactory and make it completely responsible for 
> the lifecycle of validator instances:

    public interface ConstraintValidatorFactory {
    
        <T extends ConstraintValidator<?,?>> T getInstance(Annotation constraint, Class<T> key);
    
    }

> By passing the constraint the factory would have all required information for creating and initializing validators.
> It could take care for the lifecycle and enforce the constraints required by the programing model (in case of CDI 
> for instance a CDI-aware factory would ensure that no singleton-scoped beans are validators etc.). It could also 
> cache validators per annotation and dispose validators when applicable.
> 
> BV providers must not keep references to validators in order to not interfere with the lifecycle management of the
> factory, i.e. they must invoke getInstance() whenever they need a validator.
>
> Emmanuel raised concerns about this due to tying the `getInstance()` and `initialize()` contracts together.
>
> Gunnar Morling, 31 October 2011

### Should we support JSR @Inject rather than CDI?

There is not equivalent to `BeanManager` in @Inject, so the only approach for this is to write a custom 
`ConstraintValidatorFactory` for each @Inject provider.

My answer to the question would then be no at this stage.

> Agreed, 330 is too undefined.
>
> Pete Muir, 27 October 2011   