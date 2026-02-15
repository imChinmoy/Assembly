import { db } from "../database/index.js";
import { students } from "../database/schema/student.js";
import { desc, ilike, or, sql, eq } from "drizzle-orm";

export const getAllStudents = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const search = req.query.search?.trim() || "";

    const offset = (page - 1) * limit;

    const searchCondition = search
      ? or(
          ilike(students.name, `%${search}%`),
          ilike(students.studentId, `%${search}%`),
        )
      : undefined;

    const studentsData = await db
      .select()
      .from(students)
      .where(searchCondition)
      .orderBy(desc(students.createdAt))
      .limit(limit)
      .offset(offset);

    const totalResult = await db
      .select({ count: sql`count(*)` })
      .from(students)
      .where(searchCondition);

    const totalStudents = Number(totalResult[0].count);

    res.status(200).json({
      success: true,
      page,
      limit,
      totalStudents,
      totalPages: Math.ceil(totalStudents / limit),
      data: studentsData,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch students",
      error: error.message,
    });
  }
};

export const getStudentById = async (req, res) => {
  try {
    const { studentId } = req.params;
    const student = await db
      .select()
      .from(students)
      .where(eq(students.studentId, studentId));

    res.status(200).json({ success: true, data: student });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch student",
      error: error.message,
    });
  }
};

export const updateStudent = async (req, res) => {
  try {
    const { studentId } = req.params;
    const { isPresent } = req.body;

    const student = await db
      .update(students)
      .set({ isPresent })
      .where(eq(students.studentId, studentId));

    res.status(200).json({ success: true, data: student });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: "Failed to update student",
      error: error.message,
    });
  }
};
