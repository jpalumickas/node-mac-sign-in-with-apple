const appleLogin = require('bindings')('main.node');

const signInWithApple = async (mainWindow) => {
  console.log('main window', mainWindow);
  return await appleLogin.signInWithApple(mainWindow);
};

module.exports = {
  signInWithApple,
};
