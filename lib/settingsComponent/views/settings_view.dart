import 'package:campus_flutter/base/enums/credentials.dart';
import 'package:campus_flutter/homeComponent/widgetComponent/views/widget_frame_view.dart';
import 'package:campus_flutter/loginComponent/viewModels/login_viewmodel.dart';
import 'package:campus_flutter/settingsComponent/views/appearance_settings_view.dart';
import 'package:campus_flutter/settingsComponent/views/contact_view.dart';
import 'package:campus_flutter/base/extensions/context.dart';
import 'package:campus_flutter/settingsComponent/views/general_settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final useWebView = StateProvider<bool>((ref) => true);
final hideFailedGrades = StateProvider<bool>((ref) => false);

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        const GeneralSettingsView(),
        const AppearanceSettingsView(),
        const ContactView(),
        _authenticationButton(context, ref),
        _versionNumberText(),
      ],
    );
  }

  Widget _authenticationButton(BuildContext context, WidgetRef ref) {
    final login = ref.read(loginViewModel).credentials.value;
    return WidgetFrameView(
      child: GestureDetector(
        onTap: () {
          if (login != Credentials.none) {
            ref.read(loginViewModel).logout(ref);
          }
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: Card(
          child: ListTile(
            dense: true,
            title: login != Credentials.tumId
                ? Text(
                    context.localizations.login,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                    textAlign: TextAlign.center,
                  )
                : Text(
                    context.localizations.logout,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _versionNumberText() {
    return Center(
      child: FutureBuilder(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(
              context.localizations.versionNumber(snapshot.data!.version),
            );
          } else {
            return Text(context.localizations.versionNumber("-.-.-"));
          }
        },
      ),
    );
  }
}
