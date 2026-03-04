const Attendance = require('../models/Attendance');
const { catchAsync, sendResponse } = require('../utils/helpers');

exports.getAttendance = catchAsync(async (req, res) => {
  const { userId, courseId, semester, page = 1, limit = 50 } = req.query;

  const filter = {};
  if (userId) filter.userId = userId;
  if (courseId) filter.courseId = courseId;
  if (semester) filter.semester = semester;

  const skip = (page - 1) * limit;

  const attendance = await Attendance.find(filter)
    .sort({ date: -1 })
    .skip(skip)
    .limit(parseInt(limit))
    .populate('userId', 'name email semester');

  const total = await Attendance.countDocuments(filter);

  sendResponse(res, 200, true, 'Attendance records retrieved', {
    attendance,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / limit),
    },
  });
});

exports.getUserAttendance = catchAsync(async (req, res) => {
  const userId = req.params.userId || req.user.userId;
  const { courseId, semester } = req.query;

  const filter = { userId };
  if (courseId) filter.courseId = courseId;
  if (semester) filter.semester = semester;

  const attendanceRecords = await Attendance.find(filter)
    .sort({ date: -1 })
    .populate('userId', 'name email semester');

  const stats = {
    total: attendanceRecords.length,
    present: attendanceRecords.filter((r) => r.status === 'Present').length,
    absent: attendanceRecords.filter((r) => r.status === 'Absent').length,
    leave: attendanceRecords.filter((r) => r.status === 'Leave').length,
    percentage: attendanceRecords.length ? 
      Math.round(
        (attendanceRecords.filter((r) => r.status === 'Present').length / attendanceRecords.length) * 100
      ) : 0,
  };

  sendResponse(res, 200, true, 'User attendance retrieved', {
    records: attendanceRecords,
    stats,
  });
});

exports.markAttendance = catchAsync(async (req, res) => {
  const { userId, courseId, courseName, date, status, semester, academicYear, remarks } = req.body;

  if (!userId || !courseId || !courseName || !date || !status || !semester || !academicYear) {
    return sendResponse(res, 400, false, 'All required fields must be provided');
  }

  const attendance = await Attendance.create({
    userId,
    courseId,
    courseName,
    date,
    status,
    semester,
    academicYear,
    remarks,
  });

  await attendance.populate('userId', 'name email semester');

  sendResponse(res, 201, true, 'Attendance marked successfully', attendance);
});

exports.updateAttendance = catchAsync(async (req, res) => {
  const attendance = await Attendance.findById(req.params.id);

  if (!attendance) {
    return sendResponse(res, 404, false, 'Attendance record not found');
  }

  const { status, remarks } = req.body;
  if (status) attendance.status = status;
  if (remarks) attendance.remarks = remarks;

  await attendance.save();

  sendResponse(res, 200, true, 'Attendance updated successfully', attendance);
});

exports.deleteAttendance = catchAsync(async (req, res) => {
  const attendance = await Attendance.findByIdAndDelete(req.params.id);

  if (!attendance) {
    return sendResponse(res, 404, false, 'Attendance record not found');
  }

  sendResponse(res, 200, true, 'Attendance deleted successfully');
});
