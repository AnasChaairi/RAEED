// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raeed_database.dart';

// ignore_for_file: type=lint
class $CachedSessionsTable extends CachedSessions
    with TableInfo<$CachedSessionsTable, CachedSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupNameMeta = const VerificationMeta(
    'groupName',
  );
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startsAtMeta = const VerificationMeta(
    'startsAt',
  );
  @override
  late final GeneratedColumn<DateTime> startsAt = GeneratedColumn<DateTime>(
    'starts_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsAtMeta = const VerificationMeta('endsAt');
  @override
  late final GeneratedColumn<DateTime> endsAt = GeneratedColumn<DateTime>(
    'ends_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupId,
    groupName,
    startsAt,
    endsAt,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
      );
    } else if (isInserting) {
      context.missing(_groupNameMeta);
    }
    if (data.containsKey('starts_at')) {
      context.handle(
        _startsAtMeta,
        startsAt.isAcceptableOrUnknown(data['starts_at']!, _startsAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startsAtMeta);
    }
    if (data.containsKey('ends_at')) {
      context.handle(
        _endsAtMeta,
        endsAt.isAcceptableOrUnknown(data['ends_at']!, _endsAtMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      )!,
      startsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starts_at'],
      )!,
      endsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ends_at'],
      ),
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedSessionsTable createAlias(String alias) {
    return $CachedSessionsTable(attachedDatabase, alias);
  }
}

class CachedSession extends DataClass implements Insertable<CachedSession> {
  /// `session.id`.
  final String id;

  /// `session.group_id` — the group whose attendance this sheet belongs to.
  final String groupId;

  /// The group's display name, denormalised so the screen has a title offline.
  final String groupName;

  /// When the session starts (UTC).
  final DateTime startsAt;

  /// When the session ends (UTC), where the server supplied it.
  final DateTime? endsAt;

