// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      firstname: json['vorname'] as String?,
      obfuscatedID: json['obfuscated_id'] as String?,
      obfuscatedIDEmployee: json['obfuscated_id_bedienstete'] as String?,
      obfuscatedIDExtern: json['obfuscated_id_extern'] as String?,
      obfuscatedIDStudent: json['obfuscated_id_studierende'] as String?,
      surname: json['familienname'] as String?,
      tumID: json['kennung'] as String?,
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'vorname': instance.firstname,
      'obfuscated_id': instance.obfuscatedID,
      'obfuscated_id_bedienstete': instance.obfuscatedIDEmployee,
      'obfuscated_id_extern': instance.obfuscatedIDExtern,
      'obfuscated_id_studierende': instance.obfuscatedIDStudent,
      'familienname': instance.surname,
      'kennung': instance.tumID,
    };

ProfileData _$ProfileDataFromJson(Map<String, dynamic> json) => ProfileData(
      profilesAttribute:
          Profiles.fromJson(json['rowset'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProfileDataToJson(ProfileData instance) =>
    <String, dynamic>{
      'rowset': instance.profilesAttribute,
    };

Profiles _$ProfilesFromJson(Map<String, dynamic> json) => Profiles(
      profile: Profiles._profileFromJson(json['row']),
    );

Map<String, dynamic> _$ProfilesToJson(Profiles instance) => <String, dynamic>{
      'row': instance.profile,
    };
