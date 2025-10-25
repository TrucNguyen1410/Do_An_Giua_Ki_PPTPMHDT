// src/routes/activities.js
import express from 'express';
import Activity from '../models/Activity.js';
import Registration from '../models/Registration.js';
import User from '../models/User.js'; 
import authMiddleware from '../middlewares/auth.js'; 

const router = express.Router();

// ---
// GET /api/activities (Lấy tất cả hoạt động)
// ---
router.get('/', authMiddleware, async (req, res) => {
  try {
    const activities = await Activity.find()
      .populate('participantCount') 
      .sort({ startDate: 1 }); 

    if (req.user.role === 'student') {
      const studentId = req.user.userId;
      const registrations = await Registration.find({ student: studentId });
      
      const registrationMap = new Map();
      registrations.forEach(reg => {
        registrationMap.set(reg.activity.toString(), {
          attended: reg.attended,
        });
      });

      const activitiesWithStatus = activities.map(activity => {
        const plainActivity = activity.toObject(); 
        const regStatus = registrationMap.get(plainActivity._id.toString());

        return {
          ...plainActivity,
          isRegistered: !!regStatus, 
          attended: regStatus ? regStatus.attended : false, 
        };
      });
      return res.json(activitiesWithStatus);
    }

    res.json(activities);

  } catch (error) {
    console.error('Lỗi lấy activities:', error);
    res.status(500).json({ message: 'Lỗi máy chủ' });
  }
});

// ---
// POST /api/activities (Tạo hoạt động mới - Admin)
// ---
router.post('/', authMiddleware, async (req, res) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Không có quyền truy cập' });
  }
  
  try {
    const { 
      name, description, location, maxParticipants, 
      startDate, endDate, registrationDeadline 
    } = req.body;

    if (!startDate || !endDate || !registrationDeadline) {
      return res.status(400).json({ message: 'Vui lòng nhập đủ Ngày bắt đầu, Ngày kết thúc và Hạn chót đăng ký' });
    }
    
    const newActivity = new Activity({ 
      name, 
      description, 
      location,
      maxParticipants: maxParticipants || 0,
      startDate, 
      endDate, 
      registrationDeadline 
    });
    
    await newActivity.save();
    res.status(201).json(newActivity);
  } catch (error) {
    console.error('Lỗi tạo hoạt động:', error);
    res.status(500).json({ message: 'Lỗi tạo hoạt động' });
  }
});

// ---
// PUT /api/activities/:id (Cập nhật hoạt động - Admin)
// ---
router.put('/:id', authMiddleware, async (req, res) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Không có quyền truy cập' });
  }
  
  try {
    const updatedActivity = await Activity.findByIdAndUpdate(
      req.params.id,
      req.body, 
      { new: true } 
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
// DELETE /api/activities/:id (Xóa hoạt động - Admin)
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

    const activity = await Activity.findById(activityId);
    if (!activity) {
      return res.status(404).json({ message: 'Hoạt động không tồn tại' });
    }

    // LOGIC 1: KIỂM TRA QUÁ HẠN ĐĂNG KÝ
    const now = new Date();
    if (now > activity.registrationDeadline) { 
      return res.status(400).json({ message: 'Hoạt động này đã quá hạn đăng ký' });
    }

    // LOGIC 2: KIỂM TRA SỐ LƯỢNG
    if (activity.maxParticipants && activity.maxParticipants > 0) {
      const currentCount = await Registration.countDocuments({ activity: activityId });
      if (currentCount >= activity.maxParticipants) {
        return res.status(400).json({ message: 'Hoạt động này đã đủ số lượng' });
      }
    }

    const existingRegistration = await Registration.findOne({
      activity: activityId,
      student: studentId,
    });

    if (existingRegistration) {
      return res.status(409).json({ message: 'Bạn đã đăng ký hoạt động này rồi' });
    }

    const newRegistration = new Registration({
      activity: activityId,
      student: studentId,
      attended: false, 
    });
    await newRegistration.save();
    res.status(201).json({ message: 'Đăng ký thành công' });

  } catch (error) {
    console.error('Lỗi đăng ký:', error);
    res.status(500).json({ message: 'Lỗi máy chủ' });
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

    // LOGIC: KIỂM TRA QUÁ HẠN ĐĂNG KÝ (Không cho hủy nếu ĐÃ HẾT HẠN)
    const activity = await Activity.findById(activityId);
    if (activity) {
      const now = new Date();
      if (now > activity.registrationDeadline) { 
        return res.status(400).json({ message: 'Không thể hủy đăng ký vì đã quá hạn chót' });
      }
    }

    const deletedRegistration = await Registration.findOneAndDelete({
      activity: activityId,
      student: studentId,
    });

    if (!deletedRegistration) {
      return res.status(404).json({ message: 'Bạn chưa đăng ký hoạt động này' });
    }
    
    res.status(200).json({ message: 'Hủy đăng ký thành công' });

  } catch (error) {
    console.error('Lỗi hủy đăng ký:', error);
    res.status(500).json({ message: 'Lỗi máy chủ' });
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
    const registrations = await Registration.find({ student: studentId })
                                            .populate('activity')
                                            .sort({ createdAt: -1 }); 

    const activitiesWithStatus = registrations.map(reg => {
      if (!reg.activity) return null; 
      
      const plainActivity = reg.activity.toObject();
      return {
        ...plainActivity,
        isRegistered: true,
        attended: reg.attended, 
      };
    }).filter(Boolean); 
    
    res.json(activitiesWithStatus);

  } catch (error) {
    console.error('Lỗi lấy lịch sử:', error);
    res.status(500).json({ message: 'Lỗi máy chủ' });
  }
});


