import '../repositories/movie_repository.dart';

class GetFavoriteIdsUseCase {
  const GetFavoriteIdsUseCase(this._repository);

  final MovieRepository _repository;

  // ✓ Add userId parameter
  Future<Set<int>> call(String userId) {
    return _repository.getFavoriteIds(userId);
  }
}
