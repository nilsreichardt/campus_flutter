import 'dart:developer';

import 'package:campus_flutter/base/enums/credentials.dart';
import 'package:campus_flutter/base/networking/protocols/api.dart';
import 'package:campus_flutter/base/networking/base/rest_client.dart';
import 'package:campus_flutter/loginComponent/model/confirm.dart';
import 'package:campus_flutter/loginComponent/services/login_service.dart';
import 'package:campus_flutter/loginComponent/views/location_permissions_view.dart';
import 'package:campus_flutter/main.dart';
import 'package:campus_flutter/personDetailedComponent/viewModel/person_details_viewmodel.dart';
import 'package:campus_flutter/profileComponent/viewModel/profile_viewmodel.dart';
import 'package:campus_flutter/studentCardComponent/viewModel/student_card_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

final loginViewModel = Provider((ref) => LoginViewModel());

class LoginViewModel {
  final _storage = const FlutterSecureStorage();
  BehaviorSubject<Credentials?> credentials = BehaviorSubject.seeded(null);
  BehaviorSubject<bool> tumIdValid = BehaviorSubject.seeded(false);

  bool _isSkipped = false;

  final TextEditingController textEditingController1 = TextEditingController();
  final TextEditingController textEditingController2 = TextEditingController();
  final TextEditingController textEditingController3 = TextEditingController();

  void clearTextFields() {
    textEditingController1.clear();
    textEditingController2.clear();
    textEditingController3.clear();
  }

  void checkTumId() {
    final RegExp lettersRegex = RegExp(r'^$|^[a-zA-Z]+$');
    final RegExp numberRegex = RegExp(r'^$|^[0-9]+$');

    if (!lettersRegex.hasMatch(textEditingController1.text)) {
      tumIdValid.addError("make sure to use letters only");
      return;
    }

    if (lettersRegex.hasMatch(textEditingController1.text)) {
      tumIdValid.add(false);
    }

    if (!numberRegex.hasMatch(textEditingController2.text)) {
      tumIdValid.addError("make sure to use numbers only");
      return;
    }

    if (lettersRegex.hasMatch(textEditingController2.text)) {
      tumIdValid.add(false);
    }

    if (!lettersRegex.hasMatch(textEditingController3.text)) {
      tumIdValid.addError("make sure to use letters only");
      return;
    }

    if (lettersRegex.hasMatch(textEditingController3.text)) {
      tumIdValid.add(false);
    }

    if (textEditingController1.text.length != 2) {
      return;
    }

    if (textEditingController2.text.length != 2) {
      return;
    }

    if (textEditingController3.text.length != 3) {
      return;
    }

    tumIdValid.add(true);
  }

  Future checkLogin() async {
    _storage.read(key: "token").then(
      (value) async {
        if (value != null) {
          Api.tumToken = value;
          await LoginService.confirmToken(false).then(
            (value) {
              credentials.add(Credentials.tumId);
            },
            onError: (error) {
              credentials.add(Credentials.none);
              _errorHandling(error);
            },
          );
        } else {
          credentials.add(Credentials.none);
        }
      },
      onError: (error) => _errorHandling(error),
    );
  }

  _errorHandling(dynamic error) {
    log(error.toString());
    credentials.add(Credentials.none);
  }

  Future requestLogin() async {
    return LoginService.requestNewToken(
      true,
      "${textEditingController1.text}${textEditingController2.text}${textEditingController3.text}",
    ).then((value) {
      final token = value.content;
      _storage.write(key: "token", value: token);
      Api.tumToken = token;
    });
  }

  Future<Confirm> confirmLogin() async {
    return LoginService.confirmToken(true).then((value) {
      if (value.confirmed) {
        credentials.add(Credentials.tumId);
      }
      return value;
    });
  }

  void skip(BuildContext context) {
    _isSkipped = true;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LocationPermissionView(),
      ),
    );
  }

  Future<void> requestLocation(BuildContext context) async {
    Permission.location.request().then(
      (value) {
        if (_isSkipped) {
          credentials.add(Credentials.noTumId);
        }
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }

  Future logout(WidgetRef ref) async {
    ref.invalidate(profileViewModel);
    ref.invalidate(personDetailsViewModel);
    ref.invalidate(studentCardViewModel);
    await getIt<RESTClient>().clearCache();
    await _storage.delete(key: "token");
    Api.tumToken = "";
    credentials.add(Credentials.none);
  }
}
