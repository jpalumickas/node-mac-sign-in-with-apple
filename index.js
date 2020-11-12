const appleLogin = process.platform === 'darwin' ? require('bindings')('main.node') : undefined;

const signInWithApple = async (mainWindow) => {
  if (process.platform !== 'darwin') {
    throw new Error('node-mac-sign-in-with-apple only works on macOS')
  }

  return await appleLogin.signInWithApple(mainWindow);
};

module.exports = {
  signInWithApple,
};
