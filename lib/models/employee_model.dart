class Employee {
  final String matricule;
  final String name;

  // Prime de Performance
  final Map<String, int> perfWeeks; // S01 -> S05
  final int perfPP;
  final int perfPF;

  // Heures Supp
  final Map<String, double> hours; // V04, V05, V06, V07
  final double totalSupp;

  // Prime Auto
  final Map<String, int> autoWeeks; // S01 -> S05
  final int autoPP;

  final String remarque;

  Employee({
    required this.matricule,
    required this.name,
    required this.perfWeeks,
    required this.perfPP,
    required this.perfPF,
    required this.hours,
    required this.totalSupp,
    required this.autoWeeks,
    required this.autoPP,
    required this.remarque,
  });
}
