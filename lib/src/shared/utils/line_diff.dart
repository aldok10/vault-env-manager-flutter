/// 🧬 LCS-Based Line Diff Algorithm
/// Pure Dart implementation — no external dependencies.
/// Produces git-style unified diff output.

/// The type of change for a diff line.
enum DiffOperation { equal, insert, delete }

/// A single line in the diff output.
class DiffLine {
  final DiffOperation operation;
  final String text;

  /// Line number in the OLD text (null for insertions).
  final int? oldLineNumber;

  /// Line number in the NEW text (null for deletions).
  final int? newLineNumber;

  const DiffLine({
    required this.operation,
    required this.text,
    this.oldLineNumber,
    this.newLineNumber,
  });

  String get prefix {
    switch (operation) {
      case DiffOperation.insert:
        return '+';
      case DiffOperation.delete:
        return '-';
      case DiffOperation.equal:
        return ' ';
    }
  }
}

/// A hunk header (e.g. @@ -1,5 +1,7 @@).
class DiffHunk {
  final int oldStart;
  final int oldCount;
  final int newStart;
  final int newCount;
  final List<DiffLine> lines;

  const DiffHunk({
    required this.oldStart,
    required this.oldCount,
    required this.newStart,
    required this.newCount,
    required this.lines,
  });

  String get header =>
      '@@ -$oldStart,$oldCount +$newStart,$newCount @@';
}

/// Computes a unified diff between [oldText] and [newText].
class LineDiff {
  /// Context lines around each change (like `git diff -U3`).
  final int contextLines;

  const LineDiff({this.contextLines = 3});

  /// Returns the full list of [DiffLine]s (every line, not just hunks).
  List<DiffLine> computeFull(String oldText, String newText) {
    final oldLines = oldText.split('\n');
    final newLines = newText.split('\n');

    final lcs = _computeLCS(oldLines, newLines);
    return _buildFullDiff(oldLines, newLines, lcs);
  }

  /// Returns grouped [DiffHunk]s with context, like `git diff`.
  List<DiffHunk> computeHunks(String oldText, String newText) {
    final fullDiff = computeFull(oldText, newText);
    return _groupIntoHunks(fullDiff);
  }

  /// Stats: additions, deletions.
  ({int additions, int deletions}) computeStats(
    String oldText,
    String newText,
  ) {
    final diff = computeFull(oldText, newText);
    final additions =
        diff.where((d) => d.operation == DiffOperation.insert).length;
    final deletions =
        diff.where((d) => d.operation == DiffOperation.delete).length;
    return (additions: additions, deletions: deletions);
  }

  // ── LCS Table ────────────────────────────────────────────────────────
  List<List<int>> _computeLCS(List<String> a, List<String> b) {
    final m = a.length;
    final n = b.length;
    final table = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (a[i - 1] == b[j - 1]) {
          table[i][j] = table[i - 1][j - 1] + 1;
        } else {
          table[i][j] = table[i - 1][j] > table[i][j - 1]
              ? table[i - 1][j]
              : table[i][j - 1];
        }
      }
    }
    return table;
  }

  // ── Full Diff via LCS Backtrack ──────────────────────────────────────
  List<DiffLine> _buildFullDiff(
    List<String> oldLines,
    List<String> newLines,
    List<List<int>> lcs,
  ) {
    final result = <DiffLine>[];
    int i = oldLines.length;
    int j = newLines.length;

    while (i > 0 || j > 0) {
      if (i > 0 && j > 0 && oldLines[i - 1] == newLines[j - 1]) {
        result.add(DiffLine(
          operation: DiffOperation.equal,
          text: newLines[j - 1],
          oldLineNumber: i,
          newLineNumber: j,
        ));
        i--;
        j--;
      } else if (j > 0 && (i == 0 || lcs[i][j - 1] >= lcs[i - 1][j])) {
        result.add(DiffLine(
          operation: DiffOperation.insert,
          text: newLines[j - 1],
          newLineNumber: j,
        ));
        j--;
      } else if (i > 0) {
        result.add(DiffLine(
          operation: DiffOperation.delete,
          text: oldLines[i - 1],
          oldLineNumber: i,
        ));
        i--;
      }
    }

    return result.reversed.toList();
  }

  // ── Group into Hunks ─────────────────────────────────────────────────
  List<DiffHunk> _groupIntoHunks(List<DiffLine> fullDiff) {
    if (fullDiff.isEmpty) return [];

    // Find indices of changed lines
    final changedIndices = <int>[];
    for (int i = 0; i < fullDiff.length; i++) {
      if (fullDiff[i].operation != DiffOperation.equal) {
        changedIndices.add(i);
      }
    }

    if (changedIndices.isEmpty) return [];

    // Group changes that are within contextLines of each other
    final hunks = <DiffHunk>[];
    int groupStart = changedIndices.first;
    int groupEnd = changedIndices.first;

    for (int k = 1; k < changedIndices.length; k++) {
      if (changedIndices[k] - groupEnd <= contextLines * 2 + 1) {
        groupEnd = changedIndices[k];
      } else {
        hunks.add(_buildHunk(fullDiff, groupStart, groupEnd));
        groupStart = changedIndices[k];
        groupEnd = changedIndices[k];
      }
    }
    hunks.add(_buildHunk(fullDiff, groupStart, groupEnd));

    return hunks;
  }

  DiffHunk _buildHunk(List<DiffLine> fullDiff, int start, int end) {
    final hunkStart = (start - contextLines).clamp(0, fullDiff.length);
    final hunkEnd = (end + contextLines + 1).clamp(0, fullDiff.length);
    final lines = fullDiff.sublist(hunkStart, hunkEnd);

    // Calculate old/new start line numbers
    int oldStart = 1;
    int newStart = 1;
    for (int i = 0; i < hunkStart; i++) {
      if (fullDiff[i].operation != DiffOperation.insert) oldStart++;
      if (fullDiff[i].operation != DiffOperation.delete) newStart++;
    }

    int oldCount = lines
        .where((l) => l.operation != DiffOperation.insert)
        .length;
    int newCount = lines
        .where((l) => l.operation != DiffOperation.delete)
        .length;

    return DiffHunk(
      oldStart: oldStart,
      oldCount: oldCount,
      newStart: newStart,
      newCount: newCount,
      lines: lines,
    );
  }
}
