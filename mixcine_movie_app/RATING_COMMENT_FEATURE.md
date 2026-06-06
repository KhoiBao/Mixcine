# 📽️ Tài Liệu Chức Năng: Rating Phim & Bình Luận Phim

## 📌 Tổng Quan

Chức năng **Rating Phim và Bình Luận Phim** được tích hợp vào màn hình chi tiết phim (Movie Detail Screen). Người dùng có thể:
- ⭐ Đánh giá phim từ 1-10 sao
- 💬 Thêm bình luận với timestamp tự động
- ⭐ Đánh giá bình luận của người khác (1-5 sao)
- ❌ Xóa bình luận của mình

---

## 🏗️ Kiến Trúc Hệ Thống

### Tầng Dữ Liệu (Entity Layer)
```
lib/domain/entities/
├── movie_comment.dart          # Model dữ liệu bình luận
```

### Tầng Quản Lý Trạng Thái (State Management)
```
lib/presentation/providers/
├── rating_comment_provider.dart # Provider Riverpod cho rating & comments
```

### Tầng Giao Diện (Presentation Layer)
```
lib/presentation/screens/movie_detail/
├── movie_detail_screen.dart    # 3 widgets: _RatingSection, _CommentsSection, _CommentTile
```

---

## 📊 Chi Tiết Từng Thành Phần

### 1️⃣ Entity: MovieComment (`lib/domain/entities/movie_comment.dart`)

Định nghĩa cấu trúc dữ liệu bình luận:

```dart
class MovieComment {
  const MovieComment({
    required this.id,           // ID duy nhất (tạo bằng DateTime.now().millisecondsSinceEpoch)
    required this.movieId,      // ID phim
    required this.author,       // Tác giả ("You" cho bình luận của người dùng)
    required this.text,         // Nội dung bình luận
    required this.rating,       // Đánh giá (0-5 sao)
    required this.createdAt,    // Thời gian tạo
  });

  // Tính toán thời gian tương đối (2h ago, 1d ago, 5/15/2026...)
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
    }
  }
}
```

**Tính năng nổi bật:**
- `formattedDate` getter: Tự động tính thời gian tương đối
- Hỗ trợ rating từ 0-5 sao

---

### 2️⃣ State Management: Provider (`lib/presentation/providers/rating_comment_provider.dart`)

Quản lý 2 trạng thái chính: **Rating** và **Comments**

#### **A. movieRatingsProvider** - Quản lý đánh giá phim

```dart
final movieRatingsProvider = NotifierProvider<
  MovieRatingsNotifier,
  Map<int, double>
>((ref) => MovieRatingsNotifier());

class MovieRatingsNotifier extends Notifier<Map<int, double>> {
  @override
  Map<int, double> build() => {};

  void setRating(int movieId, double rating) {
    final newState = {...state};
    newState[movieId] = rating;
    state = newState;
  }

  double getRating(int movieId) => state[movieId] ?? 0;
}
```

**Dữ liệu lưu trữ:** `Map<movieId, rating>`
- Ví dụ: `{123: 8.5, 456: 9.0}`

**Phương thức:**
| Phương Thức | Tham Số | Tác Dụng | Ví Dụ |
|-----------|--------|---------|-------|
| `setRating()` | `(movieId, rating)` | Lưu rating (0-10) | `setRating(123, 8.5)` |
| `getRating()` | `(movieId)` | Lấy rating đã lưu | `getRating(123)` → 8.5 |

#### **B. movieCommentsProvider** - Quản lý bình luận

```dart
final movieCommentsProvider = NotifierProvider<
  MovieCommentsNotifier,
  Map<int, List<MovieComment>>
>((ref) => MovieCommentsNotifier());

class MovieCommentsNotifier extends Notifier<Map<int, List<MovieComment>>> {
  @override
  Map<int, List<MovieComment>> build() => {};

  void addComment(int movieId, String author, String text, double rating) {
    final comment = MovieComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      movieId: movieId,
      author: author,
      text: text,
      rating: rating,
      createdAt: DateTime.now(),
    );
    
    final newState = {...state};
    final comments = [...?newState[movieId]];
    newState[movieId] = [comment, ...comments];
    state = newState;
  }

  List<MovieComment> getComments(int movieId) => state[movieId] ?? [];

  void deleteComment(int movieId, String commentId) {
    final newState = {...state};
    newState[movieId] = (newState[movieId] ?? [])
        .where((c) => c.id != commentId)
        .toList();
    state = newState;
  }
}
```

**Dữ liệu lưu trữ:** `Map<movieId, List<MovieComment>>`
- Ví dụ: `{123: [comment1, comment2, ...], 456: [...]}`

