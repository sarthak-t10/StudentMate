const Joi = require('joi');

const validateRequest = (schema) => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const messages = error.details.map((detail) => ({
        field: detail.path.join('.'),
        message: detail.message,
      }));
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        errors: messages,
      });
    }

    req.validatedData = value;
    next();
  };
};

const loginSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': 'Please provide a valid email address',
    'any.required': 'Email is required',
  }),
  password: Joi.string().min(6).required().messages({
    'string.min': 'Password must be at least 6 characters',
    'any.required': 'Password is required',
  }),
});

const registerSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': 'Please provide a valid email address',
    'any.required': 'Email is required',
  }),
  password: Joi.string().min(6).required().messages({
    'string.min': 'Password must be at least 6 characters',
    'any.required': 'Password is required',
  }),
  name: Joi.string().required().messages({
    'any.required': 'Name is required',
  }),
  role: Joi.string().valid('Student', 'Faculty', 'Admin').default('Student'),
});

const announcementSchema = Joi.object({
  title: Joi.string().required().messages({
    'any.required': 'Title is required',
  }),
  description: Joi.string().required().messages({
    'any.required': 'Description is required',
  }),
  category: Joi.string().valid('General', 'Department', 'Event', 'Emergency').default('General'),
  department: Joi.string().optional(),
  priority: Joi.string().valid('Low', 'Medium', 'High', 'Urgent').default('Medium'),
});

const eventSchema = Joi.object({
  title: Joi.string().required(),
  description: Joi.string().required(),
  eventDate: Joi.date().required(),
  startTime: Joi.string().required(),
  endTime: Joi.string().required(),
  venue: Joi.string().required(),
  category: Joi.string().valid('Academic', 'Sports', 'Cultural', 'Workshop', 'Seminar', 'Other'),
});

const jobPostingSchema = Joi.object({
  title: Joi.string().required(),
  description: Joi.string().required(),
  company: Joi.string().required(),
  position: Joi.string().required(),
  location: Joi.string().required(),
  jobType: Joi.string().valid('Full-time', 'Part-time', 'Internship', 'Contract').required(),
  deadline: Joi.date().required(),
  requiredSkills: Joi.array().items(Joi.string()).optional(),
});

module.exports = {
  validateRequest,
  loginSchema,
  registerSchema,
  announcementSchema,
  eventSchema,
  jobPostingSchema,
};
