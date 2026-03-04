const express = require('express');
const userController = require('../controllers/userController');
const { authMiddleware, roleMiddleware } = require('../middleware/auth');

const router = express.Router();

router.use(authMiddleware);

router.get('/profile/:id?', userController.getProfile);
router.put('/profile/:id?', userController.updateProfile);
router.get('/', roleMiddleware('Admin'), userController.getAllUsers);
router.delete('/:id', roleMiddleware('Admin'), userController.deleteUser);

module.exports = router;
