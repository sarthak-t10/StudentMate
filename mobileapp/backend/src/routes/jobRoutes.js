const express = require('express');
const jobController = require('../controllers/jobController');
const { authMiddleware, roleMiddleware } = require('../middleware/auth');
const { validateRequest, jobPostingSchema } = require('../middleware/validation');

const router = express.Router();

router.get('/', jobController.getJobPostings);
router.get('/:id', jobController.getJobPostingById);

router.use(authMiddleware);

router.post('/', roleMiddleware('Faculty', 'Admin'), validateRequest(jobPostingSchema), jobController.createJobPosting);
router.put('/:id', roleMiddleware('Faculty', 'Admin'), jobController.updateJobPosting);
router.delete('/:id', roleMiddleware('Faculty', 'Admin'), jobController.deleteJobPosting);
router.post('/:id/apply', jobController.applyForJob);
router.get('/:id/applications', jobController.getApplications);

module.exports = router;
