// Classe base abstrata para todos os casos de uso
// Segue o princípio de responsabilidade única (SRP)
abstract class UseCase<Type, Params> {
  // Método principal que executa o caso de uso
  Future<Type> call(Params params);
}

// Classe para casos de uso sem parâmetros
abstract class NoParamsUseCase<Type> {
  Future<Type> call();
}

// Classe para casos de uso que retornam Stream
abstract class StreamUseCase<Type, Params> {
  Stream<Type> call(Params params);
}

// Classe para casos de uso sem parâmetros que retornam Stream
abstract class NoParamsStreamUseCase<Type> {
  Stream<Type> call();
}

// Classe vazia para casos de uso sem parâmetros
class NoParams {
  const NoParams();
} 