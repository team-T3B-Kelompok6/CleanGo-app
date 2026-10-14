// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $StoredAddressesTable extends StoredAddresses
    with TableInfo<$StoredAddressesTable, StoredAddressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoredAddressesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullAddressMeta = const VerificationMeta(
    'fullAddress',
  );
  @override
  late final GeneratedColumn<String> fullAddress = GeneratedColumn<String>(
    'full_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactNameMeta = const VerificationMeta(
    'contactName',
  );
  @override
  late final GeneratedColumn<String> contactName = GeneratedColumn<String>(
    'contact_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSelectedMeta = const VerificationMeta(
    'isSelected',
  );
  @override
  late final GeneratedColumn<bool> isSelected = GeneratedColumn<bool>(
    'is_selected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_selected" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    fullAddress,
    note,
    type,
    contactName,
    phoneNumber,
    isPrimary,
    isSelected,
    latitude,
    longitude,
    sortOrder,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stored_addresses';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredAddressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('full_address')) {
      context.handle(
        _fullAddressMeta,
        fullAddress.isAcceptableOrUnknown(
          data['full_address']!,
          _fullAddressMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fullAddressMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('contact_name')) {
      context.handle(
        _contactNameMeta,
        contactName.isAcceptableOrUnknown(
          data['contact_name']!,
          _contactNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contactNameMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    if (data.containsKey('is_selected')) {
      context.handle(
        _isSelectedMeta,
        isSelected.isAcceptableOrUnknown(data['is_selected']!, _isSelectedMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredAddressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredAddressRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      fullAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_address'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      contactName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_name'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      )!,
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
      isSelected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_selected'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StoredAddressesTable createAlias(String alias) {
    return $StoredAddressesTable(attachedDatabase, alias);
  }
}

class StoredAddressRow extends DataClass
    implements Insertable<StoredAddressRow> {
  final String id;
  final String title;
  final String fullAddress;
  final String note;
  final String type;
  final String contactName;
  final String phoneNumber;
  final bool isPrimary;
  final bool isSelected;
  final double? latitude;
  final double? longitude;
  final int sortOrder;
  final int updatedAt;
  const StoredAddressRow({
    required this.id,
    required this.title,
    required this.fullAddress,
    required this.note,
    required this.type,
    required this.contactName,
    required this.phoneNumber,
    required this.isPrimary,
    required this.isSelected,
    this.latitude,
    this.longitude,
    required this.sortOrder,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['full_address'] = Variable<String>(fullAddress);
    map['note'] = Variable<String>(note);
    map['type'] = Variable<String>(type);
    map['contact_name'] = Variable<String>(contactName);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['is_selected'] = Variable<bool>(isSelected);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  StoredAddressesCompanion toCompanion(bool nullToAbsent) {
    return StoredAddressesCompanion(
      id: Value(id),
      title: Value(title),
      fullAddress: Value(fullAddress),
      note: Value(note),
      type: Value(type),
      contactName: Value(contactName),
      phoneNumber: Value(phoneNumber),
      isPrimary: Value(isPrimary),
      isSelected: Value(isSelected),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      sortOrder: Value(sortOrder),
      updatedAt: Value(updatedAt),
    );
  }

  factory StoredAddressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredAddressRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      fullAddress: serializer.fromJson<String>(json['fullAddress']),
      note: serializer.fromJson<String>(json['note']),
      type: serializer.fromJson<String>(json['type']),
      contactName: serializer.fromJson<String>(json['contactName']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      isSelected: serializer.fromJson<bool>(json['isSelected']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'fullAddress': serializer.toJson<String>(fullAddress),
      'note': serializer.toJson<String>(note),
      'type': serializer.toJson<String>(type),
      'contactName': serializer.toJson<String>(contactName),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'isSelected': serializer.toJson<bool>(isSelected),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  StoredAddressRow copyWith({
    String? id,
    String? title,
    String? fullAddress,
    String? note,
    String? type,
    String? contactName,
    String? phoneNumber,
    bool? isPrimary,
    bool? isSelected,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    int? sortOrder,
    int? updatedAt,
  }) => StoredAddressRow(
    id: id ?? this.id,
    title: title ?? this.title,
    fullAddress: fullAddress ?? this.fullAddress,
    note: note ?? this.note,
    type: type ?? this.type,
    contactName: contactName ?? this.contactName,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    isPrimary: isPrimary ?? this.isPrimary,
    isSelected: isSelected ?? this.isSelected,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    sortOrder: sortOrder ?? this.sortOrder,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StoredAddressRow copyWithCompanion(StoredAddressesCompanion data) {
    return StoredAddressRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      fullAddress: data.fullAddress.present
          ? data.fullAddress.value
          : this.fullAddress,
      note: data.note.present ? data.note.value : this.note,
      type: data.type.present ? data.type.value : this.type,
      contactName: data.contactName.present
          ? data.contactName.value
          : this.contactName,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      isSelected: data.isSelected.present
          ? data.isSelected.value
          : this.isSelected,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredAddressRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('fullAddress: $fullAddress, ')
          ..write('note: $note, ')
          ..write('type: $type, ')
          ..write('contactName: $contactName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('isSelected: $isSelected, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    fullAddress,
    note,
    type,
    contactName,
    phoneNumber,
    isPrimary,
    isSelected,
    latitude,
    longitude,
    sortOrder,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredAddressRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.fullAddress == this.fullAddress &&
          other.note == this.note &&
          other.type == this.type &&
          other.contactName == this.contactName &&
          other.phoneNumber == this.phoneNumber &&
          other.isPrimary == this.isPrimary &&
          other.isSelected == this.isSelected &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.sortOrder == this.sortOrder &&
          other.updatedAt == this.updatedAt);
}

class StoredAddressesCompanion extends UpdateCompanion<StoredAddressRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> fullAddress;
  final Value<String> note;
  final Value<String> type;
  final Value<String> contactName;
  final Value<String> phoneNumber;
  final Value<bool> isPrimary;
  final Value<bool> isSelected;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int> sortOrder;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const StoredAddressesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.fullAddress = const Value.absent(),
    this.note = const Value.absent(),
    this.type = const Value.absent(),
    this.contactName = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.isSelected = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoredAddressesCompanion.insert({
    required String id,
    required String title,
    required String fullAddress,
    this.note = const Value.absent(),
    required String type,
    required String contactName,
    required String phoneNumber,
    this.isPrimary = const Value.absent(),
    this.isSelected = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    required int sortOrder,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       fullAddress = Value(fullAddress),
       type = Value(type),
       contactName = Value(contactName),
       phoneNumber = Value(phoneNumber),
       sortOrder = Value(sortOrder),
       updatedAt = Value(updatedAt);
  static Insertable<StoredAddressRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? fullAddress,
    Expression<String>? note,
    Expression<String>? type,
    Expression<String>? contactName,
    Expression<String>? phoneNumber,
    Expression<bool>? isPrimary,
    Expression<bool>? isSelected,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? sortOrder,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (fullAddress != null) 'full_address': fullAddress,
      if (note != null) 'note': note,
      if (type != null) 'type': type,
      if (contactName != null) 'contact_name': contactName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (isSelected != null) 'is_selected': isSelected,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoredAddressesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? fullAddress,
    Value<String>? note,
    Value<String>? type,
    Value<String>? contactName,
    Value<String>? phoneNumber,
    Value<bool>? isPrimary,
    Value<bool>? isSelected,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<int>? sortOrder,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return StoredAddressesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      fullAddress: fullAddress ?? this.fullAddress,
      note: note ?? this.note,
      type: type ?? this.type,
      contactName: contactName ?? this.contactName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPrimary: isPrimary ?? this.isPrimary,
      isSelected: isSelected ?? this.isSelected,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (fullAddress.present) {
      map['full_address'] = Variable<String>(fullAddress.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (contactName.present) {
      map['contact_name'] = Variable<String>(contactName.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (isSelected.present) {
      map['is_selected'] = Variable<bool>(isSelected.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredAddressesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('fullAddress: $fullAddress, ')
          ..write('note: $note, ')
          ..write('type: $type, ')
          ..write('contactName: $contactName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('isSelected: $isSelected, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StoredAddressesTable storedAddresses = $StoredAddressesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [storedAddresses];
}

typedef $$StoredAddressesTableCreateCompanionBuilder =
    StoredAddressesCompanion Function({
      required String id,
      required String title,
      required String fullAddress,
      Value<String> note,
      required String type,
      required String contactName,
      required String phoneNumber,
      Value<bool> isPrimary,
      Value<bool> isSelected,
      Value<double?> latitude,
      Value<double?> longitude,
      required int sortOrder,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$StoredAddressesTableUpdateCompanionBuilder =
    StoredAddressesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> fullAddress,
      Value<String> note,
      Value<String> type,
      Value<String> contactName,
      Value<String> phoneNumber,
      Value<bool> isPrimary,
      Value<bool> isSelected,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<int> sortOrder,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$StoredAddressesTableFilterComposer
    extends Composer<_$AppDatabase, $StoredAddressesTable> {
  $$StoredAddressesTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullAddress => $composableBuilder(
    column: $table.fullAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactName => $composableBuilder(
    column: $table.contactName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSelected => $composableBuilder(
    column: $table.isSelected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StoredAddressesTableOrderingComposer
    extends Composer<_$AppDatabase, $StoredAddressesTable> {
  $$StoredAddressesTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullAddress => $composableBuilder(
    column: $table.fullAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactName => $composableBuilder(
    column: $table.contactName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSelected => $composableBuilder(
    column: $table.isSelected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoredAddressesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoredAddressesTable> {
  $$StoredAddressesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get fullAddress => $composableBuilder(
    column: $table.fullAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get contactName => $composableBuilder(
    column: $table.contactName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<bool> get isSelected => $composableBuilder(
    column: $table.isSelected,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StoredAddressesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoredAddressesTable,
          StoredAddressRow,
          $$StoredAddressesTableFilterComposer,
          $$StoredAddressesTableOrderingComposer,
          $$StoredAddressesTableAnnotationComposer,
          $$StoredAddressesTableCreateCompanionBuilder,
          $$StoredAddressesTableUpdateCompanionBuilder,
          (
            StoredAddressRow,
            BaseReferences<
              _$AppDatabase,
              $StoredAddressesTable,
              StoredAddressRow
            >,
          ),
          StoredAddressRow,
          PrefetchHooks Function()
        > {
  $$StoredAddressesTableTableManager(
    _$AppDatabase db,
    $StoredAddressesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoredAddressesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoredAddressesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoredAddressesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> fullAddress = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> contactName = const Value.absent(),
                Value<String> phoneNumber = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<bool> isSelected = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredAddressesCompanion(
                id: id,
                title: title,
                fullAddress: fullAddress,
                note: note,
                type: type,
                contactName: contactName,
                phoneNumber: phoneNumber,
                isPrimary: isPrimary,
                isSelected: isSelected,
                latitude: latitude,
                longitude: longitude,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String fullAddress,
                Value<String> note = const Value.absent(),
                required String type,
                required String contactName,
                required String phoneNumber,
                Value<bool> isPrimary = const Value.absent(),
                Value<bool> isSelected = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                required int sortOrder,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => StoredAddressesCompanion.insert(
                id: id,
                title: title,
                fullAddress: fullAddress,
                note: note,
                type: type,
                contactName: contactName,
                phoneNumber: phoneNumber,
                isPrimary: isPrimary,
                isSelected: isSelected,
                latitude: latitude,
                longitude: longitude,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StoredAddressesTable, StoredAddressRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $StoredAddressesTable,
                    StoredAddressRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StoredAddressesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoredAddressesTable,
      StoredAddressRow,
      $$StoredAddressesTableFilterComposer,
      $$StoredAddressesTableOrderingComposer,
      $$StoredAddressesTableAnnotationComposer,
      $$StoredAddressesTableCreateCompanionBuilder,
      $$StoredAddressesTableUpdateCompanionBuilder,
      (
        StoredAddressRow,
        BaseReferences<_$AppDatabase, $StoredAddressesTable, StoredAddressRow>,
      ),
      StoredAddressRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StoredAddressesTableTableManager get storedAddresses =>
      $$StoredAddressesTableTableManager(_db, _db.storedAddresses);
}
