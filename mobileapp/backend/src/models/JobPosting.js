const mongoose = require('mongoose');

const jobPostingSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Job title is required'],
      trim: true,
    },
    description: {
      type: String,
      required: [true, 'Job description is required'],
    },
    company: {
      type: String,
      required: [true, 'Company name is required'],
      trim: true,
    },
    companyLogo: {
      type: String,
      default: null,
    },
    position: {
      type: String,
      required: [true, 'Position is required'],
    },
    location: {
      type: String,
      required: [true, 'Location is required'],
    },
    salary: {
      min: {
        type: Number,
        default: null,
      },
      max: {
        type: Number,
        default: null,
      },
      currency: {
        type: String,
        default: 'INR',
      },
    },
    jobType: {
      type: String,
      enum: ['Full-time', 'Part-time', 'Internship', 'Contract'],
      required: true,
    },
    experience: {
      type: String,
      default: null,
    },
    requiredSkills: [
      {
        type: String,
      },
    ],
    qualifications: [
      {
        type: String,
      },
    ],
    postedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    applicants: [
      {
        userId: mongoose.Schema.Types.ObjectId,
        appliedAt: Date,
        status: {
          type: String,
          enum: ['Applied', 'Reviewed', 'Selected', 'Rejected'],
          default: 'Applied',
        },
      },
    ],
    deadline: {
      type: Date,
      required: [true, 'Application deadline is required'],
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    createdAt: {
      type: Date,
      default: Date.now,
    },
    updatedAt: {
      type: Date,
      default: Date.now,
    },
  },
  { collection: 'job_postings' }
);

jobPostingSchema.pre(/^find/, function (next) {
  this.populate({
    path: 'postedBy',
    select: 'name email company',
  });
  next();
});

jobPostingSchema.pre('save', function (next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('JobPosting', jobPostingSchema);
