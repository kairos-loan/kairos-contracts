module.exports = {
  env: {
    node: true,
    commonjs: true,
    es2021: true,
    "jest/globals": true,
  },
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:prettier/recommended",
  ],
  overrides: [],
  parserOptions: {
    ecmaVersion: "latest",
  },
  rules: {
    "linebreak-style": ["error", "unix"],
    quotes: ["error", "double"],
    semi: ["error", "never"],
    // "max-lines-per-function": ["error", 35],
    // "max-lines": ["error", 150]
  },
  parser: "@typescript-eslint/parser",
  plugins: ["jest", "@typescript-eslint"],
  root: true,
};
