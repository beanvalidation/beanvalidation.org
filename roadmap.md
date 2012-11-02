---
title: Bean Validation roadmap
layout: default
author: Emmanuel Bernard
---

# #{page.title}

* [Topics](#topics)
* [Priorities](#priorities)
  * [Must have](#must-have)
  * [Should have](#should-have)
  * [Nice to have](#nice-to-have)
  * [Next version](#next)

***

Bean Validation standardizes constraint definition, declaration and validation for the Java platform. Its first incarnation has been widely popular amongst the Java community in both SE and EE environments.

Being a version 1.0, Bean Validation stayed on the conservative side feature wise. The community has expressed interest in additional features to enhance the work done in the first version of the specification.

***

## Topics <a id="topics"></a>

The work of the Expert Group will be around the following main topics:

* Integration with other JSRs   
 While not part of the Bean Validation specification per se, we want to pursue further collaborative work with some other JSR leads on how to integrate Bean Validation into the various lifecycles of the SE/EE platforms. The work we did with JPA 2 and JSF 2 showed that it is possible and beneficial for the platform and developers.   
 These following propositions and starting points that will be run by the various expert groups. Based on these discussions, the Bean Validation expert group will adjust or add new features to the core of the Bean Validation specification as deemed necessary to achieve a successful integration. The Bean Validation expert group will also try and achieve consistent validation declaration and usage across the various specifications it integrates with to ensure Java SE/EE coherence.  
 
    * JAX-RS: call Bean Validation upon HTTP method calls on parameters and return values.
    * JAXB: some people have asked for integration between Bean Validation and JAXB. Basically, the Bean Validation constraints (at least the fundamental ones) could be converted into the XML schema descriptor (and vice versa) to guarantee a unified propagation between the Java land and the XML land.
    * JPA: improve the integration by letting Bean Validation constraints influence the DDL generated with the constraints declared on the entity model.
    * CDI: offer a way for Bean Validation pluggable components to allow CDI style injection (in particular constraint validator implementations).
    * CDI: integrate method-level validation (see below).
    * EJB: integrate method-level validation (see below) - eg. validation of parameters and results of EJB business method calls.
    * JSF: In addition to property-level constraints class-level constraints should be supported, offer support for client side validation based on Java side constraints (offered today by some JSF libraries).    
    
* Method level validation   
 Offer APIs to validate parameters and return values of method calls. These APIs would be used by any injection or AOP framework around method invocations. If a constraint violation is detected, an exception (eg. ConstraintViolationException) would be raised.
* @Valid and group propagation   
 Ability to translate a group into another group while cascading the validation. This can help reduce the number of groups and increase reuse.
* Constraint composition   
 Extend the model to support both AND and OR style composition
* Clarification of ambiguities found in Bean Validation 1.0
* Better alignment with modular environments
* Exclusion flag on @BigDecimal / @BigInteger   
 In Bean Validation 1.0, boundaries are included by default and it is not possible to declare a boundary as excluded from the valid values
* ConstraintViolationException builder   
 Today Bean Validation clients need to assemble `ConstraintViolationException`s by hand.
* Conversion from persistence storage exception to Bean Validation exception
* Validate an object graph assuming a list of changes to be applied
* Separate the notion of MessageResolver and MessageInterpolator
* Consider interpolating the invalid value in error messages
* Offer stereotypes to skip validation on empty or null
* Apply constraints on the elements of an iterator
* Add formatter syntax for interpolated messages
* Provide a way for accessing default implementations for XML configured bootstrap artifacts
* Programmatic API to declare constraints (as opposed to annotations today)   


Note that this list is not exhaustive but gives a good representation. Additional feature requests are available in Bean Validation's [issue tracker](/issues).   
The goal of the Expert Group will be to assess these issues, prioritize them as well as identify and pursue directions for enhancement of the overall programming model and facilities of Bean Validation.

***

## Priorities <a id="priorities"></a>

Priorities are constantly evolving but the expert group as of today has the following priorities.

### Must have  <a id="must-have"></a>

| Issue Id                                                  | Description                                        | Proposal                            | Completed |
| --------------------------------------------------------- | -------------------------------------------------- | ----------------------------------- | --------: |
| [BVAL-241](https://hibernate.onjira.com/browse/BVAL-241)  | Method level validation                            | [241](/proposals/BVAL-241) | ![](/images/completed.png)
| [BVAL-272](https://hibernate.onjira.com/browse/BVAL-272)  | Close remaining loops in method validation support |                                     |
| [BVAL-232](https://hibernate.onjira.com/browse/BVAL-232)  | Solve cross-parameter validation                   | [232](/proposals/BVAL-232) | ![](/images/completed.png)
| [BVAL-274](https://hibernate.onjira.com/browse/BVAL-274)  | Extend the meta-data API with required convenience methods for method validation | [274](/proposals/BVAL-274) | ![](/images/completed.png)
|                                                           | Should method validation methods be defined on j.v.Validator or a dedicated new interface? | |  
| [BVAL-306](https://hibernate.onjira.com/browse/BVAL-306)  | Clarify interceptor order in method validation triggering | | ![](/images/completed.png)
| [BVAL-314](https://hibernate.onjira.com/browse/BVAL-314)  | Provide ability to disable validation and customize groups for method/constructor validation | [314](/proposals/BVAL-314/) | 
| [BVAL-238](https://hibernate.onjira.com/browse/BVAL-238)  | Support for container injection in ConstraintValidator | [238](/proposals/BVAL-238) | ![](/images/completed.png) 
|                                                           | Discuss and clarify vf.close() and the usage expectation (ie when to close a VF) | | 
|                                                           | Bring back interaction descriptions with Java EE and CDI in the Bean Validation specification |  
| [BVAL-307](https://hibernate.onjira.com/browse/BVAL-307)  | Decide how CDI and Bean Validation is integrated   |                                      | ![](/images/completed.png)
| [BVAL-265](https://hibernate.onjira.com/browse/BVAL-265)  | Expose settings defined in XML in the Configuration API | [265](/proposals/BVAL-265) |  ![](/images/completed.png) 
| [BVAL-293](https://hibernate.onjira.com/browse/BVAL-293)  | Finish renaming of `ConfigurationSource`           |                                      | ![](/images/completed.png)
| [BVAL-226](https://hibernate.onjira.com/browse/BVAL-226)  | Clarify whether the static or the runtime type should be considered when creating property paths in case of cascaded validations | | ![](/images/completed.png)
| [BVAL-221](https://hibernate.onjira.com/browse/BVAL-221)  | The constraint violation builder cannot put constraint on a top level map key | [221](/proposals/BVAL-221) |
| [BVAL-210](https://hibernate.onjira.com/browse/BVAL-210)  | Make sure JTA / Java EE plays well with Bean Validation + JPA when exceptions occurs (at least raise the concern upstairs ;) ) | |
| [BVAL-208](https://hibernate.onjira.com/browse/BVAL-208)  | Support groups translation when cascading operations (hosted on @Valid or not) | [208](/proposals/BVAL-208) | ![](/images/completed.png)
| [BVAL-248](https://hibernate.onjira.com/browse/BVAL-248)  | Introduce an evalutation order for constraints on a single property | [248](/proposals/BVAL-248) |
| [BVAL-259](https://hibernate.onjira.com/browse/BVAL-259)  | Stop validation of composed constraints at first failing constraint | [259](/proposals/BVAL-259) | ![](/images/completed.png)
| [BVAL-268](https://hibernate.onjira.com/browse/BVAL-268)  | Align with the EE platform on where to find validation.xml | |

### Should have <a id="should-have"></a>

| Issue Id                                                  | Description                                        | Proposal                            | Completed |
| --------------------------------------------------------- | -------------------------------------------------- | ----------------------------------- | --------: |
| [BVAL-259](https://hibernate.onjira.com/browse/BVAL-259)  | Enforce in the spec that @ReportAsSingleViolation does apply validators once one is reporting a failure ||![](/images/completed.png)
| [BVAL-220](https://hibernate.onjira.com/browse/BVAL-220)  | Offer stereotypes to skip validation on empty or null ||
| [BVAL-240](https://hibernate.onjira.com/browse/BVAL-240)  | Revisit cross-field validation ||
| [BVAL-225](https://hibernate.onjira.com/browse/BVAL-225)  | Propose ability to provide default resource bundles (for a constraint definition provider) ||
| [BVAL-219](https://hibernate.onjira.com/browse/BVAL-219)  | Consider interpolating the value in error messages ||
| [BVAL-223](https://hibernate.onjira.com/browse/BVAL-223)  | Add formatter syntax for interpolated messages ||
| [BVAL-216](https://hibernate.onjira.com/browse/BVAL-216)  | Work with the JAXB EG to have a nice Bean Validation integration ||
| [BVAL-214](https://hibernate.onjira.com/browse/BVAL-214)  | Ability to validate an object and a list of changes ||
| [BVAL-199](https://hibernate.onjira.com/browse/BVAL-199)  | Offer helper classes to build ConstraintViolationExceptions (and potentially raise them) ||
| [BVAL-198](https://hibernate.onjira.com/browse/BVAL-198)  | Simplify creation of ConstraintViolationExceptions ||
| [BVAL-192](https://hibernate.onjira.com/browse/BVAL-192)  | Add 'exclusive' boolean attribute to @DecimalMin/@DecimalMax constraints ||
| [BVAL-230](https://hibernate.onjira.com/browse/BVAL-230)  | Add support for validating CharSequence types instead of just Strings || ![](/images/completed.png)
| [BVAL-217](https://hibernate.onjira.com/browse/BVAL-217)  | Seperate the notion of message resolver vs message interpolator ||
| [BVAL-249](https://hibernate.onjira.com/browse/BVAL-249)  | Add unwrap method to ConstraintValidatorContext for provider extension ||
| [BVAL-252](https://hibernate.onjira.com/browse/BVAL-252)  | Improve support for the creation of constraint libraries ||
| [BVAL-251](https://hibernate.onjira.com/browse/BVAL-251)  | Improve Bean Validation support for modularized environments ||
| [BVAL-282](https://hibernate.onjira.com/browse/BVAL-282)  | Make clear whether it's legal to invoke Configuration#buildValidatorFactory() several times || ![](/images/completed.png)

### Nice to have <a id="nice-to-have"></a>

| Issue Id                                                  | Description                                        | Proposal                            | Completed |
| --------------------------------------------------------- | -------------------------------------------------- | ----------------------------------- | --------: |
| [BVAL-235](https://hibernate.onjira.com/browse/BVAL-235)  |Support parameterized payload attributes (additional string param on @Payload) || 
| [BVAL-233](https://hibernate.onjira.com/browse/BVAL-233)  | Provide access to contextual info during message interpolation ||
| [BVAL-229](https://hibernate.onjira.com/browse/BVAL-229)  | Offer a programmatic API to declare constraints on a domain model ||
| [BVAL-222](https://hibernate.onjira.com/browse/BVAL-222)  | Add a ALL group to validate all groups instead of DEFAULT or the selected ones ||
| [BVAL-215](https://hibernate.onjira.com/browse/BVAL-215)  | Make composition more flexible (OR support) ||
| [BVAL-213](https://hibernate.onjira.com/browse/BVAL-213)  | Convert persistence storage exception into Bean Validation exceptions ||
| [BVAL-202](https://hibernate.onjira.com/browse/BVAL-202)  | Apply constraints on the elements of an iterator ||
| [BVAL-191](https://hibernate.onjira.com/browse/BVAL-191)  | Introduce a addEntityNode() method to the fluent node builder API ||
| [BVAL-211](https://hibernate.onjira.com/browse/BVAL-211)  | Consider making javax.validation.ValidatorContext a self-referential generic type ||
| [BVAL-237](https://hibernate.onjira.com/browse/BVAL-237)  | Expose validated bean via ConstraintValidatorContext ||
| [BVAL-304](https://hibernate.onjira.com/browse/BVAL-304)  | Add OSGi headers in the reference implementation ||

### Discuss with JPA's expert group

| Issue Id                                                  | Description                                        | Proposal                            | Completed |
| --------------------------------------------------------- | -------------------------------------------------- | ----------------------------------- | --------: |
| [BVAL-234](https://hibernate.onjira.com/browse/BVAL-234)  | Ignore @NotNull on JPA's @GeneratedValue properties for pre-persist operations | [234](/proposals/BVAL-234) |

### Next revision  <a id="next"></a>
-
