import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color get pastel {
    var hsl = HSLColor.fromColor(this);
    var newSaturation = hsl.saturation > 0.1 ? 0.65 : hsl.saturation;
    return hsl.withSaturation(newSaturation).withLightness(0.87).toColor();
  }

  Color get onPastel {
    var hsl = HSLColor.fromColor(this);
    var newSaturation = hsl.saturation > 0.1 ? 0.48 : hsl.saturation;
    return hsl.withSaturation(newSaturation).withLightness(0.20).toColor();
  }
}

extension IterableExtension<T> on List<T> {
  Iterable<T> distinctBy(Object getCompareValue(T e)) {
    var idSet = <Object>{};
    var distinct = <T>[];
    for (var d in this) {
      if (idSet.add(getCompareValue(d))) {
        distinct.add(d);
      }
    }
    return distinct;
  }
}
