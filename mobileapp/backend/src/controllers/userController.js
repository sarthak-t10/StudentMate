const User = require('../models/User');
const { catchAsync, sendResponse } = require('../utils/helpers');

exports.getProfile = catchAsync(async (req, res) => {
  const user = await User.findById(req.params.id || req.user.userId);

  if (!user) {
    return sendResponse(res, 404, false, 'User not found');
  }

  sendResponse(res, 200, true, 'User profile retrieved', {
    id: user._id,
    email: user.email,
    name: user.name,
    role: user.role,
    department: user.department,
    semester: user.semester,
    phone: user.phone,
    profileImageUrl: user.profileImageUrl,
    lastLogin: user.lastLogin,
    createdAt: user.createdAt,
  });
});

exports.updateProfile = catchAsync(async (req, res) => {
  const userId = req.params.id || req.user.userId;
  const { name, department, semester, phone, profileImageUrl } = req.body;

  const user = await User.findById(userId);
  if (!user) {
    return sendResponse(res, 404, false, 'User not found');
  }

  // Users can only update their own profile unless they're admin
  if (user._id.toString() !== req.user.userId && req.user.role !== 'Admin') {
    return sendResponse(res, 403, false, 'Unauthorized');
  }

  if (name) user.name = name;
  if (department) user.department = department;
  if (semester) user.semester = semester;
  if (phone) user.phone = phone;
  if (profileImageUrl) user.profileImageUrl = profileImageUrl;

  await user.save();

  sendResponse(res, 200, true, 'Profile updated successfully', {
    id: user._id,
    email: user.email,
    name: user.name,
    role: user.role,
    department: user.department,
    semester: user.semester,
    phone: user.phone,
    profileImageUrl: user.profileImageUrl,
  });
});

exports.getAllUsers = catchAsync(async (req, res) => {
  const { role, department, page = 1, limit = 20 } = req.query;

  const filter = {};
  if (role) filter.role = role;
  if (department) filter.department = department;

  const skip = (page - 1) * limit;

  const users = await User.find(filter).skip(skip).limit(parseInt(limit));
  const total = await User.countDocuments(filter);

  sendResponse(res, 200, true, 'Users retrieved', {
    users: users.map((u) => ({
      id: u._id,
      email: u.email,
      name: u.name,
      role: u.role,
      department: u.department,
      semester: u.semester,
    })),
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / limit),
    },
  });
});

exports.deleteUser = catchAsync(async (req, res) => {
  const user = await User.findByIdAndDelete(req.params.id);

  if (!user) {
    return sendResponse(res, 404, false, 'User not found');
  }

  sendResponse(res, 200, true, 'User deleted successfully');
});
