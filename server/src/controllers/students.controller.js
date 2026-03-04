import { db } from "../database/index.js";
import { players, teams } from "../database/schema/student.js";
import { eq, and, desc, sql, or, ilike } from "drizzle-orm";

export const getAllPlayers = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const search = req.query.search?.trim() || "";

    const offset = (page - 1) * limit;

    const searchCondition = search
      ? or(
          ilike(players.name, `%${search}%`),
          ilike(players.student_no, `%${search}%`),
        )
      : undefined;

    const playersData = await db
      .select()
      .from(players)
      .where(searchCondition)
      .orderBy(desc(players.id))
      .limit(limit)
      .offset(offset);

    const totalResult = await db
      .select({ count: sql`count(*)` })
      .from(players)
      .where(searchCondition);

    const totalPlayers = Number(totalResult[0].count);

    res.status(200).json({
      success: true,
      page,
      limit,
      totalPlayers,
      totalPages: Math.ceil(totalPlayers / limit),
      data: playersData,
    });
  } catch (error) {
    console.error("Error fetching players:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch players",
      error: error.message,
    });
  }
};

export const getPlayerByStudentNo = async (req, res) => {
  try {
    const { studentNo } = req.params;
    const player = await db
      .select()
      .from(players)
      .where(eq(players.student_no, studentNo));

    if (!player.length) {
      return res.status(404).json({
        success: false,
        message: "Player not found",
      });
    }

    res.status(200).json({ success: true, data: player[0] });
  } catch (error) {
    console.error("Error fetching player:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch player",
      error: error.message,
    });
  }
};

export const markAttendance = async (req, res) => {
  try {
    const { studentNo } = req.params;
    const isPresent = req.body.is_present ?? req.body.isPresent ?? false;

    const updateResult = await db
      .update(players)
      .set({
        is_present: Boolean(isPresent),
        attendance_updated_at: new Date(),
      })
      .where(eq(players.student_no, studentNo))
      .returning({ id: players.id });

    if (!updateResult || updateResult.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Player not found to update attendance",
      });
    }

    res.status(200).json({
      success: true,
      message: `Attendance marked as ${isPresent ? "Present" : "Absent"}`,
    });
  } catch (error) {
    console.error("Error updating attendance:", error);
    res.status(500).json({
      success: false,
      message: "Failed to update attendance",
      error: error.message,
    });
  }
};
