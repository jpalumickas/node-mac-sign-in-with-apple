const appleLogin = require('bindings')('main.node')

const signInWithApple = (mainWindow) => {
  console.log('main window', mainWindow);
  appleLogin.signInWithApple(mainWindow);
}

module.exports = {
  signInWithApple
}
