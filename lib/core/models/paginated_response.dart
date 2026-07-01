// lib/core/models/paginated_response.dart

class PaginatedResponse<T> {
  final int     count;
  final String? next;
  final String? previous;
  final List<T> results;

  const PaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  bool get hasMore     => next != null;
  bool get hasNext     => next != null;
  bool get hasPrevious => previous != null;

  int totalPages(int pageSize) =>
      pageSize > 0 ? (count / pageSize).ceil().clamp(1, 9999) : 1;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PaginatedResponse<T>(
      count:    json['count']    as int,
      next:     json['next']     as String?,
      previous: json['previous'] as String?,
      results:  (json['results'] as List)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
