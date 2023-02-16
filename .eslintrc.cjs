module.exports = {
  env: {
    node: true,
    commonjs: true,
    es2021: true
  },
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:prettier/recommended"
  ],
  overrides: [],
  parserOptions: {
    ecmaVersion: "latest"
  },
  rules: {
    "linebreak-style": ["error", "unix"],
    "no-undef": 2,
    quotes: ["error", "double"],
    semi: ["error", "never"]
  },
  parser: "@typescript-eslint/parser",
  plugins: ["@typescript-eslint"],
  ignorePatterns: ["**/out/*", "**/generated/*", "**/node_modules/*"],
  root: true
}
