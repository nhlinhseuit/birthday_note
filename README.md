// tái cấu trúc sd bloc
// sn mẹ chưa hiện trên lịch âm
// gộp 2 lịch làm 1

# 📅 Birthday Note - Ứng dụng Ghi Chú Sinh Nhật & Sự Kiện

Ứng dụng Flutter giúp bạn quản lý và theo dõi các sự kiện quan trọng, sinh nhật, và ngày lễ theo cả lịch dương và lịch âm.

## ✨ Tính Năng Chính

### 🗓️ **Dual Calendar System**

- **Lịch Dương**: Hiển thị theo lịch Gregorian chuẩn
- **Lịch Âm**: Hiển thị theo âm lịch Việt Nam với thuật toán chuyển đổi chính xác
- **Chuyển đổi linh hoạt**: Dễ dàng chuyển đổi giữa 2 loại lịch

### 📝 **Quản Lý Sự Kiện**

- **Tạo sự kiện mới**: Ghi chú các sự kiện quan trọng
- **Hỗ trợ cả lịch dương và âm**: Chọn loại lịch phù hợp cho từng sự kiện
- **Lặp lại hàng năm**: Tự động nhắc nhở các sự kiện quan trọng mỗi năm
- **Mô tả chi tiết**: Thêm thông tin mô tả cho từng sự kiện

### 🔔 **Upcoming Events**

- **Xem sự kiện sắp tới**: Danh sách các sự kiện trong năm
- **Filter thông minh**:
  - Tất cả sự kiện
  - Sự kiện cá nhân (do bạn tạo)
  - Ngày lễ lịch âm có sẵn
- **Đếm ngược**: Hiển thị số ngày còn lại đến sự kiện

### 🎉 **Ngày Lễ Lịch Âm Tích Hợp**

Tự động hiển thị các ngày lễ truyền thống Việt Nam với **màu đỏ** để dễ nhận biết:

- **Tết Nguyên Đán** (1/1 âm lịch) - Ngày đầu năm mới
- **Tết Trung Thu** (15/8 âm lịch) - Tết thiếu nhi

### 🎂 **Hệ Thống Biểu Tượng Thông Minh**

Ứng dụng sử dụng **2 loại biểu tượng** để phân biệt các loại sự kiện:

#### 🔴 **Ngày Lễ Lịch Âm**

- **Màu đỏ**: Text của ngày lễ được hiển thị màu đỏ
- **Font đậm**: Tên ngày lễ được làm đậm để nổi bật
- **Tự động**: Hiển thị tự động theo lịch âm Việt Nam

#### 🎂 **Sự Kiện Cá Nhân**

- **Icon bánh kem**: Biểu tượng bánh kem màu tím hiển thị trên ngày có sự kiện
- **Vị trí**: Góc dưới bên phải của ô ngày
- **Tương tác**: Click vào ngày để xem chi tiết sự kiện

## 🎨 **Giao Diện & Trải Nghiệm**

### **Dark Theme Elegant**

