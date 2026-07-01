// lib/features/aulas/domain/entities/paged_result.dart

/// Resultado paginado genérico devuelto por los endpoints de listado
/// (mapea la respuesta estándar de DRF: count / next / previous / results).
class PagedResult<T> {
  final List<T> items;
  final bool hasNext;
  final int? count;

  const PagedResult({
    required this.items,
    required this.hasNext,
    this.count,
  });

  PagedResult<R> map<R>(R Function(T) convert) => PagedResult<R>(
        items: items.map(convert).toList(),
        hasNext: hasNext,
        count: count,
      );
}