// ---
// POST /api/activities/attend (Sinh viên điểm danh bằng QR - ĐÃ SỬA)
// ---
router.post('/attend', authMiddleware, async (req, res) => {
  if (req.user.role !== 'student') {
    return res.status(403).json({ message: 'Chỉ sinh viên mới được điểm danh' });
  }

  try {
    const { activityId } = req.body;
    const studentId = req.user.userId;

    // 1. Kiểm tra Hoạt động có tồn tại
    const activity = await Activity.findById(activityId);
    if (!activity) {
      return res.status(404).json({ message: 'Hoạt động không tồn tại' });
    }
    
    // --- LOGIC MỚI: KIỂM TRA QUÁ THỜI GIAN KẾT THÚC HOẠT ĐỘNG ---
    const now = new Date();
    // Nếu thời gian hiện tại LỚN HƠN thời gian kết thúc hoạt động (endDate)
    if (now > activity.endDate) { 
        return res.status(400).json({ message: 'Đã quá thời gian kết thúc hoạt động. Không thể điểm danh.' });
    }
    // -----------------------------------------------------------------

    // 2. Kiểm tra đăng ký
    const registration = await Registration.findOne({
      activity: activityId,
      student: studentId,
    });

    if (!registration) {
      return res.status(404).json({ message: 'Bạn chưa đăng ký hoạt động này. Vui lòng đăng ký trước.' });
    }

    if (registration.attended === true) {
      return res.status(200).json({ message: 'Bạn đã điểm danh hoạt động này rồi' });
    }

    // 3. Điểm danh thành công
    registration.attended = true;
    await registration.save();
    
    res.status(200).json({ message: 'Điểm danh thành công' });

  } catch (error) {
    console.error('Lỗi điểm danh:', error);
    res.status(500).json({ message: 'Lỗi máy chủ' });
  }
});


// --- ROUTE MỚI: LẤY DANH SÁCH ĐIỂM DANH CỦA MỘT HOẠT ĐỘNG (ADMIN) ---
// ---
// GET /api/activities/:activityId/attendance (Chỉ Admin)
// ---
router.get('/:activityId/attendance', authMiddleware, async (req, res) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Chỉ Admin mới có quyền xem danh sách điểm danh' });
  }
  
  try {
    const { activityId } = req.params;

    // 1. Tìm tất cả các bản ghi đăng ký thỏa mãn ĐÃ ĐIỂM DANH
    const registrations = await Registration.find({
      activity: activityId,
      attended: true, // Chỉ lấy những người đã điểm danh
    })
    .populate({
      path: 'student', // Lấy thông tin chi tiết của sinh viên
      select: 'fullName email studentId role', // Chỉ chọn các trường cần thiết (Cần đảm bảo User model có studentId)
    })
    .sort({ createdAt: 1 }); // Sắp xếp theo thứ tự đăng ký/điểm danh

    // 2. Định dạng lại dữ liệu trả về
    const attendanceList = registrations.map(reg => {
        // Kiểm tra xem reg.student có tồn tại không (nếu user bị xóa)
        if (!reg.student) return null; 

        return {
            studentId: reg.student.studentId, // ID sinh viên (ví dụ: MSSV)
            fullName: reg.student.fullName,
            email: reg.student.email,
            registrationDate: reg.createdAt, // Dùng ngày đăng ký (createdAt)
        };
    }).filter(Boolean); // Lọc bỏ các mục null
    

    res.json(attendanceList);

  } catch (error) {
    console.error('Lỗi lấy danh sách điểm danh:', error);
    res.status(500).json({ message: 'Lỗi máy chủ khi lấy danh sách điểm danh' });
  }
});
// -------------------------------------------------------------------------


// Dùng 'export default' ở cuối
export default router;