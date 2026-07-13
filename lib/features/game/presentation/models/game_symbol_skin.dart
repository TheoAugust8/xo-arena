enum GameSymbolSkin { classic, geometric, power, nature }

extension GameSymbolSkinLabel on GameSymbolSkin {
  String get label => switch (this) {
    GameSymbolSkin.classic => 'Classic',
    GameSymbolSkin.geometric => 'Geometric',
    GameSymbolSkin.power => 'Power',
    GameSymbolSkin.nature => 'Nature',
  };
}
