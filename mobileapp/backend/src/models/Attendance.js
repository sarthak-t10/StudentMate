const mongoose = require('mongoose');

const attendanceSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    courseId: {
      type: String,
      required: [true, 'Course ID is required'],
    },
    courseName: {
      type: String,
      required: [true, 'Course name is required'],
    },
    date: {
      type: Date,
      required: [true, 'Date is required'],
    },
    status: {
      type: String,
      enum: ['Present', 'Absent', 'Leave'],
      required: true,
    },
    semester: {
      type: String,
      required: true,
    },
    academicYear: {
      type: String,
      required: true,
    },
    remarks: {
      type: String,
      default: null,
    },
    createdAt: {
      type: Date,
      default: Date.now,
    },
  },
  { collection: 'attendance' }
);

// Compound index for userId and courseId for faster queries
attendanceSchema.index({ userId: 1, courseId: 1 });
attendanceSchema.index({ userId: 1, date: 1 });

attendanceSchema.pre(/^find/, function (next) {
  this.populate({
    path: 'userId',
    select: 'name email semester',
  });
  next();
});

module.exports = mongoose.model('Attendance', attendanceSchema);
