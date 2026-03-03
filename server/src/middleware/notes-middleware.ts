import { body, ValidationChain } from 'express-validator';

export const noteId = body('id')
    .exists().withMessage('ID is required')
    .isInt({ allow_leading_zeroes: false, min: 1 })
    .withMessage('ID must be a positive integer without leading zeros')

export const noteTitle = body('title')
    .exists().withMessage('Title is required')
    .isString().withMessage('Title must be a string')
    .trim()
    .isLength({ min: 3 }).withMessage('Title must be at least 3 characters long');

export const noteContent = body('content')
    .exists().withMessage('Content is required')
    .isString().withMessage('Content must be a string')
    .trim()
    .isLength({ min: 1 }).withMessage('Content must be at least 1 character long');

export const noteCategoryId = body('categoryId')
    .optional()
    .isInt({ allow_leading_zeroes: false, min: 1 })
    .withMessage('categoryId must be a positive integer without leading zeros');

export const getNoteValidation: ValidationChain[] = [
    noteId,
];

export const createNoteValidation: ValidationChain[] = [
    noteTitle,
    noteContent,
    noteCategoryId,
];

export const updateNoteValidation: ValidationChain[] = [
    noteId,
    noteTitle,
    noteContent,
    noteCategoryId,
];

export const deleteNoteValidation: ValidationChain[] = [
    noteId,
];
