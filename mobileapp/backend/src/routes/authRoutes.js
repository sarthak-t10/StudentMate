const express = require('express');
const authController = require('../controllers/authController');
const { validateRequest, loginSchema, registerSchema } = require('../middleware/validation');
const { loginLimiter } = require('../middleware/rateLimiter');

const router = express.Router();

router.post('/register', validateRequest(registerSchema), authController.register);
router.post('/login', loginLimiter, validateRequest(loginSchema), authController.login);
router.post('/logout', authController.logout);
router.post('/refresh', authController.refreshToken);

module.exports = router;
