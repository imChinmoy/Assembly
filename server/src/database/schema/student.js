import {
  pgTable,
  serial,
  varchar,
  text,
  boolean,
  timestamp,
  integer,
  foreignKey,
  pgEnum
} from "drizzle-orm/pg-core";

export const teamTypeEnum = pgEnum("team_type_enum", ["solo", "duo"]);

export const yearEnum = pgEnum("year_enum", ["1", "2"]);

export const genderEnum = pgEnum("gender_enum", ["MALE", "FEMALE"]);

export const branchEnum = pgEnum("branch_enum", [
  "CSE",
  "ECE",
  "MECH",
  "CIVIL",
  "EEE",
]);


export const teams = pgTable("teams", {
  id: serial("id").primaryKey(),
  team_id: varchar("team_id", { length: 255 }).notNull(),
  team_type: teamTypeEnum("team_type").notNull(),
  password: varchar("password", { length: 255 }).notNull(),
  payment_order_id: varchar("payment_order_id", { length: 255 }),
  payment_id: varchar("payment_id", { length: 255 }),
  payment_status: boolean("payment_status").default(false),
  email_sent: boolean("email_sent").default(false),
  created_at: timestamp("created_at").defaultNow().notNull(),
});

export const players = pgTable("players", {
  id: serial("id").primaryKey(),
  team_id: integer("team_id")
    .notNull()
    .references(() => teams.id, { onDelete: "cascade" }),
  name: varchar("name", { length: 255 }).notNull(),
  phone: varchar("phone", { length: 10 }).notNull(),
  student_no: varchar("student_no", { length: 255 }).notNull().unique(),
  roll_no: varchar("roll_no", { length: 255 }),
  email: varchar("email", { length: 255 }),
  year: yearEnum("year").notNull(),
  gender: genderEnum("gender").notNull(),
  branch: branchEnum("branch").notNull(),
  is_present: boolean("is_present").default(false).notNull(),
  attendance_updated_at: timestamp("attendance_updated_at"),
});
