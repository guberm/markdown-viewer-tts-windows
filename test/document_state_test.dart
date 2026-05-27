import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_viewer_tts_windows/src/domain/document_state.dart';

void main() {
  test('records recent documents in most recent first order', () {
    final store = DocumentStateStore(maxRecentDocuments: 3);

    store.recordOpen('a.md', 'A');
    store.recordOpen('b.md', 'B');
    store.recordOpen('a.md', 'A updated');

    final recent = store.recentDocuments;
    expect(recent, hasLength(2));
    expect(recent.first.path, 'a.md');
    expect(recent.first.title, 'A updated');
    expect(recent.last.path, 'b.md');
  });

  test('keeps only configured recent history limit', () {
    final store = DocumentStateStore(maxRecentDocuments: 2);

    store.recordOpen('a.md', 'A');
    store.recordOpen('b.md', 'B');
    store.recordOpen('c.md', 'C');

    expect(store.recentDocuments.map((doc) => doc.path).toList(), ['c.md', 'b.md']);
  });

  test('stores reading positions per document', () {
    final store = DocumentStateStore();

    store.recordOpen('a.md', 'A');
    store.saveReadingPosition('a.md', 420.5);

    expect(store.getReadingPosition('a.md'), 420.5);
    expect(store.recentDocuments.first.lastScrollOffset, 420.5);
    expect(store.getReadingPosition('missing.md'), isNull);
  });

  test('round-trips recent docs and offsets through json', () {
    final store = DocumentStateStore();
    store.recordOpen('a.md', 'A');
    store.saveReadingPosition('a.md', 12.0);

    final restored = DocumentStateStore.fromJson(store.toJson());

    expect(restored.recentDocuments, hasLength(1));
    expect(restored.recentDocuments.first.path, 'a.md');
    expect(restored.getReadingPosition('a.md'), 12.0);
  });

  test('clearAll removes history and offsets', () {
    final store = DocumentStateStore();
    store.recordOpen('a.md', 'A');
    store.saveReadingPosition('a.md', 12.0);

    store.clearAll();

    expect(store.recentDocuments, isEmpty);
    expect(store.getReadingPosition('a.md'), isNull);
  });
}