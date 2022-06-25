mixin CacheMixin {
  final Map<String, dynamic> _cache = {};

  T cachedData<T>(String key, T Function() ifAbsent) {
    return _cache.putIfAbsent(key, ifAbsent);
  }
}
