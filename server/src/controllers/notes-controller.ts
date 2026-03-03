import { NextFunction, Request, Response } from 'express';

class NotesController {
    async getNote(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.body;
            console.log(id);
            res.status(200).json({ message: `Note ${id}` });
        } catch (error) {
            next(error);
        }
    }

    async getAllNotes(req: Request, res: Response, next: NextFunction) {
        try {
            res.status(200).json({ message: 'Notes fetched' });
        } catch (error) {
            next(error);
        }
    }

    async createNote(req: Request, res: Response, next: NextFunction) {
        try {
            res.status(200).json({ message: 'Note created' });
        } catch (error) {
            next(error);
        }
    }
    
    async updateNote(req: Request, res: Response, next: NextFunction) {
        try {
            res.status(200).json({ message: 'Note updated' });
        } catch (error) {
            next(error);
        }
    }

    async deleteNote(req: Request, res: Response, next: NextFunction) {
        try {
            res.status(200).json({ message: 'Note deleted' });
        } catch (error) {
            next(error);
        }
    }

}

export default NotesController;