import dotenv from "dotenv";
dotenv.config();

import express from "express";
import cors from "cors";
import morgan from "morgan";

import studentRouter from "./src/routes/student.route.js";

const app = express();
const PORT = process.env.PORT || 3000;
app.use(cors());
app.use(morgan("dev"));
app.use(express.json());


app.use("/api/test", (req, res) => {
    res.json({ message: "Hello from the server!" });
} );
app.use('/api/students', studentRouter);

app.listen(PORT, () => {
  console.log(`Server started on port ${PORT}`);
});
