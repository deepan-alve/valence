/// The 8 types of events that appear in the group feed timeline.
enum FeedItemType {
  /// A member completed a habit. May include plugin verification badge.
  completion,

  /// A member missed a habit. Framing is always supportive, never punitive.
  /// Only shown for habits with Full visibility.
  miss,

  /// A member nudged another member. The actual LLM-generated message is
  /// private — the feed only shows that a nudge was sent.
  nudge,

  /// A member sent kudos to another member.
  kudos,

  /// A status+norm message (e.g. streak milestone + group norm).
  statusNorm,

  /// End-of-day chain link result (Gold/Silver/Broken).
  chainLink,

  /// A habit reached a goal graduation milestone (Foundation, Momentum, etc.).
  milestone,

  /// A member used a streak freeze to protect the chain.
  streakFreeze,
}

/// A single event in the group feed timeline.
class FeedItem {
  final String id;
  final FeedItemType type;
  final String senderName;
  final String senderId;
  final String? receiverName;
  final String? receiverId;
  final DateTime timestamp;
  final String? habitName;
  final String? verificationSource;
  final String? message;

  const FeedItem({
    required this.id,
    required this.type,
    required this.senderName,
    required this.senderId,
    this.receiverName,
    this.receiverId,
    required this.timestamp,
    this.habitName,
    this.verificationSource,
    this.message,
  });

  /// Relative time label: "now", "2min", "3h", "1d".
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