- Thiết kế tối với màu chủ đạo xanh navy (#202A35)
- Giao diện hiện đại, dễ nhìn và thân thiện
- Icons và typography được tối ưu cho mobile

### **Navigation Intuitive**

- **Bottom Navigation Bar** với 3 tab chính:
  - 📅 **Lịch Dương**: Xem lịch dương với sự kiện
  - 🌙 **Lịch Âm**: Xem lịch âm với ngày lễ truyền thống
  - 🔔 **Sắp tới**: Danh sách sự kiện sắp diễn ra

### **Floating Action Button**

- Nút thêm sự kiện mới nổi bật ở giữa
- Thiết kế gradient đẹp mắt
- Dễ dàng truy cập từ mọi màn hình

## 🔧 **Công Nghệ & Kiến Trúc**

### **Flutter Framework**

- **Flutter SDK**: ^3.5.3
- **Dart**: Latest stable version
- **Cross-platform**: iOS, Android, Web, macOS, Linux, Windows

### **State Management**

- **BLoC Pattern**: Quản lý state hiệu quả với flutter_bloc
- **Equatable**: So sánh object dễ dàng

### **Local Storage**

- **SharedPreferences**: Lưu trữ dữ liệu events
- **JSON Serialization**: Chuyển đổi dữ liệu an toàn
- **Real-time Sync**: Đồng bộ dữ liệu giữa các màn hình lịch

### **UI Libraries**

- **Table Calendar**: Hiển thị lịch đẹp mắt với marker builder
- **Font Awesome**: Icons phong phú
- **Flutter Animate**: Hiệu ứng mượt mà

### **Lunar Calendar Accuracy**

- **Hồ Ngọc Đức Algorithm**: Sử dụng thuật toán chuẩn của Việt Nam
- **24h.com.vn Data**: Dữ liệu chính xác từ nguồn uy tín
- **Lookup Tables**: Bảng tra cứu cho năm 2025 với độ chính xác cao
- **Fallback Algorithm**: Thuật toán dự phòng cho các năm khác

### **Firebase Integration**

- **Firebase Core**: Cơ sở hạ tầng
- **Firebase Auth**: Xác thực người dùng (sẵn sàng)
- **Firebase Messaging**: Push notifications (sẵn sàng)

## 📱 **Cài Đặt & Chạy**

### **Yêu Cầu Hệ Thống**

- Flutter SDK 3.5.3+
- Dart SDK
- iOS 13.0+ (cho iOS)
- Android API 21+ (cho Android)

### **Cài Đặt**

```bash
# Clone repository
git clone <repository-url>
cd birthday_note

# Cài đặt dependencies
flutter pub get

# Chạy ứng dụng
flutter run
```

### **Build cho Production**

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 🚀 **Tính Năng Sắp Tới**

### **Phase 2**

- [ ] **Push Notifications**: Nhắc nhở sự kiện
- [ ] **Cloud Sync**: Đồng bộ dữ liệu với Firebase
- [ ] **Multi-user**: Hỗ trợ nhiều tài khoản
- [ ] **Event Categories**: Phân loại sự kiện
- [ ] **Reminder Settings**: Tùy chỉnh nhắc nhở

### **Phase 3**

- [ ] **Widget Home Screen**: Widget hiển thị sự kiện sắp tới
- [ ] **Export/Import**: Xuất nhập dữ liệu
- [ ] **Statistics**: Thống kê sự kiện
- [ ] **Custom Themes**: Chủ đề tùy chỉnh
- [ ] **Multi-language**: Hỗ trợ nhiều ngôn ngữ

## 🛠️ **Cấu Trúc Dự Án**

```
lib/
├── models/
│   └── event_model.dart                    # Model cho sự kiện với EventType & RepeatType
├── screens/
│   ├── create_event_screen.dart            # Màn hình tạo sự kiện với dual calendar support
│   └── upcoming_events_screen.dart         # Màn hình sự kiện sắp tới
├── services/
│   ├── event_service.dart                  # Service quản lý sự kiện với SharedPreferences
│   ├── lunar_calendar_service.dart         # Service lịch âm wrapper
│   └── accurate_lunar_calendar_service.dart # Service lịch âm chính xác với lookup tables
├── widgets/
│   ├── calendar_day_cell.dart              # Component ô ngày với holiday detection
│   ├── cupertino_date_picker_widget.dart   # Date picker component
│   ├── detailed_day_view.dart              # Chi tiết ngày được chọn
│   ├── legend_item.dart                    # Component legend
│   └── weekday_header.dart                 # Header thứ trong tuần
├── utils/
│   ├── app_utils.dart                      # Utilities chung
│   └── utils.dart                           # Helper functions
├── home_screen.dart                         # Màn hình chính với bottom navigation
├── main_screen.dart                         # Màn hình lịch dương
├── lunar_calendar_screen.dart               # Màn hình lịch âm với event markers
├── table_calendar.dart                      # Component lịch dương với event markers
├── app_view.dart                            # App configuration
└── main.dart                                # Entry point
```

## 📄 **License**

Dự án này được phát hành dưới giấy phép MIT. Xem file `LICENSE` để biết thêm chi tiết.

## 🤝 **Đóng Góp**

Mọi đóng góp đều được chào đón! Vui lòng:

1. Fork dự án
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## 📞 **Liên Hệ**

Nếu có bất kỳ câu hỏi hoặc đề xuất nào, vui lòng tạo issue hoặc liên hệ qua:

- **Email**: [your-email@example.com]
- **GitHub**: [your-github-username]

---

**Birthday Note** - Không bao giờ bỏ lỡ những sự kiện quan trọng trong cuộc sống! 🎂✨
