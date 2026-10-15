export default {
  defaultBrowser: "Zen",
  handlers: [
    {
      match: [
        finicky.matchHostnames([
          /\.salesforce\.com$/,
          /\.force\.com$/,
          /\.my\.site\.com$/,
        ]),
      ],
      browser: "Google Chrome",
    },
    {
      match: [
        finicky.matchHostnames([
          /(^|\.)youtube\.com$/,
          /^youtu\.be$/,
          /(^|\.)netflix\.com$/,
          /(^|\.)max\.com$/,
          /(^|\.)hbomax\.com$/,
        ]),
      ],
      browser: "Firefox",
    },
  ],
};
