import '../repositories/movie_repository.dart';

class GetFavoriteIdsUseCase {
  const GetFavoriteIdsUseCase(this._repository);

  final MovieRepository _repository;

  Future<Set<int>> call() {
    return _repository.getFavoriteIds();
  }
}
