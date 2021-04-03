# Flutter Router Package Comparative Analysis  
As part of the [Navigator 2.0 API Usability Research](https://github.com/flutter/uxr/wiki/Navigator-2.0-API-Usability-Research), we have conducted a [preliminary comparative analysis](https://github.com/flutter/uxr/issues/13) of existing router packages Flutter community has produced around common navigation scenarios ([PDF](https://github.com/flutter/uxr/blob/master/nav2-usability/storyboards/%5BPublic%5D%20Flutter%20Navigator%20Scenarios%20Storyboards%20v2.pdf)) the Flutter UX Research team has identified through previous user studies.  
  
## Analysis  
Scroll right to see all >

|  | auto_route | beamer | flit-router | flouter | flow_builder | fluro | flutter_modular | navi | page_router | qlevar_router | routemaster | vrouter |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **Deep Linking - Path Parameters** | ✅ | ✅ | ✅ | ✅ | 🆇 - in TODO list | ✅ | ✅ | ✅ - currently only work for root stack. Support for child stacks is in TODO list | ✅ | ✅ | ✅ | ✅ |
|  |  |  |  |  |  |  |  | [example app](https://github.com/zenonine/navi/tree/master/examples/uxr/1-deep-linking-path-parameters) |  |  |  | [code snippets](https://github.com/lulupointu/vrouter_navigator_scenarios/blob/main/lib/path_parameters.dart) |
| **Deep Linking - Query Parameters** | ✅ | ✅ | ✅ | ✅ | 🆇 | ✅ | ✅ | ✅ - currently only work for root stack. Support for child stacks is in TODO list | 🆇 - in TODO list | ✅ | ✅ | ✅ |
|  |  |  |  |  |  |  |  | [example app](https://github.com/zenonine/navi/tree/master/examples/uxr/2-deep-linking-query-parameters) |  |  |  | [code snippets](https://github.com/lulupointu/vrouter_navigator_scenarios/blob/main/lib/query_parameters.dart) |
| **Dynamic Linking** | ✅ | ✅ | ✅ | ✅ | 🆇 - in TODO list | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
|  |  |  |  |  |  |  |  |  |  |  |  | [code snippets](https://github.com/lulupointu/vrouter_navigator_scenarios/blob/main/lib/dynamic_linking.dart) |
| **Validation (Login/Logout/Sign-up Routing)** | ✅ - route validation happens at the route pattern level, but no custom validators (e.g. check if id is valid before routing) | ✅ - BeamGuard | 🆇 - in TODO list | 🆇 | ✅ | 🆇 - in TODO list | ✅ | ✅ | ✅ - no way to specify "default" route when validation fails (e.g. go to login/ screen if user is logged out) | ✅ | ✅ | ✅- VNavigationGuard |
|  |  |  |  |  |  |  |  | [example app](https://github.com/zenonine/navi/tree/master/examples/uxr/3a-authentication-home) |  |  |  | [code snippets](https://github.com/lulupointu/vrouter_navigator_scenarios/blob/main/lib/login_logout.dart) |
| **Nested Routing** | ✅ | ✅ | 🆇 - in TODO list (highest priority) | 🆇 - in TODO list | ✅ | 🆇 - in TODO list | ✅ | ✅ - no web yet | 🆇 | ✅ | ✅ | ✅ |
|  |  |  |  |  |  |  |  |  |  |  |  | [code snippets](https://github.com/lulupointu/vrouter_navigator_scenarios/blob/main/lib/nested_routing.dart) |
| **Skipping Stacks** | ✅ | ✅ | ✅ | ✅ | ✅ | 🆇 | 🆇 | ✅ - currently only possible via updating `StackOutlet` witget. Update state to switch stack in TODO list.  | ✅ | ✅ | ✅ | ✅ |
|  |  |  |  |  |  |  |  |  |  |  |  | [code snippets](https://github.com/lulupointu/vrouter_navigator_scenarios/blob/main/lib/skipping_stacks.dart) |
| **Custom Pages / Custom transition animations** | ✅ | ✅ - slovnicki/beamer#51 (TODO: slovnicki/beamer#108) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅- Custom transitions are supported, but custom Page objects aren't (it currently hard-codes MaterialPage) |
|  |  |  |  |  |  |  |  |  |  |  |  |  |


## Packages Included in the Analysis  
Learn more about the packcages inluded in this analysis on Github:  
  
- [auto_route](https://github.com/Milad-Akarie/auto_route_library)
- [beamer](https://github.com/slovnicki/beamer)
- [flit-router](https://github.com/polyflection/flit_router)
- [flouter](https://github.com/Kleak/flouter)
- [flow_builder](https://github.com/felangel/flow_builder)
- [fluro](https://github.com/lukepighetti/fluro)
- [flutter_modular](https://github.com/Flutterando/modular)
- [navi](https://github.com/zenonine/navi)
- [page_router](https://github.com/johnpryan/page_router)
- [qlevar_router](https://github.com/SchabanBo/qlevar_router)
- [routemaster](https://github.com/tomgilder/routemaster)
- [vrouter](https://github.com/lulupointu/vrouter)
 
## Acknowledgment  
Authors of the abovementioned packages shared their feedback on the analysis via email and Github [comments](https://github.com/flutter/uxr/issues/13). We appreciate your contributions.  
  
## This is a living document
This analysis is not final, and this page is meant to be a living document. Please feel free to add or edit content by opening a pull request.  
  
## What's Next  
Our immediate next step in the [Navigator 2.0 API Usability Research](https://github.com/flutter/uxr/wiki/Navigator-2.0-API-Usability-Research) is to conduct a more detailed evaluation ([#7](https://github.com/flutter/uxr/issues/7)) of usability benefits and disadvantages based on code snippets ([#9](https://github.com/flutter/uxr/issues/9)) provided by package authors based on the finalized navigator scenarios in [#4](https://github.com/flutter/uxr/issues/4). We have about 5 authors who expressed interest so far to participate in the next round and contribute code snippets for the usability evaluation. We will share a more detailed plan here: [#9](https://github.com/flutter/uxr/issues/9)
