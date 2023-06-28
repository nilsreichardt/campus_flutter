import 'dart:developer';

import 'package:campus_flutter/base/networking/protocols/api.dart';
import 'package:campus_flutter/base/networking/protocols/api_exception.dart';
import 'package:campus_flutter/loginComponent/model/confirm.dart';
import 'package:campus_flutter/loginComponent/services/loginService.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

class LoginViewModel {
  final _storage = const FlutterSecureStorage();
  BehaviorSubject<Credentials?> credentials = BehaviorSubject.seeded(null);
  BehaviorSubject<bool> tumIdValid = BehaviorSubject.seeded(false);

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
    _storage.read(key: "token").then((value) async {
      if (value != null) {
        Api.tumToken = value;
        await LoginService.confirmToken(false).then((value) {
          credentials.add(Credentials.tumId);
        }, onError: (error) {
          credentials.add(Credentials.none);
          _errorHandling(error);
        });
      } else {
        credentials.add(Credentials.none);
      }
    }, onError: (error) => _errorHandling(error));
  }

  _errorHandling(dynamic error) {
    log(error.toString());
    credentials.add(Credentials.none);
  }

  Future requestLogin() async {
    return LoginService.requestNewToken(
        true,
        "${textEditingController1.text}${textEditingController2.text}${textEditingController3.text}")
        .then((value) {
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

  skip() {
    credentials.add(Credentials.noTumId);
  }

  Future logout() async {
    credentials.add(Credentials.none);
    final directory = await getTemporaryDirectory();
    Api.tumToken = "";
    HiveCacheStore(directory.path).close();
    _storage.delete(key: "token");
  }
}

enum Credentials { none, noTumId, tumId }