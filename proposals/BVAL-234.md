---
title: Fix annoyance between JPA and Bean Validation when @Id @GeneratedValue and @NotNull are used
layout: default
author: Emmanuel Bernard
---

# #{page.title}

[Link to JIRA ticket][jira]  
See also [NetBeans issue][netbeans]

## Problem description

Today when a property marked @Id @GeneratedValue is also marked @NotNull, it will fail if the identity generation is post-insert 
in the database. This can be the case if the underlying table is using column id generation for example.

The id property is thus null when Bean Validation is executed during the pre-persist phase and a constraint
violation is raised.

## Solutions

### 1. User adjusts

One option is to stay put and consider the behavior valid. The user can work around that by:

- creating a `com.acme.groups.Created` group
- marking the `@NotNull` annotation as belonging to the group
- override the groups in `persistence.xml` to validate `Created` accordingly

Here is the snipped of the `persistence.xml` file

    <property name="javax.persistence.validation.group.pre-persist"
              value="javax.validation.groups.Default"/>
    <property name="javax.persistence.validation.group.pre-update"
              value="javax.validation.groups.Default,com.acme.groups.Created"/>


### 2 User adjusts with some help

We could use option 1 but have JPA provide the created group: `javax.persistence.validation.groups.Created`

### 3. Have JPA disable validation of id properties at pre-persist

JPA could disable validation on id properties if in pre-persist and if the generated value is not created yet.
Note that we disable all validations - not simply `@NotNull` - as it does not make much sense to execute other 
validations when a property is null.

`TraversableResolver` can be used to solve the problem as `isReachable` can stop the processing of a property.

### Conclusions

Option 3 seems the most reasonable but it could be complicated at the JPA level.
Before going to the JPA EG, let's discuss the situation here.

### Questions remaining

- should the `Created` groups be renamed?
- is that correct to sneakily disable @NotNull constraint validation?

    
[netbeans]: http://netbeans.org/bugzilla/show_bug.cgi?id=197845#c3
[jira]: https://hibernate.onjira.com/browse/BVAL-234