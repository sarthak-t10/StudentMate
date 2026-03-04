const jwt = require('jsonwebtoken');
const config = require('../config/env');

const generateToken = (payload, secret = config.jwt.secret, expiresIn = config.jwt.expiresIn) => {
  return jwt.sign(payload, secret, { expiresIn });
};

const generateAuthTokens = (userId, email, role) => {
  const accessToken = generateToken(
    { userId, email, role },
    config.jwt.secret,
    config.jwt.expiresIn
  );

  const refreshToken = generateToken(
    { userId },
    config.jwt.refreshSecret,
    config.jwt.refreshExpiresIn
  );

  return {
    accessToken,
    refreshToken,
  };
};

const verifyToken = (token, secret = config.jwt.secret) => {
  try {
    return jwt.verify(token, secret);
  } catch (error) {
    throw new Error(`Invalid token: ${error.message}`);
  }
};

module.exports = {
  generateToken,
  generateAuthTokens,
  verifyToken,
};
