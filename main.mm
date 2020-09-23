#import <AuthenticationServices/AuthenticationServices.h>
#import "./AppleLogin.h"
#include <napi.h>

Napi::ThreadSafeFunction ts_fn;

/***** HELPERS *****/

static NSWindow *windowFromBuffer(const Napi::Buffer<uint8_t> &buffer) {
      NSLog(@"window from buffer 1----------------------------");
  auto data = (NSView **)buffer.Data();
      NSLog(@"window from buffer 2----------------------------");
  auto view = data[0];
      NSLog(@"window from buffer 3----------------------------");
      NSLog(@"window from buffer 3---------------------------- %@", @(view != nil));
  return view.window;
}

Napi::Boolean SignInWithApple(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
      NSLog(@"VIEW----------------------------");
  if (info.Length() < 1) {
    Napi::Error::New(info.Env(), "Wrong number of arguments")
        .ThrowAsJavaScriptException();
  return Napi::Boolean::New(env, false);
  }

      NSLog(@"VIEW2----------------------------");

      NSLog(@"VIEW2----------------------------%@", @(info[0] != nil));
  Napi::Buffer<uint8_t> buffer = info[0].As<Napi::Buffer<uint8_t>>();
  if (buffer.Length() != 8) {
    Napi::Error::New(info.Env(), "Pointer buffer is invalid")
        .ThrowAsJavaScriptException();
  return Napi::Boolean::New(env, false);
  }
      NSLog(@"VIEW3----------------------------");
      NSLog(@"VIEW3----------------------------%@", @(buffer != nil));

  NSWindow *win = windowFromBuffer(buffer);
      NSLog(@"VIEW4----------------------------");
      NSLog(@"VIEW4----------------------------%@", win);


  // Napi::Buffer<void*> winHandle = info[0].As<Napi::Buffer<void*>>();
        // NSView *view = *reinterpret_cast<NSView **>(winHandle.Data());

  // NSView* view = static_cast<NSView*>(*reinterpret_cast<void **>(winHandle.Data()));

  // NSWindow *originalWindow = view.window;


  AppleLogin *appleLogin = [[AppleLogin alloc] initWithWindow: win];
  [appleLogin initiateLoginProcess];


  return Napi::Boolean::New(env, true);
}

// Initializes all functions exposed to JS.
Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "signInWithApple"),
              Napi::Function::New(env, SignInWithApple));



  return exports;
}

NODE_API_MODULE(main, Init)