**Phương thức:**
| Phương Thức | Tham Số | Tác Dụng |
|-----------|--------|---------|
| `addComment()` | `(movieId, author, text, rating)` | Thêm bình luận mới (prepend list) |
| `getComments()` | `(movieId)` | Lấy danh sách bình luận |
| `deleteComment()` | `(movieId, commentId)` | Xóa bình luận theo ID |

---

### 3️⃣ UI Widgets (`lib/presentation/screens/movie_detail/movie_detail_screen.dart`)

#### **A. _RatingSection** - Đánh Giá Phim (1-10 sao)

**Mục đích:** Cho phép người dùng đánh giá phim từ 1-10 sao

**Bố cục:**
```
┌─────────────────────────────────┐
│ Rate this movie                 │
│ ⭐⭐⭐⭐⭐⭐⭐⭐⭐⭐         │
│ 7.0/10 (hoặc "Rate now")       │
└─────────────────────────────────┘
```

**Luồng hoạt động:**
```
1. Người dùng click sao (vị trí 1-10)
   ↓
2. setState() cập nhật _currentRating
   ↓
3. Gọi provider: setRating(movieId, rating)
   ↓
4. Provider lưu: {movieId: rating}
   ↓
5. UI rebuild: Hiển thị "x/10" hoặc "Rate now"
```

**Code chính:**
```dart
class _RatingSection extends ConsumerStatefulWidget {
  final int movieId;
  final WidgetRef ref;

  @override
  ConsumerState<_RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends ConsumerState<_RatingSection> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = ref.read(movieRatingsProvider)[widget.movieId] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rate this movie', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: List.generate(10, (index) {
              final rating = index + 1;
              final isSelected = rating <= _currentRating;
              return GestureDetector(
                onTap: () {
                  setState(() { _currentRating = rating.toDouble(); });
                  ref.read(movieRatingsProvider.notifier)
                     .setRating(widget.movieId, rating.toDouble());
                },
                child: Icon(
                  Icons.star_rounded,
                  color: isSelected ? AppColors.primary : Colors.grey,
                  size: 24,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _currentRating > 0 ? '$_currentRating/10' : 'Rate now',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
```

**Tính năng:**
- ✅ 10 sao tương tác
- ✅ Hiển thị rating hiện tại hoặc "Rate now"
- ✅ Cập nhật realtime
- ✅ Lưu trữ persistent

---

#### **B. _CommentsSection** - Bình Luận Phim

**Mục đích:** Hiển thị form nhập bình luận và danh sách bình luận

**Bố cục:**
```
┌──────────────────────────────────┐
│ Comments                         │
├──────────────────────────────────┤
│ Add your comment                 │
│ ┌──────────────────────────────┐ │
│ │ Write your comment...        │ │
│ └──────────────────────────────┘ │
│                      [ Post ]    │
├──────────────────────────────────┤
│ Bình luận 1                      │
├──────────────────────────────────┤
│ Bình luận 2                      │
└──────────────────────────────────┘
```

**Luồng hoạt động:**
```
1. Người dùng nhập text vào TextField
   ↓
2. Click nút Post (nền đỏ, chữ đen)
   ↓
3. Validate: Kiểm tra text không trống
   ├─ Nếu trống → Hiển thị SnackBar cảnh báo
   └─ Nếu có → Tiếp tục
   ↓
4. Gọi provider: addComment(movieId, 'You', text, 0)
   ↓
5. Provider tạo MovieComment object với:
   - id: Timestamp hiện tại
   - author: 'You' (tự động)
   - rating: 0 (không cho phép self-rating)
   ↓
6. Thêm vào đầu danh sách (prepend)
   ↓
7. ListView rebuild hiển thị danh sách
   ↓
8. Xóa text từ TextField + Hiển thị success message
```

**Code chính:**
```dart
class _CommentsSectionState extends ConsumerState<_CommentsSection> {
  final TextEditingController _commentController = TextEditingController();

  void _submitComment() {
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please write a comment')));
      return;
    }

    ref.read(movieCommentsProvider.notifier).addComment(
      widget.movieId,
      'You',                      // ✓ Tự động là "You"
      _commentController.text,
      0,                          // ✓ Rating comment = 0 (không cho phép self-rating)
    );

    _commentController.clear();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Comment added successfully')));
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(movieCommentsProvider)[widget.movieId] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Comments', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        // Form nhập bình luận
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add your comment', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write your comment...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _submitComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,        // ✓ Nền đỏ
                    foregroundColor: Colors.black,      // ✓ Chữ đen
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Post'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Danh sách bình luận
        if (comments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('No comments yet', style: Theme.of(context).textTheme.bodyMedium),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final comment = comments[index];
              return _CommentTile(comment: comment, movieId: widget.movieId, ref: ref);
            },
          ),
      ],
    );
  }
}
```

