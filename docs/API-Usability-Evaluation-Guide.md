# API Usability Evaluation Guide
---

This document defines a set of rubrics for evaluating the usability of routing APIs for Flutter based on the [Cognitive Dimensions of Notations](https://www.cl.cam.ac.uk/~afb21/CognitiveDimensions/workshop2005/Clarke_position_paper.pdf) framework.

# Core dimensions
We will focus on the following 7 dimensions in our evaluation:

*   [_Role expressiveness_](#role-expressiveness): do the API names clearly communicate what the APIs do?
*   [_Domain correspondence_](#domain-correspondence): does the API directly map the concepts the programmer thinks in the application domain?
*   [_Consistency_](#domain-correspondence): is the API consistent with its own surface and across the API surface of the framework?
*   [_Premature commitment_](#premature-commitment): does the API require the programmer to make some upfront decisions which are hard to reverse?
*   [_Abstraction level_](#abstraction-level): does the API allow the programmer to achieve a set of common goals with just a few components or many building blocks?   
*  [_Work-step unit_](#work-step-unit): how concise is the code for implementing common API usage scenarios?
*   [_Viscosity_](#viscosity): does the API allow the programmer to make changes to their code easily? Is there a “domino effect” when refactoring code?


The rest of the document describes how to assess each dimension.



## Role Expressiveness

Role expressiveness is about how well the API’s names and usage communicate what the system does. We aim for transparent role expressiveness. In other words, “say what you mean and mean what you say!”


### Assessment procedure

1. Select a scenario from our common scenario catalog
2. Examine a code snippet implementing that scenario using the API in question
3. Try to summarize what each code block does in your own words. (While the goal is to cover every class in the snippet that is directly related to the scenario, it’s okay to skip the ones that simply define a data model or a page scaffolding.) is  When reading code that uses the API, was it easy to tell what each section of the code does? Why? Which were the parts that were more difficult to interpret? Use the following table as an example. 


Line# | Code block | What it does | Difficulty to interpret<sup>*</sup>
-- | -- | -- | --
19 | Book | Defining a data model for a book | Transparent
50 | BooksApp | Boilerplate for creating a StatefulWidget | Transparent
55 | _BooksAppState | Building the main UI of BooksApp. Creating a MaterialApp using this new .router constructor.Questions:What does the BookRouterDelegate do?And what about the BookRouteInformationParser? Where is the actual UI building logic for this Material app? | Plausible
... | ... | ...

<sup>*</sup> The scale for "difficulty to interpret" is available in Assessment Results.

4. When reading the code, how often do you feel you need to check a class or a method’s API reference to understand what it does?
    *   Frequently
    *   Occasionally
    *   Rarely
5. Repeat the above for another scenario


### Assessment results

Overall rating: 

*   **Transparent**: the code can be interpreted correctly _without_ reading documentation
*   Between **Transparent** and **Plausible**
*   **Plausible**: the code can be interpreted correctly _after_ reading documentation
*   Between **Plausible** and **Opaque**
*   **Opaque**: the code _cannot_ be interpreted correctly after reading documentation

Additional comments about your rating:

```
```

## Domain Correspondence

Domain correspondence refers to how well the API maps to concepts the programmer needs to manipulate in the application domain.


### Assessment procedure

Domain correspondence can be assessed via a concept mapping exercise, following these steps:

1. Select an app usage scenario from the storyboards
2. Describe the same scenario in generic technical terms. Imagine you’re writing your app’s requirements doc.
3. Examine a code snippet implementing that scenario using the API in question
4. Identify classes and methods exposed by the API
5. Discuss how related those classes and methods are to the generic technical terms in step 2 (For example, if an API for file I/O exposes a File class, does that map well to your understanding of a file?). Using the following table as a template for your analysis.

Generic concept | API concept | Comments
-- | -- | --
Navigation System | Navigator, Router | There are two classes for configuring the app’s navigation system. The differences between Router and Navigator are not obvious at a glance.
... | ... | ...


6. Was it easy to map concepts from that scenario to specific APIs?
   * Very easy
   * Somewhat easy
   * Somewhat hard
   * Very hard
7. Repeat the above steps for another scenario

### Assessment results

Overall rating: 

*   **Direct**: the mapping makes sense _without_ reading documentation
*   Between **Direct** and **Plausible**
*   **Plausible**: the mapping makes sense _after_ reading documentation
*   Between **Plausible** and **Arbitrary**
*   **Arbitrary**: the mapping does _not_ make sense even after reading documentation

Additional comments about your rating:

```
```
## Consistency

Consistency in an API allows users to make use of what they have learned about how one part of the API works when they start working with another, similar part of the API. There are two aspects of API consistency we need to consider: within-API consistency and cross-API consistency. They are further explained in the assessment procedure.

### Assessment procedure

Please assess the following three aspects of API consistency based on the API usage.

Within-API consistency

* Examine the snippets of using the API to implement different scenarios, identify any conceptually similar user goals implemented differently. Are there good reasons for the differences?

    ```

    ```


Cross-API consistency

* Identify new coding patterns, if any, introduced by this API that are not used anywhere else in the Flutter framework. Are the benefits of introducing those new patterns outweigh the cost of learning them?
    ```

    ```
* Identify new concepts, if any, introduced by the API that do not exist anywhere in the Flutter framework. Will these new concepts cause confusion?

    ```

    ```

### Assessment results

Overall rating: 
*   **Full**: API achieves a high-level of both within-API consistency and cross-API consistency
*   Between **Full** and **Core**
*   **Core**: API achieves a high-level of within-API consistency
*   Between **Core** and **Arbitrary**
*   **Arbitrary**: API fails to achieve a high-level of within-API consistency nor cross-API consistency

Additional comments about your rating:

```
```

## Premature commitment

This dimension assesses the consequences of making premature decisions in API usage and the cost of reversing a decision. We aim to present the user with a small number of choices about how to accomplish some goal. We also aim for reversible choices, so users can recover easily. 


### Assessment procedure


1. Select a scenario from our common scenario catalog
2. Examine a code snippet implementing that scenario using the API in question
3. List all the choices the developer needs to make when writing this snippet. Draw a decision tree if applicable. Below is an example: 

    Line# | Choice | Implications
    -- | -- | --
    [39](https://github.com/flutter/uxr/blob/master/nav2-usability/scenario-code/deeplink-pathparam/router.dart#L39) | Using MaterialApp vs. MaterialApp.router | To support deep linking, the app must use MaterialApp.router. If the developer chose MaterialApp initially, a substantial amount of refactoring will be required to switch the constructor to MaterialApp.router, as described in [this article](https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade#9ce8).
    ... | ... | ...


4. Describe how the developer is supposed to determine what to do next at any branching point in the decision tree drawn at the previous step.

    ```

    ```


5. Was it obvious that you needed to make those decisions or did you learn about this through trial and error?
   * It was obvious
   * I had to learn through trial and error
   * I had to learn it by reading a full tutorial

6. If the developer made a bad choice, what does the developer need to do to recover from that? Was the effort of reversing a bad choice reasonable?

    ```

    ```


7. Repeat the above for another scenario.


### Assessment results

Overall rating:

*   **Minor Reversible**: The API presents the user with a small number of choices about how to accomplish some goal and the differences between any alternatives are minimal
*   Between **Minor Reversible** and **Major Reversible**
*   **Major Reversible**: The API presents the user with a significant number of choices about how to accomplish some goal or the differences between the alternatives are significant
*   Between **Major Reversible** and **Arbitrary**
*   **Arbitrary**: The API presents the user with a significant number of choices about how to accomplish some goal and the differences between the alternatives are significant

Additional comments about your rating:

```
```


## Abstraction Level

This dimension is a measure of the type and number of abstractions that the developer has to work with. We aim to lower the barrier to entry with aggregate components. Provide Layered and Progressive Abstraction Architecture. In addition, abstraction level needs to fit the target programmer’s [work style](https://blog.codinghorror.com/mort-elvis-einstein-and-you/).


### Assessment procedure

1. Select a scenario from our common scenario catalog
2. Examine a code snippet implementing that scenario using the API in question
3. Count the number of classes that have to be used to implement the scenario
4. Given the number of user-facing concepts in the scenario, does the number of classes seem to be reasonable?
    *   more than what I would expect
    *   About the same as what I would expect
    *   Fewer than what I would expect
5. How would you describe your experiences with respect to the types of classes used to implement this scenario?
    *   They were just as I expected
    *   They were too low level
    *   They were too high level
6. Describe the parts of the implementation you feel the system should just take care of for the developer.

    ```

    ```

7. Repeat the above procedure for another scenario.


### Assessment results

Overall rating:

*   **Aggregate**: I was able to use one component to achieve a set of goals
*   Between **Aggregate** and **Coordinated**
*   **Coordinated**: multiple classes need to be used together to achieve a particular user goal, but it’s easy to discover what else is needed from a single entry point. 
*   Between **Coordinated** and **Primitive**
*   **Primitive**: Individual components exposed by the API do not map on to unique user tasks and it’s hard to find what is needed to accomplish a user task. 

Additional comments about your rating:

```
```

## Work-step Unit 

This dimension is about how concise the code is for implementing common API usage scenarios.

### Assessment procedure

1. Select a scenario from our common scenario catalog
2. Examine a code snippet implementing the main navigation tasks in the scenario using the API
3. Count the lines of code for implementing that task
4. How would you describe the amount of code that you had to write for the task? Did you have to write more code than you expected or did you have to write less code? Please explain. 

    ```

    ```
5. Repeat the above for another scenario 

### Assessment results

Overall rating: 

*   **Local Incremental**: the amount of code for accomplishing a task is proportional to the size of the task, and the code is completely contained within one local code block.
*   Between **Local Incremental** and **Functional Chunk**
*   **Functional Chunk**: code for accomplishing a task is not local, but in clearly connected code blocks (e.g., via a call back function)
*   Between **Functional Chunk** and **Parallel Components**
*   **Parallel Components**: the amount of code for accomplishing a task is out of proportion, and the code also spreads across multiple code blocks or classes. 

Additional comments about your rating:

```
```

## Viscosity

API viscosity measures the resistance to change of code written using a particular API. When you need to make changes to code that you have written using the API, how easy is it to make the change? Beware the  'domino' effect of any change.  

### Assessment procedure

1. Select a scenario from our common scenario catalog
2. Examine a code snippet implementing that scenario using the API in question
3. Introduce requirement changes to the scenario. In the context of the routing API research, you can select 1-2 changes for each scenario from the list below:

   * Deep linking by path parameter 
     * Adding a new route (e.g., a settings page)
     * Deleting a route
     * Changing the destination of a route
     * Changing the path pattern (i.g., change ‘/books/’ to ‘/items/’ )
     * Adding a query parameter to the route

   * Sign-in
     * Splitting the sign-in screen into two steps, username and password.
     * Adding a two-factor verification screen

   * Nested routing
     * Changing page transition animations between views in an inner route
     * Moving code of an inner route to a separate library, so a separate team can work on it
     * Unnesting a route (i.e. promoting a secondary section to a primary section)


4. Try revising the code snippet to reflect the requirement change
5. Examine the code snippet rewritten to reflect the change. 
6. Count the amount of changes using diff tools
7. When you need to make changes to code that you have written using the API, how easy was it to make the change? Why?

    ```

    ```


8. Are there particular changes that were more difficult or especially difficult to make in your code? Which ones?

    ```

    ```

9. Repeat the above steps for another scenario


### Assessment results

Overall rating:

*   **Low**: the changes are local and small. 
*   Between **Low** and **Medium**
*   **Medium**: the changes spread out in a few different code blocks but they do not affect the app architecture.
*   Between **Medium** and **High**
*   **High**: the changes require adjustment of the app architecture or they are large enough to be characterized as having a “domino effect” from a seemingly simple user-facing change.

Additional comments about your rating:

```
```



# Additional dimensions

There are 5 additional dimensions in the Cognitive Dimensions of Notations framework, but we don't plan to use them in this evaluation due to help scale the effort across multiple packages. For completeness, those dimensions are listed below:

* *API Elaboration*: Were you able to use the API exactly ‘as-is’ or did you have to create new objects by deriving from classes in the API? How easy is it to extend the API for advanced use cases?
* *Progressive Evaluation*: How easy was it to stop in the middle of the task you were working on, and check your work so far?
* *Working Framework*: How many classes you had to work with simultaneously to accomplish the task?
* *Learning Style*: which learning style does the API support? Trial and error, example-centric, or systematic?  
* *Penetrability*: How much of the details of the API do you have to understand in order to be able to use the API successfully?


# References

*   Steven Clarke (2005). [Describing and Measuring API Usability with the Cognitive Dimensions](https://www.cl.cam.ac.uk/~afb21/CognitiveDimensions/workshop2005/Clarke_position_paper.pdf)
*   Steven Clarke (2004). [Questionnaire and ratings sheet for cognitive dimensions analysis](https://sites.google.com/site/apiusability/publications/Clarke_Cog_Dim_questionnaire.zip). 

*   Meital Tagor Sbero (2020). A Practical Guide for Understanding API usability [Google internal resource]