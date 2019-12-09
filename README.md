# SCTE35-SwiftLibrary

Swift library for parsing [SCTE35](https://www.scte.org/SCTEDocs/Standards/ANSI_SCTE%2035%202019r1.pdf) data either via base64 or hex string

## Features

* SCTE35 Binary Parsing

## Installation

This library is available through Carthage or Cocoapods

### Carthage

Add the following to your Cartfile replacing `<version>` with desired version number, example `1.0.5`

```text
github "realeyes-media/scte35-swift" "<version>"
```

### Cocoapods

Add the following to your Podfile replacing `<version>` with desired version number, example `1.0.5`

```text
pod 'SCTE35', :git => 'https://github.com/realeyes-media/scte35-swift.git', :tag => '<version>'
```

## API

Parse From Base64 String

```Swift
let scte35Base64Str = "/DA4AAAAAAAA///wBQb+AAAAAAAiAiBDVUVJAAAAA3//AAApPWwDDEFCQ0QwMTIzNDU2SBAAAGgCL9A="
let converter = SCTE35Converter()
do {
    let result: SpliceInfoSection = try converter.parseFrom(base64String: scte35Base64Str)
} catch {
    // error parsing scte data
    // error is of type SCTE35ParsingError
}
```

Parse from Hex String

```Swift
let scte35HexStr = "0xFC3034000000000000FFFFF00506FE72BD0050001E021C435545494800008E7FCF0001A599B00808000000002CA0A18A3402009AC9D17E"
let converter = SCTE35Converter()
do {
    let result: SpliceInfoSection = try converter.parseFrom(hexString: scte35HexStr)
} catch {
    // error parsing scte data
    // error is of type SCTE35ParsingError
}
```

>SpliceInfoSection is the Swifty version of SCTE-35 Standards as defined in [SCTE35 Standards](https://www.scte.org/SCTEDocs/Standards/SCTE%2035%202019r1.pdf)
>For Reference on Terminology and definitions see [SCTE35 Standards].
>Definitions of properties are copied and pasted from here
>See Page 12 for definitions and abbreviations

For more examples refer to the unit tests

## Contributing

Please read CONTRIBUTING.md for details on our code of conduct, and the process for submitting pull requests to us.

## License

This project is licensed under the MIT License - see LICENSE file for details
