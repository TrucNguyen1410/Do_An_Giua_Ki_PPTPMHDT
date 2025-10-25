// src/routes/activities.js
import express from 'express';
import Activity from '../models/Activity.js';
import Registration from '../models/Registration.js';
import authMiddleware from '../middlewares/auth.js'; // Dùng 'import'

const router = express.Router();

// ---
// GET /api/activities (Lấy tất cả hoạt động - cho cả Student và Admin)
// ---
router.get('/', authMiddleware, async (req, res) => {
  try {
    const activities = await Activity.find().sort({ date: -1 }); // Sắp xếp mới nhất
    
    // Nếu là student, kiểm tra xem họ đã đăng ký hoạt động nào
    if (req.user.role === 'student') {
      const studentId = req.user.userId;
      // Lấy danh sách ID các hoạt động mà student này đã đăng ký
      const registrations = await Registration.find({ student: studentId });
      const registeredActivityIds = new Set(registrations.map(reg => reg.activity.toString()));

      // Chuyển 'activities' (Mongoose document) thành object JS
      const activitiesWithStatus = activities.map(activity => {
        const plainActivity = activity.toObject(); 
        return {
          ...plainActivity,
          isRegistered: registeredActivityIds.has(plainActivity._id.toString()),
        };
      });
      return res.json(activitiesWithStatus);
    }

    // Nếu là Admin, cứ trả về danh sách
    res.json(activities);

  } catch (error) {
    console.error('Lỗi lấy activities:', error);
    res.status(500).json({ message: 'Lỗi máy chủ' });
  }
});

// ---
// POST /api/activities (Tạo hoạt động mới - Chỉ Admin)
// ---
router.post('/', authMiddleware, async (req, res) => {
  // Kiểm tra quyền Admin
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Không có quyền truy cập' });
  }
  
  try {
    const { name, description, date, location } = req.body;
    const newActivity = new Activity({ name, description, date, location });
    await newActivity.save();
    res.status(201).json(newActivity);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi tạo hoạt động' });
  }
});

// ---
// PUT /api/activities/:id (Cập nhật hoạt động - Chỉ Admin)
// ---
router.put('/:id', authMiddleware, async (req, res) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Không có quyền truy cập' });
  }
  
  try {
    const updatedActivity = await Activity.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true } // Trả về document đã được cập nhật
    );
    if (!updatedActivity) {
      return res.status(404).json({ message: 'Không tìm thấy hoạt động' });
    }
    res.json(updatedActivity);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi cập nhật hoạt động' });
  }
});

// ---
// DELETE /api/activities/:id (Xóa hoạt động - Chỉ Admin)
// ---
router.delete('/:id', authMiddleware, async (req, res) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Không có quyền truy cập' });
  }
  
  try {
    const deletedActivity = await Activity.findByIdAndDelete(req.params.id);
    if (!deletedActivity) {
      return res.status(404).json({ message: 'Không tìm thấy hoạt động' });
    }
    // TODO: Bạn cũng nên xóa các 'Registration' liên quan đến HĐ này
    await Registration.deleteMany({ activity: req.params.id });
    res.json({ message: 'Xóa hoạt động thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi xóa hoạt động' });
  }
});


// === STUDENT ROUTES ===

// ---
// POST /api/activities/:id/register (Sinh viên đăng ký)
// ---
router.post('/:id/register', authMiddleware, async (req, res) => {
  if (req.user.role !== 'student') {
    return res.status(403).json({ message: 'Chỉ sinh viên mới được đăng ký' });
  }

  try {
    const activityId = req.params.id;
    const studentId = req.user.userId;

    // 1. Kiểm tra hoạt động có tồn tại không
    const activity = await Activity.findById(activityId);
    if (!activity) {
      return res.status(404).json({ message: 'Hoạt động không tồn tại' });
    }

    // 2. Kiểm tra đã đăng ký chưa
    const existingRegistration = await Registration.findOne({
      activity: activityId,
      student: studentId,
    });

    if (existingRegistration) {
      return res.status(409).json({ message: 'Bạn đã đăng ký hoạt động này rồi' });
    }

    // 3. Tạo đăng ký mới
    const newRegistration = new Registration({
      activity: activityId,
      student: studentId,
    });
    await newRegistration.save();
    res.status(201).json({ message: 'Đăng ký thành công' });

  } catch (error) {
    res.status(500).json({ message: 'Lỗi đăng ký' });
  }
});

// ---
// POST /api/activities/:id/unregister (Sinh viên hủy đăng ký)
// ---
router.post('/:id/unregister', authMiddleware, async (req, res) => {
  if (req.user.role !== 'student') {
    return res.status(403).json({ message: 'Chỉ sinh viên mới được hủy' });
  }

  try {
    const activityId = req.params.id;
    const studentId = req.user.userId;

    // 1. Tìm và xóa đăng ký
    const deletedRegistration = await Registration.findOneAndDelete({
      activity: activityId,
      student: studentId,
    });

    if (!deletedRegistration) {
      return res.status(404).json({ message: 'Bạn chưa đăng ký hoạt động này' });
    }
    
    res.status(200).json({ message: 'Hủy đăng ký thành công' });

  } catch (error) {
    res.status(500).json({ message: 'Lỗi hủy đăng ký' });
  }
});

// ---
// GET /api/activities/my-history (Lấy lịch sử của sinh viên)
// ---
router.get('/my-history', authMiddleware, async (req, res) => {
  if (req.user.role !== 'student') {
    return res.status(403).json({ message: 'Chỉ sinh viên mới có lịch sử' });
  }
  
  try {
    const studentId = req.user.userId;
    // Tìm các đăng ký của sinh viên, và 'populate' (lấy) thông tin chi tiết của hoạt động
    const registrations = await Registration.find({ student: studentId })
                                            .populate('activity');

    // Chỉ trả về mảng các hoạt động
    const activities = registrations.map(reg => reg.activity);
    res.json(activities);

  } catch (error) {
    res.status(500).json({ message: 'Lỗi lấy lịch sử' });
  }
});


// Dùng 'export default' ở cuối
export default router;