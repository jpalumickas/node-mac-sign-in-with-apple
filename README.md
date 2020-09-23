# node macOS Sign in With Apple

## Usage with Electron

Add to main process

```js
import { signInWithApple } from 'node-mac-sign-in-with-apple';

ipcMain.on('sign-in-with-apple', async () => {
  const nativeWindow = mainWindow.getNativeWindowHandle();
  signInWithApple(nativeWindow);
})
```

Add to entitlements.plist

```xml
<key>com.apple.developer.applesignin</key>
<array>
  <string>Default</string>
</array>
```
