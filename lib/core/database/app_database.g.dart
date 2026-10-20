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

class $BookingDraftsTable extends BookingDrafts
    with TableInfo<$BookingDraftsTable, BookingDraftRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookingDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceIdMeta = const VerificationMeta(
    'serviceId',
  );
  @override
  late final GeneratedColumn<String> serviceId = GeneratedColumn<String>(
    'service_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _selectedDateMeta = const VerificationMeta(
    'selectedDate',
  );
  @override
  late final GeneratedColumn<int> selectedDate = GeneratedColumn<int>(
    'selected_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _selectedTimeMeta = const VerificationMeta(
    'selectedTime',
  );
  @override
  late final GeneratedColumn<String> selectedTime = GeneratedColumn<String>(
    'selected_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressIdMeta = const VerificationMeta(
    'addressId',
  );
  @override
  late final GeneratedColumn<String> addressId = GeneratedColumn<String>(
    'address_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    serviceId,
    selectedDate,
    selectedTime,
    addressId,
    note,
    synced,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'booking_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookingDraftRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('service_id')) {
      context.handle(
        _serviceIdMeta,
        serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serviceIdMeta);
    }
    if (data.containsKey('selected_date')) {
      context.handle(
        _selectedDateMeta,
        selectedDate.isAcceptableOrUnknown(
          data['selected_date']!,
          _selectedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_selectedDateMeta);
    }
    if (data.containsKey('selected_time')) {
      context.handle(
        _selectedTimeMeta,
        selectedTime.isAcceptableOrUnknown(
          data['selected_time']!,
          _selectedTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_selectedTimeMeta);
    }
    if (data.containsKey('address_id')) {
      context.handle(
        _addressIdMeta,
        addressId.isAcceptableOrUnknown(data['address_id']!, _addressIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
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
  BookingDraftRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookingDraftRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      serviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_id'],
      )!,
      selectedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_date'],
      )!,
      selectedTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_time'],
      )!,
      addressId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BookingDraftsTable createAlias(String alias) {
    return $BookingDraftsTable(attachedDatabase, alias);
  }
}

class BookingDraftRow extends DataClass implements Insertable<BookingDraftRow> {
  final String id;
  final String serviceId;
  final int selectedDate;
  final String selectedTime;
  final String? addressId;
  final String note;
  final bool synced;
  final int updatedAt;
  const BookingDraftRow({
    required this.id,
    required this.serviceId,
    required this.selectedDate,
    required this.selectedTime,
    this.addressId,
    required this.note,
    required this.synced,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['service_id'] = Variable<String>(serviceId);
    map['selected_date'] = Variable<int>(selectedDate);
    map['selected_time'] = Variable<String>(selectedTime);
    if (!nullToAbsent || addressId != null) {
      map['address_id'] = Variable<String>(addressId);
    }
    map['note'] = Variable<String>(note);
    map['synced'] = Variable<bool>(synced);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  BookingDraftsCompanion toCompanion(bool nullToAbsent) {
    return BookingDraftsCompanion(
      id: Value(id),
      serviceId: Value(serviceId),
      selectedDate: Value(selectedDate),
      selectedTime: Value(selectedTime),
      addressId: addressId == null && nullToAbsent
          ? const Value.absent()
          : Value(addressId),
      note: Value(note),
      synced: Value(synced),
      updatedAt: Value(updatedAt),
    );
  }

  factory BookingDraftRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookingDraftRow(
      id: serializer.fromJson<String>(json['id']),
      serviceId: serializer.fromJson<String>(json['serviceId']),
      selectedDate: serializer.fromJson<int>(json['selectedDate']),
      selectedTime: serializer.fromJson<String>(json['selectedTime']),
      addressId: serializer.fromJson<String?>(json['addressId']),
      note: serializer.fromJson<String>(json['note']),
      synced: serializer.fromJson<bool>(json['synced']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serviceId': serializer.toJson<String>(serviceId),
      'selectedDate': serializer.toJson<int>(selectedDate),
      'selectedTime': serializer.toJson<String>(selectedTime),
      'addressId': serializer.toJson<String?>(addressId),
      'note': serializer.toJson<String>(note),
      'synced': serializer.toJson<bool>(synced),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  BookingDraftRow copyWith({
    String? id,
    String? serviceId,
    int? selectedDate,
    String? selectedTime,
    Value<String?> addressId = const Value.absent(),
    String? note,
    bool? synced,
    int? updatedAt,
  }) => BookingDraftRow(
    id: id ?? this.id,
    serviceId: serviceId ?? this.serviceId,
    selectedDate: selectedDate ?? this.selectedDate,
    selectedTime: selectedTime ?? this.selectedTime,
    addressId: addressId.present ? addressId.value : this.addressId,
    note: note ?? this.note,
    synced: synced ?? this.synced,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BookingDraftRow copyWithCompanion(BookingDraftsCompanion data) {
    return BookingDraftRow(
      id: data.id.present ? data.id.value : this.id,
      serviceId: data.serviceId.present ? data.serviceId.value : this.serviceId,
      selectedDate: data.selectedDate.present
          ? data.selectedDate.value
          : this.selectedDate,
      selectedTime: data.selectedTime.present
          ? data.selectedTime.value
          : this.selectedTime,
      addressId: data.addressId.present ? data.addressId.value : this.addressId,
      note: data.note.present ? data.note.value : this.note,
      synced: data.synced.present ? data.synced.value : this.synced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookingDraftRow(')
          ..write('id: $id, ')
          ..write('serviceId: $serviceId, ')
          ..write('selectedDate: $selectedDate, ')
          ..write('selectedTime: $selectedTime, ')
          ..write('addressId: $addressId, ')
          ..write('note: $note, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serviceId,
    selectedDate,
    selectedTime,
    addressId,
    note,
    synced,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookingDraftRow &&
          other.id == this.id &&
          other.serviceId == this.serviceId &&
          other.selectedDate == this.selectedDate &&
          other.selectedTime == this.selectedTime &&
          other.addressId == this.addressId &&
          other.note == this.note &&
          other.synced == this.synced &&
          other.updatedAt == this.updatedAt);
}

class BookingDraftsCompanion extends UpdateCompanion<BookingDraftRow> {
  final Value<String> id;
  final Value<String> serviceId;
  final Value<int> selectedDate;
  final Value<String> selectedTime;
  final Value<String?> addressId;
  final Value<String> note;
  final Value<bool> synced;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const BookingDraftsCompanion({
    this.id = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.selectedDate = const Value.absent(),
    this.selectedTime = const Value.absent(),
    this.addressId = const Value.absent(),
    this.note = const Value.absent(),
    this.synced = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookingDraftsCompanion.insert({
    required String id,
    required String serviceId,
    required int selectedDate,
    required String selectedTime,
    this.addressId = const Value.absent(),
    this.note = const Value.absent(),
    this.synced = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       serviceId = Value(serviceId),
       selectedDate = Value(selectedDate),
       selectedTime = Value(selectedTime),
       updatedAt = Value(updatedAt);
  static Insertable<BookingDraftRow> custom({
    Expression<String>? id,
    Expression<String>? serviceId,
    Expression<int>? selectedDate,
    Expression<String>? selectedTime,
    Expression<String>? addressId,
    Expression<String>? note,
    Expression<bool>? synced,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceId != null) 'service_id': serviceId,
      if (selectedDate != null) 'selected_date': selectedDate,
      if (selectedTime != null) 'selected_time': selectedTime,
      if (addressId != null) 'address_id': addressId,
      if (note != null) 'note': note,
      if (synced != null) 'synced': synced,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookingDraftsCompanion copyWith({
    Value<String>? id,
    Value<String>? serviceId,
    Value<int>? selectedDate,
    Value<String>? selectedTime,
    Value<String?>? addressId,
    Value<String>? note,
    Value<bool>? synced,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return BookingDraftsCompanion(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      addressId: addressId ?? this.addressId,
      note: note ?? this.note,
      synced: synced ?? this.synced,
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
    if (serviceId.present) {
      map['service_id'] = Variable<String>(serviceId.value);
    }
    if (selectedDate.present) {
      map['selected_date'] = Variable<int>(selectedDate.value);
    }
    if (selectedTime.present) {
      map['selected_time'] = Variable<String>(selectedTime.value);
    }
    if (addressId.present) {
      map['address_id'] = Variable<String>(addressId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
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
    return (StringBuffer('BookingDraftsCompanion(')
          ..write('id: $id, ')
          ..write('serviceId: $serviceId, ')
          ..write('selectedDate: $selectedDate, ')
          ..write('selectedTime: $selectedTime, ')
          ..write('addressId: $addressId, ')
          ..write('note: $note, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServiceCachesTable extends ServiceCaches
    with TableInfo<$ServiceCachesTable, ServiceCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastFetchedMeta = const VerificationMeta(
    'lastFetched',
  );
  @override
  late final GeneratedColumn<int> lastFetched = GeneratedColumn<int>(
    'last_fetched',
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
    payload,
    sortOrder,
    synced,
    lastFetched,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_caches';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServiceCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('last_fetched')) {
      context.handle(
        _lastFetchedMeta,
        lastFetched.isAcceptableOrUnknown(
          data['last_fetched']!,
          _lastFetchedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastFetchedMeta);
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
  ServiceCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceCacheRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      lastFetched: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_fetched'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ServiceCachesTable createAlias(String alias) {
    return $ServiceCachesTable(attachedDatabase, alias);
  }
}

class ServiceCacheRow extends DataClass implements Insertable<ServiceCacheRow> {
  final String id;
  final String payload;
  final int sortOrder;
  final bool synced;
  final int lastFetched;
  final int updatedAt;
  const ServiceCacheRow({
    required this.id,
    required this.payload,
    required this.sortOrder,
    required this.synced,
    required this.lastFetched,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload'] = Variable<String>(payload);
    map['sort_order'] = Variable<int>(sortOrder);
    map['synced'] = Variable<bool>(synced);
    map['last_fetched'] = Variable<int>(lastFetched);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ServiceCachesCompanion toCompanion(bool nullToAbsent) {
    return ServiceCachesCompanion(
      id: Value(id),
      payload: Value(payload),
      sortOrder: Value(sortOrder),
      synced: Value(synced),
      lastFetched: Value(lastFetched),
      updatedAt: Value(updatedAt),
    );
  }

  factory ServiceCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceCacheRow(
      id: serializer.fromJson<String>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      synced: serializer.fromJson<bool>(json['synced']),
      lastFetched: serializer.fromJson<int>(json['lastFetched']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payload': serializer.toJson<String>(payload),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'synced': serializer.toJson<bool>(synced),
      'lastFetched': serializer.toJson<int>(lastFetched),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ServiceCacheRow copyWith({
    String? id,
    String? payload,
    int? sortOrder,
    bool? synced,
    int? lastFetched,
    int? updatedAt,
  }) => ServiceCacheRow(
    id: id ?? this.id,
    payload: payload ?? this.payload,
    sortOrder: sortOrder ?? this.sortOrder,
    synced: synced ?? this.synced,
    lastFetched: lastFetched ?? this.lastFetched,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ServiceCacheRow copyWithCompanion(ServiceCachesCompanion data) {
    return ServiceCacheRow(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      synced: data.synced.present ? data.synced.value : this.synced,
      lastFetched: data.lastFetched.present
          ? data.lastFetched.value
          : this.lastFetched,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceCacheRow(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('synced: $synced, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, payload, sortOrder, synced, lastFetched, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceCacheRow &&
          other.id == this.id &&
          other.payload == this.payload &&
          other.sortOrder == this.sortOrder &&
          other.synced == this.synced &&
          other.lastFetched == this.lastFetched &&
          other.updatedAt == this.updatedAt);
}

class ServiceCachesCompanion extends UpdateCompanion<ServiceCacheRow> {
  final Value<String> id;
  final Value<String> payload;
  final Value<int> sortOrder;
  final Value<bool> synced;
  final Value<int> lastFetched;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ServiceCachesCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.synced = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServiceCachesCompanion.insert({
    required String id,
    required String payload,
    required int sortOrder,
    this.synced = const Value.absent(),
    required int lastFetched,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payload = Value(payload),
       sortOrder = Value(sortOrder),
       lastFetched = Value(lastFetched),
       updatedAt = Value(updatedAt);
  static Insertable<ServiceCacheRow> custom({
    Expression<String>? id,
    Expression<String>? payload,
    Expression<int>? sortOrder,
    Expression<bool>? synced,
    Expression<int>? lastFetched,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (synced != null) 'synced': synced,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServiceCachesCompanion copyWith({
    Value<String>? id,
    Value<String>? payload,
    Value<int>? sortOrder,
    Value<bool>? synced,
    Value<int>? lastFetched,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return ServiceCachesCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
      sortOrder: sortOrder ?? this.sortOrder,
      synced: synced ?? this.synced,
      lastFetched: lastFetched ?? this.lastFetched,
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
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<int>(lastFetched.value);
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
    return (StringBuffer('ServiceCachesCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('synced: $synced, ')
          ..write('lastFetched: $lastFetched, ')
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
  late final $BookingDraftsTable bookingDrafts = $BookingDraftsTable(this);
  late final $ServiceCachesTable serviceCaches = $ServiceCachesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    storedAddresses,
    bookingDrafts,
    serviceCaches,
  ];
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
typedef $$BookingDraftsTableCreateCompanionBuilder =
    BookingDraftsCompanion Function({
      required String id,
      required String serviceId,
      required int selectedDate,
      required String selectedTime,
      Value<String?> addressId,
      Value<String> note,
      Value<bool> synced,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$BookingDraftsTableUpdateCompanionBuilder =
    BookingDraftsCompanion Function({
      Value<String> id,
      Value<String> serviceId,
      Value<int> selectedDate,
      Value<String> selectedTime,
      Value<String?> addressId,
      Value<String> note,
      Value<bool> synced,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$BookingDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $BookingDraftsTable> {
  $$BookingDraftsTableFilterComposer({
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

  ColumnFilters<String> get serviceId => $composableBuilder(
    column: $table.serviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selectedDate => $composableBuilder(
    column: $table.selectedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedTime => $composableBuilder(
    column: $table.selectedTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressId => $composableBuilder(
    column: $table.addressId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookingDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookingDraftsTable> {
  $$BookingDraftsTableOrderingComposer({
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

  ColumnOrderings<String> get serviceId => $composableBuilder(
    column: $table.serviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectedDate => $composableBuilder(
    column: $table.selectedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedTime => $composableBuilder(
    column: $table.selectedTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressId => $composableBuilder(
    column: $table.addressId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookingDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookingDraftsTable> {
  $$BookingDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serviceId =>
      $composableBuilder(column: $table.serviceId, builder: (column) => column);

  GeneratedColumn<int> get selectedDate => $composableBuilder(
    column: $table.selectedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedTime => $composableBuilder(
    column: $table.selectedTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get addressId =>
      $composableBuilder(column: $table.addressId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BookingDraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookingDraftsTable,
          BookingDraftRow,
          $$BookingDraftsTableFilterComposer,
          $$BookingDraftsTableOrderingComposer,
          $$BookingDraftsTableAnnotationComposer,
          $$BookingDraftsTableCreateCompanionBuilder,
          $$BookingDraftsTableUpdateCompanionBuilder,
          (
            BookingDraftRow,
            BaseReferences<_$AppDatabase, $BookingDraftsTable, BookingDraftRow>,
          ),
          BookingDraftRow,
          PrefetchHooks Function()
        > {
  $$BookingDraftsTableTableManager(_$AppDatabase db, $BookingDraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookingDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookingDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookingDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> serviceId = const Value.absent(),
                Value<int> selectedDate = const Value.absent(),
                Value<String> selectedTime = const Value.absent(),
                Value<String?> addressId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookingDraftsCompanion(
                id: id,
                serviceId: serviceId,
                selectedDate: selectedDate,
                selectedTime: selectedTime,
                addressId: addressId,
                note: note,
                synced: synced,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String serviceId,
                required int selectedDate,
                required String selectedTime,
                Value<String?> addressId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BookingDraftsCompanion.insert(
                id: id,
                serviceId: serviceId,
                selectedDate: selectedDate,
                selectedTime: selectedTime,
                addressId: addressId,
                note: note,
                synced: synced,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookingDraftsTable, BookingDraftRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BookingDraftsTable,
                    BookingDraftRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookingDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookingDraftsTable,
      BookingDraftRow,
      $$BookingDraftsTableFilterComposer,
      $$BookingDraftsTableOrderingComposer,
      $$BookingDraftsTableAnnotationComposer,
      $$BookingDraftsTableCreateCompanionBuilder,
      $$BookingDraftsTableUpdateCompanionBuilder,
      (
        BookingDraftRow,
        BaseReferences<_$AppDatabase, $BookingDraftsTable, BookingDraftRow>,
      ),
      BookingDraftRow,
      PrefetchHooks Function()
    >;
typedef $$ServiceCachesTableCreateCompanionBuilder =
    ServiceCachesCompanion Function({
      required String id,
      required String payload,
      required int sortOrder,
      Value<bool> synced,
      required int lastFetched,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$ServiceCachesTableUpdateCompanionBuilder =
    ServiceCachesCompanion Function({
      Value<String> id,
      Value<String> payload,
      Value<int> sortOrder,
      Value<bool> synced,
      Value<int> lastFetched,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$ServiceCachesTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceCachesTable> {
  $$ServiceCachesTableFilterComposer({
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

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ServiceCachesTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceCachesTable> {
  $$ServiceCachesTableOrderingComposer({
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

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServiceCachesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceCachesTable> {
  $$ServiceCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<int> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ServiceCachesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServiceCachesTable,
          ServiceCacheRow,
          $$ServiceCachesTableFilterComposer,
          $$ServiceCachesTableOrderingComposer,
          $$ServiceCachesTableAnnotationComposer,
          $$ServiceCachesTableCreateCompanionBuilder,
          $$ServiceCachesTableUpdateCompanionBuilder,
          (
            ServiceCacheRow,
            BaseReferences<_$AppDatabase, $ServiceCachesTable, ServiceCacheRow>,
          ),
          ServiceCacheRow,
          PrefetchHooks Function()
        > {
  $$ServiceCachesTableTableManager(_$AppDatabase db, $ServiceCachesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceCachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> lastFetched = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServiceCachesCompanion(
                id: id,
                payload: payload,
                sortOrder: sortOrder,
                synced: synced,
                lastFetched: lastFetched,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String payload,
                required int sortOrder,
                Value<bool> synced = const Value.absent(),
                required int lastFetched,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ServiceCachesCompanion.insert(
                id: id,
                payload: payload,
                sortOrder: sortOrder,
                synced: synced,
                lastFetched: lastFetched,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ServiceCachesTable, ServiceCacheRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ServiceCachesTable,
                    ServiceCacheRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ServiceCachesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServiceCachesTable,
      ServiceCacheRow,
      $$ServiceCachesTableFilterComposer,
      $$ServiceCachesTableOrderingComposer,
      $$ServiceCachesTableAnnotationComposer,
      $$ServiceCachesTableCreateCompanionBuilder,
      $$ServiceCachesTableUpdateCompanionBuilder,
      (
        ServiceCacheRow,
        BaseReferences<_$AppDatabase, $ServiceCachesTable, ServiceCacheRow>,
      ),
      ServiceCacheRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StoredAddressesTableTableManager get storedAddresses =>
      $$StoredAddressesTableTableManager(_db, _db.storedAddresses);
  $$BookingDraftsTableTableManager get bookingDrafts =>
      $$BookingDraftsTableTableManager(_db, _db.bookingDrafts);
  $$ServiceCachesTableTableManager get serviceCaches =>
      $$ServiceCachesTableTableManager(_db, _db.serviceCaches);
}
