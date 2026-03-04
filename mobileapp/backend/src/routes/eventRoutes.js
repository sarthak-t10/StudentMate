const express = require('express');
const eventController = require('../controllers/eventController');
const { authMiddleware } = require('../middleware/auth');
const { validateRequest, eventSchema } = require('../middleware/validation');

const router = express.Router();

router.get('/', eventController.getEvents);
router.get('/:id', eventController.getEventById);

router.use(authMiddleware);

router.post('/', validateRequest(eventSchema), eventController.createEvent);
router.put('/:id', eventController.updateEvent);
router.delete('/:id', eventController.deleteEvent);
router.post('/:id/register', eventController.registerEvent);
router.post('/:id/unregister', eventController.unregisterEvent);

module.exports = router;
