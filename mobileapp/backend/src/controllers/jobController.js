const JobPosting = require('../models/JobPosting');
const { catchAsync, sendResponse } = require('../utils/helpers');

exports.getJobPostings = catchAsync(async (req, res) => {
  const { company, jobType, isActive = true, page = 1, limit = 20 } = req.query;

  const filter = {};
  if (company) filter.company = { $regex: company, $options: 'i' };
  if (jobType) filter.jobType = jobType;
  filter.isActive = isActive === 'true';

  const skip = (page - 1) * limit;

  const jobs = await JobPosting.find(filter)
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(parseInt(limit))
    .populate('postedBy', 'name email')
    .select('-applicants'); // Exclude detailed applicants array for list view

  const total = await JobPosting.countDocuments(filter);

  sendResponse(res, 200, true, 'Job postings retrieved', {
    jobs,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / limit),
    },
  });
});

exports.getJobPostingById = catchAsync(async (req, res) => {
  const job = await JobPosting.findById(req.params.id).populate('postedBy', 'name email');

  if (!job) {
    return sendResponse(res, 404, false, 'Job posting not found');
  }

  sendResponse(res, 200, true, 'Job posting retrieved', job);
});

exports.createJobPosting = catchAsync(async (req, res) => {
  const {
    title,
    description,
    company,
    position,
    location,
    salary,
    jobType,
    experience,
    requiredSkills,
    qualifications,
    deadline,
  } = req.validatedData;

  const job = await JobPosting.create({
    title,
    description,
    company,
    position,
    location,
    salary,
    jobType,
    experience,
    requiredSkills,
    qualifications,
    deadline,
    postedBy: req.user.userId,
  });

  await job.populate('postedBy', 'name email');

  sendResponse(res, 201, true, 'Job posting created successfully', job);
});

exports.updateJobPosting = catchAsync(async (req, res) => {
  const job = await JobPosting.findById(req.params.id);

  if (!job) {
    return sendResponse(res, 404, false, 'Job posting not found');
  }

  // Check if user is poster or admin
  if (job.postedBy.toString() !== req.user.userId && req.user.role !== 'Admin') {
    return sendResponse(res, 403, false, 'Unauthorized');
  }

  const {
    title,
    description,
    company,
    position,
    location,
    salary,
    jobType,
    experience,
    requiredSkills,
    qualifications,
    deadline,
    isActive,
  } = req.body;

  if (title) job.title = title;
  if (description) job.description = description;
  if (company) job.company = company;
  if (position) job.position = position;
  if (location) job.location = location;
  if (salary) job.salary = salary;
  if (jobType) job.jobType = jobType;
  if (experience) job.experience = experience;
  if (requiredSkills) job.requiredSkills = requiredSkills;
  if (qualifications) job.qualifications = qualifications;
  if (deadline) job.deadline = deadline;
  if (typeof isActive === 'boolean') job.isActive = isActive;

  await job.save();
  await job.populate('postedBy', 'name email');

  sendResponse(res, 200, true, 'Job posting updated successfully', job);
});

exports.deleteJobPosting = catchAsync(async (req, res) => {
  const job = await JobPosting.findById(req.params.id);

  if (!job) {
    return sendResponse(res, 404, false, 'Job posting not found');
  }

  // Check if user is poster or admin
  if (job.postedBy.toString() !== req.user.userId && req.user.role !== 'Admin') {
    return sendResponse(res, 403, false, 'Unauthorized');
  }

  await JobPosting.findByIdAndDelete(req.params.id);

  sendResponse(res, 200, true, 'Job posting deleted successfully');
});

exports.applyForJob = catchAsync(async (req, res) => {
  const job = await JobPosting.findById(req.params.id);

  if (!job) {
    return sendResponse(res, 404, false, 'Job posting not found');
  }

  const existingApplication = job.applicants.find(
    (app) => app.userId.toString() === req.user.userId
  );

  if (existingApplication) {
    return sendResponse(res, 400, false, 'Already applied for this job');
  }

  job.applicants.push({
    userId: req.user.userId,
    appliedAt: new Date(),
    status: 'Applied',
  });

  await job.save();

  sendResponse(res, 200, true, 'Application submitted successfully', {
    applicationCount: job.applicants.length,
  });
});

exports.getApplications = catchAsync(async (req, res) => {
  const job = await JobPosting.findById(req.params.id);

  if (!job) {
    return sendResponse(res, 404, false, 'Job posting not found');
  }

  // Check if user is poster or admin
  if (job.postedBy.toString() !== req.user.userId && req.user.role !== 'Admin') {
    return sendResponse(res, 403, false, 'Unauthorized');
  }

  await job.populate('applicants.userId', 'name email department semester');

  sendResponse(res, 200, true, 'Applications retrieved', {
    applicants: job.applicants,
    totalApplications: job.applicants.length,
  });
});
