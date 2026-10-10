# Flutter #193765: standalone iOS Password AutoFill probe

Issue: https://github.com/flutter/flutter/issues/193765

Maintainer request: https://github.com/flutter/flutter/issues/193765#issuecomment-5991075365

This is an iOS-only project created with Flutter 3.47.5 using:

```sh
flutter create --empty --platforms ios --org com.example --project-name autofill_probe --no-pub autofill_probe
```

`lib/main.dart` is the issue's two-TextField sample, with formatting changes only. It has no plugins, application dependencies, network calls, submission action, custom focus behavior, or integration-test binding. The username is the dummy value `+12025550148`. The password starts empty. `AutofillGroup.onDisposeAction` is `cancel`.

## Run

Use Flutter 3.47.5 (framework `6a19cca56475dbfba1478ee68d7bd0c2ef891da1`, engine `af7e796e161ae0bb1ff0758c71a7105418bd9ded`, Dart 3.13.4).

```sh
flutter pub get
flutter analyze
flutter run -d <device-id>
```

For a physical iPhone, open `ios/Runner.xcworkspace` and select your own development team under Runner > Signing & Capabilities. The distributable source omits the local development-team assignment. The bundle identifier is `com.example.autofillProbe`; change it if required by your signing account. Do not replace an existing app's bundle identifier.

## Native configuration

- The complete generated iOS runner, AppDelegate, SceneDelegate, Info.plist, Xcode project, and shared Runner scheme are included.
- This runner has no `CODE_SIGN_ENTITLEMENTS` assignment and no Associated Domains capability or entitlements file. No `webcredentials:` association or AASA file is required to trigger the suggestion in the observed fresh-simulator run.
- The native delegates use the stock Flutter template. There are no custom native text fields or keyboard handlers.
- Dart requests `AutofillHints.username` on a read-only username and `AutofillHints.newPassword` on an obscured password.
- In iOS Settings > General > AutoFill & Passwords, verify **AutoFill Passwords and Passkeys**, **Passwords**, and **Suggest Strong Passwords** are enabled. They were already enabled on the newly created test simulator; no Apple Account was signed in and no Passwords onboarding was performed.
- For Simulator, turn **I/O > Keyboard > Connect Hardware Keyboard** off. Confirm a normal software keyboard appears when the strong-password suggestion is dismissed.

The original application's runner had these associated domains:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:otiumz.com</string>
  <string>applinks:www.otiumz.com</string>
</array>
```

These are `applinks` entries, not `webcredentials` entries, and they are **not enabled in this reproduction**. They are documented to clarify the original report's description of its existing runner.

## Generated-password sequence

1. Cold-launch the app with ordinary `flutter run`, outside `integration_test`.
2. Tap the empty Password field.
3. Wait for Apple's **Use Strong Password?** sheet. If it does not appear, record that prerequisite failure; it is not a passing result for the editing issue.
4. Tap **Fill Strong Password** and wait until obscured characters appear in the Flutter field.
5. Tap the populated Password field. Record whether a usable caret and software keyboard return.
6. If the keyboard returns, delete one character and enter another to establish actual editability.

Expected: the generated value remains editable.

## Manual-entry control

Cold-launch again, tap Password, dismiss the suggestion with its close button, and type a dummy value using the software keyboard. Press Done, tap Password again, and delete one character. This distinguishes a general keyboard setup problem from the generated-password path.

## Observed results — 2026-10-10

Tested with Flutter 3.47.5, Xcode 26.2 (17C52), and ordinary debug `flutter run`.

| Target | Generated-password result |
| --- | --- |
| Newly created iPhone 17 Pro Max simulator, iOS 26.2 | Reproduced: the password fills, but tapping the populated field does not restore a usable caret or software keyboard. |
| Physical iPhone 16 Pro Max, iOS 26.6.2 (23G90), deployed over USB | Succeeded: the keyboard reopened and the generated password remained editable. |

The manual-entry control passed on both targets. The simulator was created with `simctl create`, not cloned. AutoFill Passwords and Passkeys, the Passwords provider, and Suggest Strong Passwords were enabled on both targets. The different iOS versions mean this comparison does not isolate simulator versus hardware from the OS-version difference.

The failure recording is provided in the linked Flutter issue. The sample does not authenticate an account or submit a password.

## Validation

The published source uses the exact tested `lib/main.dart`. A clean extraction of the source archive passed `flutter pub get --offline`, `flutter analyze`, and `flutter build ios --simulator --debug`. The working project also passed the signed device build and ran on the physical phone. Local signing-team settings and machine-generated files are omitted from this repository.
