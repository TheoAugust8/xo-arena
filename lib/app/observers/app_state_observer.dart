import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef StateLogSink = void Function(String message);

final class AppStateObserver extends ProviderObserver {
  const AppStateObserver() : _sink = null;

  @visibleForTesting
  const AppStateObserver.withSink(this._sink);

  final StateLogSink? _sink;

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    _log('[Riverpod] add ${_nameOf(context)}: $value');
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    _log(
      '[Riverpod] update ${_nameOf(context)}: '
      '$previousValue -> $newValue',
    );
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    _log('[Riverpod] error ${_nameOf(context)}: $error\n$stackTrace');
  }

  void _log(String message) => (_sink ?? debugPrint)(message);

  String _nameOf(ProviderObserverContext context) {
    return context.provider.name ?? context.provider.runtimeType.toString();
  }
}
