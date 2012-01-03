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

### Should we specify the lifecycle of `ConstraintValidator` instances?

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

#### Option 1: Add a Method to inject the BeanManager instance on Bean Validation bootstrap sequence

One approach would be to let the container set a `BeanManager` instance

    ValidatorFactory factory = Validation
        .byDefaultProvider()
        .configure()
            .cdiBeanManager(beanManager)
         .buildValidatorFactory();

However that would add a hard dependency between CDI and Bean Validation which is probably not welcomed.

An alternative is to use an untyped version (which should probably be favored):


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


- have an untyped version of the above proposal
- offer a generic `Map<String,Object> addObject(String key, Object value)` method on `Configuration`

#### Option 2: Use CDI facility to retrive the current `BeanManager`

CDI exposes `BeanManager` via JNDI in EE, we could use it.

Also CDI 1.1 offers programmatic lookup via the CDI class, see EDR1 spec for details. 
<http://docs.jboss.org/cdi/spec/1.1.EDR1/html/spi.html#provider>

#### Option 3: Ask CDI to inject a CDI aware `ConstraintValidatorFactory` when creating the `ValidatorFactory` object

Another idea would be to integrate BV/CDI via a CDI-aware `ConstraintValidatorFactory` to be provided by CDI runtimes:

    ValidatorFactory factory = Validation
        .byDefaultProvider()
        .configure()
            .constraintValidatorFactory( new CdiAwareConstraintValidatorFactory( beanManager ) )
        .buildValidatorFactory();
 
That way the integration is completely managed by the CDI-side. `Validator` and `ValidatorFactory` are already 
built-in beans in CDI so this wouldn't add much complexity. 
The CDI runtime would use this factory whenever a `Validator` or `ValidatorFactory` is retrieved.

#### Option 4: Add a method accepting an `InstanceProvider` implementation in Bean Validation's bootstrap

    ValidatorFactory factory = Validation
        .byDefaultProvider()
        .configure()
            .instanceProvider(cdiInstanceProvider)
         .buildValidatorFactory();

    public interface InstanceProvider {
        public <T> T createInstance(Class<T> type);
        public destroyInstance(Object instance);
    }

The default implementation can be the no-arg constructor we have today. We can either ask CDI to 
provide a `CDIInstanceProvider` at `ValidatorFactory` creation like in option 3 or make it the
default implementation if CDI is present according to option 2.

This option works fine as long as we don't require more complex object creation logic.

#### Which option?

Option 1 has many drawbacks and should be avoided.

Option 2 is the easiest solution but puts CDI above other DI technologies. This is not bad per se but that's a point.

Option 3 is quite elegant as most of the time CDI is responsible for the lifecycle of `ValidatorFactory` and can
interject in the bootstrap process. When `ValidatorFactory` is created manually, we can ask the user to use a
provider specific `CdiAwareConstraintValidatorFactory`.

My main concern with option 3 is whether or not we (will) need access to CDI's `BeanManager` to handle the
lifecycle of other objects in the Bean Validation universe. 
`MessageInterpolator` and `TraversableResolver` could also benefit from CDI. 
Note that these examples do not create objects, they are objects.

Option 4 tries to address the shortcomings of option 3 provided we keep the simple
object creation logic. It has my preference so far.

#### How would injection of `MessageInterpolator` and `TraversableResolver` be solved?

If instances are provided, we could still let CDI do setter-style `inject()`ion. constructor injection won't work.
But it seems to me it's preferable to *not* do any injection on provided instances.

We should however let people provide `MessageInterpolator` and `TraversableResolver` implementation classes
that will be used to ask for a CDI bean instance (like `ConstraintValidator` are resolved).

Suggestions?

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