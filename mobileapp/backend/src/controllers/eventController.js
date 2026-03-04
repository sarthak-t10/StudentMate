const Event = require('../models/Event');
const { catchAsync, sendResponse } = require('../utils/helpers');

exports.getEvents = catchAsync(async (req, res) => {
  const { category, isFeatured, page = 1, limit = 20 } = req.query;

  const filter = {};
  if (category) filter.category = category;
  if (isFeatured === 'true') filter.isFeatured = true;

  const skip = (page - 1) * limit;

  const events = await Event.find(filter)
    .sort({ eventDate: 1 })
    .skip(skip)
    .limit(parseInt(limit))
    .populate('organizer', 'name email department')
    .populate('registeredUsers', 'name email');

  const total = await Event.countDocuments(filter);

  sendResponse(res, 200, true, 'Events retrieved', {
    events,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / limit),
    },
  });
});

exports.getEventById = catchAsync(async (req, res) => {
  const event = await Event.findById(req.params.id)
    .populate('organizer')
    .populate('registeredUsers', 'name email');

  if (!event) {
    return sendResponse(res, 404, false, 'Event not found');
  }

  sendResponse(res, 200, true, 'Event retrieved', event);
});

exports.createEvent = catchAsync(async (req, res) => {
  const { title, description, eventDate, startTime, endTime, venue, category, capacity } =
    req.validatedData;

  const event = await Event.create({
    title,
    description,
    eventDate,
    startTime,
    endTime,
    venue,
    category,
    capacity,
    organizer: req.user.userId,
  });

  await event.populate('organizer', 'name email department');

  sendResponse(res, 201, true, 'Event created successfully', event);
});

exports.updateEvent = catchAsync(async (req, res) => {
  const event = await Event.findById(req.params.id);

  if (!event) {
    return sendResponse(res, 404, false, 'Event not found');
  }

  // Check if user is organizer or admin
  if (event.organizer.toString() !== req.user.userId && req.user.role !== 'Admin') {
    return sendResponse(res, 403, false, 'Unauthorized');
  }

  const { title, description, eventDate, startTime, endTime, venue, category, isFeatured } =
    req.body;

  if (title) event.title = title;
  if (description) event.description = description;
  if (eventDate) event.eventDate = eventDate;
  if (startTime) event.startTime = startTime;
  if (endTime) event.endTime = endTime;
  if (venue) event.venue = venue;
  if (category) event.category = category;
  if (typeof isFeatured === 'boolean') event.isFeatured = isFeatured;

  await event.save();
  await event.populate('organizer', 'name email department');

  sendResponse(res, 200, true, 'Event updated successfully', event);
});

exports.deleteEvent = catchAsync(async (req, res) => {
  const event = await Event.findById(req.params.id);

  if (!event) {
    return sendResponse(res, 404, false, 'Event not found');
  }

  // Check if user is organizer or admin
  if (event.organizer.toString() !== req.user.userId && req.user.role !== 'Admin') {
    return sendResponse(res, 403, false, 'Unauthorized');
  }

  await Event.findByIdAndDelete(req.params.id);

  sendResponse(res, 200, true, 'Event deleted successfully');
});

exports.registerEvent = catchAsync(async (req, res) => {
  const event = await Event.findById(req.params.id);

  if (!event) {
    return sendResponse(res, 404, false, 'Event not found');
  }

  if (event.registeredUsers.includes(req.user.userId)) {
    return sendResponse(res, 400, false, 'Already registered for this event');
  }

  if (event.capacity && event.registeredUsers.length >= event.capacity) {
    return sendResponse(res, 400, false, 'Event capacity full');
  }

  event.registeredUsers.push(req.user.userId);
  await event.save();

  sendResponse(res, 200, true, 'Registered for event successfully', {
    registeredCount: event.registeredUsers.length,
  });
});

exports.unregisterEvent = catchAsync(async (req, res) => {
  const event = await Event.findById(req.params.id);

  if (!event) {
    return sendResponse(res, 404, false, 'Event not found');
  }

  const index = event.registeredUsers.indexOf(req.user.userId);
  if (index === -1) {
    return sendResponse(res, 400, false, 'Not registered for this event');
  }

  event.registeredUsers.splice(index, 1);
  await event.save();

  sendResponse(res, 200, true, 'Unregistered from event successfully', {
    registeredCount: event.registeredUsers.length,
  });
});
