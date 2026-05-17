class Employee {
  final String matricule;
  final String name;
  final Map<String, int> weekData; // S01 -> S05
  final int pp;
  final int pf;
  final Map<String, double> hours; // V04, V05, V06, V07
  final double totalSupp;
  final String remarque;

  Employee({
    required this.matricule,
    required this.name,
    required this.weekData,
    required this.pp,
    required this.pf,
    required this.hours,
    required this.totalSupp,
    required this.remarque,
  });
}
