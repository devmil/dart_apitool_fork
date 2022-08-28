// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'type_alias_declaration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$TypeAliasDeclaration {
  String get name => throw _privateConstructorUsedError;
  String get aliasedTypeName => throw _privateConstructorUsedError;
  bool get isDeprecated => throw _privateConstructorUsedError;
  Set<String>? get entryPoints => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TypeAliasDeclarationCopyWith<TypeAliasDeclaration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TypeAliasDeclarationCopyWith<$Res> {
  factory $TypeAliasDeclarationCopyWith(TypeAliasDeclaration value,
          $Res Function(TypeAliasDeclaration) then) =
      _$TypeAliasDeclarationCopyWithImpl<$Res>;
  $Res call(
      {String name,
      String aliasedTypeName,
      bool isDeprecated,
      Set<String>? entryPoints});
}

/// @nodoc
class _$TypeAliasDeclarationCopyWithImpl<$Res>
    implements $TypeAliasDeclarationCopyWith<$Res> {
  _$TypeAliasDeclarationCopyWithImpl(this._value, this._then);

  final TypeAliasDeclaration _value;
  // ignore: unused_field
  final $Res Function(TypeAliasDeclaration) _then;

  @override
  $Res call({
    Object? name = freezed,
    Object? aliasedTypeName = freezed,
    Object? isDeprecated = freezed,
    Object? entryPoints = freezed,
  }) {
    return _then(_value.copyWith(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      aliasedTypeName: aliasedTypeName == freezed
          ? _value.aliasedTypeName
          : aliasedTypeName // ignore: cast_nullable_to_non_nullable
              as String,
      isDeprecated: isDeprecated == freezed
          ? _value.isDeprecated
          : isDeprecated // ignore: cast_nullable_to_non_nullable
              as bool,
      entryPoints: entryPoints == freezed
          ? _value.entryPoints
          : entryPoints // ignore: cast_nullable_to_non_nullable
              as Set<String>?,
    ));
  }
}

/// @nodoc
abstract class _$$_TypeAliasDeclarationCopyWith<$Res>
    implements $TypeAliasDeclarationCopyWith<$Res> {
  factory _$$_TypeAliasDeclarationCopyWith(_$_TypeAliasDeclaration value,
          $Res Function(_$_TypeAliasDeclaration) then) =
      __$$_TypeAliasDeclarationCopyWithImpl<$Res>;
  @override
  $Res call(
      {String name,
      String aliasedTypeName,
      bool isDeprecated,
      Set<String>? entryPoints});
}

/// @nodoc
class __$$_TypeAliasDeclarationCopyWithImpl<$Res>
    extends _$TypeAliasDeclarationCopyWithImpl<$Res>
    implements _$$_TypeAliasDeclarationCopyWith<$Res> {
  __$$_TypeAliasDeclarationCopyWithImpl(_$_TypeAliasDeclaration _value,
      $Res Function(_$_TypeAliasDeclaration) _then)
      : super(_value, (v) => _then(v as _$_TypeAliasDeclaration));

  @override
  _$_TypeAliasDeclaration get _value => super._value as _$_TypeAliasDeclaration;

  @override
  $Res call({
    Object? name = freezed,
    Object? aliasedTypeName = freezed,
    Object? isDeprecated = freezed,
    Object? entryPoints = freezed,
  }) {
    return _then(_$_TypeAliasDeclaration(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      aliasedTypeName: aliasedTypeName == freezed
          ? _value.aliasedTypeName
          : aliasedTypeName // ignore: cast_nullable_to_non_nullable
              as String,
      isDeprecated: isDeprecated == freezed
          ? _value.isDeprecated
          : isDeprecated // ignore: cast_nullable_to_non_nullable
              as bool,
      entryPoints: entryPoints == freezed
          ? _value._entryPoints
          : entryPoints // ignore: cast_nullable_to_non_nullable
              as Set<String>?,
    ));
  }
}

/// @nodoc

class _$_TypeAliasDeclaration extends _TypeAliasDeclaration {
  const _$_TypeAliasDeclaration(
      {required this.name,
      required this.aliasedTypeName,
      required this.isDeprecated,
      final Set<String>? entryPoints})
      : _entryPoints = entryPoints,
        super._();

  @override
  final String name;
  @override
  final String aliasedTypeName;
  @override
  final bool isDeprecated;
  final Set<String>? _entryPoints;
  @override
  Set<String>? get entryPoints {
    final value = _entryPoints;
    if (value == null) return null;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(value);
  }

  @override
  String toString() {
    return 'TypeAliasDeclaration(name: $name, aliasedTypeName: $aliasedTypeName, isDeprecated: $isDeprecated, entryPoints: $entryPoints)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TypeAliasDeclaration &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality()
                .equals(other.aliasedTypeName, aliasedTypeName) &&
            const DeepCollectionEquality()
                .equals(other.isDeprecated, isDeprecated) &&
            const DeepCollectionEquality()
                .equals(other._entryPoints, _entryPoints));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(aliasedTypeName),
      const DeepCollectionEquality().hash(isDeprecated),
      const DeepCollectionEquality().hash(_entryPoints));

  @JsonKey(ignore: true)
  @override
  _$$_TypeAliasDeclarationCopyWith<_$_TypeAliasDeclaration> get copyWith =>
      __$$_TypeAliasDeclarationCopyWithImpl<_$_TypeAliasDeclaration>(
          this, _$identity);
}

abstract class _TypeAliasDeclaration extends TypeAliasDeclaration
    implements Declaration {
  const factory _TypeAliasDeclaration(
      {required final String name,
      required final String aliasedTypeName,
      required final bool isDeprecated,
      final Set<String>? entryPoints}) = _$_TypeAliasDeclaration;
  const _TypeAliasDeclaration._() : super._();

  @override
  String get name;
  @override
  String get aliasedTypeName;
  @override
  bool get isDeprecated;
  @override
  Set<String>? get entryPoints;
  @override
  @JsonKey(ignore: true)
  _$$_TypeAliasDeclarationCopyWith<_$_TypeAliasDeclaration> get copyWith =>
      throw _privateConstructorUsedError;
}
