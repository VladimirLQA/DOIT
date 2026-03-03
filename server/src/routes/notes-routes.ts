import { Router } from "express";
import { createNoteValidation, deleteNoteValidation, getNoteValidation, updateNoteValidation } from "../middleware/notes-middleware";
import NotesController from "../controllers/notes-controller";
import { validateResults } from "../middleware/validateResults-middleware";

const notesRoutes = Router();
const notesController = new NotesController();

notesRoutes.post('/notes/get', getNoteValidation, validateResults, notesController.getNote);
notesRoutes.post('/notes/getAll', validateResults, notesController.getAllNotes);
notesRoutes.post('/notes/create', createNoteValidation, validateResults, notesController.createNote);
notesRoutes.post('/notes/update', updateNoteValidation, validateResults, notesController.updateNote);
notesRoutes.post('/notes/delete', deleteNoteValidation, validateResults, notesController.deleteNote);

export default notesRoutes