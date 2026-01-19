class EntityOptions {
  const EntityOptions({
    required this.statuses,
    required this.categories,
  });

  final List<String> statuses;
  final List<String> categories;

  Map<String, dynamic> toJson() {
    return {
      'statuses': statuses,
      'categories': categories,
    };
  }

  factory EntityOptions.fromJson(Map<String, dynamic> json) {
    final rawStatuses = json['statuses'];
    final rawCategories = json['categories'];

    return EntityOptions(
      statuses: rawStatuses is List
          ? rawStatuses.map((value) => value.toString()).toList()
          : const [],
      categories: rawCategories is List
          ? rawCategories.map((value) => value.toString()).toList()
          : const [],
    );
  }
}
