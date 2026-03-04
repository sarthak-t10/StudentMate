const User = require('../models/User');
const { generateAuthTokens } = require('../utils/jwt');
const { catchAsync, sendResponse, AppError } = require('../utils/helpers');

exports.register = catchAsync(async (req, res) => {
  const { email, password, name, role } = req.validatedData;

  const existingUser = await User.findOne({ email });
  if (existingUser) {
    return sendResponse(res, 400, false, 'Email already registered');
  }

  const user = await User.create({
    email,
    password,
    name,
    role,
  });

  const { accessToken, refreshToken } = generateAuthTokens(user._id, user.email, user.role);

  sendResponse(res, 201, true, 'User registered successfully', {
    user: {
      id: user._id,
      email: user.email,
      name: user.name,
      role: user.role,
    },
    accessToken,
    refreshToken,
  });
});

exports.login = catchAsync(async (req, res) => {
  const { email, password } = req.validatedData;

  const user = await User.findOne({ email }).select('+password');
  if (!user) {
    return sendResponse(res, 401, false, 'Invalid email or password');
  }

  const isPasswordValid = await user.matchPassword(password);
  if (!isPasswordValid) {
    return sendResponse(res, 401, false, 'Invalid email or password');
  }

  user.lastLogin = new Date();
  await user.save();

  const { accessToken, refreshToken } = generateAuthTokens(user._id, user.email, user.role);

  sendResponse(res, 200, true, 'Login successful', {
    user: {
      id: user._id,
      email: user.email,
      name: user.name,
      role: user.role,
      department: user.department,
      semester: user.semester,
      profileImageUrl: user.profileImageUrl,
    },
    accessToken,
    refreshToken,
  });
});

exports.logout = catchAsync(async (req, res) => {
  // Token invalidation can be implemented using Redis/blacklist
  sendResponse(res, 200, true, 'Logout successful');
});

exports.refreshToken = catchAsync(async (req, res) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    return sendResponse(res, 401, false, 'Refresh token required');
  }

  try {
    const { userId } = jwt.verify(refreshToken, config.jwt.refreshSecret);
    const user = await User.findById(userId);

    if (!user) {
      return sendResponse(res, 401, false, 'User not found');
    }

    const { accessToken, refreshToken: newRefreshToken } = generateAuthTokens(
      user._id,
      user.email,
      user.role
    );

    sendResponse(res, 200, true, 'Token refreshed', {
      accessToken,
      refreshToken: newRefreshToken,
    });
  } catch (error) {
    sendResponse(res, 401, false, 'Invalid refresh token');
  }
});
