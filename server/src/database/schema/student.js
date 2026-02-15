import { pgTable, varchar, boolean, timestamp } from "drizzle-orm/pg-core";

export const students = pgTable("student", {
    studentId: varchar("student_id", { length: 255 }).notNull(),
    name: varchar("name", { length: 255 }).notNull(),
    email: varchar("email", { length: 255 }).notNull(),
    isPresent: boolean("is_present").notNull().default(false),
    password: varchar("password", { length: 255 }).notNull(),
    createdAt: timestamp("created_at").notNull().defaultNow(),
    updatedAt: timestamp("updated_at").notNull().defaultNow(),
});