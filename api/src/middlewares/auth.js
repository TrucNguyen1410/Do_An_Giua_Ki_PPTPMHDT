// api/src/middlewares/auth.js

import jwt from 'jsonwebtoken';

// Dùng 'export default' cho hàm middleware
export default function(req, res, next) {
  // === SỬA LỖI Ở ĐÂY ===
  // 1. Đọc đúng header 'x-auth-token'
  // (Đây là header mà api_client.dart đang gửi)
  const token = req.header('x-auth-token');

  // 2. Kiểm tra nếu không có token
  if (!token) {
    // Trả về đúng định dạng JSON { "msg": "..." }
    // mà api_client.dart đang mong đợi
    return res.status(401).json({ msg: 'Không có token, truy cập bị từ chối' });
  }

  // 3. Xác thực token
  try {
    // Giải mã token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Gán thông tin user vào request object
    // Phải khớp với cấu trúc payload bạn tạo khi đăng nhập: { user: { id: "...", role: "..." } }
    req.user = decoded.user; 
    
    // Chuyển sang middleware/route tiếp theo (ví dụ: adminMiddleware)
    next();
  } catch (err) {
    // Nếu token không hợp lệ (hết hạn, sai chữ ký...)
    res.status(401).json({ msg: 'Token không hợp lệ' });
  }
};