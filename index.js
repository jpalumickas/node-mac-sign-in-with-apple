const appleLogin = process.platform === 'darwin' ? require('bindings')('main.node') : undefined;

const signInWithApple = async (mainWindow) => {
  if (process.platform !== 'darwin') {
    throw new Error('node-mac-sign-in-with-apple only works on macOS')
  }

  return new Promise((resolve, reject) => {
    appleLogin.signInWithApple((result) => {
      if (result.is_error === 'true') {
        delete result.is_error;
        reject(result);
        return;
      }

      delete result.is_error;
      resolve(result);
    }, mainWindow);
  })
};

module.exports = {
  signInWithApple,
};
