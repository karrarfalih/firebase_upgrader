library firebase_upgrader;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_feature_flag/firebase_feature_flag.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// 1- add this to the main() :
///   WidgetsFlutterBinding.ensureInitialized();
/// 2- add the to the MaterialApp:
///   navigatorKey: FirebaseUpgrader.navigationKey,
///   builder: FirebaseUpgrader.builder,

class FirebaseUpgrader extends StatefulWidget {
  final Widget? child;
  final Widget? optionalUpgradeScreen;
  final Widget? forceUpgradeScreen;
  final bool useDialog;
  final GlobalKey<NavigatorState> _navigationKey;
  final String? optionalTitle;
  final String? optionalMessage;
  final String? forceTitle;
  final String? forceMessage;
  final String? forceButtonText;
  final String? optionalButtonText;
  final String? optionalButtonCancelText;
  final Widget? logo;
  final String? appStoreLink;
  final String? playStoreLink;

  FirebaseUpgrader({
    this.child,
    this.optionalUpgradeScreen,
    this.forceUpgradeScreen,
    this.useDialog = true,
    this.optionalTitle,
    this.optionalMessage,
    this.forceTitle,
    this.forceMessage,
    this.forceButtonText,
    this.optionalButtonText,
    this.optionalButtonCancelText,
    this.logo,
    this.appStoreLink,
    this.playStoreLink,
    GlobalKey<NavigatorState>? customNavigationKey,
  }) : _navigationKey = customNavigationKey ?? navigationKey;

  static final navigationKey = GlobalKey<NavigatorState>();
  static Widget builder(BuildContext context, Widget? child) {
    return FirebaseUpgrader(child: child ?? const SizedBox());
  }

  @override
  State<FirebaseUpgrader> createState() => _FirebaseUpgraderState();
}

class _FirebaseUpgraderState extends State<FirebaseUpgrader> {
  final currentVersion = FeatureFlag(key: 'currentVersion', initialValue: '0');
  final minVersion = FeatureFlag(key: 'minVersion', initialValue: '1.0.43');
  late final storeLink = FeatureFlag(
    key: 'storeLink',
    initialValue: Platform.isAndroid
        ? widget.playStoreLink ?? ''
        : widget.appStoreLink ?? '',
  );

  bool _shouldUpdate(String v1, String v2) {
    try {
      final v1Nums = v1.split('.').map(int.parse).toList();
      final v2Nums = v2.split('.').map(int.parse).toList();
      for (int i = 0; i < v1Nums.length; i++) {
        final result = v1Nums[i].compareTo(v2Nums[i]);
        if (result != 0) {
          return result == 1;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _checkOptionalUpdate();
    });
  }

  _checkOptionalUpdate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (storeLink.value.isEmpty) return;
    final packageInfo = await PackageInfo.fromPlatform();
    if (_shouldUpdate(currentVersion.value, packageInfo.version)) return;
    currentVersion.listen((currentVersion) {
      if (_shouldUpdate(currentVersion, packageInfo.version)) {
        if (widget._navigationKey.currentContext == null) return;
        if (!widget.useDialog) {
          Navigator.of(widget._navigationKey.currentContext!).pushReplacement(
            MaterialPageRoute(
              builder: (context) {
                return widget.optionalUpgradeScreen ??
                    const Scaffold(
                      body: Center(
                        child:
                            Text('Please update the app to the latest version'),
                      ),
                    );
              },
            ),
          );

          return;
        }
        showDialog(
          context: widget._navigationKey.currentContext!,
          builder: (context) {
            return widget.optionalUpgradeScreen ??
                AlertDialog(
                  title: Text(widget.optionalTitle ?? 'Update App?'),
                  content: Text(widget.optionalMessage ??
                      'A new version is available. Do you want to update?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(widget.optionalButtonCancelText ?? 'Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        launchUrl(Uri.parse(storeLink.value));
                      },
                      child: Text(widget.optionalButtonText ?? 'Update'),
                    ),
                  ],
                );
          },
        );
      }
    });
  }

  @override
  dispose() {
    currentVersion.dispose();
    minVersion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return widget.child ?? const SizedBox();
          }
          return FeatureFlagBuilder(
            builder: (context, value) {
              if (_shouldUpdate(
                  minVersion.value, snapshot.data?.version ?? '0')) {
                return widget.forceUpgradeScreen ??
                    Scaffold(
                        body: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.logo != null) widget.logo!,
                          Text(
                            widget.forceTitle ?? "We're Better Than Ever!",
                            style: TextStyle(fontSize: 24),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            widget.forceMessage ??
                                'The current version is no longer supported. Please update the app to the latest version.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () async {
                              if (storeLink.value.isNotEmpty) {
                                launchUrl(Uri.parse(storeLink.value));
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 10,
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            child: Text(
                              widget.forceButtonText ?? 'Update',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ));
              }

              return widget.child ?? const SizedBox();
            },
            feature: minVersion,
          );
        });
  }
}
