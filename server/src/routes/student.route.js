import express from 'express';
import { getAllPlayers, getPlayerByStudentNo, markAttendance } from '../controllers/students.controller.js';

const router = express.Router();

router.get('/', getAllPlayers);
router.get('/:studentNo', getPlayerByStudentNo);
router.patch('/attendance/:studentNo', markAttendance);

export default router;
