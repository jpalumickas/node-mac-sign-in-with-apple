# node macOS Sign in With Apple

## Installation

Using Yarn
```sh
yarn add node-mac-sign-in-with-apple
```

Using NPM

```sh
npm install node-mac-sign-in-with-apple
```

## Usage with Electron

Add to main process

```js
import { signInWithApple } from 'node-mac-sign-in-with-apple';

ipcMain.on('sign-in-with-apple', async () => {
  const nativeWindow = mainWindow.getNativeWindowHandle();
  const data = await signInWithApple(nativeWindow);
})
```

> Note: Only on first login Apple returns email and user name, on other requests
> Apple returns only **idToken**


Add to entitlements.plist

```xml
<key>com.apple.developer.applesignin</key>
<array>
  <string>Default</string>
</array>
```

## License

The package is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
