import express, { Request, Response } from 'express';
import cookieParser from 'cookie-parser';
import dotenv from 'dotenv';
import notesRoutes from './routes/notes-routes';

dotenv.config();

const PORT = process.env.PORT || 8086;
const app = express();

app.use(express.json());
app.use(cookieParser());

app.get("/health", (req: Request, res: Response) => {
    res.status(200).json({ message: "Server is running" });
});

app.use(notesRoutes);

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
