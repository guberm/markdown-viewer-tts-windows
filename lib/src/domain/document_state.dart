import 'dart:convert';

class RecentDocument {
  const RecentDocument({
    required this.path,
    required this.title,
    required this.lastOpenedAt,
    this.lastScrollOffset,
  });

  final String path;
  final String title;
  final DateTime lastOpenedAt;
  final double? lastScrollOffset;

  RecentDocument copyWith({
    String? path,
    String? title,
    DateTime? lastOpenedAt,
    double? lastScrollOffset,
    bool clearScrollOffset = false,
  }) {
    return RecentDocument(
      path: path ?? this.path,
      title: title ?? this.title,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      lastScrollOffset: clearScrollOffset
          ? null
          : (lastScrollOffset ?? this.lastScrollOffset),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'path': path,
      'title': title,
      'lastOpenedAt': lastOpenedAt.toIso8601String(),
      'lastScrollOffset': lastScrollOffset,
    };
  }

  factory RecentDocument.fromMap(Map<String, dynamic> map) {
    return RecentDocument(
      path: map['path'] as String,
      title: map['title'] as String,
      lastOpenedAt: DateTime.parse(map['lastOpenedAt'] as String),
      lastScrollOffset: (map['lastScrollOffset'] as num?)?.toDouble(),
    );
  }
}

class DocumentStateStore {
  DocumentStateStore({
    List<RecentDocument>? recentDocuments,
    this.maxRecentDocuments = 12,
  }) : _recentDocuments = List<RecentDocument>.from(recentDocuments ?? const []);

  final int maxRecentDocuments;
  final List<RecentDocument> _recentDocuments;

  List<RecentDocument> get recentDocuments =>
      List<RecentDocument>.unmodifiable(_recentDocuments);

  void recordOpen(String path, String title, {DateTime? openedAt}) {
    final now = openedAt ?? DateTime.now();
    final existing = _recentDocuments.where((doc) => doc.path == path).toList();
    final scrollOffset = existing.isEmpty ? null : existing.first.lastScrollOffset;

    _recentDocuments
      ..removeWhere((doc) => doc.path == path)
      ..insert(
        0,
        RecentDocument(
          path: path,
          title: title,
          lastOpenedAt: now,
          lastScrollOffset: scrollOffset,
        ),
      );

    if (_recentDocuments.length > maxRecentDocuments) {
      _recentDocuments.removeRange(maxRecentDocuments, _recentDocuments.length);
    }
  }

  void saveReadingPosition(String path, double offset) {
    final index = _recentDocuments.indexWhere((doc) => doc.path == path);
    if (index < 0) return;
    _recentDocuments[index] = _recentDocuments[index].copyWith(
      lastScrollOffset: offset,
    );
  }

  double? getReadingPosition(String path) {
    final index = _recentDocuments.indexWhere((doc) => doc.path == path);
    return index < 0 ? null : _recentDocuments[index].lastScrollOffset;
  }

  RecentDocument? getMostRecentDocument() {
    return _recentDocuments.isEmpty ? null : _recentDocuments.first;
  }

  void clearAll() {
    _recentDocuments.clear();
  }

  String toJson() {
    return jsonEncode(
      _recentDocuments.map((doc) => doc.toMap()).toList(growable: false),
    );
  }

  factory DocumentStateStore.fromJson(
    String? raw, {
    int maxRecentDocuments = 12,
  }) {
    if (raw == null || raw.trim().isEmpty) {
      return DocumentStateStore(maxRecentDocuments: maxRecentDocuments);
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return DocumentStateStore(
        maxRecentDocuments: maxRecentDocuments,
        recentDocuments: decoded
            .map((item) => RecentDocument.fromMap(item as Map<String, dynamic>))
            .toList(growable: false),
      );
    } catch (_) {
      return DocumentStateStore(maxRecentDocuments: maxRecentDocuments);
    }
  }
}
