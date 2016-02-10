---
title: Bean Validation 1.1 goals
layout: default
author: Emmanuel Bernard
---

The expert group and the community focused on a few key goals as well as smaller issues.

- [Main goals](#goals)
  - [Openness](#openness)
  - [Dependency injection and CDI](#dependency-injection)
  - [Method validation](#method-validation)
  - [Group conversion](#group-conversion)
  - [Message interpolation using EL](#message-interpolation)
  - [Integration with other specifications](#integration)
- [Detailed changelog](#changelog)

## Main goals <a id="goals"></a>

### Openness <a id="openness"></a>

All of Bean Validation 1.1 work has been done in the open and in an open source
way. Source code for the
[API](https://github.com/beanvalidation/beanvalidation-api/), [reference
implementation](https://github.com/hibernate/hibernate-validator/), [test
compatibility kit](https://github.com/beanvalidation/beanvalidation-tck/) as
well as the
[specification](https://github.com/beanvalidation/beanvalidation-spec/) and the
[website sources](https://github.com/beanvalidation/beanvalidation.org/) are
available in the open.  All discussions are done in the open in the publicly
available development mailing list. Road map and proposals are also published
on the website.

In short, everything is available at <http://beanvalidation.org>.

### Dependency injection and CDI integration <a id="dependency-injection"></a>

Bean Validation uses a few components: `MessageInterpolator`, `TraversableResolver`,
`ParameterNameProvider`, `ConstraintValidatorFactory` and `ConstraintValidator`. We
have standardized how these objects are managed by a container and how these
objects can benefit from container services. In particular, CDI support within
Java EE is defined. Note that CDI integration also encompasses support for method
validation.

An example of the most common use case is using CDI injection in constraint validator
implementations:

    class ZipCodeValidator implements ConstraintValidator<ZipCode, String> {

        @Inject @France
        private ZipCodeChecker checker;

        public void initialize(ZipCode zipCode) {}

        public boolean isValid(String value, ConstraintValidationContext context) {
            if (value==null) return true;
            return checker.isZipCodeValid(value);
        }
    }

### Method validation <a id="method-validation"></a>

Bean Validation 1.1 allows to apply constraints on parameters and return
values of methods and constructors. That way the Bean Validation API
can be used to describe and validate the contract applying to a given method or
constructor, that is:

- the preconditions that must be met by the caller before the method or
  constructor may be invoked and
- the postconditions that are guaranteed to the caller after a method or
  constructor invocation returns.

This enables a programming style known as "Programming by Contract" (PbC).
Compared to traditional means of checking the sanity of argument and return
values this approach has several advantages:

- These checks are expressed declaratively and don't have to be performed
  manually, which results in less code to write, read and maintain.
- The pre- and postconditions applying for a method or constructor don't have
  to be expressed again in the documentation, since any of its annotations will
  automatically be included in the generated JavaDoc. This reduces redundancies,
  thus avoiding efforts and inconsistencies between implementation and
  documentation.

Here is an example:

    @RequestScope class Client {
        @Inject AccountService service;
        public void createClient() { service.createUser(...); }
    }

    @Dependent class AccountService {
        public User createUser(
                @NotEmpty String username,
                String firstname,
                String lastname,
                @NotNull @Email String email,
                @Past Date birthDate) {
            // parameters are automatically validated and an exception
            // is raised upon failure
            // Method code focuses on the business logic
        }
    }


### Group conversion <a id="group-conversion"></a>

The specification offers a way to alter the targeted group when validation
cascading is happening. This feature is particularly useful to reuse a given
object (graph) and to avoid leaking groups between various object subgraphs. It
also makes for more readable constraints.

    public class User {
        @Email String email;
        @Strength(group=Complete.class)
        String password;
        @Valid
        @ConvertGroup.List( {
            @ConvertGroup(from=Default.class, to=BasicPostal.class),
            @ConvertGroup(from=Complete.class, to=FullPostal.class)
        } )
        Address homeAddress;
    }

    class Address {
        @NotNull(group=BasicPostal.class) String street1;
         String street2;
         @ZipCode(group=BasicPostal.class)
         String zipCode;
         @CodeChecker(group=FullPostal.class)
         String doorCode;
    }

### Message interpolation via the unified expression language <a id="message-interpolation"></a>

Constraint violation messages can now use EL expressions for a much more
flexible rendering and string formatting. In particular a formatter object is
injected in the EL context to convert numbers, dates etc. into the locale
specific string representation. Likewise, the validated value is also available
in the EL context.

    javax.validation.constraints.DecimalMax.message=\
        must be less than ${inclusive == true ? 'or equal to ' : ''}{value}

### Integration with other specifications <a id="integration"></a>

A lot of the work produced is not in this specification but in others. In
particular, validation of JAX-RS components is supported and reuses the Bean
Validation method validation.

## Detailed changelog <a id="changelog"></a>

This list shows a detailed set of changes done in the specification. It does not
cover everything (check the changelog appendix in the spec for this) but shows a
detailed and feature centric view. It also references the issue ticket as well as
the design discussions.


| Issue Id (JIRA)                                           | Done | Proposal | Description |
| --------------------------------------------------------- | ---- | -------- | --------------------------- |
| [BVAL-241](https://hibernate.onjira.com/browse/BVAL-241)  | ![](/images/completed.png) |  [241](/proposals/BVAL-241) | Method level validation
| [BVAL-272](https://hibernate.onjira.com/browse/BVAL-272)  | ![](/images/completed.png) |  | Close remaining loops in method validation support
| [BVAL-232](https://hibernate.onjira.com/browse/BVAL-232)  | ![](/images/completed.png) | [232](/proposals/BVAL-232) | Solve cross-parameter validation
| [BVAL-274](https://hibernate.onjira.com/browse/BVAL-274)  | ![](/images/completed.png) | [274](/proposals/BVAL-274) | Extend the meta-data API with required convenience methods for method validation
|                                                           | ![](/images/completed.png) |  | Should method validation methods be defined on j.v.Validator or a dedicated new interface?
| [BVAL-306](https://hibernate.onjira.com/browse/BVAL-306)  | ![](/images/completed.png) |  | Clarify interceptor order in method validation triggering
| [BVAL-314](https://hibernate.onjira.com/browse/BVAL-314)  | ![](/images/completed.png) | [314](/proposals/BVAL-314/) | Provide ability to disable validation for method/constructor
| [BVAL-238](https://hibernate.onjira.com/browse/BVAL-238)  | ![](/images/completed.png) | [238](/proposals/BVAL-238)  | Support for container injection in ConstraintValidator
|                                                           | ![](/images/completed.png) |  | Discuss and clarify vf.close() and the usage expectation (ie when to close a VF)
|                                                           | ![](/images/completed.png) |  | Bring back interaction descriptions with Java EE and CDI in the Bean Validation specification
| [BVAL-307](https://hibernate.onjira.com/browse/BVAL-307)  | ![](/images/completed.png) |  | Decide how CDI and Bean Validation is integrated
| [BVAL-265](https://hibernate.onjira.com/browse/BVAL-265)  | ![](/images/completed.png) | [265](/proposals/BVAL-265) | Expose settings defined in XML in the Configuration API
| [BVAL-293](https://hibernate.onjira.com/browse/BVAL-293)  | ![](/images/completed.png) |  | Finish renaming of `ConfigurationSource`
| [BVAL-226](https://hibernate.onjira.com/browse/BVAL-226)  | ![](/images/completed.png) |  | Clarify whether the static or the runtime type should be considered when creating property paths in case of cascaded validations
| [BVAL-221](https://hibernate.onjira.com/browse/BVAL-221)  | ![](/images/completed.png) | [221](/proposals/BVAL-221) | The constraint violation builder cannot put constraint on a top level map key
| [BVAL-208](https://hibernate.onjira.com/browse/BVAL-208)  | ![](/images/completed.png) | [208](/proposals/BVAL-208) | Support groups translation when cascading operations (hosted on @Valid or not)
| [BVAL-259](https://hibernate.onjira.com/browse/BVAL-259)  | ![](/images/completed.png) | [259](/proposals/BVAL-259) | Stop validation of composed constraints at first failing constraint
| [BVAL-327](https://hibernate.onjira.com/browse/BVAL-327)  | ![](/images/completed.png) | [327](/proposals/BVAL-327) | Discuss whether or not getter should be considered constrained methods
| [BVAL-259](https://hibernate.onjira.com/browse/BVAL-259)  | ![](/images/completed.png) | | Enforce in the spec that @ReportAsSingleViolation does apply validators once one is reporting a failure
| [BVAL-219](https://hibernate.onjira.com/browse/BVAL-219)  | ![](/images/completed.png) |  | Consider interpolating the value in error messages
| [BVAL-223](https://hibernate.onjira.com/browse/BVAL-223)  | ![](/images/completed.png)  |  | Add formatter syntax for interpolated messages
| [BVAL-198](https://hibernate.onjira.com/browse/BVAL-198)  | ![](/images/completed.png) |  | Simplify creation of ConstraintViolationExceptions
| [BVAL-192](https://hibernate.onjira.com/browse/BVAL-192)  | ![](/images/completed.png) |  | Add 'exclusive' boolean attribute to @DecimalMin/@DecimalMax constraints
| [BVAL-230](https://hibernate.onjira.com/browse/BVAL-230)  | ![](/images/completed.png) |  | Add support for validating CharSequence types instead of just Strings
| [BVAL-249](https://hibernate.onjira.com/browse/BVAL-249)  | ![](/images/completed.png) |  | Add unwrap method to ConstraintValidatorContext for provider extension
| [BVAL-282](https://hibernate.onjira.com/browse/BVAL-282)  | ![](/images/completed.png) |  | Make clear whether it's legal to invoke Configuration#buildValidatorFactory() several times
| [BVAL-191](https://hibernate.onjira.com/browse/BVAL-191)  | ![](/images/completed.png) |  | Introduce a addEntityNode() method to the fluent node builder API
| [BVAL-304](https://hibernate.onjira.com/browse/BVAL-304)  | ![](/images/completed.png) |  | Add OSGi headers in the reference implementation
