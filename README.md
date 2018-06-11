[![license](https://img.shields.io/github/license/eliashaeussler/multiconvert.svg)](LICENSE.md)
[![release](https://img.shields.io/github/release/eliashaeussler/multiconvert.svg)](https://github.com/eliashaeussler/multiconvert/releases/)


# <img src="assets/app-icon-rounded.png" height="23"> MultiConvert

A conversion app for iOS which supports the conversion of multiple quantities such as area, currency, length, speed, time
and weight. For currency conversion, the API of [open exchange rates](https://openexchangerates.org/) is used to provide
current exchange rates.

**Note that this app is not available in the App Store.**


## Requirements

* Mac with Xcode or any other Swift IDE, i.e. [AppCode](https://www.jetbrains.com/objc/) 
* API key from [open exchange rates](https://openexchangerates.org/signup)


## Installation

For installation, clone the repository first.

```bash
git clone https://github.com/eliashaeussler/multiconvert.git
cd multiconvert
```

Now copy the `Config.plist.sample` file to `Config.plist`.
You need this file to insert your API key from *open exchange rates*.

```bash
cd MultiConvert
cp Config.plist.sample Config.plist
```

Open the project in Xcode and navigate to the `MultiConvert/Config.plist` file.
Now insert your API key as value for the `API_KEY` key:

![Insert API key to `Config.plist` file](assets/api-key.png)


## Usage

You can use the app either in the Simulator or on your iOS device. In both cases, it's necessary to initialize the
targets. For this, please refer to existing instructions such as [Build an iOS App](https://v1.designcode.io/xcode)
by [design+code](https://v1.designcode.io/).

To build the app, simply run `⌘`+`R`.


## License

[MIT License](LICENSE.md)