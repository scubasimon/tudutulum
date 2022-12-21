import 'package:tudu/models/event.dart';
import 'package:tudu/utils/func_utils.dart';

import '../../consts/strings/str_const.dart';
import '../../services/firebase/firebase_service.dart';

abstract class EventRepository {
  List<Event> getEventsWithFilterSortSearch(
      List<Event> listSiteInput, int? businessFilterId, String? keywordSort, String? keywordSearch);
}

class EventRepositoryImpl extends EventRepository {
  @override
  List<Event> getEventsWithFilterSortSearch(
    List<Event> listEventInput,
    int? eventTypeFilterId,
    String? keywordSort,
    String? keywordSearch,
  ) {
    // Clone data of input Events
    List<Event> listEventResult = listEventInput.where((event) => true).toList();
    // Filter with eventTypeId (Filter function)
    if (eventTypeFilterId != null) {
      if (eventTypeFilterId != -1) {
        listEventResult = listEventResult
            .where((event) => (event.eventTypes != null) && event.eventTypes!.contains(eventTypeFilterId))
            .toList();
      }
    }

    // Sort with keywordSort (Sort function)
    if (keywordSort != null) {
      if (keywordSort == StrConst.sortTitle) {
        // Sort with title
        listEventResult.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      } else if (keywordSort == StrConst.sortDistance) {
        // Sort with distance ///TODO: IMPL LOGIC
        listEventResult.sort((a, b) => a.title.compareTo(b.title));
      } else {
        throw Exception("Sort type not found. Please check again");
      }
    }

    // Filter with keywordSearch (Search function)
    if (keywordSearch != null) {
      if (keywordSearch.isNotEmpty) {
        listEventResult =
            listEventResult.where((site) => site.title.toLowerCase().contains(keywordSearch.toLowerCase())).toList();
      }
    }

    return listEventResult;
  }
}
