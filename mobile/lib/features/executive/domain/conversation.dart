import 'package:meta/meta.dart';

import '../../../core/authorization/ability.dart' show ConversationKind;
import '../../../core/authorization/raeed_role.dart';

export '../../../core/authorization/ability.dart' show ConversationKind;

/// One row of the executive's thread list.
@immutable
class ConversationSummary {
  const ConversationSummary({
    required this.id,
    required this.kind,
    required this.title,
    required this.isMember,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.hasOpenReport = false,
  });

  final String id;
  final ConversationKind kind;

  /// The child's name for a child thread, the group's for a staff channel.
  final String title;

  /// Whether the executive is a participant. When false, reading is oversight
  /// (`MSG-08`): logged, and disclosed to the members.
  final bool isMember;

  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int unreadCount;

  /// Whether a message in this thread was reported and not yet resolved.
  final bool hasOpenReport;
}

/// A thread's header.
@immutable
class ConversationDetail {
  const ConversationDetail({
    required this.id,
    required this.kind,
    required this.title,
    required this.isMember,
    this.memberNames = const [],
  });

  final String id;
  final ConversationKind kind;
  final String title;
  final bool isMember;

  /// Display names with a role word, e.g. "سعاد (الأم)" — rendered by the
  /// server, which knows each member's relationship to the child. Never a
  /// phone number (`MSG-06`).
  final List<String> memberNames;
}

/// `message.kind` from `specs/03-domain-model/schema.sql`.
enum MessageKind {
  text('text'),
  voice('voice'),
  file('file');

  const MessageKind(this.wireValue);

  final String wireValue;
}

/// A message hidden by an executive — still visible to executives, marked.
@immutable
class HiddenMessageInfo {
  const HiddenMessageInfo({required this.hiddenByName, required this.hiddenAt});

  final String hiddenByName;
  final DateTime hiddenAt;
}

/// An open report on a message.
@immutable
class MessageReport {
  const MessageReport({
    required this.id,
    required this.reporterName,
    required this.reason,
  });

  final String id;
  final String reporterName;

  /// Already worded by the server, e.g. "طلب معلومات شخصية".
  final String reason;
}

/// One message in a thread.
@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.kind,
    required this.sentAt,
    this.senderRole,
    this.body,
    this.durationSeconds,
    this.hidden,
    this.report,
  });

  final String id;
  final String senderId;
  final String senderName;

  /// The role the sender wrote as — an educator, a guardian, an executive.
  final RaeedRole? senderRole;

  final MessageKind kind;
  final DateTime sentAt;
  final String? body;

  /// For a voice note.
  final int? durationSeconds;

  /// Set when the message was hidden (`MSG-08`). Hidden is never deleted.
  final HiddenMessageInfo? hidden;

  /// Set while a report on it is open.
  final MessageReport? report;

  bool get isHidden => hidden != null;
  bool get isReported => report != null;

  /// Whether [userId] wrote this.
  bool isFrom(String userId) => senderId == userId;

  ChatMessage hiddenBy({required String name, required DateTime at}) =>
      ChatMessage(
        id: id,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        kind: kind,
        sentAt: sentAt,
        body: body,
        durationSeconds: durationSeconds,
        hidden: HiddenMessageInfo(hiddenByName: name, hiddenAt: at),
      );

  ChatMessage withoutReport() => ChatMessage(
    id: id,
    senderId: senderId,
    senderName: senderName,
    senderRole: senderRole,
    kind: kind,
    sentAt: sentAt,
    body: body,
    durationSeconds: durationSeconds,
    hidden: hidden,
  );
}