**Tính năng:**
- ✅ Form nhập bình luận với validation
- ✅ Nút Post: Nền đỏ, chữ đen
- ✅ Tự động xử lý author là "You"
- ✅ Danh sách bình luận realtime
- ✅ Hiển thị "No comments yet"
- ✅ Clear input sau khi post

---

#### **C. _CommentTile** - Hiển Thị Từng Bình Luận

**Mục đích:** Hiển thị chi tiết một bình luận

**Bố cục:**
```
┌─────────────────────────────────────┐
│ You                    [❌]          │
│ 2h ago                              │
│                                     │
│ This movie is amazing! Very good... │
│                                     │
│ ⭐⭐⭐⭐⭐ (chỉ cho comment khác) │
└─────────────────────────────────────┘
```

**Logic điều kiện:**

| Trường Hợp | Hiển Thị |
|-----------|---------|
| `comment.author == 'You'` | Không hiển thị sao, có nút xóa |
| `comment.author != 'You'` | Hiển thị sao (1-5), không có nút xóa |

**Code chính:**
```dart
class _CommentTile extends StatelessWidget {
  final MovieComment comment;
  final int movieId;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Author + Delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.author, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    // ✓ Hiển thị sao chỉ cho bình luận của người khác
                    if (comment.author != 'You')
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: index < comment.rating.toInt()
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // ✓ Nút xóa chỉ cho "You"
              if (comment.author == 'You')
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref.read(movieCommentsProvider.notifier)
                       .deleteComment(movieId, comment.id);
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Timestamp
          Text(
            comment.formattedDate,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          // Comment text
          Text(
            comment.text,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
```

**Tính năng:**
- ✅ Hiển thị tên tác giả
- ✅ Hiển thị timestamp tương đối (2h ago, 1d ago...)
- ✅ Nút xóa chỉ cho bình luận của mình
- ✅ Sao chỉ hiển thị cho bình luận của người khác (1-5 sao)
- ✅ Đoạn văn bản giới hạn 3 dòng với ellipsis

---

## 📋 Quy Tắc Kinh Doanh (Business Logic)

### Rating Phim

| Tình Huống | Hành Động | Kết Quả |
|-----------|---------|--------|
| Click sao 1-10 | Lưu vào provider | Hiển thị "x/10" |
| Không rating | - | Hiển thị "Rate now" |
| Rating lại | Click sao khác | Cập nhật giá trị mới |

### Bình Luận

| Tình Huống | Hành Động | Kết Quả |
|-----------|---------|--------|
| Nhập text trống + click Post | Validate fail | Hiển thị cảnh báo |
| Nhập text + click Post | Validate pass | Thêm vào đầu danh sách |
| Bình luận của mình | View | Hiển thị nút xóa, không có sao |
| Bình luận của người khác | View | Hiển thị sao (1-5), không có nút xóa |
| Click nút xóa | Delete action | Xóa khỏi danh sách |

---

## 🔄 Luồng Dữ Liệu (Data Flow)

### Rating Phim Flow
```
┌─────────────────────────────────────────────────────────┐
│                  UI Layer (_RatingSection)              │
│   User clicks star 7 → setState(_currentRating = 7)    │
└──────────────────────┬──────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────┐
│            Riverpod Provider Layer                       │
│   ref.read(movieRatingsProvider.notifier)               │
│           .setRating(movieId, 7)                        │
└──────────────────────┬──────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────┐
│            State Storage                                 │
│   {movieId: 7.0}                                        │
│   (Map<int, double>)                                    │
└──────────────────────┬──────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────┐
│            UI Rebuild                                    │
│   Text('7/10')                                          │
└─────────────────────────────────────────────────────────┘
```

