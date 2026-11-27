// La sesión de IA solo vive en memoria durante el acceso autorizado.
abstract interface class BrisaSessionRepository {
  bool get brisaAvailable;
  Future<String?> askBrisa(String question);
  Future<void> closeBrisaSession();
}
