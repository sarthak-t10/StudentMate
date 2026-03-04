const express = require('express');
const announcementController = require('../controllers/announcementController');
const { authMiddleware, roleMiddleware } = require('../middleware/auth');
const { validateRequest, announcementSchema } = require('../middleware/validation');

const router = express.Router();

router.get('/', announcementController.getAnnouncements);
router.get('/:id', announcementController.getAnnouncementById);

router.use(authMiddleware);

router.post('/', validateRequest(announcementSchema), announcementController.createAnnouncement);
router.put('/:id', announcementController.updateAnnouncement);
router.delete('/:id', announcementController.deleteAnnouncement);

module.exports = router;
