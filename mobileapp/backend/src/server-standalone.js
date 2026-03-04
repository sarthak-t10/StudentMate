const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

const app = express();

// In-memory data store
const users = [];
const announcements = [];
const events = [];
const jobs = [];

const JWT_SECRET = 'your_super_secret_jwt_key_change_this';
const JWT_EXPIRE = '7d';

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// Request logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// JWT Token generation
const generateToken = (userId, email, role) => {
  return jwt.sign(
    { userId, email, role },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRE }
  );
};

// Auth Middleware
const authMiddleware = (req, res, next) => {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'No token provided. Please authenticate.',
    });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Invalid token.',
    });
  }
};

// ==================== AUTH ROUTES ====================

app.post('/api/v1/auth/register', async (req, res) => {
  try {
    const { email, password, name, role } = req.body;

    // Validation
    if (!email || !password || !name) {
      return res.status(400).json({
        success: false,
        message: 'Email, password, and name are required',
      });
    }

    // Check if user exists
    const existingUser = users.find((u) => u.email === email);
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Email already registered',
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const newUser = {
      id: 'user_' + Date.now(),
      email,
      password: hashedPassword,
      name,
      role: role || 'Student',
      createdAt: new Date(),
    };

    users.push(newUser);

    // Generate token
    const token = generateToken(newUser.id, newUser.email, newUser.role);

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        user: {
          id: newUser.id,
          email: newUser.email,
          name: newUser.name,
          role: newUser.role,
        },
        accessToken: token,
      },
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({
      success: false,
      message: 'Registration failed',
    });
  }
});

app.post('/api/v1/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required',
      });
    }

    const user = users.find((u) => u.email === email);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    const token = generateToken(user.id, user.email, user.role);

    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
        },
        accessToken: token,
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Login failed',
    });
  }
});

app.post('/api/v1/auth/logout', (req, res) => {
  res.json({
    success: true,
    message: 'Logout successful',
  });
});

// ==================== ANNOUNCEMENTS ROUTES ====================

app.get('/api/v1/announcements', (req, res) => {
  const { page = 1, limit = 20 } = req.query;
  const skip = (page - 1) * limit;

  const paginatedAnnouncements = announcements.slice(skip, skip + limit);

  res.json({
    success: true,
    message: 'Announcements retrieved',
    data: {
      announcements: paginatedAnnouncements,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: announcements.length,
        pages: Math.ceil(announcements.length / limit),
      },
    },
  });
});

app.post('/api/v1/announcements', authMiddleware, (req, res) => {
  try {
    const { title, description, category, priority } = req.body;

    if (!title || !description) {
      return res.status(400).json({
        success: false,
        message: 'Title and description are required',
      });
    }

    const announcement = {
      id: 'ann_' + Date.now(),
      title,
      description,
      category: category || 'General',
      priority: priority || 'Medium',
      createdBy: req.user.userId,
      createdAt: new Date(),
    };

    announcements.push(announcement);

    res.status(201).json({
      success: true,
      message: 'Announcement created successfully',
      data: announcement,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to create announcement',
    });
  }
});

// ==================== EVENTS ROUTES ====================

app.get('/api/v1/events', (req, res) => {
  const { page = 1, limit = 20 } = req.query;
  const skip = (page - 1) * limit;

  const paginatedEvents = events.slice(skip, skip + limit);

  res.json({
    success: true,
    message: 'Events retrieved',
    data: {
      events: paginatedEvents,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: events.length,
        pages: Math.ceil(events.length / limit),
      },
    },
  });
});

app.post('/api/v1/events', authMiddleware, (req, res) => {
  try {
    const { title, description, eventDate, venue } = req.body;

    if (!title || !description || !eventDate || !venue) {
      return res.status(400).json({
        success: false,
        message: 'Title, description, date, and venue are required',
      });
    }

    const event = {
      id: 'evt_' + Date.now(),
      title,
      description,
      eventDate,
      venue,
      organizer: req.user.userId,
      registeredUsers: [],
      createdAt: new Date(),
    };

    events.push(event);

    res.status(201).json({
      success: true,
      message: 'Event created successfully',
      data: event,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to create event',
    });
  }
});

app.post('/api/v1/events/:id/register', authMiddleware, (req, res) => {
  const event = events.find((e) => e.id === req.params.id);

  if (!event) {
    return res.status(404).json({
      success: false,
      message: 'Event not found',
    });
  }

  if (event.registeredUsers.includes(req.user.userId)) {
    return res.status(400).json({
      success: false,
      message: 'Already registered for this event',
    });
  }

  event.registeredUsers.push(req.user.userId);

  res.json({
    success: true,
    message: 'Registered for event successfully',
    data: {
      registeredCount: event.registeredUsers.length,
    },
  });
});

// ==================== JOBS ROUTES ====================

app.get('/api/v1/jobs', (req, res) => {
  const { page = 1, limit = 20 } = req.query;
  const skip = (page - 1) * limit;

  const paginatedJobs = jobs.slice(skip, skip + limit);

  res.json({
    success: true,
    message: 'Job postings retrieved',
    data: {
      jobs: paginatedJobs,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: jobs.length,
        pages: Math.ceil(jobs.length / limit),
      },
    },
  });
});

app.post('/api/v1/jobs', authMiddleware, (req, res) => {
  try {
    const { title, company, position, location, jobType, deadline } = req.body;

    if (!title || !company || !position || !location || !jobType || !deadline) {
      return res.status(400).json({
        success: false,
        message: 'All fields are required',
      });
    }

    const job = {
      id: 'job_' + Date.now(),
      title,
      company,
      position,
      location,
      jobType,
      deadline,
      postedBy: req.user.userId,
      applicants: [],
      createdAt: new Date(),
    };

    jobs.push(job);

    res.status(201).json({
      success: true,
      message: 'Job posting created successfully',
      data: job,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to create job posting',
    });
  }
});

// ==================== USER ROUTES ====================

app.get('/api/v1/users/profile', authMiddleware, (req, res) => {
  const user = users.find((u) => u.id === req.user.userId);

  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'User not found',
    });
  }

  res.json({
    success: true,
    message: 'Profile retrieved',
    data: {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      createdAt: user.createdAt,
    },
  });
});

// ==================== ERROR HANDLER ====================

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

// ==================== START SERVER ====================

const PORT = 5000;
app.listen(PORT, () => {
  console.log(`\n`);
  console.log(`========================================`);
  console.log(`Campus Management API (Standalone Mode)`);
  console.log(`========================================`);
  console.log(`Server running on port ${PORT}`);
  console.log(`API available at: http://localhost:${PORT}/api/v1`);
  console.log(`Health check: http://localhost:${PORT}/health`);
  console.log(`\nDatabase: In-memory (test data only)`);
  console.log(`========================================\n`);
});
