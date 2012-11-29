---
title: The constraint violation builder cannot put constraint on a top level map key
layout: default
author: Emmanuel Bernard
comments: true
---

# #{page.title}

[Link to JIRA ticket][jira]  

## Problem

It's not possible to put a constraint violation on a top-level indexed element or a map element.

## Solution

### Natural options

The natural solution would be to use the following approach

    context.buildConstraintViolationWithTemplate("oh noes")
            .addNode(null) //ie the contained element
                inIterable().atKey(someKey)
            .addConstraintViolation();

It is aligned with how the `Path.Node` API behaves.

There are three options ot reach the natural approach.

#### Changing the return type (1)

This solution would be the standard approach but we would need
to change the return type to accept `inIterable()` etc
which could be backward incompatible if people select the intermediate return type.

    interface ConstraintViolationBuilder {

        // Old API: NodeBuilderDefinedContext addNode(String name);

        NodeBuilderCustomizableContext addNode(String name);

        ConstraintValidatorContext addConstraintViolation();

        /**
         * Represent a node whose context is known
         * (ie index, key and isInIterable)
         */
        interface NodeBuilderDefinedContext {
            NodeBuilderCustomizableContext addNode(String name);
            ConstraintValidatorContext addConstraintViolation();
        }

        /**
         * Represent a node whose context is
         * configurable (ie index, key and isInIterable)
         */
        interface NodeBuilderCustomizableContext {
            NodeContextBuilder inIterable();
            NodeBuilderCustomizableContext addNode(String name);
            ConstraintValidatorContext addConstraintViolation();
        }

        /**
         * Represent refinement choices for a node which is
         * in an <code>Iterator</code> or <code>Map</code>.
         * If the iterator is an indexed collection or a map,
         * the index or the key should be set.
         */
        interface NodeContextBuilder {
            NodeBuilderDefinedContext atKey(Object key);
            NodeBuilderDefinedContext atIndex(Integer index);
            NodeBuilderCustomizableContext addNode(String name);
            ConstraintValidatorContext addConstraintViolation();
        }
    }

#### Adding the methods to existing return type (2)

The alternative would be to add `inIterable()` etc to `NodeBuilderDefinedContext`.
But that would break the contextual and safety of the API as this interface is 
also returned by `atKey` and `atIndex`.

    interface ConstraintViolationBuilder {

        NodeBuilderDefinedContext addNode(String name);
        
        ConstraintValidatorContext addConstraintViolation();

        /**
         * Represent a node whose context is known
         * (ie index, key and isInIterable)
         */
        interface NodeBuilderDefinedContext {
            //Adding method to support use case
            NodeContextBuilder inIterable();
            NodeBuilderCustomizableContext addNode(String name);
            ConstraintValidatorContext addConstraintViolation();
        }

        /**
         * Represent a node whose context is
         * configurable (ie index, key and isInIterable)
         */
        interface NodeBuilderCustomizableContext {
            NodeContextBuilder inIterable();
            NodeBuilderCustomizableContext addNode(String name);
            ConstraintValidatorContext addConstraintViolation();
        }

        /**
         * Represent refinement choices for a node which is
         * in an <code>Iterator</code> or <code>Map</code>.
         * If the iterator is an indexed collection or a map,
         * the index or the key should be set.
         */
        interface NodeContextBuilder {
            //would have the side effect of offereing isIterable() where it's not allowed
            NodeBuilderDefinedContext atKey(Object key);
            NodeBuilderDefinedContext atIndex(Integer index);
            NodeBuilderCustomizableContext addNode(String name);
            ConstraintValidatorContext addConstraintViolation();
        }
    }

#### Make `NodeBuilderCustomizableContext` a subinterface of the existing return type (3)

Another approach would be to make `NodeBuilderCustomizableContext` a sub insterface of 
`NodeBuilderDefinedContext`. 

Question: would that be backward compatible? That sounds like the best approach.

    interface ConstraintViolationBuilder {

        // Old API: NodeBuilderDefinedContext addNode(String name);

        NodeBuilderCustomizableContext addNode(String name);

        ConstraintValidatorContext addConstraintViolation();

        /**
         * Represent a node whose context is known
         * (ie index, key and isInIterable)
         */
        interface NodeBuilderDefinedContext {
            NodeBuilderCustomizableContext addNode(String name);
            ConstraintValidatorContext addConstraintViolation();
        }

        /**
         * Represent a node whose context is
         * configurable (ie index, key and isInIterable)
         */
        // make NodeBuilderCustomizableContext extend NodeBuilderDefinedContext
        interface NodeBuilderCustomizableContext extends NodeBuilderDefinedContext {
            NodeContextBuilder inIterable();
            NodeBuilderCustomizableContext addNode(String name);
            ConstraintValidatorContext addConstraintViolation();
        }

        /**
         * Represent refinement choices for a node which is
         * in an <code>Iterator</code> or <code>Map</code>.
         * If the iterator is an indexed collection or a map,
         * the index or the key should be set.
         */
        interface NodeContextBuilder {
            NodeBuilderDefinedContext atKey(Object key);
            NodeBuilderDefinedContext atIndex(Integer index);
            NodeBuilderCustomizableContext addNode(String name);
            ConstraintValidatorContext addConstraintViolation();
        }
    }

### Adding a different method with the proper return type (4)

An alternative solution is to add a specific method next to `addNode` to provide `NodeBuilderCustomizableContext`
from `context` directly. But what name would it be? `addNode` is already taken :)

    interface ConstraintViolationBuilder {

        NodeBuilderDefinedContext addNode(String name);

        //adding ad hoc method
        NodeBuilderCustomizableContext addNodeWithIterable(String name);

        ConstraintValidatorContext addConstraintViolation();

        /**
         * Represent a node whose context is known
         * (ie index, key and isInIterable)
         */
        interface NodeBuilderDefinedContext {
            NodeBuilderCustomizableContext addNode(String name);
            ConstraintValidatorContext addConstraintViolation();
        }

        /**
         * Represent a node whose context is
         * configurable (ie index, key and isInIterable)
         */
        // make NodeBuilderCustomizableContext extend NodeBuilderDefinedContext
        interface NodeBuilderCustomizableContext extends NodeBuilderDefinedContext {
            NodeContextBuilder inIterable();
            NodeBuilderCustomizableContext addNode(String name);
            ConstraintValidatorContext addConstraintViolation();
        }

        /**
         * Represent refinement choices for a node which is
         * in an <code>Iterator</code> or <code>Map</code>.
         * If the iterator is an indexed collection or a map,
         * the index or the key should be set.
         */
        interface NodeContextBuilder {
            NodeBuilderDefinedContext atKey(Object key);
            NodeBuilderDefinedContext atIndex(Integer index);
            NodeBuilderCustomizableContext addNode(String name);
            ConstraintValidatorContext addConstraintViolation();
        }
    }

[jira]: https://hibernate.onjira.com/browse/BVAL-221
