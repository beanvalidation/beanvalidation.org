---
title: Support for method validation
layout: default
author: Gunnar Morling
---

# #{page.title}

[Link to JIRA ticket](https://hibernate.onjira.com/browse/BVAL-241)

## Contents

* [Goal](#goal)
* [Declaring method level constraints (to become 3.5?)](#method_level)
    * [Requirements on methods to be validated](#requirements)
    * [Defining parameter constraints](#parameter)
        * [Cross-parameter constraints](#cross_parameter)
        * [Naming parameters](#naming)
    * [Defining return value constraints](#return_value)
    * [Marking parameters and return values for cascaded validation](#cascaded)
    * [Inheritance hierarchies](#inheritance)
        * [Examples](#inheritance_examples)
* [Validating method level constraints](#validating)
    * [Methods for method level validation (to become 4.1.2)](#mfm)
        * [Examples](#validating_examples)
    * [MethodConstraintViolation (to become 4.3)](#method_constraint_violation)
        * [Examples](#mcv_examples)
    * [Triggering validation](#triggering)
* [Extensions to the meta-data API](#meta_data)
    * [BeanDescriptor (5.3)](#bean_descriptor)
    * [MethodDescriptor (to become 5.5)](#method_descriptor)
    * [ConstructorDescriptor (to become 5.6)](#constructor_descriptor)
    * [ParameterDescriptor (to become 5.7)](#parameter_descriptor)
* [Extensions to the XML schema for constraint mappings](#xml)
    * [MethodConstraintViolationException (to become 8.2)](#mcve)
* [Required changes in 1.0 wording](#changes)
* [Misc.](#misc)
    * [Validating invariants](#invariants)
    * [Applying property constraints to setter methods](#setters)
        * [Option 1: A class-level annotation](#class)
        * [Option 2: A property level annotation](#property)
        * [Option 3: An option in the configuration API](#option)
* [Archive](#archive)
    * [Alternative options for inheritance hierarchies](#inheritance_alternatives)
        * [Option 1: Don't allow allow refinement](#no_refinement)
        * [Option 2: allow param (OR style) and return value (AND style) refinement](#parameter_refinement)

## Goal <a name="goal"></a>

As of version 1.1, the Bean Validation API can not only be used for the validation of invariants applying to JavaBeans, but also to validate constraints applying to the parameters and return values of methods of arbitrary Java types. 

That means that the Bean Validation API can be used to describe and validate the contract applying to a given method, that is

* the preconditions that must be met by the method caller before the method may be invoked and
* the postconditions that are guaranteed to the caller after a method invocation returns.

This allows to use the Bean Validation API for a programming style known as "Programming by Contract" (PbC). Note that it is *not* the goal of this specification to develop a fully-fledged PbC solution but rather an easy-to-use facility to fulfill the most common needs related to applying constraints to method parameters and return values based on the proven concepts of the Bean Validation API.

Compared to traditional means of checking the sanity of a method's argument values (within the method implementation) and its return value (by the caller after invoking the method) this approach has several advantages:

* These checks are expressed declaratively and don't have to be performed manually, which results in less code to write, read and maintain.
* The pre- and postconditions applying for a method don't have to be expressed again in the method's JavaDoc, since any of it's annotations will automatically be included in the generated JavaDoc. This means less redundancy which reduces the chance of inconsistencies between implementation and comments.

## Declaring method level constraints (to become 3.5?) <a id="method_level"></a>

Note: In the following, the term "method level constraint" refers to constraints declared on methods as well as constructors.

Method constraints are defined by adding constraint annotations to method or constructor parameters (parameter constraints) or methods (return value constraints). 

As with bean constraints, this can happen using either actual Java annotations or using an XML constraint mapping file (see ...). BV providers are free to provide additional means of defining method constraints such as an API-based aproach.

### Requirements on methods to be validated <a id="requirements"></a>

Methods which shall be annotated with parameter or return value constraints must be non-static. 

There is no restriction with respect to the visibility of validated methods from the perspective of this specification, but it's possible that certain technologies integrating with method validation (see ...) support only the validation of methods with certain visibilities.

### Defining parameter constraints <a id="parameter"></a>
 
Parameter constraints are defined by putting constraint annotations to method or constructor parameters.

Example xy: Declaring parameter constraints

	public class OrderService {

		public OrderService(@NotNull CreditCardProcessor creditCardProcessor) {
			//...
		}

		public void placeOrder(@NotNull @Size(min=3, max=20) String customerCode, @NotNull Item item, @Min(1) int quantity) {
			//...
		}
	}

Here the following preconditions are defined which must be satisfied in order to legally invoke the methods of the `OrderService` class:

* The `CreditCardProcessor` passed to the constructor must not be null.
* The customer code passed to the `placeOrder()` method must not be null and must be between 3 and 20 characters long.
* The `Item` passed to the `placeOrder()` method must not be null.
* The quantity passed to the `placeOrder()` method must be 1 at least.

Note that declaring these constraints does not automatically cause their validation when the concerned methods are invoked. It's the responsibility of an integration layer to trigger the validation of the constraints using a method interceptor, dynamic proxy or similar. See chapter ... for more details.

Tip: In order to use constraint annotations for method parameters, their element type must be `ELEMENTTYPE.METHOD`. All built-in constraints support this element type and it's considered a best practice to do the same for custom constraints also if they are not primarily intended to be used as parameter constraints.

#### Cross-parameter constraints ([BVAL-232](https://hibernate.onjira.com/browse/BVAL-232)) <a id="cross_parameter"></a>

*DISCUSSION: There are several options for implementing cross-parameter constraints. I feel rather unsure about which one to pursue, likely I'd prefer to provide #3 and #4. #2 seems obvious at first but has actually more disadvantages compared to #3.*

##### Option 1: Don't support cross-parameter constraints

* Pro: Wait for actual user demand, let BV providers come up with specific solutions, see what works out best
* Con: Needs BV providers to come up with specific solutions ;-)

##### Option 2: New interface `MethodConstraintValidator`

We could have a new interface `MethodConstraintValidator` which gets the parameters passed as `Object[]` to the `isValid()` method:

	/**
	 * Defines the logic to validate a given cross-parameter method level constraint A.
	 *
	 * @author Gunnar Morling
	 */
	public interface MethodConstraintValidator<A extends Annotation> {

		/**
		 * Initializes the validator in preparation for isValid calls.
		 * The constraint annotation for a given constraint declaration
		 * is passed.
		 * <p/>
		 * This method is guaranteed to be called before any use of this instance for
		 * validation.
		 *
		 * @param constraintAnnotation annotation instance for a given constraint declaration
		 */
		void initialize(A constraintAnnotation);

		/**
		 * Implement the validation logic.
		 * The state of <code>value</code> must not be altered.
		 *
		 * This method can be accessed concurrently, thread-safety must be ensured
		 * by the implementation.
		 *
		 * @param parameterValues The parameter values to be validated.
		 * @param context context in which the constraint is evaluated
		 *
		 * @return false if <code>value</code> does not pass the constraint
		 */
		boolean isValid(Object[] parameterValues, ConstraintValidatorContext context);
	}

Example:

	public class ReservationService {

		@DateParameterCheck
		void bookHotel(@NotNull Customer customer, @NotNull Date from, @NotNull Date to) {
			//...
		}
	}

	public class DateParameterCheckValidator implements MethodConstraintValidator<DateParameterCheck> {

		@Override
		public void initialize(DateParameterCheck constraint) {}

		@Override
		public boolean isValid(Object[] parameterValues, ConstraintValidatorContext context) {
			if(parameterValues[1] == null || parameterValues[2] == null) {
				return true;
			}

			return ((Date)parameterValues[1]).before((Date)parameterValues[2]);
		}
}

* Pro: Rathers straight-forward
* Con: Not that type-safe: Fiddling with object array, casts etc. required. How to avoid using constraints at methods with wrong signature? This will just fail upon invoking `isValid()`.

##### Option 3: Invoke validator methods by signature matching

Instead of having a static `isValid()` method, one could be invoked by signature matching. We would have an initialization contract:

	public interface Initializable<A extends Annotation> {

		void initialize(A constraintAnnotation);

	}

Validator implementations must define a matching `isValid()` method per supported signature:

	public class ReservationService {

		@DateParameterCheck
		void bookHotel(@NotNull Customer customer, @NotNull Date from, @NotNull Date to) {
			//...
		}

		@DateParameterCheck //from must be before to AND alternativeTo
		void bookHotel(@NotNull Customer customer, @NotNull Date from, @NotNull Date to, @NotNull Date alternativeTo) {
			//...
		}
	}

	public class DateParameterCheckValidator implements Initializable<DateParameterCheck> {

		@Override
		public void initialize(DateParameterCheck constraint) {}

		public boolean isValid(Customer customer, Date from, Date to, ConstraintValidatorContext context) {
			if(from == null || to == null) {
				return true;
			}
			return from.before(to);
		}

		public boolean isValid(Customer customer, Date from, Date to, Date alternativeTo, ConstraintValidatorContext context) {
			if(from == null || to == null || alternativeTo == null) {
				return true;
			}
			return from.before(to) && from.before(alternativeTo);
		}
	}

* Pro: Implementation of validators much simpler to write and read (no casts required)
* Pro: Allows BV providers to check for matching validators and fail if none exists (exception raised by BV and NOT in validator)
* Con: `isValid()` method can't be defined in validator interface
* Con: Not refactoring safe (changing signatures), but option #2 isn't as well)

##### Option 4: Have a script based approach:

We might define a special script based constraint:

	public class ReservationService {

		@ParameterAssert(script="arg1.before(arg2)", lang="javascript")
		void bookHotel(@NotNull Customer customer, @NotNull Date from, @NotNull Date to) {
			//...
		}
	}

* Pro: Good to read and write
* Con: Not type safe

Parameter names would be retrieved via the `ParameterNameProvider` (see next section).

Probably basic constraints (`@NotNull` etc.) should be checked beforehand in order to allow for concise script expressions without redundant null checks.

##### Option 4b: Script based asserts next to parameters

	public class ReservationService {

		void bookHotel(
			@NotNull Customer customer,
			@NotNull Date from,
			@NotNull @Assert(script="_param.after(arg1)", lang="javascript") Date to) {
			//...
		}
	}

* Pro: Script is given where it is used as constraint
* Con: Reads bad for longer expressions?
* Con: Asymmetric to class-level constraints

##### Option 5: Have parametrized interfaces `MethodConstraintValidatorN` for N method parameters:

	public interface MethodConstraintValidator3<A extends Annotation, T1, T2, T3> {

		void initialize(A constraintAnnotation);

		boolean isValid(T1 parameter1, T2 parameter2, T3 parameter3, ConstraintValidatorContext context);
	}

	public class DateParameterCheckValidator implements MethodConstraintValidator3<DateParameterCheck, Customer, Date, Date> {

		@Override
		public void initialize(DateParameterCheck constraint) {}

		public boolean isValid(Customer customer, Date from, Date to, ConstraintValidatorContext context) {
			if(from == null || to == null) {
				return true;
			}
			return from.before(to);
		}
	}

* Pro: type safe
* Con: doesn't scale well, feels akward

#### Naming parameters <a id="naming"></a>

If the validation of a parameter constraint fails the concerned parameter needs to be identified in the resulting `MethodConstraintViolation` (see ...).

Java doesn't provide a portable way to retrieve parameter names. Bean Validation therefore defines the `ParameterNameProvider` API to which the retrieval of parameter names is delegated:

	public interface ParameterNameProvider {

		String[] getParameterNames(Constructor< ? > constructor) throws ValidationException;

		String[] getParameterNames(Method method) throws ValidationException;
	}

A conforming BV implementation provides a default `ParameterNameProvider` implementation which returns parameter names in the form `arg<PARAMETER_INDEX>`, where `PARAMETER_INDEX` starts at 0 for the first parameter, e.g. `arg0`, `arg1` etc.

BV providers are free to provide additional implementations (e.g. based on annotations specifying parameter names, debug symbols etc.). If a user wishes to use another parameter name provider than the default implementation, she may specify the provider to use with help of the bootstrap API (see ...) or the XML configuration (see ...).

TODO: Add options to bootstrap API and XML schema

### Defining return value constraints <a id="return_value"></a>

Return value constraints are defined by putting constraint annotations directly to the method itself.

Example xy: Declaring return value constraints

	public class OrderService {

		@NotNull
		@Size(min=1)
		public Set<CreditCardProcessor> getCreditCardProcessors() {
			//...
		}

		@NotNull
		@Future
		public Date getNextAvailableDeliveryDate() {
			//...
		}
	}

Here the following postconditions are defined which are guaranteed to the caller of the methods of the `OrderService` class:

* The set of `CreditCardProcessor` objects returned by `getCreditCardProcessors()` will neither be null nor empty.

* The `Date` object returned by `getNextAvailableDeliveryDate()` will not be null and be in the future.

As with parameter constraints, these return value constraints are not automatically validated upon method invocation but instead an integration layer invoking the validation is required.

*DISCUSSION: Should property constraints (on getter methods) also be handled as method constraints?*

### Marking parameters and return values for cascaded validation <a id="cascaded"></a>

Similar to normal bean validation, the `@Valid` annotation can be used to declare that a cascaded validation of given method parameters or return values shall be performed by the Bean Validation provider.

Generally the same rules as for standard object graph validation (see 3.5.1) apply, in particular

* null arguments and return values are ignored
* the validation is recursive, that is, if validated parameter or return value objects have references marked with `@Valid` themselves, these references will also be validated
* Bean Validation providers must guarantee the prevention of infinite loops during cascaded validation.

Example xy: Marking parameters and return values for cascaded validation

	public class OrderService {

		@Valid
		public Order getOrderByPk(@NotNull @Valid OrderPK orderPk) {
			//...
		}
	
		@NotNull
		@Valid
		public Set<Order> getOrdersByCustomer(@NotNull @Valid CustomerPK customerPk) {
			//...
		}
	}

Here the following recursive validations will happen when validating the methods of the `OrderService` class:

* Validation of the constraints on the object passed for the `orderPk` parameter and the returned `Order` object of the `getOrderByPk()` method
* Validation of the constraints on the object passed for the `customerPk` parameter and the constraints on each object contained within the returned `Set<Order>` of the getOrdersByCustomer() method

Again, solely marking parameters and return values for cascaded validation does not trigger the actual validation.

*DISCUSSION: There were discussions whether to use `@Valid` or a new annotation such as `@ValidParameter`.*

*IMO introducing a new annotation doesn't really make sense, as the `@Valid` annotation is used here in its originally intended sense: marking a (referenced) object for cascaded validation.*

### Inheritance hierarchies <a id="inheritance"></a>

When defining method level constraints within inheritance hierarchies (that is, class inheritance by extending base classes and interface inheritance by implementing interfaces) one has to obey the [Liskov substitution principle](http://en.wikipedia.org/wiki/Liskov_substitution_principle) which mandates that

* a method's preconditions (as represented by parameter constraints) may not be strengthened in sub types
* a method's postconditions (as represented by return value constraints) may not be weakened in sub types

TODO: Add a box explaining the rationale behind the Liskov substitution principle

Therefore the following rules with respect to the definition of method level constraints in inheritance hierarchies apply:

* In sub types (be it sub classes or interface implementations) no parameter constraints must be declared on overridden or implemented methods (since this would pose a strengthening of preconditions to be fulfilled by the caller).

* In sub types (be it sub classes or interface implementations) return value constraints may be declared on overridden or implemented methods. Upon validation, all return value constraints of the method in question are validated, wherever they are declared in the hierarchy (since this only poses possibly a strengthening but no weakening of the method's postconditions guaranteed to the caller).

A conforming Bean Validation provider must throw a `ConstraintDefinitionException` when discovering that any of these rules are violated.

#### Examples <a id="inheritance_examples"></a>

Example xy: Illegally declared parameter constraints on interface implementation

	public interface OrderService {

		void placeOrder(String customerCode, Item item, int quantity) { //... }

	}

	public class DefaultOrderService implements OrderService {

		@Override
		public void placeOrder(@NotNull @Size(min=3, max=20) String customerCode, @NotNull Item item, @Min(1) int quantity) { //... }

	}

The constraints in `DefaultOrderService` in example xy are illegal, as they strengthen the preconditions of `placeOrder()` as constituted by the interface `OrderService`.

Example xy: Illegally declared parameter constraints on sub class

	public class OrderService {

		void placeOrder(String customerCode, Item item, int quantity) { //... }

	}

	public class DefaultOrderService extends OrderService {

		@Override
		public void placeOrder(@NotNull @Size(min=3, max=20) String customerCode, @NotNull Item item, @Min(1) int quantity) { //... }

	}

The constraints in `DefaultOrderService` in example xy are illegal, as they strengthen the preconditions of `placeOrder()` as constituted by the super class `OrderService`.

Example xy: Correctly declared return value constraints on sub class

	public class OrderService {

		Order placeOrder(String customerCode, Item item, int quantity) { //... }

	}

	public class DefaultOrderService extends OrderService {

		@Override
		@NotNull
		@Valid
		public Order placeOrder(String customerCode, Item item, int quantity) { //... }

	}

The return value constraints in `DefaultOrderService` in example xy are legal, as they strengthen the postconditions of `placeOrder()` as constituted by the super class `OrderService` but don't weaken it.

## Validating method level constraints <a id="validating"></a>

As standard bean constraints method level constraints are evaluated using the `javax.validation.Validator` API.

The following new methods are suggested on `javax.validation.Validator` (to be added to the listing in section 4.1):

	<T> Set<MethodConstraintViolation<T>> validateParameter(
		T object, Method method, Object parameterValue, int parameterIndex, Class<?>... groups);

	<T> Set<MethodConstraintViolation<T>> validateAllParameters(
		T object, Method method, Object[] parameterValues, Class<?>... groups);

	<T> Set<MethodConstraintViolation<T>> validateReturnValue(
		T object, Method method, Object returnValue, Class<?>... groups);

	<T> Set<MethodConstraintViolation<T>> validateConstructorParameter(
		Constructor<T> constructor, Object parameterValue, int parameterIndex, Class<?>... groups);

	<T> Set<MethodConstraintViolation<T>> validateAllConstructorParameters(
		Constructor<T> constructor, Object[] parameterValues, Class<?>... groups);

*DISCUSSION: Would a separate interface `MethodValidator` make sense? I personally don't think so, but maybe there are arguments for that.*

### Methods for method level validation (to become 4.1.2) <a id="mfm"></a>

The method `<T> Set<MethodConstraintViolation<T>> validateParameter(T object, Method method, Object parameterValue, int parameterIndex, Class<?>... groups)` validates the value (identified by `parameterValue`) for a single method parameter (identified by `method` and `parameterIndex`). A `Set` containing all `MethodConstraintViolation` objects representing the failing constraints is returned, an empty `Set` is returned otherwise.

The method `<T> Set<MethodConstraintViolation<T>> validateAllParameters(T object, Method method, Object[] parameterValues, Class<?>... groups);` validates the arguments (as given in `parameterValues`) for the parameters of a given method (identified by `method`). A `Set` containing all `MethodConstraintViolation` objects representing the failing constraints is returned, an empty `Set` is returned otherwise.

The method `<T> Set<MethodConstraintViolation<T>> validateConstructorParameter(Constructor<T> constructor, Object parameterValue, int parameterIndex, Class<?>... groups);` validates the value (identified by `parameterValue`) for a single method parameter (identified by `constructor` and `parameterIndex`). A `Set` containing all `MethodConstraintViolation` objects representing the failing constraints is returned, an empty `Set` is returned otherwise.

The method `<T> Set<MethodConstraintViolation<T>> validateAllConstructorParameters(Constructor<T> constructor, Object[] parameterValues, Class<?>... groups);` validates the arguments (as given in `parameterValues`) for the parameters of a given constructor (identified by `constructor`). A `Set` containing all `MethodConstraintViolation` objects representing the failing constraints is returned, an empty `Set` is returned otherwise.

The method `<T> Set<MethodConstraintViolation<T>> validateReturnValue(T object, Method method, Object returnValue, Class<?>... groups);` validates the return value (specified by `returnValue`) of a given method (identified by `method`). A `Set` containing all `MethodConstraintViolation` objects representing the failing constraints is returned, an empty `Set` is returned otherwise.

TODO: What's the root bean in case of constructor parameter validation? The object isn't created yet.

#### Examples <a id="validating_examples"></a>

All the examples will be based on the following class definitions, constraint declarations and instances.

	public class OrderService {

		public OrderService(@NotNull CreditCardProcessor creditCardProcessor) {
			//...
		}

		@NotNull
		public Order placeOrder(@NotNull @Size(min=3, max=20) String customerCode, @NotNull @Valid Item item, @Min(1) int quantity) {
			//...
		}
	}

	public class Item {

		@NotNull;
		private String name;

		public String getName() { return name; }
		public void setName(String name) { this.name = name; }
	}

	Item item1 = new Item();
	item1.setName("Kiwi");

	Item item2 = new Item();
	item2.setName(null);

	Constructor<OrderService> constructor = ... ; //get constructor object
	Method<OrderService> placeOrder = ... ; //get method object

	OrderService orderService = new OrderService(new DefaultCreditCardProcessor());

The following method parameter validation will return one `MethodConstraintViolation` object as the customer code is `null`.

	//orderService.placeOrder(null, item1, 1);
	validator.validateAllParameters(orderService, placeOrder, new Object[] { null, item1, 1 }).size() == 1;

The following method parameter validation will return no `MethodConstraintViolation` object as the customer code is `null` but the quantity parameter is validated.

	//orderService.placeOrder(null, item1, 1);
	validator.validateParameter(orderService, placeOrder, new Object[] { null, item1, 1 }, 2).size() == 0;

The following method parameter validation will return one `MethodConstraintViolation` object as the item is not valid (its name is `null`).

	//orderService.placeOrder("CUST-123", item2, 1);
	validator.validateAllParameters(orderService, placeOrder, new Object[] { "CUST-123", item2, 1 }).size() == 1;

The following constructor parameter validation will return one `MethodConstraintViolation` as `null` is passed for the credit card processor parameter.

	//new OrderService(null);
	validator.validateAllConstructorParameters(constructor, new Object[] { null }).size() == 1;

Assuming the `placeOrder` method returned `null`, the following return value validation will return one `MethodConstraintViolation`:

	validator.validateReturnValue(orderService, placeOrder, null).size() == 1;

TODO: More examples to follow. Define semantics of constructor validation.

### MethodConstraintViolation (to become 4.3) <a id="method_constraint_violation"></a>

`MethodConstraintViolation` is the class describing a single method constraint failure. A (possibly empty) set of `MethodConstraintViolation`s is returned for a method validation.

	/**
	 * Describes the violation of a method-level constraint by providing access to
	 * the method, constructor (and parameter) hosting the violated constraint etc.
	 *
	 * @author Gunnar Morling
	 */
	public interface MethodConstraintViolation<T> extends ConstraintViolation<T> {
	
		/**
		 * The kind of a {@link MethodConstraintViolation}.
		 *
		 * @author Gunnar Morling
		 */
		public enum Kind {
			METHOD_PARAMETER, CONSTRUCTOR_PARAMETER, RETURN_VALUE;
		}

		Method getMethod();

		Constructor<T> getConstructor();

		Integer getParameterIndex();

		String getParameterName();

		Kind getKind();
	}


The `getMethod()` method returns a `java.lang.reflect.Method` object representing the method hosting the violated constraint in case a method constraint was violated, `null` otherwise.

TODO: Should this alternatively be the invoked method? Or do we need both? It makes a difference when constraints are defined on super types and an overriding/implementing method is validated.

The `getConstructor()` method returns a `java.lang.reflect.Constructor` object representing the constructor hosting the violated constraint in case a constructor constraint was violated, `null` otherwise.

The `getParameterIndex()` method returns the index of the parameter hosting the violated constraint in case it is a parameter constraint, otherwise `null`.

The `getParameterName()` method returns the name of the parameter hosting the violated constraint in case it is a parameter constraint, otherwise `null`. The returned name will be determined by the `ParameterNameProvider` used by the current validator (see ...).

The `getKind()` method returns the `Kind` of the constraint violation, which can either be `Kind.CONSTRUCTOR_PARAMETER`, `Kind.METHOD_PARAMETER` or `Kind.RETURN_VALUE`.

TODO: describe behavior of `getPropertyPath()`, `getLeafBean()`, `getRootBean()` etc. (as inherited from `ConstraintViolation`). Maybe `MethodConstraintViolation` shouldn't extend `ConstraintViolation`?

#### Examples <a id="mcv_examples"></a>

The following examples are based on the class definitions, constraint declarations and instances given in section 4.1.2.

The method parameter validation

	//orderService.placeOrder(null, item1, 1);
	validator.validateAllParameters(orderService, placeOrder, new Object[] { null, item1, 1 }).size() == 1;

will return a `MethodConstraintViolation` with the following properties:

	assert placeOrder == constraintViolation.getMethod();
	assert 0 == constraintViolation.getParameterIndex();
	assert "arg0".equals(constraintViolation.getParameterName();
	assert Kind.METHOD_PARAMETER == constraintViolation.getKind();

	 //TODO: is that what we want?
	assert orderService == constraintViolation.getRootBean();
	assert "OrderService#placeOrder(arg0)".equals(constraintViolation.getPropertyPath().toString());

TODO: Add further examples

### Triggering validation <a id="triggering"></a>

It's important to understand that BV itself doesn't trigger the evaluation of any method level constraints. That is, just annotating any methods with parameter or return value constraints doesn't automatically enforce these constraints, just as annotating any fields or properties with bean constraints doesn't enforce these either.

Instead method level constraints must be validated by invoking the appropriate methods on `javax.validation.Validator`. It is expected that this usually doesn't happen by manually invoking these methods but rather automatically using approaches and techniques such as:

* CDI/EJB interceptors
* aspect-oriented programming
* Java proxies

How integrators control whether a validation of method level constraints shall be performed or not for given types is out of scope of this specification. 

As it is expected though, that a very common approach will be to leverage annotations for this, the Bean Validation API defines the `javax.validation.ValidateGroups` annotation which can be used by integrators for that purpose. Integrators are encouraged to reuse this annotation instead of creating their own one.

	/**
	 * Marker for a type or method indicating that method level constraints shall be
	 * validated.
	 *
	 * @author Gunnar Morling
	 *
	 */
	@Target({ ElementType.METHOD, ElementType.TYPE })
	@Retention(RetentionPolicy.RUNTIME)
	public @interface ValidateGroups {

		Class<?>[] groups() default {};

		ValidationMode validationMode() default ValidationMode.ALL;

		public enum ValidationMode {
			PARAMETERS, RETURN_VALUE, ALL, NONE;
		}

	}

Using the `groups` attribute the groups to be validated can be specified. If no value is given, implicitely the group `javax.validation.groups.Default` will be validated. Using the `validationMode` attribute it can be controlled whether only parameters, only return values or both shall be validated.

The `ValidateGroups` annotation can be specified on type as well as on method level. It is left to integrators how to handle situations where the annotation is given on a type *and* a method of the same. It is recommended though to give method level annotations precedence, effectively allowing a default configuration to be given on the class level which can be overridden on the method level (e.g. to turn off validation for single methods by using `ValidationMode.NONE`).

It is left to integrators how to handle situations where the annotation is given on several types (be it classes or interfaces) within an inheritance hierarchy.

*DISCUSSION: A better name is to be found. Some proposals from the list: `@Guarded`, `@ValidateMethods`, `@ValidateOnMethodCall`, `@AutoValidating`, `@AutoValidated`, `@ValidateMethodCall`. IMO an adjective would be make a better annotation name.*

## Extensions to the meta-data API <a id="meta_data"></a>

### BeanDescriptor (5.3) <a id="bean_descriptor"></a>

The following two method should be added to `javax.validation.metadata.BeanDescriptor`:

	public interface BeanDescriptor extends ElementDescriptor {

		MethodDescriptor getConstraintsForMethod(String methodName, Class<?>... parameterTypes);

		Set<MethodDescriptor> getConstrainedMethods();

		ConstructorDescriptor getConstraintsForConstructor(Class<?>... parameterTypes);

		Set<ConstructorDescriptor> getConstrainedConstructors();

	}

Meaning of `isBeanConstrained` should be re-defined to also return `true`, if at least one constrained method or constructor exists (having a constrained or cascaded parameter and/or return value).

`getConstraintsForProperty` returns a `MethodDescriptor` describing the method level constraints of the method uniquely identified the given name and parameter types. `null` will be returned if no method with the given name and parameter types exist or if that method is not constrained (has neither parameter or return value constraints, neither return value or parameters are marked for cascaded validation).

`getConstrainedMethods` returns the `MethodDescriptor`s for those of the type's methods having at least one parameter or return value constraint or at least one cascaded parameter or a cascaded return value.

`getConstraintsForConstructor` returns a `ConstructorDescriptor` describing the method level constraints of the constructor uniquely identified by the given parameter types. `null` will be returned if no constructor with the given parameter types exist or if that constructor is not constrained (has neither parameter or return value constraints, neither return value or parameters are marked for cascaded validation).

`getConstrainedConstructors` returns the `ConstructorDescriptor`s for those of the type's constructors having at least one parameter or return value constraint or at least one cascaded parameter or a cascaded return value.

TODO: what does return value constraints/cascadation mean in the context of constructors?

### MethodDescriptor (to become 5.5) <a id="method_descriptor"></a>

The `MethodDescriptor` interface describes a constrained method of a Java type.

`MethodDescriptor` lives in the `javax.validation.metadata` package.

This interface is returned by `BeanDescriptor.getConstraintsForMethod(String, Class<?>...)` and `BeanDescriptor.getConstrainedMethods`.

	/**
	 * Describes a validated method.
	 *
	 * @author Gunnar Morling
	 *
	 */
	public interface MethodDescriptor extends ElementDescriptor {

		String getMethodName();

		List<ParameterDescriptor> getParameterDescriptors();

		boolean isCascaded();

	}

`getMethodName` returns the simple name of the represented method.

`getParameterDescriptors` returns a list of `ParameterDescriptor`s representing the method's parameters in their natural order. An empty list will be returned in case the method has no parameters.

`isCascaded` returns `true`, if the represented method's return value is marked for cascaded validation, `false` otherwise. 

### ConstructorDescriptor (to become 5.6) <a id="constructor_descriptor"></a>

The `ConstructorDescriptor` interface describes a constrained constructor of a Java class.

`ConstructorDescriptor` lives in the `javax.validation.metadata` package.

This interface is returned by `BeanDescriptor.getConstraintsForConstructor(Class<?>...)` and `BeanDescriptor.getConstrainedConstructors`.

	/**
	 * Describes a validated constructor.
	 *
	 * @author Gunnar Morling
	 *
	 */
	public interface ConstructorDescriptor extends ElementDescriptor {

		List<ParameterDescriptor> getParameterDescriptors();

		boolean isCascaded();

	}

`getParameterDescriptors` returns a list of `ParameterDescriptor`s representing the constructor's parameters in their natural order. An empty list will be returned in case the constructor has no parameters.

TODO does `isCascaded` make sense here?

### ParameterDescriptor (to become 5.7) <a id="parameter_descriptor"></a>

The `ParameterDescriptor` interface describes a constrained parameter of a method or constructor of a Java type.

`ParameterDescriptor` lives in the `javax.validation.metadata` package.

This interface is returned by `MethodDescriptor.getParameterDescriptors` and `ConstructorDescriptor.getParameterDescriptors`.

	/**
	 * Describes a validated method parameter.
	 *
	 * @author Gunnar Morling
	 *
	 */
	public interface ParameterDescriptor extends ElementDescriptor {

		int getIndex();

		String getName();

		boolean isCascaded();

	}

`getIndex` returns the index of the represented parameter within the holding method's or constructor's list of parameters.

`getName` returns the name of the represented parameter as generated by the `ParameterNameProvider` used by the validator from which this descriptor was obtained (see ...).

`isCascaded` returns `true`, if the represented parameter is marked for cascaded validation, `false` otherwise.

## Extensions to the XML schema for constraint mappings <a id="xml"></a>

## MethodConstraintViolationException (to become 8.2) <a id="mcve"></a>

The method validation mechanism is typically not invoked manually during normal program execution, but rather automatically using a proxy, method interceptor or similar. Typically the program flow shouldn't continue its normal execution in case a parameter or return value constraint is violated which is realized by throwing an exception. 

Bean Validation provides a reference exception for such cases. Frameworks and applications are encouraged to use `MethodConstraintViolationException` as opposed to a custom exception to increase consistency of the Java platform.

	/**
	 * Exception class to be thrown by integrators of the BV method validation feature.
	 *
	 * @author Gunnar Morling
	 */
	public class MethodConstraintViolationException extends ValidationException {
	
		private static final long serialVersionUID = 5694703022614920634L;
		
		private final Set<MethodConstraintViolation<?>> constraintViolations;
		
		/**
		 * Creates a new {@link MethodConstraintViolationException}.
		 *
		 * @param constraintViolations A set of constraint violations for which this exception shall be created.
		 */
		public MethodConstraintViolationException(Set<? extends MethodConstraintViolation<?>> constraintViolations) {
		
			this( null, constraintViolations );
		}
		
		/**
		 * Creates a new {@link MethodConstraintViolationException}.
		 *
		 * @param message The message for the exception to be created.
		 * @param constraintViolations A set of constraint violations for which this exception shall be created.
		*/
		public MethodConstraintViolationException(String message,
			Set<? extends MethodConstraintViolation<?>> constraintViolations) {
		
			super( message );
			this.constraintViolations = constraintViolations == null ? 
				Collections.<MethodConstraintViolation<?>>emptySet() : 
				Collections .unmodifiableSet( constraintViolations );
		}
		
		/**
		 * Returns the set of constraint violations reported during a validation.
		 *
		 * @return An unmodifiable set of {@link MethodConstraintViolation}s occurred during a method level validation call.
		 */
		public Set<MethodConstraintViolation<?>> getConstraintViolations() {
			return constraintViolations;
		}
	
	}

## Required changes in 1.0 wording <a id="changes"></a>

* section [2.1](http://beanvalidation.org/1.0/spec/#constraintsdefinitionimplementation-constraintdefinition): `ElementType.PARAMETER` should be mandatory now
* section [3.1.2](http://beanvalidation.org/1.0/spec/#constraintdeclarationvalidationprocess-requirements-property): Remove sentence "Constraints on non getter methods are not supported."

## Misc. <a id="misc"></a>

This section contains some issues which might be added to the proposal if there is demand for them.

### Validating invariants <a id="invariants"></a>

*DISCUSSION: Should there be some way to trigger validation of bean constraints upon method invocations?*

*IMO this falls in the same category as triggering method validation itself and should be handled by integrators, e.g. by defining a interceptor binding annotation for CDI.*

### Applying property constraints to setter methods <a id="setters"></a>

It might be useful to have the possibility to apply property constraints (defined on getter methods) also as parameter constraints within the corresponding setter methods.

*DISCUSSION: Might that be required/helpful by JAX-RS?*

#### Option 1: A class-level annotation <a id="class"></a>

	@ApplyPropertyConstraintsToSetters
	public class Foo {
	
	}

#### Option 2: A property level annotation <a id="property"></a>

	public class Foo {
	
		@ApplyToSetter
		@Min(5)
		public int getBar() { return bar; }
	}

#### Option 3: An option in the configuration API <a id="option"></a>

	Validator validator = Validation.byDefaultProvider()
	       .configure()
	       .applyPropertyConstraintsToSetters()
	       .buildValidatorFactory()
	       .getValidator();

The options don't really exclude but amend each other.

## Archive <a id="archive"></a>

This section contains some alternative approaches for dicussed items and are temporarily here for reference.

### Alternative options for inheritance hierarchies <a id="inheritance_alternatives"></a>

*DISCUSSION: Besides the proposed approach other options exist (see below). The first is unnecessary strict to me, while the latter seems somewhat undeterministic to me. I sensed some agreement on the proposal above in the discussions on the mailing list.*

#### Option 2: allow return value refinement (AND style) <a id="return_refinement"></a>

#### Option 3: allow param (OR style) and return value (AND style) refinement <a id="parameter_refinement"></a>

### Alternative options for triggering validations

* reuse @Valid
* let each integrator use a specific annotation
* specify a standardized one in BV (see proposal above)

Based on the related discussions I think we agree on providing an annotation in BV. According to Pete from the CDI EG that approach also works with CDI which could convert our annotation into a CDI interceptor binding annotation programmatically.
