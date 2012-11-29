---
title: Expose settings defined in XML in the Configuration API (for ConstraintValidatorFactory, MessageInterpolator etc)
layout: default
author: Emmanuel Bernard
comments: true
---

# #{page.title}

[Link to JIRA](https://hibernate.onjira.com/browse/BVAL-265)

## Goals

While working on the dependency injection (BVAL-238), I need to solve a subproblem. A container needs to know what is in `validation.xml`
to either:

- plug its `ConstraintValidatorFactory` / `MessageResolver` etc implementation, 
- use the one defined by the user and possibly instantiate these objects as managed objects

There are a few strategies

## Option 1: Let the XML parsing be done by the DI bootstrap code

The easiest solution is to leave the container read `validation.xml` and extract information itself. No need to change the API in this case.

## Option 2: Expose the data on the `Configuration` object as strings

Add three methods to `Configuration` to return the explicit value (if set) and null otherwise:

- `String getConstraintValidatorFactoryFromXML()`
- `String getMessageInterpolatorFromXML()`
- `String getTraversableResolverFromXML()`

	//example of bootstrap code by the container
	Configuration conf = Validation
	    .byDefaultProvider()
	    .configure();

	String cVFClassName = conf.getConstraintValidatorFactoryFromXML();
	ConstraintValidatorFactory cVF;
	if (cVFClassName == null) {
	   //use DI custom one
	   cVF = new ContainerCustomConstraintValidatorFactory();
	}
	else {
	   cVF = Container.getManagedBean(cVFClassName);
	}

	//same logic for MessageResolver and TraversableResolver
	[...]

	conf.constraintValidatorFactory(cVF)
	   .messageResolver(messageRes)
	   .traversableResolver(traversRes)
	   .buildValidatorFactory();


The spec would recommend that `getConstraintValidatorFactoryFromXML()` and its siblings lazily read the XML file.

## Option 3: Expose the data in `Configuration` as instantiated objects

Same as above except that `Configuration` returns already instantiated objects. But I don't think that's an 
interesting option.

## Discussion

Which options should be favor? I am tempted by option 2 but the risk is an explosion of `getDefaultXXX()` 
and `getXXXFromXML()` the more we add components to Bean Validation.

What do you think?
