// babel.config.js  (at project root; overwrite if needed)
module.exports = function (api) {
  api.cache(true);
  return { presets: ["babel-preset-expo"] };
};
