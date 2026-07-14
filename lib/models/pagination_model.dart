class Pagination {
  int page;
  int limit;
  int total;
  int totalPages;

  Pagination({this.page = 1, this.limit = 20, this.total = 0, this.totalPages = 1});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json["page"] ?? 1,
    limit: json["limit"] ?? 20,
    total: json["total"] ?? 0,
    totalPages: json["totalPages"] ?? 1,
  );
}