### Bình Luận Flow
```
┌─────────────────────────────────────────────────────────┐
│        UI Layer (_CommentsSectionState)                 │
│   User types "Great movie!" → click Post                │
└──────────────────────┬──────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────┐
│            Validation                                    │
│   if (text.isEmpty) → Show SnackBar                     │
│   else → Continue                                       │
└──────────────────────┬──────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────┐
│        Create MovieComment Object                       │
│   MovieComment(                                         │
│     id: '1717670400000',                                │
│     movieId: 123,                                       │
│     author: 'You',                                      │
│     text: 'Great movie!',                               │
│     rating: 0,                                          │
│     createdAt: DateTime.now(),                          │
│   )                                                     │
└──────────────────────┬──────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────┐
│        Riverpod Provider Layer                          │
│   ref.read(movieCommentsProvider.notifier)              │
│       .addComment(movieId, 'You', text, 0)             │
└──────────────────────┬──────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────┐
│        State Storage (Prepend)                          │
│   {movieId: [newComment, ...oldComments]}               │
│   (Map<int, List<MovieComment>>)                        │
└──────────────────────┬──────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────┐
│        UI Rebuild                                        │
│   Clear TextField + Show SnackBar + Rebuild ListView    │
│   Hiển thị bình luận mới ở đầu danh sách                │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 Tóm Tắt Chức Năng

| # | Chức Năng | Chi Tiết | Trạng Thái |
|---|----------|---------|-----------|
| 1 | Rating phim | 10 sao, hiển thị "x/10" | ✅ |
| 2 | Thêm bình luận | Không cần nhập tên (auto "You") | ✅ |
| 3 | Xóa bình luận | Chỉ xóa bình luận của mình | ✅ |
| 4 | Rating bình luận | Chỉ người khác có thể (1-5 sao) | ✅ |
| 5 | Thời gian | Tương đối (2h ago, 1d ago...) | ✅ |
| 6 | Post button | Nền đỏ, chữ đen | ✅ |
| 7 | Validation | Kiểm tra comment trống | ✅ |
| 8 | Persistent | Lưu trong memory (xóa khi restart) | ✅ |

---

## 📁 File Liên Quan

```
lib/
├── domain/entities/
│   └── movie_comment.dart                          # ✅ Entity
├── presentation/providers/
│   └── rating_comment_provider.dart                # ✅ State Management
├── presentation/screens/movie_detail/
│   └── movie_detail_screen.dart                    # ✅ UI Widgets
└── core/config/
    └── api_config.dart                             # ✅ API Configuration
```

---

## 🚀 Cách Sử Dụng (Usage Example)

### 1. Import provider
```dart
import 'package:riverpod/riverpod.dart';
import 'rating_comment_provider.dart';
```

### 2. Sử dụng trong widget
```dart
final rating = ref.watch(movieRatingsProvider)[movieId] ?? 0;
final comments = ref.watch(movieCommentsProvider)[movieId] ?? [];
```

### 3. Cập nhật rating
```dart
ref.read(movieRatingsProvider.notifier).setRating(movieId, 8.0);
```

### 4. Thêm bình luận
```dart
ref.read(movieCommentsProvider.notifier).addComment(
  movieId,
  'You',
  'Great movie!',
  0,  // rating comment của chính mình
);
```

### 5. Xóa bình luận
```dart
ref.read(movieCommentsProvider.notifier).deleteComment(movieId, commentId);
```

---

## 📝 Ghi Chú Kỹ Thuật

### State Management Pattern
- **Framework:** Riverpod v2
- **Pattern:** NotifierProvider (hỗ trợ tạo state mutable)
- **State Immutability:** Sử dụng spread operator `{...state}` để tạo state mới

### Data Persistence
- **Hiện tại:** Lưu trong memory (Map collection trong provider)
- **Khi restart app:** Dữ liệu bị mất
- **Nâng cấp tương lai:** Có thể thêm Hive/SQLite để persistent storage

### Performance Optimization
- `ListView.separated` with `shrinkWrap: true`
- `NeverScrollableScrollPhysics` để tránh nested scrolling
- `formattedDate` getter tính toán realtime (có thể cache nếu cần)

### UX Improvements
- Auto "You" identifier (không cần nhập tên)
- Prevent self-rating (rating = 0 cho comment của chính mình)
- Conditional UI rendering (sao chỉ cho người khác)
- Relative timestamps (2h ago instead of full datetime)

---

## 🔮 Cải Tiến Tương Lai

### Phase 2 (Optional)
- [ ] Lưu dữ liệu vào local database (Hive/SQLite)
- [ ] Đồng bộ rating/comment với API backend
- [ ] Avatar cho người bình luận
- [ ] Like/dislike bình luận
- [ ] Reply/nested comments
- [ ] Edit bình luận
- [ ] Sorting/filtering bình luận (mới nhất, top rated...)
- [ ] Hiển thị số lượng rating của bình luận

---

## 📞 Contact & Support

**Repository:** https://github.com/KhoiBao/Mixcine  
**Branch:** `dev/Khanh`  
**Created:** 2026-06-06

---

*Tài liệu này cung cấp tổng quan chi tiết về chức năng Rating Phim & Bình Luận Phim được tích hợp trong ứng dụng Mixcine Movie App.*
