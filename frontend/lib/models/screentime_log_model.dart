class ScreenTimeLogModel {
  final int? id;
  final int? userId;
  final int minute; // Khớp với Column(Integer) ở backend
  final DateTime? createdAt; // Từ TimestampMixin
  final DateTime? updatedAt; // Từ TimestampMixin

  ScreenTimeLogModel({
    this.id,
    this.userId,
    required this.minute,
    this.createdAt,
    this.updatedAt,
  });

  // Chuyển JSON từ Backend trả về thành Object Flutter
  factory ScreenTimeLogModel.fromJson(Map<String, dynamic> json) {
    return ScreenTimeLogModel(
      id: json['id'],
      userId: json['user_id'],
      minute: json['minute'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // Đóng gói Object thành JSON để bắn POST lên FastAPI
  Map<String, dynamic> toJson() {
    return {
      // Thường khi POST lên, id và user_id backend sẽ tự gen hoặc lấy từ Token
      'minute': minute,
    };
  }
}
