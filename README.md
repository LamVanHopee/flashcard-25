# FlashcardMaster

Ứng dụng học tập với flashcard được xây dựng bằng Flutter.

## Tính năng

- Tạo và quản lý flashcard với câu hỏi và đáp án
- Phân loại flashcard theo chủ đề
- Chế độ học với animation lật thẻ
- Theo dõi tiến độ học tập (số lần trả lời đúng/sai)
- Giao diện người dùng thân thiện và hiện đại
- Lưu trữ dữ liệu cục bộ với Hive

## Cài đặt

1. Cài đặt Flutter SDK:
   ```bash
   https://flutter.dev/docs/get-started/install
   ```

2. Clone repository:
   ```bash
   git clone https://github.com/yourusername/flashcardmaster.git
   cd flashcardmaster
   ```

3. Cài đặt dependencies:
   ```bash
   flutter pub get
   ```

4. Chạy ứng dụng:
   ```bash
   flutter run
   ```

## Cấu trúc dự án

```
lib/
├── models/
│   ├── flashcard.dart
│   └── flashcard.g.dart
├── providers/
│   └── flashcard_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── quiz_screen.dart
│   └── add_flashcard_screen.dart
├── widgets/
│   └── flashcard_widget.dart
└── main.dart
```

## Dependencies

- provider: ^6.1.1
- hive: ^2.2.3
- hive_flutter: ^1.1.0
- flutter_flip_card: ^0.0.4

## Hướng dẫn sử dụng

1. Thêm flashcard mới:
   - Nhấn nút "+" trên màn hình chính
   - Nhập câu hỏi và đáp án
   - Tùy chọn thêm chủ đề
   - Nhấn "Add Flashcard" để lưu

2. Học với flashcard:
   - Chọn flashcard từ màn hình chính
   - Chạm vào thẻ để xem đáp án
   - Đánh dấu "Remembered" hoặc "Forgot"
   - Di chuyển qua lại giữa các thẻ

3. Quản lý chủ đề:
   - Sử dụng menu dropdown trên thanh công cụ
   - Lọc flashcard theo chủ đề

## Đóng góp

Mọi đóng góp đều được hoan nghênh! Vui lòng tạo issue hoặc pull request. 