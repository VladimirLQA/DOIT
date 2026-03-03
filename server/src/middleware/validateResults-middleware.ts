import { NextFunction, Request, RequestHandler, Response } from "express";
import { validationResult } from "express-validator";

export const validateResults: RequestHandler = (req: Request, res: Response, next: NextFunction) => {
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        res.status(200).json({ errors: errors.mapped(), type: 'Validation failed' });
        return;
    }
    next();
};
