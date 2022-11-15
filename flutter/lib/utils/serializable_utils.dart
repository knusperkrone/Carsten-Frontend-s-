Iterable<dynamic> genericListFromJson(List<dynamic> json) => json;
List<Map> genericListToJson(Iterable<dynamic> items) => new List.from(items);

dynamic genericObjectFromJson(dynamic json) => json;
dynamic genericObjectToJson(dynamic item) => item;
