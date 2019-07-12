---
title: Glossary
layout: default
author: Emmanuel Bernard
comments: false
---

This page is a glossary of Jakarta Bean Validation terms as well as Java generics terms.

Java Generic terms are copied from [Angelika Langer's glossary](http://www.angelikalanger.com/GenericsFAQ/FAQSections/Glossary.html).

## G

**Generic type**: A class or interface with one or more type parameters.

    class List<E> { ... } 

## P

**Parameterized type** (instantiated type): A type created from a generic type by providing an actual type argument per formal type parameter .

    List<String>

## T

**Type argument**: A reference type or a wildcard that is used for instantiation / invocation of a generic type or a reference type used for instantiation / invocation of a generic method .

    List< ? > list = new LinkedList< String >();

**Type parameter** (type variable): A place holder for a type argument. Each type parameter is replaced by a type argument when a generic type or generic method is instantiated / invoked.

    interface Comparable <E> { 
        int compareTo( E other); 
    }

**Type use**: Where annotations are placed on the type parameter of a parameterized type of a member or method declaration
(this is a Bean Validation terminology borrowed from the TargetType's `TYPE_USE` enum value).

    List<@Email String> emails;
