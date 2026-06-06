import '../entities/movie_section.dart';
import '../repositories/movie_repository.dart';

class GetHomeSectionsUseCase {
  const GetHomeSectionsUseCase(this._repository);

  final MovieRepository _repository;

  Future<List<MovieSection>> call() {
    return _repository.getHomeSections();
  }
}