  /// When this row was last refreshed from the server.
  final DateTime cachedAt;
  const CachedSession({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.startsAt,
    this.endsAt,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['group_name'] = Variable<String>(groupName);
    map['starts_at'] = Variable<DateTime>(startsAt);
    if (!nullToAbsent || endsAt != null) {
      map['ends_at'] = Variable<DateTime>(endsAt);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedSessionsCompanion toCompanion(bool nullToAbsent) {
    return CachedSessionsCompanion(
      id: Value(id),
      groupId: Value(groupId),
      groupName: Value(groupName),
      startsAt: Value(startsAt),
      endsAt: endsAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endsAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedSession(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      groupName: serializer.fromJson<String>(json['groupName']),
      startsAt: serializer.fromJson<DateTime>(json['startsAt']),
      endsAt: serializer.fromJson<DateTime?>(json['endsAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'groupName': serializer.toJson<String>(groupName),
      'startsAt': serializer.toJson<DateTime>(startsAt),
      'endsAt': serializer.toJson<DateTime?>(endsAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedSession copyWith({
    String? id,
    String? groupId,
    String? groupName,
    DateTime? startsAt,
    Value<DateTime?> endsAt = const Value.absent(),
    DateTime? cachedAt,
  }) => CachedSession(
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    groupName: groupName ?? this.groupName,
    startsAt: startsAt ?? this.startsAt,
    endsAt: endsAt.present ? endsAt.value : this.endsAt,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedSession copyWithCompanion(CachedSessionsCompanion data) {
    return CachedSession(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      startsAt: data.startsAt.present ? data.startsAt.value : this.startsAt,
      endsAt: data.endsAt.present ? data.endsAt.value : this.endsAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedSession(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('groupName: $groupName, ')
          ..write('startsAt: $startsAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, groupId, groupName, startsAt, endsAt, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedSession &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.groupName == this.groupName &&
          other.startsAt == this.startsAt &&
          other.endsAt == this.endsAt &&
          other.cachedAt == this.cachedAt);
}

class CachedSessionsCompanion extends UpdateCompanion<CachedSession> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> groupName;
  final Value<DateTime> startsAt;
  final Value<DateTime?> endsAt;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedSessionsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.groupName = const Value.absent(),
    this.startsAt = const Value.absent(),
    this.endsAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedSessionsCompanion.insert({
    required String id,
    required String groupId,
    required String groupName,
    required DateTime startsAt,
    this.endsAt = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       groupId = Value(groupId),
       groupName = Value(groupName),
       startsAt = Value(startsAt),
       cachedAt = Value(cachedAt);
  static Insertable<CachedSession> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? groupName,
    Expression<DateTime>? startsAt,
    Expression<DateTime>? endsAt,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (groupName != null) 'group_name': groupName,
      if (startsAt != null) 'starts_at': startsAt,
      if (endsAt != null) 'ends_at': endsAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? groupId,
    Value<String>? groupName,
    Value<DateTime>? startsAt,
    Value<DateTime?>? endsAt,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedSessionsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (startsAt.present) {
      map['starts_at'] = Variable<DateTime>(startsAt.value);
    }
    if (endsAt.present) {
      map['ends_at'] = Variable<DateTime>(endsAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedSessionsCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('groupName: $groupName, ')
          ..write('startsAt: $startsAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedAttendanceEntriesTable extends CachedAttendanceEntries
    with TableInfo<$CachedAttendanceEntriesTable, CachedAttendanceEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedAttendanceEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cached_sessions (id)',
    ),
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childNameMeta = const VerificationMeta(
    'childName',
  );
  @override
  late final GeneratedColumn<String> childName = GeneratedColumn<String>(
    'child_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasHealthAlertMeta = const VerificationMeta(
    'hasHealthAlert',
  );
  @override
  late final GeneratedColumn<bool> hasHealthAlert = GeneratedColumn<bool>(
    'has_health_alert',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_health_alert" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _presenceAnswerMeta = const VerificationMeta(
    'presenceAnswer',
  );
  @override
  late final GeneratedColumn<String> presenceAnswer = GeneratedColumn<String>(
    'presence_answer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _presenceReasonMeta = const VerificationMeta(
    'presenceReason',
  );
  @override
  late final GeneratedColumn<String> presenceReason = GeneratedColumn<String>(
    'presence_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverStatusMeta = const VerificationMeta(
    'serverStatus',
  );
  @override
  late final GeneratedColumn<String> serverStatus = GeneratedColumn<String>(
    'server_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverRecordedAtMeta = const VerificationMeta(
    'serverRecordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverRecordedAt =
      GeneratedColumn<DateTime>(
        'server_recorded_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    childId,
    childName,
    photoUrl,
    hasHealthAlert,
    presenceAnswer,
    presenceReason,
    serverStatus,
    serverRecordedAt,
    position,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_attendance_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedAttendanceEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('child_name')) {
      context.handle(
        _childNameMeta,
        childName.isAcceptableOrUnknown(data['child_name']!, _childNameMeta),
      );
    } else if (isInserting) {
      context.missing(_childNameMeta);
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('has_health_alert')) {
      context.handle(
        _hasHealthAlertMeta,
        hasHealthAlert.isAcceptableOrUnknown(
          data['has_health_alert']!,
          _hasHealthAlertMeta,
        ),
      );
    }
    if (data.containsKey('presence_answer')) {
      context.handle(
        _presenceAnswerMeta,
        presenceAnswer.isAcceptableOrUnknown(
          data['presence_answer']!,
          _presenceAnswerMeta,
        ),
      );
    }
    if (data.containsKey('presence_reason')) {
      context.handle(
        _presenceReasonMeta,
        presenceReason.isAcceptableOrUnknown(
          data['presence_reason']!,
          _presenceReasonMeta,
        ),
      );
    }
    if (data.containsKey('server_status')) {
      context.handle(
        _serverStatusMeta,
        serverStatus.isAcceptableOrUnknown(
          data['server_status']!,
          _serverStatusMeta,
        ),
      );
    }
    if (data.containsKey('server_recorded_at')) {
      context.handle(
        _serverRecordedAtMeta,
        serverRecordedAt.isAcceptableOrUnknown(
          data['server_recorded_at']!,
          _serverRecordedAtMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, childId};
  @override
  CachedAttendanceEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAttendanceEntry(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_id'],
      )!,
      childName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_name'],
      )!,
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      hasHealthAlert: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_health_alert'],
      )!,
      presenceAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}presence_answer'],
      ),
      presenceReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}presence_reason'],
      ),
      serverStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_status'],
      ),
      serverRecordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_recorded_at'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedAttendanceEntriesTable createAlias(String alias) {
    return $CachedAttendanceEntriesTable(attachedDatabase, alias);
  }
}

class CachedAttendanceEntry extends DataClass
    implements Insertable<CachedAttendanceEntry> {
  /// `attendance_record.session_id`.
  final String sessionId;

  /// `attendance_record.child_id`.
  final String childId;

  /// The child's display name.
  final String childName;

  /// Avatar URL, when one exists.
  final String? photoUrl;

  /// `child.health_alert` — the presence-only flag.
  ///
  /// Never the health text itself: `specs/04-api/openapi.yaml` states the full
  /// text is never inlined in a list response, and it is not cached on the
  /// device either. The badge is an icon; the text is fetched on tap-through,
  /// online, and that read is audit-logged server-side (`AUD-03`).
  final bool hasHealthAlert;

  /// The guardian's `presence_answer.answer`, when one was given.
  final String? presenceAnswer;

  /// The guardian's `presence_answer.reason`, when one was given.
  final String? presenceReason;

  /// `attendance_record.status` as the server last reported it.
  final String? serverStatus;

  /// `attendance_record.recorded_at` — **server** time, the source of truth for
  /// "who wrote last" and the left-hand side of the conflict comparison.
  final DateTime? serverRecordedAt;

  /// Preserves the order the server returned, so the list does not reshuffle
  /// between an online load and an offline one.
  final int position;

  /// When this row was last refreshed from the server.
  final DateTime cachedAt;
  const CachedAttendanceEntry({
    required this.sessionId,
    required this.childId,
    required this.childName,
    this.photoUrl,
    required this.hasHealthAlert,
    this.presenceAnswer,
    this.presenceReason,
    this.serverStatus,
    this.serverRecordedAt,
    required this.position,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['child_id'] = Variable<String>(childId);
    map['child_name'] = Variable<String>(childName);
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    map['has_health_alert'] = Variable<bool>(hasHealthAlert);
    if (!nullToAbsent || presenceAnswer != null) {
      map['presence_answer'] = Variable<String>(presenceAnswer);
    }
    if (!nullToAbsent || presenceReason != null) {
      map['presence_reason'] = Variable<String>(presenceReason);
    }
    if (!nullToAbsent || serverStatus != null) {
      map['server_status'] = Variable<String>(serverStatus);
    }
    if (!nullToAbsent || serverRecordedAt != null) {
      map['server_recorded_at'] = Variable<DateTime>(serverRecordedAt);
    }
    map['position'] = Variable<int>(position);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedAttendanceEntriesCompanion toCompanion(bool nullToAbsent) {
    return CachedAttendanceEntriesCompanion(
      sessionId: Value(sessionId),
      childId: Value(childId),
      childName: Value(childName),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      hasHealthAlert: Value(hasHealthAlert),
      presenceAnswer: presenceAnswer == null && nullToAbsent
          ? const Value.absent()
          : Value(presenceAnswer),
      presenceReason: presenceReason == null && nullToAbsent
          ? const Value.absent()
          : Value(presenceReason),
      serverStatus: serverStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(serverStatus),
      serverRecordedAt: serverRecordedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRecordedAt),
      position: Value(position),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedAttendanceEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedAttendanceEntry(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      childId: serializer.fromJson<String>(json['childId']),
      childName: serializer.fromJson<String>(json['childName']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      hasHealthAlert: serializer.fromJson<bool>(json['hasHealthAlert']),
      presenceAnswer: serializer.fromJson<String?>(json['presenceAnswer']),
      presenceReason: serializer.fromJson<String?>(json['presenceReason']),
      serverStatus: serializer.fromJson<String?>(json['serverStatus']),
      serverRecordedAt: serializer.fromJson<DateTime?>(
        json['serverRecordedAt'],
      ),
      position: serializer.fromJson<int>(json['position']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'childId': serializer.toJson<String>(childId),
      'childName': serializer.toJson<String>(childName),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'hasHealthAlert': serializer.toJson<bool>(hasHealthAlert),
      'presenceAnswer': serializer.toJson<String?>(presenceAnswer),
      'presenceReason': serializer.toJson<String?>(presenceReason),
      'serverStatus': serializer.toJson<String?>(serverStatus),
      'serverRecordedAt': serializer.toJson<DateTime?>(serverRecordedAt),
      'position': serializer.toJson<int>(position),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedAttendanceEntry copyWith({
    String? sessionId,
    String? childId,
    String? childName,
    Value<String?> photoUrl = const Value.absent(),
    bool? hasHealthAlert,
    Value<String?> presenceAnswer = const Value.absent(),
    Value<String?> presenceReason = const Value.absent(),
    Value<String?> serverStatus = const Value.absent(),
    Value<DateTime?> serverRecordedAt = const Value.absent(),
    int? position,
    DateTime? cachedAt,
  }) => CachedAttendanceEntry(
    sessionId: sessionId ?? this.sessionId,
    childId: childId ?? this.childId,
    childName: childName ?? this.childName,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    hasHealthAlert: hasHealthAlert ?? this.hasHealthAlert,
    presenceAnswer: presenceAnswer.present
        ? presenceAnswer.value
        : this.presenceAnswer,
    presenceReason: presenceReason.present
        ? presenceReason.value
        : this.presenceReason,
    serverStatus: serverStatus.present ? serverStatus.value : this.serverStatus,
    serverRecordedAt: serverRecordedAt.present
        ? serverRecordedAt.value
        : this.serverRecordedAt,
    position: position ?? this.position,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedAttendanceEntry copyWithCompanion(
    CachedAttendanceEntriesCompanion data,
  ) {
    return CachedAttendanceEntry(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      childId: data.childId.present ? data.childId.value : this.childId,
      childName: data.childName.present ? data.childName.value : this.childName,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      hasHealthAlert: data.hasHealthAlert.present
          ? data.hasHealthAlert.value
          : this.hasHealthAlert,
      presenceAnswer: data.presenceAnswer.present
          ? data.presenceAnswer.value
          : this.presenceAnswer,
      presenceReason: data.presenceReason.present
          ? data.presenceReason.value
          : this.presenceReason,
      serverStatus: data.serverStatus.present
          ? data.serverStatus.value
          : this.serverStatus,
      serverRecordedAt: data.serverRecordedAt.present
          ? data.serverRecordedAt.value
          : this.serverRecordedAt,
      position: data.position.present ? data.position.value : this.position,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedAttendanceEntry(')
          ..write('sessionId: $sessionId, ')
          ..write('childId: $childId, ')
          ..write('childName: $childName, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('hasHealthAlert: $hasHealthAlert, ')
          ..write('presenceAnswer: $presenceAnswer, ')
          ..write('presenceReason: $presenceReason, ')
          ..write('serverStatus: $serverStatus, ')
          ..write('serverRecordedAt: $serverRecordedAt, ')
          ..write('position: $position, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    childId,
    childName,
    photoUrl,
    hasHealthAlert,
    presenceAnswer,
    presenceReason,
    serverStatus,
    serverRecordedAt,
    position,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedAttendanceEntry &&
          other.sessionId == this.sessionId &&
          other.childId == this.childId &&
          other.childName == this.childName &&
          other.photoUrl == this.photoUrl &&
          other.hasHealthAlert == this.hasHealthAlert &&
          other.presenceAnswer == this.presenceAnswer &&
          other.presenceReason == this.presenceReason &&
          other.serverStatus == this.serverStatus &&
          other.serverRecordedAt == this.serverRecordedAt &&
          other.position == this.position &&
          other.cachedAt == this.cachedAt);
}

class CachedAttendanceEntriesCompanion
    extends UpdateCompanion<CachedAttendanceEntry> {
  final Value<String> sessionId;
  final Value<String> childId;
  final Value<String> childName;
  final Value<String?> photoUrl;
  final Value<bool> hasHealthAlert;
  final Value<String?> presenceAnswer;
  final Value<String?> presenceReason;
  final Value<String?> serverStatus;
  final Value<DateTime?> serverRecordedAt;
  final Value<int> position;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedAttendanceEntriesCompanion({
    this.sessionId = const Value.absent(),
    this.childId = const Value.absent(),
    this.childName = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.hasHealthAlert = const Value.absent(),
    this.presenceAnswer = const Value.absent(),
    this.presenceReason = const Value.absent(),
    this.serverStatus = const Value.absent(),
    this.serverRecordedAt = const Value.absent(),
    this.position = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedAttendanceEntriesCompanion.insert({
    required String sessionId,
    required String childId,
    required String childName,
    this.photoUrl = const Value.absent(),
    this.hasHealthAlert = const Value.absent(),
    this.presenceAnswer = const Value.absent(),
    this.presenceReason = const Value.absent(),
    this.serverStatus = const Value.absent(),
    this.serverRecordedAt = const Value.absent(),
    this.position = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       childId = Value(childId),
       childName = Value(childName),
       cachedAt = Value(cachedAt);
  static Insertable<CachedAttendanceEntry> custom({
    Expression<String>? sessionId,
    Expression<String>? childId,
    Expression<String>? childName,
    Expression<String>? photoUrl,
    Expression<bool>? hasHealthAlert,
    Expression<String>? presenceAnswer,
    Expression<String>? presenceReason,
    Expression<String>? serverStatus,
    Expression<DateTime>? serverRecordedAt,
    Expression<int>? position,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (childId != null) 'child_id': childId,
      if (childName != null) 'child_name': childName,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (hasHealthAlert != null) 'has_health_alert': hasHealthAlert,
      if (presenceAnswer != null) 'presence_answer': presenceAnswer,
      if (presenceReason != null) 'presence_reason': presenceReason,
      if (serverStatus != null) 'server_status': serverStatus,
      if (serverRecordedAt != null) 'server_recorded_at': serverRecordedAt,
      if (position != null) 'position': position,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedAttendanceEntriesCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? childId,
    Value<String>? childName,
    Value<String?>? photoUrl,
    Value<bool>? hasHealthAlert,
    Value<String?>? presenceAnswer,
    Value<String?>? presenceReason,
    Value<String?>? serverStatus,
    Value<DateTime?>? serverRecordedAt,
    Value<int>? position,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedAttendanceEntriesCompanion(
      sessionId: sessionId ?? this.sessionId,
      childId: childId ?? this.childId,
      childName: childName ?? this.childName,
      photoUrl: photoUrl ?? this.photoUrl,
      hasHealthAlert: hasHealthAlert ?? this.hasHealthAlert,
      presenceAnswer: presenceAnswer ?? this.presenceAnswer,
      presenceReason: presenceReason ?? this.presenceReason,
      serverStatus: serverStatus ?? this.serverStatus,
      serverRecordedAt: serverRecordedAt ?? this.serverRecordedAt,
      position: position ?? this.position,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (childName.present) {
      map['child_name'] = Variable<String>(childName.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (hasHealthAlert.present) {
      map['has_health_alert'] = Variable<bool>(hasHealthAlert.value);
    }
    if (presenceAnswer.present) {
      map['presence_answer'] = Variable<String>(presenceAnswer.value);
    }
    if (presenceReason.present) {
      map['presence_reason'] = Variable<String>(presenceReason.value);
    }
    if (serverStatus.present) {
      map['server_status'] = Variable<String>(serverStatus.value);
    }
    if (serverRecordedAt.present) {
      map['server_recorded_at'] = Variable<DateTime>(serverRecordedAt.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedAttendanceEntriesCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('childId: $childId, ')
          ..write('childName: $childName, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('hasHealthAlert: $hasHealthAlert, ')
          ..write('presenceAnswer: $presenceAnswer, ')
          ..write('presenceReason: $presenceReason, ')
          ..write('serverStatus: $serverStatus, ')
          ..write('serverRecordedAt: $serverRecordedAt, ')
          ..write('position: $position, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingWritesTable extends PendingWrites
    with TableInfo<$PendingWritesTable, PendingWrite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingWritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PendingWriteKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PendingWriteKind>($PendingWritesTable.$converterkind);
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtClientMeta = const VerificationMeta(
    'recordedAtClient',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAtClient =
      GeneratedColumn<DateTime>(
        'recorded_at_client',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _queuedAtMeta = const VerificationMeta(
    'queuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> queuedAt = GeneratedColumn<DateTime>(
    'queued_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PendingWriteState, String> state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pending'),
      ).withConverter<PendingWriteState>($PendingWritesTable.$converterstate);
  static const VerificationMeta _claimTokenMeta = const VerificationMeta(
    'claimToken',
  );
  @override
  late final GeneratedColumn<String> claimToken = GeneratedColumn<String>(
    'claim_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conflictPayloadMeta = const VerificationMeta(
    'conflictPayload',
  );
  @override
  late final GeneratedColumn<String> conflictPayload = GeneratedColumn<String>(
    'conflict_payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    targetId,
    childId,
    payload,
    recordedAtClient,
    queuedAt,
    state,
    claimToken,
    attempts,
    lastErrorCode,
    conflictPayload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_writes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingWrite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('recorded_at_client')) {
      context.handle(
        _recordedAtClientMeta,
        recordedAtClient.isAcceptableOrUnknown(
          data['recorded_at_client']!,
          _recordedAtClientMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordedAtClientMeta);
    }
    if (data.containsKey('queued_at')) {
      context.handle(
        _queuedAtMeta,
        queuedAt.isAcceptableOrUnknown(data['queued_at']!, _queuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_queuedAtMeta);
    }
    if (data.containsKey('claim_token')) {
      context.handle(
        _claimTokenMeta,
        claimToken.isAcceptableOrUnknown(data['claim_token']!, _claimTokenMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    if (data.containsKey('conflict_payload')) {
      context.handle(
        _conflictPayloadMeta,
        conflictPayload.isAcceptableOrUnknown(
          data['conflict_payload']!,
          _conflictPayloadMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {kind, targetId, childId},
  ];
  @override
  PendingWrite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingWrite(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: $PendingWritesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      recordedAtClient: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at_client'],
      )!,
      queuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}queued_at'],
      )!,
      state: $PendingWritesTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
      claimToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claim_token'],
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
      conflictPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_payload'],
      ),
    );
  }

  @override
  $PendingWritesTable createAlias(String alias) {
    return $PendingWritesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PendingWriteKind, String, String> $converterkind =
      const EnumNameConverter<PendingWriteKind>(PendingWriteKind.values);
  static JsonTypeConverter2<PendingWriteState, String, String> $converterstate =
      const EnumNameConverter<PendingWriteState>(PendingWriteState.values);
}

class PendingWrite extends DataClass implements Insertable<PendingWrite> {
  /// Local autoincrement id. Also the claim unit during a sync drain.
  final int id;

  /// Which endpoint this write is bound for.
  final PendingWriteKind kind;

  /// The path parameter: a `session.id` for a mark, a
  /// `presence_confirmation.id` for an answer.
  final String targetId;

  /// The child the write is about.
  final String childId;

  /// The request body fragment, JSON-encoded.
  final String payload;

  /// **The moment of the tap**, not the moment of the sync.
  ///
  /// This is `attendance_record.recorded_at_client`, and the distinction is the
  /// entire point of the field (`specs/03-domain-model/entities.md`): the
  /// server compares it against its current `recorded_at` to decide whether
  /// this device's intent is older than what has already been written. Stamping
  /// it at sync time would make every offline write look freshly authoritative
  /// and would silently overwrite whoever marked the child in the meantime.
  final DateTime recordedAtClient;

  /// When the row entered the queue.
  final DateTime queuedAt;

  /// Progress through the queue.
  final PendingWriteState state;

  /// Identifies the drain that claimed this row.
  ///
  /// Only the claiming drain may delete or release it, so two triggers firing
  /// at once (a reconnect and a manual submit) cannot both submit the same row.
  final String? claimToken;

  /// How many times a send has been attempted. Surfaced in diagnostics; the
  /// queue does not give up on its own.
  final int attempts;

  /// The last `ApiErrorCode.wireValue` the server answered with, if any.
  final String? lastErrorCode;

  /// For a [PendingWriteState.conflicted] row: the server's current record,
  /// JSON-encoded, so the educator can compare the two sides.
  final String? conflictPayload;
  const PendingWrite({
    required this.id,
    required this.kind,
    required this.targetId,
    required this.childId,
    required this.payload,
    required this.recordedAtClient,
    required this.queuedAt,
    required this.state,
    this.claimToken,
    required this.attempts,
    this.lastErrorCode,
    this.conflictPayload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['kind'] = Variable<String>(
        $PendingWritesTable.$converterkind.toSql(kind),
      );
    }
    map['target_id'] = Variable<String>(targetId);
    map['child_id'] = Variable<String>(childId);
    map['payload'] = Variable<String>(payload);
    map['recorded_at_client'] = Variable<DateTime>(recordedAtClient);
    map['queued_at'] = Variable<DateTime>(queuedAt);
    {
      map['state'] = Variable<String>(
        $PendingWritesTable.$converterstate.toSql(state),
      );
    }
    if (!nullToAbsent || claimToken != null) {
      map['claim_token'] = Variable<String>(claimToken);
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    if (!nullToAbsent || conflictPayload != null) {
      map['conflict_payload'] = Variable<String>(conflictPayload);
    }
    return map;
  }

  PendingWritesCompanion toCompanion(bool nullToAbsent) {
    return PendingWritesCompanion(
      id: Value(id),
      kind: Value(kind),
      targetId: Value(targetId),
      childId: Value(childId),
      payload: Value(payload),
      recordedAtClient: Value(recordedAtClient),
      queuedAt: Value(queuedAt),
      state: Value(state),
      claimToken: claimToken == null && nullToAbsent
          ? const Value.absent()
          : Value(claimToken),
      attempts: Value(attempts),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      conflictPayload: conflictPayload == null && nullToAbsent
          ? const Value.absent()
          : Value(conflictPayload),
    );
  }

  factory PendingWrite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingWrite(
      id: serializer.fromJson<int>(json['id']),
      kind: $PendingWritesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      targetId: serializer.fromJson<String>(json['targetId']),
      childId: serializer.fromJson<String>(json['childId']),
      payload: serializer.fromJson<String>(json['payload']),
      recordedAtClient: serializer.fromJson<DateTime>(json['recordedAtClient']),
      queuedAt: serializer.fromJson<DateTime>(json['queuedAt']),
      state: $PendingWritesTable.$converterstate.fromJson(
        serializer.fromJson<String>(json['state']),
      ),
      claimToken: serializer.fromJson<String?>(json['claimToken']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
      conflictPayload: serializer.fromJson<String?>(json['conflictPayload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(
        $PendingWritesTable.$converterkind.toJson(kind),
      ),
      'targetId': serializer.toJson<String>(targetId),
      'childId': serializer.toJson<String>(childId),
      'payload': serializer.toJson<String>(payload),
      'recordedAtClient': serializer.toJson<DateTime>(recordedAtClient),
      'queuedAt': serializer.toJson<DateTime>(queuedAt),
      'state': serializer.toJson<String>(
        $PendingWritesTable.$converterstate.toJson(state),
      ),
      'claimToken': serializer.toJson<String?>(claimToken),
      'attempts': serializer.toJson<int>(attempts),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
      'conflictPayload': serializer.toJson<String?>(conflictPayload),
    };
  }

  PendingWrite copyWith({
    int? id,
    PendingWriteKind? kind,
    String? targetId,
    String? childId,
    String? payload,
    DateTime? recordedAtClient,
    DateTime? queuedAt,
    PendingWriteState? state,
    Value<String?> claimToken = const Value.absent(),
    int? attempts,
    Value<String?> lastErrorCode = const Value.absent(),
    Value<String?> conflictPayload = const Value.absent(),
  }) => PendingWrite(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    targetId: targetId ?? this.targetId,
    childId: childId ?? this.childId,
    payload: payload ?? this.payload,
    recordedAtClient: recordedAtClient ?? this.recordedAtClient,
    queuedAt: queuedAt ?? this.queuedAt,
    state: state ?? this.state,
    claimToken: claimToken.present ? claimToken.value : this.claimToken,
    attempts: attempts ?? this.attempts,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
    conflictPayload: conflictPayload.present
        ? conflictPayload.value
        : this.conflictPayload,
  );
  PendingWrite copyWithCompanion(PendingWritesCompanion data) {
    return PendingWrite(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      childId: data.childId.present ? data.childId.value : this.childId,
      payload: data.payload.present ? data.payload.value : this.payload,
      recordedAtClient: data.recordedAtClient.present
          ? data.recordedAtClient.value
          : this.recordedAtClient,
      queuedAt: data.queuedAt.present ? data.queuedAt.value : this.queuedAt,
      state: data.state.present ? data.state.value : this.state,
      claimToken: data.claimToken.present
          ? data.claimToken.value
          : this.claimToken,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      conflictPayload: data.conflictPayload.present
          ? data.conflictPayload.value
          : this.conflictPayload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingWrite(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('targetId: $targetId, ')
          ..write('childId: $childId, ')
          ..write('payload: $payload, ')
          ..write('recordedAtClient: $recordedAtClient, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('state: $state, ')
          ..write('claimToken: $claimToken, ')
          ..write('attempts: $attempts, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('conflictPayload: $conflictPayload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    targetId,
    childId,
    payload,
    recordedAtClient,
    queuedAt,
    state,
    claimToken,
    attempts,
    lastErrorCode,
    conflictPayload,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingWrite &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.targetId == this.targetId &&
          other.childId == this.childId &&
          other.payload == this.payload &&
          other.recordedAtClient == this.recordedAtClient &&
          other.queuedAt == this.queuedAt &&
          other.state == this.state &&
          other.claimToken == this.claimToken &&
          other.attempts == this.attempts &&
          other.lastErrorCode == this.lastErrorCode &&
          other.conflictPayload == this.conflictPayload);
}

class PendingWritesCompanion extends UpdateCompanion<PendingWrite> {
  final Value<int> id;
  final Value<PendingWriteKind> kind;
  final Value<String> targetId;
  final Value<String> childId;
  final Value<String> payload;
  final Value<DateTime> recordedAtClient;
  final Value<DateTime> queuedAt;
  final Value<PendingWriteState> state;
  final Value<String?> claimToken;
  final Value<int> attempts;
  final Value<String?> lastErrorCode;
  final Value<String?> conflictPayload;
  const PendingWritesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.targetId = const Value.absent(),
    this.childId = const Value.absent(),
    this.payload = const Value.absent(),
    this.recordedAtClient = const Value.absent(),
    this.queuedAt = const Value.absent(),
    this.state = const Value.absent(),
    this.claimToken = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.conflictPayload = const Value.absent(),
  });
  PendingWritesCompanion.insert({
    this.id = const Value.absent(),
    required PendingWriteKind kind,
    required String targetId,
    required String childId,
    required String payload,
    required DateTime recordedAtClient,
    required DateTime queuedAt,
    this.state = const Value.absent(),
    this.claimToken = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.conflictPayload = const Value.absent(),
  }) : kind = Value(kind),
       targetId = Value(targetId),
       childId = Value(childId),
       payload = Value(payload),
       recordedAtClient = Value(recordedAtClient),
       queuedAt = Value(queuedAt);
  static Insertable<PendingWrite> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? targetId,
    Expression<String>? childId,
    Expression<String>? payload,
    Expression<DateTime>? recordedAtClient,
    Expression<DateTime>? queuedAt,
    Expression<String>? state,
    Expression<String>? claimToken,
    Expression<int>? attempts,
    Expression<String>? lastErrorCode,
    Expression<String>? conflictPayload,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (targetId != null) 'target_id': targetId,
      if (childId != null) 'child_id': childId,
      if (payload != null) 'payload': payload,
      if (recordedAtClient != null) 'recorded_at_client': recordedAtClient,
      if (queuedAt != null) 'queued_at': queuedAt,
      if (state != null) 'state': state,
      if (claimToken != null) 'claim_token': claimToken,
      if (attempts != null) 'attempts': attempts,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (conflictPayload != null) 'conflict_payload': conflictPayload,
    });
  }

  PendingWritesCompanion copyWith({
    Value<int>? id,
    Value<PendingWriteKind>? kind,
    Value<String>? targetId,
    Value<String>? childId,
    Value<String>? payload,
    Value<DateTime>? recordedAtClient,
    Value<DateTime>? queuedAt,
    Value<PendingWriteState>? state,
    Value<String?>? claimToken,
    Value<int>? attempts,
    Value<String?>? lastErrorCode,
    Value<String?>? conflictPayload,
  }) {
    return PendingWritesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      targetId: targetId ?? this.targetId,
      childId: childId ?? this.childId,
      payload: payload ?? this.payload,
      recordedAtClient: recordedAtClient ?? this.recordedAtClient,
      queuedAt: queuedAt ?? this.queuedAt,
      state: state ?? this.state,
      claimToken: claimToken ?? this.claimToken,
      attempts: attempts ?? this.attempts,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      conflictPayload: conflictPayload ?? this.conflictPayload,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $PendingWritesTable.$converterkind.toSql(kind.value),
      );
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (recordedAtClient.present) {
      map['recorded_at_client'] = Variable<DateTime>(recordedAtClient.value);
    }
    if (queuedAt.present) {
      map['queued_at'] = Variable<DateTime>(queuedAt.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $PendingWritesTable.$converterstate.toSql(state.value),
      );
    }
    if (claimToken.present) {
      map['claim_token'] = Variable<String>(claimToken.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (conflictPayload.present) {
      map['conflict_payload'] = Variable<String>(conflictPayload.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingWritesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('targetId: $targetId, ')
          ..write('childId: $childId, ')
          ..write('payload: $payload, ')
          ..write('recordedAtClient: $recordedAtClient, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('state: $state, ')
          ..write('claimToken: $claimToken, ')
          ..write('attempts: $attempts, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('conflictPayload: $conflictPayload')
          ..write(')'))
        .toString();
  }
}

abstract class _$RaeedDatabase extends GeneratedDatabase {
  _$RaeedDatabase(QueryExecutor e) : super(e);
  $RaeedDatabaseManager get managers => $RaeedDatabaseManager(this);
  late final $CachedSessionsTable cachedSessions = $CachedSessionsTable(this);
  late final $CachedAttendanceEntriesTable cachedAttendanceEntries =
      $CachedAttendanceEntriesTable(this);
  late final $PendingWritesTable pendingWrites = $PendingWritesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedSessions,
    cachedAttendanceEntries,
    pendingWrites,
  ];
}

typedef $$CachedSessionsTableCreateCompanionBuilder =
    CachedSessionsCompanion Function({
      required String id,
      required String groupId,
      required String groupName,
      required DateTime startsAt,
      Value<DateTime?> endsAt,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$CachedSessionsTableUpdateCompanionBuilder =
    CachedSessionsCompanion Function({
      Value<String> id,
      Value<String> groupId,
      Value<String> groupName,
      Value<DateTime> startsAt,
      Value<DateTime?> endsAt,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

final class $$CachedSessionsTableReferences
    extends
        BaseReferences<_$RaeedDatabase, $CachedSessionsTable, CachedSession> {
  $$CachedSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $CachedAttendanceEntriesTable,
    List<CachedAttendanceEntry>
  >
  _cachedAttendanceEntriesRefsTable(_$RaeedDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.cachedAttendanceEntries,
        aliasName: $_aliasNameGenerator(
          db.cachedSessions.id,
          db.cachedAttendanceEntries.sessionId,
        ),
      );

  $$CachedAttendanceEntriesTableProcessedTableManager
  get cachedAttendanceEntriesRefs {
    final manager = $$CachedAttendanceEntriesTableTableManager(
      $_db,
      $_db.cachedAttendanceEntries,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cachedAttendanceEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CachedSessionsTableFilterComposer
    extends Composer<_$RaeedDatabase, $CachedSessionsTable> {
  $$CachedSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cachedAttendanceEntriesRefs(
    Expression<bool> Function($$CachedAttendanceEntriesTableFilterComposer f) f,
  ) {
    final $$CachedAttendanceEntriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.cachedAttendanceEntries,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CachedAttendanceEntriesTableFilterComposer(
                $db: $db,
                $table: $db.cachedAttendanceEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CachedSessionsTableOrderingComposer
    extends Composer<_$RaeedDatabase, $CachedSessionsTable> {
  $$CachedSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedSessionsTableAnnotationComposer
    extends Composer<_$RaeedDatabase, $CachedSessionsTable> {
  $$CachedSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<DateTime> get startsAt =>
      $composableBuilder(column: $table.startsAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endsAt =>
      $composableBuilder(column: $table.endsAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  Expression<T> cachedAttendanceEntriesRefs<T extends Object>(
    Expression<T> Function($$CachedAttendanceEntriesTableAnnotationComposer a)
    f,
  ) {
    final $$CachedAttendanceEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.cachedAttendanceEntries,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CachedAttendanceEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.cachedAttendanceEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CachedSessionsTableTableManager
    extends
        RootTableManager<
          _$RaeedDatabase,
          $CachedSessionsTable,
          CachedSession,
          $$CachedSessionsTableFilterComposer,
          $$CachedSessionsTableOrderingComposer,
          $$CachedSessionsTableAnnotationComposer,
          $$CachedSessionsTableCreateCompanionBuilder,
          $$CachedSessionsTableUpdateCompanionBuilder,
          (CachedSession, $$CachedSessionsTableReferences),
          CachedSession,
          PrefetchHooks Function({bool cachedAttendanceEntriesRefs})
        > {
  $$CachedSessionsTableTableManager(
    _$RaeedDatabase db,
    $CachedSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> groupName = const Value.absent(),
                Value<DateTime> startsAt = const Value.absent(),
                Value<DateTime?> endsAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedSessionsCompanion(
                id: id,
                groupId: groupId,
                groupName: groupName,
                startsAt: startsAt,
                endsAt: endsAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String groupId,
                required String groupName,
                required DateTime startsAt,
                Value<DateTime?> endsAt = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedSessionsCompanion.insert(
                id: id,
                groupId: groupId,
                groupName: groupName,
                startsAt: startsAt,
                endsAt: endsAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CachedSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cachedAttendanceEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (cachedAttendanceEntriesRefs) db.cachedAttendanceEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cachedAttendanceEntriesRefs)
                    await $_getPrefetchedData<
                      CachedSession,
                      $CachedSessionsTable,
                      CachedAttendanceEntry
                    >(
                      currentTable: table,
                      referencedTable: $$CachedSessionsTableReferences
                          ._cachedAttendanceEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CachedSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).cachedAttendanceEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CachedSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$RaeedDatabase,
      $CachedSessionsTable,
      CachedSession,
      $$CachedSessionsTableFilterComposer,
      $$CachedSessionsTableOrderingComposer,
      $$CachedSessionsTableAnnotationComposer,
      $$CachedSessionsTableCreateCompanionBuilder,
      $$CachedSessionsTableUpdateCompanionBuilder,
      (CachedSession, $$CachedSessionsTableReferences),
      CachedSession,
      PrefetchHooks Function({bool cachedAttendanceEntriesRefs})
    >;
typedef $$CachedAttendanceEntriesTableCreateCompanionBuilder =
    CachedAttendanceEntriesCompanion Function({
      required String sessionId,
      required String childId,
      required String childName,
      Value<String?> photoUrl,
      Value<bool> hasHealthAlert,
      Value<String?> presenceAnswer,
      Value<String?> presenceReason,
      Value<String?> serverStatus,
      Value<DateTime?> serverRecordedAt,
      Value<int> position,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$CachedAttendanceEntriesTableUpdateCompanionBuilder =
    CachedAttendanceEntriesCompanion Function({
      Value<String> sessionId,
      Value<String> childId,
      Value<String> childName,
      Value<String?> photoUrl,
      Value<bool> hasHealthAlert,
      Value<String?> presenceAnswer,
      Value<String?> presenceReason,
      Value<String?> serverStatus,
      Value<DateTime?> serverRecordedAt,
      Value<int> position,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

final class $$CachedAttendanceEntriesTableReferences
    extends
        BaseReferences<
          _$RaeedDatabase,
          $CachedAttendanceEntriesTable,
          CachedAttendanceEntry
        > {
  $$CachedAttendanceEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CachedSessionsTable _sessionIdTable(_$RaeedDatabase db) =>
      db.cachedSessions.createAlias(
        $_aliasNameGenerator(
          db.cachedAttendanceEntries.sessionId,
          db.cachedSessions.id,
        ),
      );

  $$CachedSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$CachedSessionsTableTableManager(
      $_db,
      $_db.cachedSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CachedAttendanceEntriesTableFilterComposer
    extends Composer<_$RaeedDatabase, $CachedAttendanceEntriesTable> {
  $$CachedAttendanceEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childName => $composableBuilder(
    column: $table.childName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasHealthAlert => $composableBuilder(
    column: $table.hasHealthAlert,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presenceAnswer => $composableBuilder(
    column: $table.presenceAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presenceReason => $composableBuilder(
    column: $table.presenceReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverStatus => $composableBuilder(
    column: $table.serverStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverRecordedAt => $composableBuilder(
    column: $table.serverRecordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CachedSessionsTableFilterComposer get sessionId {
    final $$CachedSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.cachedSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedSessionsTableFilterComposer(
            $db: $db,
            $table: $db.cachedSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CachedAttendanceEntriesTableOrderingComposer
    extends Composer<_$RaeedDatabase, $CachedAttendanceEntriesTable> {
  $$CachedAttendanceEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childName => $composableBuilder(
    column: $table.childName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasHealthAlert => $composableBuilder(
    column: $table.hasHealthAlert,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presenceAnswer => $composableBuilder(
    column: $table.presenceAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presenceReason => $composableBuilder(
    column: $table.presenceReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverStatus => $composableBuilder(
    column: $table.serverStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverRecordedAt => $composableBuilder(
    column: $table.serverRecordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CachedSessionsTableOrderingComposer get sessionId {
    final $$CachedSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.cachedSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.cachedSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CachedAttendanceEntriesTableAnnotationComposer
    extends Composer<_$RaeedDatabase, $CachedAttendanceEntriesTable> {
  $$CachedAttendanceEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<String> get childName =>
      $composableBuilder(column: $table.childName, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<bool> get hasHealthAlert => $composableBuilder(
    column: $table.hasHealthAlert,
    builder: (column) => column,
  );

  GeneratedColumn<String> get presenceAnswer => $composableBuilder(
    column: $table.presenceAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get presenceReason => $composableBuilder(
    column: $table.presenceReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverStatus => $composableBuilder(
    column: $table.serverStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serverRecordedAt => $composableBuilder(
    column: $table.serverRecordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  $$CachedSessionsTableAnnotationComposer get sessionId {
    final $$CachedSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.cachedSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.cachedSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CachedAttendanceEntriesTableTableManager
    extends
        RootTableManager<
          _$RaeedDatabase,
          $CachedAttendanceEntriesTable,
          CachedAttendanceEntry,
          $$CachedAttendanceEntriesTableFilterComposer,
          $$CachedAttendanceEntriesTableOrderingComposer,
          $$CachedAttendanceEntriesTableAnnotationComposer,
          $$CachedAttendanceEntriesTableCreateCompanionBuilder,
          $$CachedAttendanceEntriesTableUpdateCompanionBuilder,
          (CachedAttendanceEntry, $$CachedAttendanceEntriesTableReferences),
          CachedAttendanceEntry,
          PrefetchHooks Function({bool sessionId})
        > {
  $$CachedAttendanceEntriesTableTableManager(
    _$RaeedDatabase db,
    $CachedAttendanceEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedAttendanceEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CachedAttendanceEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedAttendanceEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> childId = const Value.absent(),
                Value<String> childName = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<bool> hasHealthAlert = const Value.absent(),
                Value<String?> presenceAnswer = const Value.absent(),
                Value<String?> presenceReason = const Value.absent(),
                Value<String?> serverStatus = const Value.absent(),
                Value<DateTime?> serverRecordedAt = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedAttendanceEntriesCompanion(
                sessionId: sessionId,
                childId: childId,
                childName: childName,
                photoUrl: photoUrl,
                hasHealthAlert: hasHealthAlert,
                presenceAnswer: presenceAnswer,
                presenceReason: presenceReason,
                serverStatus: serverStatus,
                serverRecordedAt: serverRecordedAt,
                position: position,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String childId,
                required String childName,
                Value<String?> photoUrl = const Value.absent(),
                Value<bool> hasHealthAlert = const Value.absent(),
                Value<String?> presenceAnswer = const Value.absent(),
                Value<String?> presenceReason = const Value.absent(),
                Value<String?> serverStatus = const Value.absent(),
                Value<DateTime?> serverRecordedAt = const Value.absent(),
                Value<int> position = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedAttendanceEntriesCompanion.insert(
                sessionId: sessionId,
                childId: childId,
                childName: childName,
                photoUrl: photoUrl,
                hasHealthAlert: hasHealthAlert,
                presenceAnswer: presenceAnswer,
                presenceReason: presenceReason,
                serverStatus: serverStatus,
                serverRecordedAt: serverRecordedAt,
                position: position,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CachedAttendanceEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable:
                            $$CachedAttendanceEntriesTableReferences
                                ._sessionIdTable(db),
                        referencedColumn:
                            $$CachedAttendanceEntriesTableReferences
                                ._sessionIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CachedAttendanceEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$RaeedDatabase,
      $CachedAttendanceEntriesTable,
      CachedAttendanceEntry,
      $$CachedAttendanceEntriesTableFilterComposer,
      $$CachedAttendanceEntriesTableOrderingComposer,
      $$CachedAttendanceEntriesTableAnnotationComposer,
      $$CachedAttendanceEntriesTableCreateCompanionBuilder,
      $$CachedAttendanceEntriesTableUpdateCompanionBuilder,
      (CachedAttendanceEntry, $$CachedAttendanceEntriesTableReferences),
      CachedAttendanceEntry,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$PendingWritesTableCreateCompanionBuilder =
    PendingWritesCompanion Function({
      Value<int> id,
      required PendingWriteKind kind,
      required String targetId,
      required String childId,
      required String payload,
      required DateTime recordedAtClient,
      required DateTime queuedAt,
      Value<PendingWriteState> state,
      Value<String?> claimToken,
      Value<int> attempts,
      Value<String?> lastErrorCode,
      Value<String?> conflictPayload,
    });
typedef $$PendingWritesTableUpdateCompanionBuilder =
    PendingWritesCompanion Function({
      Value<int> id,
      Value<PendingWriteKind> kind,
      Value<String> targetId,
      Value<String> childId,
      Value<String> payload,
      Value<DateTime> recordedAtClient,
      Value<DateTime> queuedAt,
      Value<PendingWriteState> state,
      Value<String?> claimToken,
      Value<int> attempts,
      Value<String?> lastErrorCode,
      Value<String?> conflictPayload,
    });

class $$PendingWritesTableFilterComposer
    extends Composer<_$RaeedDatabase, $PendingWritesTable> {
  $$PendingWritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PendingWriteKind, PendingWriteKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAtClient => $composableBuilder(
    column: $table.recordedAtClient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PendingWriteState, PendingWriteState, String>
  get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get claimToken => $composableBuilder(
    column: $table.claimToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictPayload => $composableBuilder(
    column: $table.conflictPayload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingWritesTableOrderingComposer
    extends Composer<_$RaeedDatabase, $PendingWritesTable> {
  $$PendingWritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAtClient => $composableBuilder(
    column: $table.recordedAtClient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get claimToken => $composableBuilder(
    column: $table.claimToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictPayload => $composableBuilder(
    column: $table.conflictPayload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingWritesTableAnnotationComposer
    extends Composer<_$RaeedDatabase, $PendingWritesTable> {
  $$PendingWritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PendingWriteKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAtClient => $composableBuilder(
    column: $table.recordedAtClient,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get queuedAt =>
      $composableBuilder(column: $table.queuedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PendingWriteState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get claimToken => $composableBuilder(
    column: $table.claimToken,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conflictPayload => $composableBuilder(
    column: $table.conflictPayload,
    builder: (column) => column,
  );
}

class $$PendingWritesTableTableManager
    extends
        RootTableManager<
          _$RaeedDatabase,
          $PendingWritesTable,
          PendingWrite,
          $$PendingWritesTableFilterComposer,
          $$PendingWritesTableOrderingComposer,
          $$PendingWritesTableAnnotationComposer,
          $$PendingWritesTableCreateCompanionBuilder,
          $$PendingWritesTableUpdateCompanionBuilder,
          (
            PendingWrite,
            BaseReferences<_$RaeedDatabase, $PendingWritesTable, PendingWrite>,
          ),
          PendingWrite,
          PrefetchHooks Function()
        > {
  $$PendingWritesTableTableManager(
    _$RaeedDatabase db,
    $PendingWritesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingWritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingWritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingWritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<PendingWriteKind> kind = const Value.absent(),
                Value<String> targetId = const Value.absent(),
                Value<String> childId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> recordedAtClient = const Value.absent(),
                Value<DateTime> queuedAt = const Value.absent(),
                Value<PendingWriteState> state = const Value.absent(),
                Value<String?> claimToken = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String?> conflictPayload = const Value.absent(),
              }) => PendingWritesCompanion(
                id: id,
                kind: kind,
                targetId: targetId,
                childId: childId,
                payload: payload,
                recordedAtClient: recordedAtClient,
                queuedAt: queuedAt,
                state: state,
                claimToken: claimToken,
                attempts: attempts,
                lastErrorCode: lastErrorCode,
                conflictPayload: conflictPayload,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required PendingWriteKind kind,
                required String targetId,
                required String childId,
                required String payload,
                required DateTime recordedAtClient,
                required DateTime queuedAt,
                Value<PendingWriteState> state = const Value.absent(),
                Value<String?> claimToken = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String?> conflictPayload = const Value.absent(),
              }) => PendingWritesCompanion.insert(
                id: id,
                kind: kind,
                targetId: targetId,
                childId: childId,
                payload: payload,
                recordedAtClient: recordedAtClient,
                queuedAt: queuedAt,
                state: state,
                claimToken: claimToken,
                attempts: attempts,
                lastErrorCode: lastErrorCode,
                conflictPayload: conflictPayload,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingWritesTableProcessedTableManager =
    ProcessedTableManager<
      _$RaeedDatabase,
      $PendingWritesTable,
      PendingWrite,
      $$PendingWritesTableFilterComposer,
      $$PendingWritesTableOrderingComposer,
      $$PendingWritesTableAnnotationComposer,
      $$PendingWritesTableCreateCompanionBuilder,
      $$PendingWritesTableUpdateCompanionBuilder,
      (
        PendingWrite,
        BaseReferences<_$RaeedDatabase, $PendingWritesTable, PendingWrite>,
      ),
      PendingWrite,
      PrefetchHooks Function()
    >;

class $RaeedDatabaseManager {
  final _$RaeedDatabase _db;
  $RaeedDatabaseManager(this._db);
  $$CachedSessionsTableTableManager get cachedSessions =>
      $$CachedSessionsTableTableManager(_db, _db.cachedSessions);
  $$CachedAttendanceEntriesTableTableManager get cachedAttendanceEntries =>
      $$CachedAttendanceEntriesTableTableManager(
        _db,
        _db.cachedAttendanceEntries,
      );
  $$PendingWritesTableTableManager get pendingWrites =>
      $$PendingWritesTableTableManager(_db, _db.pendingWrites);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's database instance.
///
/// `keepAlive` because closing and reopening SQLite between screens would drop
/// the queue's in-flight claims, and because the sync service holds it for the
/// life of the app.

@ProviderFor(raeedDatabase)
const raeedDatabaseProvider = RaeedDatabaseProvider._();

/// The app's database instance.
///
/// `keepAlive` because closing and reopening SQLite between screens would drop
/// the queue's in-flight claims, and because the sync service holds it for the
/// life of the app.

final class RaeedDatabaseProvider
    extends $FunctionalProvider<RaeedDatabase, RaeedDatabase, RaeedDatabase>
    with $Provider<RaeedDatabase> {
  /// The app's database instance.
  ///
  /// `keepAlive` because closing and reopening SQLite between screens would drop
  /// the queue's in-flight claims, and because the sync service holds it for the
  /// life of the app.
  const RaeedDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'raeedDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$raeedDatabaseHash();

  @$internal
  @override
  $ProviderElement<RaeedDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RaeedDatabase create(Ref ref) {
    return raeedDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RaeedDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RaeedDatabase>(value),
    );
  }
}

String _$raeedDatabaseHash() => r'531a71765ca73ced676d24916d2a3624bf4646d7';
