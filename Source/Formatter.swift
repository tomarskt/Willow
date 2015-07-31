//
//  Formatter.swift
//  Willow
//
//  Created by Christian Noon on 1/18/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
public typealias Color = UIColor
#elseif os(OSX)
import Cocoa
public typealias Color = NSColor
#endif

// MARK: - Formatter

/**
    The Formatter protocol defines a single method for formatting a message after it has been constructed. This is very
    flexible allowing any object that conforms to use formatting scheme it wants.
*/
public protocol Formatter {
    func formatMessage(message: String, logLevel: LogLevel) -> String
}

// MARK: -

/**
    The TimestampFormatter class applies a timestamp to the beginning of the message.
*/
public class TimestampFormatter: Formatter {

    private let timestampFormatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    /**
        Initializes a timestamp formatter instance.

        - returns: A new timestamp formatter instance.
    */
    public init() {}

    /**
        Applies a timestamp to the beginning of the message.

        - parameter message:  The original message to format.
        - parameter logLevel: The log level set for the message.

        - returns: A newly formatted message.
    */
    public func formatMessage(message: String, logLevel: LogLevel) -> String {
        let timestampString = self.timestampFormatter.stringFromDate(NSDate())
        return "\(timestampString) \(message)"
    }
}

// MARK: -

/**
    The ColorFormatter class takes foreground and background colors and applies them to a given message. It uses the
    XcodeColors plugin color formatting scheme.

    NOTE: These should only be used with the XcodeColors plugin.
*/
public class ColorFormatter: Formatter {

    // MARK: Private - ColorConstants

    private struct ColorConstants {
        static let ESCAPE = "\u{001b}["
        static let RESET_FG = ESCAPE + "fg;"
        static let RESET_BG = ESCAPE + "bg;"
        static let RESET = ESCAPE + ";"
    }

    // MARK: Private - Properties

    private let foregroundText: String
    private let backgroundText: String

    // MARK: Initialization Methods

    /**
        Returns a fully constructed ColorFormatter from the given Color objects.

        - parameter foregroundColor: The color to apply to the foreground.
        - parameter backgroundColor: The color to apply to the background.

        - returns: A fully constructed ColorFormatter from the given Color objects.
    */
    public init(foregroundColor: Color?, backgroundColor: Color?) {
        assert(foregroundColor != nil || backgroundColor != nil, "The foreground and background colors cannot both be nil")

        let foregroundTextString = ColorFormatter.textStringForColor(foregroundColor)
        let backgroundTextString = ColorFormatter.textStringForColor(backgroundColor)

        if (!foregroundTextString.isEmpty) {
            self.foregroundText = "\(ColorConstants.ESCAPE)fg\(foregroundTextString);"
        } else {
            self.foregroundText = ""
        }

        if (!backgroundTextString.isEmpty) {
            self.backgroundText = "\(ColorConstants.ESCAPE)bg\(backgroundTextString);"
        } else {
            self.backgroundText = ""
        }
    }

    // MARK: Formatter Methods

    /**
        Applies the foreground, background and reset color formatting values to the given message.

        - parameter message: The message to apply the color formatting to.

        - returns: A new string with all the color formatting values added.
    */
    public func formatMessage(message: String, logLevel: LogLevel) -> String {
        return "\(self.foregroundText)\(self.backgroundText)\(message)\(ColorConstants.RESET)"
    }

    // MARK: Private - Helper Methods

    private class func textStringForColor(color: Color?) -> String {
        var textString = ""

        if let color = color {
            var redValue: CGFloat = 0.0
            var greenValue: CGFloat = 0.0
            var blueValue: CGFloat = 0.0

            // Since the colorspace on OSX is not guaranteed to be `deviceRGBColorSpace`, the color must be converted
            // to guarantee that the `getRed(_:green:blue:alpha:)` call will succeed.
            #if os(OSX)
            if let rgbColor = color.colorUsingColorSpace(NSColorSpace.deviceRGBColorSpace()) {
                rgbColor.getRed(&redValue, green: &greenValue, blue: &blueValue, alpha: nil)
            }
            #elseif os(iOS)
                color.getRed(&redValue, green: &greenValue, blue: &blueValue, alpha: nil)
            #endif

            let maxValue: CGFloat = 255.0

            let redInt = UInt8(round(redValue * maxValue))
            let greenInt = UInt8(round(greenValue * maxValue))
            let blueInt = UInt8(round(blueValue * maxValue))

            textString = "\(redInt),\(greenInt),\(blueInt)"
        }

        return textString
    }
}