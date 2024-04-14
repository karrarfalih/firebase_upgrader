# firebase_upgrader

A Flutter package for handling optional and forceful app updates using Firebase Reatime Database.

# Table of Contents

- [firebase\_upgrader](#firebase_upgrader)
- [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Simple Example](#simple-example)
    - [Customizable Example](#customizable-example)
  - [Contributions and Issues](#contributions-and-issues)

## Installation

Add `firebase_upgrader` to your `pubspec.yaml` file:

```yaml
dependencies:
  firebase_upgrader: ^1.0.1
```

Run flutter pub get to install the package.

## Usage

1- Add the following code to your `main()` function to ensure initialization:
```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();  //Add this line
  runApp(const MyApp());
}
```

2- Add the following properties to your `MaterialApp` widget:
```dart
navigatorKey: FirebaseUpgrader.navigationKey,
builder: FirebaseUpgrader.builder,
```

3- Specify the minimum version and current version of your app in the Firebase Realtime Database as follow:
```json
{
  "features": {
    "minVersion": "1.23.45",
    "currentVersion": "1.23.45",
  }
}
```
You can also specify different version according to the platform as follow:
```json
{
  "features": {
    "minVersion": {
      "ios": "1.23.45",
      "android": "1.23.45",
    },
    "currentVersion": {
      "ios": "1.23.45",
      "android": "1.23.45",
    },
  }
}
```

### Simple Example

```dart
import 'package:firebase_upgrader/firebase_upgrader.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: FirebaseUpgrader.navigationKey,
      builder: FirebaseUpgrader.builder,
      // Other MaterialApp properties...
    );
  }
}
```

### Customizable Example
You can customize the appearance and behavior of the `FirebaseUpgrader` providing optional parameters to the `FirebaseUpgrader` as follow:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_upgrader/firebase_upgrader.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: FirebaseUpgrader.navigationKey,
      builder: (context, child){
        return FirebaseUpgrader(
            child: child,
            optionalTitle: 'New Update Available',
            optionalMessage: 'A new version is available. Do you want to update?',
            optionalButtonText: 'Update Now',
            forceTitle: 'Upgrade Required',
            forceMessage: 'This version of the app is no longer supported. Please upgrade to the latest version.',
            forceButtonText: 'Upgrade',
            logo: Image.asset('assets/logo.png'), // Add your logo image asset
            appStoreLink: 'https://apps.apple.com/us/app/your-app-name/id123456789', // Add your App Store link
            playStoreLink: 'https://play.google.com/store/apps/details?id=com.example.app',
            optionalUpgradeScreen: someWidegt,
            forceUpgradeScreen: anotherWidget,
        );
      },
      home: child: Scaffold(
        appBar: AppBar(
          title: Text('Customized Firebase Upgrader'),
        ),
        body: Center(
          child: Text('Welcome to the customized app!'),
        ),
      ),
    );
  }
}
```

## Contributions and Issues
Contributions and bug reports are welcome! Please feel free to open an issue or submit a pull request on the [GitHub repository](https://github.com/karrarfalih/firebase_upgrader).