## [0.0.1] - 2018-08-15

* First tag, support hybrid stack management between native(ios/android) and flutter.

## [0.0.2] - 2018-08-15

* Change environment support(sdk&flutter)

## [0.0.3] - 2018-08-21

* Add License
* Process an AssertError when using flutter v0.5.8+
* Change all display tet into English

## [0.0.4] - 2018-08-21
* Change README.

## [0.0.5] - 2018-09-05
* Add TODO where developers may need to add their customized implementations for non-json-serializable objects into json-serializable ones.

## [0.0.6] - 2018-09-25
* Repository relocated.

## [0.0.7] - 2018-10-31
* Enable support to launch from flutter as the first page which mades it more flexible.
* Fix a white screen problem resulted from gesture confliction when swiping to pop in iOS.
* Add support to take screenshot from flutter side. It is asynchronous, henceforth, the native (iOS&Android) still use the old logic which is using native api and synchronous.

## [0.1.0] - 2018-12-25
* This new version only change the iOS side logic.
* As Flutter1.0 has split FlutterEngine(engine) and FlutterViewController(display), remove the FlutterViewWrapperViewController and move some logic like route control from FlutterViewWrapperViewController to XFlutterViewController.
* Taking snapshot is not needed anymore. 
