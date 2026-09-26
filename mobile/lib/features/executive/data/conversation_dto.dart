/// Wire mapping for conversations and messages (proposed paths, Epic E).
///
/// Nothing here reads a phone number: `MSG-06` forbids the serializer from
/// sending one to a non-executive, and even for an executive the thread
/// screen has no field to put it in.
library;

import '../../../core/authorization/raeed_role.dart';
import '../../../core/network/api_envelope.dart';
import '../domain/conversation.dart';
import 'wire_helpers.dart';

const Map<String, ConversationKind> _kindByWire = {
  'child': ConversationKind.child,
  'staff': ConversationKind.staff,
  'executive': ConversationKind.executive,
};

const Map<String, MessageKind> _messageKindByWire = {
  'text': MessageKind.text,
  'voice': MessageKind.voice,
  'file': MessageKind.file,
};

ConversationSummary conversationSummaryFromJson(Map<String, Object?> json) {
  final last = objectOrNull(json['last_message']);
  return ConversationSummary(
    id: requireField<String>(json, 'id'),
    kind: enumFromWire(
      json['type'] ?? json['kind'],
      _kindByWire,
      fallback: ConversationKind.child,
    ),
    title: stringOrNull(json['title']) ?? '',
    // Defaults to *not* a member: the safe error is showing an oversight
    // notice to a member, never hiding it from an overseer.
    isMember: boolOr(json['is_member'], false),
    groupName: stringOrNull(json['group_name']),
    lastMessagePreview:
        stringOrNull(last?['preview']) ??
        stringOrNull(last?['body']) ??
        stringOrNull(json['last_message_preview']),
    lastMessageAt:
        dateOrNull(last?['sent_at']) ??
        dateOrNull(last?['created_at']) ??
        dateOrNull(json['last_message_at']),
    unreadCount: intOrNull(json['unread_count']) ?? 0,
    hasOpenReport: boolOr(json['has_open_report'], false),
  );
}

ConversationDetail conversationDetailFromJson(Map<String, Object?> json) {
  final members = objectList(json['members'], field: 'members');
  return ConversationDetail(
    id: requireField<String>(json, 'id'),
    kind: enumFromWire(
      json['type'] ?? json['kind'],
      _kindByWire,
      fallback: ConversationKind.child,
    ),
    title: stringOrNull(json['title']) ?? '',
    isMember: boolOr(json['is_member'], false),
    memberNames: members.isNotEmpty
        ? [
            for (final member in members)
              if (firstString(member, ['label', 'display_name', 'full_name'])
                  case final String name)
                name,
          ]
        : stringList(json['member_names']),
  );
}

ChatMessage chatMessageFromJson(Map<String, Object?> json) {
  final sender = objectOrNull(json['sender']);
  final hidden = objectOrNull(json['hidden']);
  final report = objectOrNull(json['report']);
  final hiddenAt =
      dateOrNull(hidden?['at']) ??
      dateOrNull(hidden?['hidden_at']) ??
      dateOrNull(json['hidden_at']);
  final roleWire =
      stringOrNull(sender?['role']) ?? stringOrNull(json['sender_role']);

  return ChatMessage(
    id: requireField<String>(json, 'id'),
    senderId:
        stringOrNull(sender?['id']) ?? stringOrNull(json['sender_id']) ?? '',
    senderName:
        firstString(sender ?? const {}, ['display_name', 'full_name']) ??
        stringOrNull(json['sender_name']) ??
        '',
    senderRole: roleWire == null ? null : RaeedRole.fromWire(roleWire),
    kind: enumFromWire(
      json['kind'],
      _messageKindByWire,
      fallback: MessageKind.text,
    ),
    sentAt:
        dateOrNull(json['sent_at']) ??
        dateOrNull(json['created_at']) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    body: stringOrNull(json['body']),
    durationSeconds: intOrNull(json['duration_seconds']),
    hidden: hiddenAt == null
        ? null
        : HiddenMessageInfo(
            hiddenByName:
                firstString(hidden ?? const {}, [
                  'by_name',
                  'hidden_by_name',
                ]) ??
                stringOrNull(json['hidden_by_name']) ??
                '',
            hiddenAt: hiddenAt,
          ),
    report: report == null
        ? null
        : MessageReport(
            id: stringOrNull(report['id']) ?? '',
            reporterName: stringOrNull(report['reporter_name']) ?? '',
            reason: stringOrNull(report['reason']) ?? '',
          ),
  );
}
