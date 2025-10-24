// api/src/routes/auth.js

import express from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { check, validationResult } from 'express-validator';
import User from '../models/User.js'; // Đảm bảo model User cũng dùng export default

const router = express.Router();

/**
 * @route   POST api/auth/register
 * @desc    Đăng ký (Dành cho Student - Phần này giữ nguyên)
 */
router.post(
  '/register',
  [
    check('fullName', 'Họ tên là bắt buộc').not().isEmpty(),
    check('email', 'Vui lòng nhập email hợp lệ').isEmail(),
    check('password', 'Mật khẩu phải có ít nhất 6 ký tự').isLength({ min: 6 }),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { fullName, email, password } = req.body;

    // Chỉ cho phép email @sv.hcmunre.edu.vn đăng ký
    if (!email.endsWith('@sv.hcmunre.edu.vn')) {
      return res
        .status(400)
        .json({ errors: [{ msg: 'Chỉ chấp nhận email có đuôi @sv.hcmunre.edu.vn' }] });
    }

    try {
      let user = await User.findOne({ email });
      if (user) {
        return res.status(400).json({ errors: [{ msg: 'Email đã tồn tại' }] });
      }

      user = new User({
        fullName,
        email,
        password,
        role: 'student', // Đăng ký qua form luôn là 'student'
      });

      // Băm mật khẩu cho student
      const salt = await bcrypt.genSalt(10);
      user.password = await bcrypt.hash(password, salt);
      
      await user.save();

      const payload = {
        user: {
          id: user.id,
          role: user.role,
        },
      };

      jwt.sign(
        payload,
        process.env.JWT_SECRET,
        { expiresIn: 360000 },
        (err, token) => {
          if (err) {
            console.error('Lỗi JWT Sign:', err);
            return res.status(500).json({ msg: 'Lỗi khi tạo token' });
          }
          res.status(201).json({ token });
        }
      );
    } catch (err) {
      console.error('Lỗi khối Catch /register:', err.message);
      if (err.code === 11000) {
        return res.status(400).json({ errors: [{ msg: 'Email đã tồn tại (lỗi CSDL E11000)' }] });
      }
      res.status(500).json({ msg: 'Server error. Vui lòng thử lại.' });
    }
  }
);

/**
 * @route   POST api/auth/login
 * @desc    Đăng nhập (ĐÃ SỬA LOGIC)
 */
router.post(
  '/login',
  [
    check('email', 'Vui lòng nhập email hợp lệ').isEmail(),
    check('password', 'Mật khẩu là bắt buộc').exists(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email, password } = req.body; // 'password' là văn bản thô, vd: "123456"

    try {
      // 1. Tìm user
      let user = await User.findOne({ email });
      if (!user) {
        return res.status(400).json({ errors: [{ msg: 'Email hoặc mật khẩu không đúng' }] });
      }

      // === PHẦN LOGIC ĐÃ SỬA ===
      let isMatch = false;

      // Nếu user là 'admin' (bạn tạo thủ công trong CSDL)
      if (user.role === 'admin') {
        // So sánh mật khẩu thô (plain text)
        // Ví dụ: "123456" (app gửi) == "123456" (trong CSDL)
        isMatch = (password === user.password);
      } 
      // Nếu là 'student' (đăng ký qua app)
      else {
        // Dùng bcrypt để so sánh mật khẩu thô với mật khẩu đã băm
        isMatch = await bcrypt.compare(password, user.password);
      }
      // ==========================

      // Nếu không khớp
      if (!isMatch) {
        return res.status(400).json({ errors: [{ msg: 'Email hoặc mật khẩu không đúng' }] });
      }

      // 3. Nếu khớp, trả về JWT
      const payload = {
        user: {
          id: user.id,
          role: user.role,
        },
      };

      jwt.sign(
        payload,
        process.env.JWT_SECRET,
        { expiresIn: 360000 },
        (err, token) => {
          if (err) {
            console.error('Lỗi JWT Sign /login:', err);
            return res.status(500).json({ msg: 'Lỗi khi tạo token' });
          }
          res.json({ token });
        }
      );
    } catch (err) {
      console.error('Lỗi khối Catch /login:', err.message);
      res.status(500).json({ msg: 'Server error. Vui lòng thử lại.' });
    }
  }
);

export default router;