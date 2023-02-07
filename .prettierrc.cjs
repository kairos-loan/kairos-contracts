module.exports = {
  ...require("../../.prettierrc.cjs"),
  overrides: [
    {
      files: "*.sol",
      options: {
        printWidth: 110,
        tabWidth: 4
      }
    }
  ],
  plugins: ["prettier-plugin-solidity"],
};
