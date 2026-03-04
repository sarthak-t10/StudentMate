const Announcement = require('../models/Announcement');
const { catchAsync, sendResponse } = require('../utils/helpers');

exports.getAnnouncements = catchAsync(async (req, res) => {
  const { category, department, priority, page = 1, limit = 20 } = req.query;

  const filter = {};
  if (category) filter.category = category;
  if (department) filter.department = department;
  if (priority) filter.priority = priority;

  const skip = (page - 1) * limit;

  const announcements = await Announcement.find(filter)
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(parseInt(limit))
    .populate('createdBy', 'name email role');

  const total = await Announcement.countDocuments(filter);

  sendResponse(res, 200, true, 'Announcements retrieved', {
    announcements,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / limit),
    },
  });
});

exports.getAnnouncementById = catchAsync(async (req, res) => {
  const announcement = await Announcement.findById(req.params.id).populate('createdBy');

  if (!announcement) {
    return sendResponse(res, 404, false, 'Announcement not found');
  }

  sendResponse(res, 200, true, 'Announcement retrieved', announcement);
});

exports.createAnnouncement = catchAsync(async (req, res) => {
  const { title, description, category, department, priority } = req.validatedData;

  const announcement = await Announcement.create({
    title,
    description,
    category,
    department,
    priority,
    createdBy: req.user.userId,
  });

  await announcement.populate('createdBy', 'name email role');

  sendResponse(res, 201, true, 'Announcement created successfully', announcement);
});

exports.updateAnnouncement = catchAsync(async (req, res) => {
  const announcement = await Announcement.findById(req.params.id);

  if (!announcement) {
    return sendResponse(res, 404, false, 'Announcement not found');
  }

  // Check if user is creator or admin
  if (announcement.createdBy.toString() !== req.user.userId && req.user.role !== 'Admin') {
    return sendResponse(res, 403, false, 'Unauthorized');
  }

  const { title, description, category, department, priority } = req.body;
  if (title) announcement.title = title;
  if (description) announcement.description = description;
  if (category) announcement.category = category;
  if (department) announcement.department = department;
  if (priority) announcement.priority = priority;

  await announcement.save();
  await announcement.populate('createdBy', 'name email role');

  sendResponse(res, 200, true, 'Announcement updated successfully', announcement);
});

exports.deleteAnnouncement = catchAsync(async (req, res) => {
  const announcement = await Announcement.findById(req.params.id);

  if (!announcement) {
    return sendResponse(res, 404, false, 'Announcement not found');
  }

  // Check if user is creator or admin
  if (announcement.createdBy.toString() !== req.user.userId && req.user.role !== 'Admin') {
    return sendResponse(res, 403, false, 'Unauthorized');
  }

  await Announcement.findByIdAndDelete(req.params.id);

  sendResponse(res, 200, true, 'Announcement deleted successfully');
});
