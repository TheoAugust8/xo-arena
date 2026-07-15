import 'package:flutter/widgets.dart';

import 'package:xo_arena/l10n/generated/app_localizations.dart';

export 'package:xo_arena/l10n/generated/app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
