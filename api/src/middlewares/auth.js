// src/middlewares/auth.js
import jwt from 'jsonwebtoken';

// Dùng 'export default' thay vì 'module.exports'
export default (req, res, next) => {
  // Lấy token từ header
  const authHeader = req.header('Authorization');
  if (!authHeader) {
    return res.status(401).json({ message: 'Không có token, truy cập bị từ chối' });
  }

  // Token thường có dạng "Bearer [token]"
  const token = authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ message: 'Token không hợp lệ' });
  }

  try {
    // Xác thực token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    // Gắn thông tin user (đã giải mã) vào request
    req.user = decoded;
    next(); // Đi tiếp
  } catch (ex) {
    res.status(400).json({ message: 'Token không hợp lệ' });
  }
};