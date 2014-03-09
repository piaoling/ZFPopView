# ZFPopView

ZFPopView is a UIAlertView replacement similar to the style in iOS 7 but with a block based API and the ability to customise the styling and add custom views.

## Preview
![Demo Animation](animation.gif)

## Features

* Simple block syntax instead of delegates
* Animations that match UIAlertView in iOS 7
* Fully customisable
* Add your own UIView beneath the title

## Installation

Add the following to your [CocoaPods](http://cocoapods.org/) Podfile 

	pod 'ZFPopView', '~> 0.0.7'

or clone as a git submodule,

or just copy ```ZFPopView.h``` and ```.m``` into your project.

## Usage

See [ZFPopView.h](Classes/ZFPopView.h) for the complete API.

### An Example

```Objective-C
[ZFPopView popWithTitle:@"Feng is naive and simple"
                message:@"Feng's wife, however, is a beauty....."
            contentView:tmpView];
```

## TODO

* Add style that matches iOS 7 exactly
* Ability to dynamically specify the styling of PopView: default/dark
* Allow usage using the same API methods as UIAlertView and delegate.

## License

ZFPopView is available under the MIT license. See the LICENSE file for more info.