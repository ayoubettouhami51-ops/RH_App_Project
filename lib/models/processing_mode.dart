/// Defines the three independent HR calculation paths.
enum ProcessingMode {
  /// Prime de Performance: attendance-based with MIS/RPJ/FC/VS as presence codes
  performance,

  /// Heures Supplémentaires: V04/V05/V06/V07 extraction, sorted descending
  overtime,

  /// Prime Automobile: strict HH:MM only, MIS/FC excluded
  automobile,
}
