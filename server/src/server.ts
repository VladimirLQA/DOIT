import express from 'express';
import cookieParser from 'cookie-parser';
import dotenv from 'dotenv';
import notesRoutes from './routes/notes-routes';

dotenv.config();

const app= express();

const PORT = process.env.PORT || 3011;

app.use(express.json());
app.use(cookieParser());

app.use(notesRoutes);

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
