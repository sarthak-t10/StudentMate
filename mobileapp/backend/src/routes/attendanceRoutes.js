const express = require('express');
const attendanceController = require('../controllers/attendanceController');
const { authMiddleware, roleMiddleware } = require('../middleware/auth');

const router = express.Router();

router.use(authMiddleware);

router.get('/', roleMiddleware('Faculty', 'Admin'), attendanceController.getAttendance);
router.get('/user/:userId?', attendanceController.getUserAttendance);
router.post('/', roleMiddleware('Faculty', 'Admin'), attendanceController.markAttendance);
router.put('/:id', roleMiddleware('Faculty', 'Admin'), attendanceController.updateAttendance);
router.delete('/:id', roleMiddleware('Faculty', 'Admin'), attendanceController.deleteAttendance);

module.exports = router;
