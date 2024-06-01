# Flutter Routing API Usability Research
---

# TL; DR 
This project aims to establish a usability standard and a method for designing high-level routing APIs for Flutter. If you have any feedback after reading this page, please post your comments to [this issue](https://github.com/flutter/uxr/issues/6). The latest status of this project can be found in [issue #31](https://github.com/flutter/uxr/issues/31). This project is also referred to as Routing API Research. 

Update on Sep 2, 2021: We've published the [research report](https://github.com/flutter/uxr/raw/master/nav2-usability/Flutter%20routing%20packages%20usability%20research%20report.pdf) (PDF). You can leave your comments or questions in this [discussion thread](https://github.com/flutter/uxr/discussions/71).  

# Motivation
The [Router API](https://api.flutter.dev/flutter/widgets/Router-class.html) in Flutter provides many desirable enhancements on the original Navigator API, but it’s also considered to be complex and hard to use by Flutter users. To simplify routing implementations, the Flutter user community has started experimenting with alternate APIs. Flutter’s DevRel team has also explored potential simplifications via an experimental package called [page_router](https://github.com/johnpryan/page_router). We would like to make sure these explorations are fruitful and converging on an API that makes common navigation patterns straightforward to implement. To achieve this outcome, we are following the [User-Centered Design](https://www.usability.gov/what-and-why/user-centered-design.html) process to create a high-level navigation API for Flutter.

# Goals
* Design or endorse an easy-to-use package for implementing common navigation patterns, especially for use cases on the web. 
* Establish a model API design process for Flutter’s future development

# Non-goals

In this project, we are not pursuing the following goals, but they remain a possibility in the future:
* Making the page_router package production-ready
* Changing the existing Router API

# Planned work
  
Our design process is [scenario-driven](https://speakerdeck.com/ijansch/scenario-driven-api-design) in order to simplify the API for the common navigation patterns and enable us to measure the developer experience of the proposed API concretely. Below is an overview of our planned activities:

## 1. Scenario development and validation

We will create a set of app navigation scenarios, specified as storyboards, which the new API should allow the developer to implement easily. These scenarios should closely match what app users need in their multi-platform Flutter apps (e.g., mobile + web).

Status: Completed on Mar 16, 2021

Discussion: https://github.com/flutter/uxr/issues/4

Deliverable: [Navigation scenario storyboards](https://github.com/flutter/uxr/blob/master/nav2-usability/storyboards/)

## 2. Package comparative analysis

We will write snippets for the common scenarios identified in the previous activity using one or more proposed high-level navigation and routing APIs. We’ll then critically examine the snippets based on an [[API usability framework|API-Usability-Evaluation-Guide]] to identify pros and cons of the APIs used. 

Status: work-in-progress (https://github.com/flutter/uxr/issues/7)

Deliverables: 
* A package feature [comparison chart](https://github.com/flutter/uxr/blob/master/nav2-usability/comparative-analysis/README.md) based on scenarios they support
* A descriptive comparison of 2+ packages with snippets implementing common scenarios
* A full comparative analysis report with usability evaluations based on a set of rubrics

## 3. API usage walkthrough study

We will recruit Flutter users to participate in a study where they will read code snippets written for a set of common navigation scenarios identified in the previous step using the page_router package. We might also include snippets written with a 3p package for the same scenarios for the purpose of making comparisons in this study. The general methodology is described in [this paper](https://ecs.wgtn.ac.nz/foswiki/pub/Events/PLATEAU/2010Program/plateau10-ocallaghan.pdf).

Status: pilot sessions completed ([summary](https://github.com/flutter/uxr/issues/40))

Deliverable: Research report with recommendations on API and documentation improvements

## 4. API usability testing + concept mapping (Optional)

After iterating on the API design based on user feedback from the walkthrough study, we will evaluate how well the user can learn the API, build a mental model of how it works, and write new code against a set of requirements using the API. 

API usability testing simulates the process of learning a new API for the first time to implement a realistic feature and it offers an opportunity for the API designer to observe the participant’s thought process. 

Status: No started

Deliverable: Research report with recommendations on API and documentation improvements

# Getting involved

You can contribute to the project in the following ways:

1. Suggest a navigation package for us to study. We're aware of the following packages: [auto_route](https://github.com/Milad-Akarie/auto_route_library), [beamer](https://pub.dev/packages/beamer), [flouter](https://github.com/Kleak/flouter), [flit_router](https://github.com/polyflection/flit_router), and [vrouter](https://pub.dev/packages/vrouter). 

2. Contribute code snippets for one or more navigation scenarios (https://github.com/flutter/uxr/issues/9).

3. Engage discussions about API design proposals and research results in this repo's [Discussions section](https://github.com/flutter/uxr/discussions/categories/routing-api-research) and the [#router-research channel](https://discord.com/channels/608014603317936148/813579416264507422) on the Discord server for Flutter contributors .
