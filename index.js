const appleLogin = require('bindings')('main.node');

const signInWithApple = async (mainWindow) => {
  return await appleLogin.signInWithApple(mainWindow);
};

module.exports = {
  signInWithApple,
};
