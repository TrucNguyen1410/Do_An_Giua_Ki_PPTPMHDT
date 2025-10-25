// src/routes/auth.js (Bản CHUẨN để đăng nhập)
import express from 'express';
import User from '../models/User.js';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import authMiddleware from '../middlewares/auth.js';

const router = express.Router();

router.post('/register', async (req, res) => {
  try {
    const { fullName, email, password } = req.body;
    if (!fullName || !email || !password) {
      return res.status(400).json({ message: 'Vui lòng nhập đủ thông tin' });
    }
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(409).json({ message: 'Email này đã được sử dụng' });
    }
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);
    const newUser = new User({
      fullName,
      email,
      password: hashedPassword,
      role: 'student',
    });
    await newUser.save();
    const token = jwt.sign(
      { userId: newUser._id, role: newUser.role },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );
    res.status(201).json({
      token,
      user: {
        id: newUser._id,
        fullName: newUser.fullName,
        email: newUser.email,
        role: newUser.role,
      },
    });
  } catch (error) {
    console.error('Lỗi đăng ký:', error);
    res.status(500).json({ message: 'Lỗi máy chủ nội bộ' });
  }
});

router.post('/login', async (req, res) => {
  console.log('---------------------------------');
  console.log('ĐÃ NHẬN ĐƯỢC REQUEST LOGIN (Bản chuẩn)');
  try {
    const { email, password } = req.body;
    
    console.log('Input Email:', email);
    console.log('Input Password:', password);

    if (!email || !password) {
      console.log('LỖI: Thiếu email hoặc password');
      return res.status(400).json({ message: 'Vui lòng nhập email và mật khẩu' });
    }

    const user = await User.findOne({ email });
    if (!user) {
      console.log('LỖI: Không tìm thấy user với email:', email);
      return res.status(401).json({ message: 'Sai email hoặc mật khẩu' });
    }

    console.log('Đã tìm thấy user:', user.fullName);
    console.log('Hash trong DB:', user.password);
    
    // So sánh mật khẩu
    const isMatch = await bcrypt.compare(password, user.password);
    
    console.log('Kết quả so sánh (isMatch):', isMatch); // Dòng này BÂY GIỜ SẼ LÀ TRUE
    
    if (!isMatch) {
      console.log('LỖI: Mật khẩu không khớp!');
      return res.status(401).json({ message: 'Sai email hoặc mật khẩu' });
    }

    console.log('THÀNH CÔNG: Đăng nhập thành công, tạo token...');
    
    const token = jwt.sign(
      { userId: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );
    
    res.status(200).json({
      token,
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        role: user.role,
      },
    });

  } catch (error) {
    console.error('LỖI SERVER 500:', error);
    res.status(500).json({ message: 'Lỗi máy chủ nội bộ' });
  }
});

router.get('/me', authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.user.userId).select('-password');
    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng' });
    }
    res.status(200).json(user);
  } catch (error) {
    console.error('Lỗi /api/auth/me:', error);
    res.status(500).json({ message: 'Lỗi máy chủ nội bộ' });
  }
});

export default router;