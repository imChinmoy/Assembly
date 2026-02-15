import express from "express";
import { getAllStudents, getStudentById, updateStudent } from "../controllers/students.controller.js";

const router = express.Router();

router.get("/", getAllStudents);
router.get("/:studentId", getStudentById);
router.patch("/:studentId", updateStudent);

export default router;