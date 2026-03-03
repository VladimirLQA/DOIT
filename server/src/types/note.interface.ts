export interface INote {
    id: number;
    title: string;
    content: string;
    categoryId?: number;
}

export interface ICreateNote {
    title: string;
    content: string;
    categoryId?: number;
}

export interface IUpdateNote {
    id: number;
    title: string;
    content: string;
    categoryId?: number;
}

export interface IDeleteNote {
    id: number;
}
