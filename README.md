# JWSETKit

A library for working with JSON Web Signature (JWS) and JSON Web Token (JWT).

## Overview

JSON Web Signature (JWS) represents content secured with digital
signatures or Message Authentication Codes (MACs) using JSON-based
[RFC7159](https://www.rfc-editor.org/rfc/rfc7159) data structures.
The JWS cryptographic mechanisms provide integrity protection for 
an arbitrary sequence of octets.

JSON Web Token (JWT) is a compact claims representation format
intended for space constrained environments such as HTTP
Authorization headers and URI query parameters.

This module makes it possible to serialize, deserialize, create, 
and verify JWS/JWT messages.

## Supported Swift Versions

This library was introduced with support for Swift 5.8 or later.

## Getting Started

To use JWSETKit, add the following dependency to your Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/amosavian/JWSETKit", .upToNextMinor(from: "0.1.0"))
]
```

Note that this repository does not have a 1.0 tag yet, so the API is not stable.

You can then add the specific product dependency to your target:

```swift
dependencies: [
    .product(name: "JWSETKit", package: "JWSETKit"),
]
```

## Usage

For detailed usage and API documentation, check [the documentation](https://amosavian.github.io/JWSETKit/documentation/jwsetkit/).
