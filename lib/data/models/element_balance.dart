import 'dart:convert';

class ElementBalance {
  final int air;
  final int water;
  final int fire;
  final int earth;
  final int balanceNine;

  final double dominantScore;
  final double passiveScore;

  final String dominantElement;
  final String weakestElement;
  final String energyType;

  const ElementBalance({
    required this.air,
    required this.water,
    required this.fire,
    required this.earth,
    required this.balanceNine,
    required this.dominantScore,
    required this.passiveScore,
    required this.dominantElement,
    required this.weakestElement,
    required this.energyType,
  });

  Map<String, dynamic> toJson() => {
        'air': air,
        'water': water,
        'fire': fire,
        'earth': earth,
        'balanceNine': balanceNine,
        'dominantScore': dominantScore,
        'passiveScore': passiveScore,
        'dominantElement': dominantElement,
        'weakestElement': weakestElement,
        'energyType': energyType,
      };

  factory ElementBalance.fromJson(Map<String, dynamic> json) => ElementBalance(
        air: json['air'] as int,
        water: json['water'] as int,
        fire: json['fire'] as int,
        earth: json['earth'] as int,
        balanceNine: json['balanceNine'] as int,
        dominantScore: (json['dominantScore'] as num).toDouble(),
        passiveScore: (json['passiveScore'] as num).toDouble(),
        dominantElement: json['dominantElement'] as String,
        weakestElement: json['weakestElement'] as String,
        energyType: json['energyType'] as String,
      );
}
