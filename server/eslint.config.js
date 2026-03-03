import { defineConfig } from 'eslint/config';
import tseslint from 'typescript-eslint';
import eslint from '@eslint/js';

export default defineConfig(
    {
        // NOTE: config with just ignores is the replacement for `.eslintignore`
        ignores: ['**/build/**', '**/dist/**', 'node_modules/**'],
    },
    eslint.configs.recommended,
    tseslint.configs.strictTypeChecked,
    tseslint.configs.stylisticTypeChecked,
    {
        languageOptions: {
            parser: tseslint.parser,
            parserOptions: {
                projectService: true,
                tsconfigRootDir: process.cwd(),
                project: ['./tsconfig.json'],
            },
        },
        plugins: {
            'typescript-eslint': tseslint,
        },
        extends: [
            'eslint:recommended',
            'plugin:typescript-eslint/recommended',
        ],
        rules: {
            'no-unused-vars': 'error',
        },
    }
);