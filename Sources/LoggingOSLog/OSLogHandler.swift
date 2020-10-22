/***************************************************************************
 * This source file is part of the swift-log-oslog open source project.    *
 *                                                                         *
 * Copyright (c) 2020-present, InMotion Software and the project authors   *
 * Licensed under the MIT License                                          *
 *                                                                         *
 * See LICENSE.txt for license information                                 *
 ***************************************************************************/

import Foundation
import Logging
import struct Logging.Logger
import os

///
/// A logging backend for `SwiftLog` that sends log messages to `OSLog`.
///
/// The logger's `label` is used to specify the `subsystem` and `categorgy` for `OSLog`.
/// The `metadataContentType` is used to control the output of `LoggerMetadata`.
/// If `private` is set, the `LoggerMetadata` content output is replaced with `<private>`
/// String value. This is useful for protecting sensitive information for Release build.
///
public struct OSLogHandler: LogHandler {

    /// The LoggerMetadata content type
    public enum MetadataContentType: String {
        /// Replace metadata content type with `<private>` string
        case `private`
        /// Log metadata content as string
        case `public`
    }

    public var logLevel: Logger.Level = .trace
    public var metadataContentType: MetadataContentType
    private let oslogger: OSLog

    public init(label: String, metadataContentType: MetadataContentType = .private) {
        self.metadataContentType = metadataContentType
        let config = label.loggerConfig()
        self.oslogger = OSLog(subsystem: config.subsystem, category: config.category)
    }

    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        var formedMessage = ""

        if level < .info && self.metadataContentType == .public && !file.isEmpty {
            let filename = file.split(separator: "/").last.map { String($0) } ?? ""
            formedMessage += "[\(filename)(\(line))]"
        }

        formedMessage += "[\(source)]: \(message.description)"

        if let metadataOverride = metadata {
            switch self.metadataContentType {
                case .private:
                    formedMessage += " -- <private>"
                case .public:
                    formedMessage += " -- \(self.prettyMetadata.map { "\($0) " } ?? "")\(self.prettify(metadataOverride) ?? "")"
            }
        }

        os_log("%{public}@", log: self.oslogger, type: OSLogType.from(loggerLevel: level), formedMessage as NSString)
    }

    private var prettyMetadata: String?
    public var metadata = Logger.Metadata() {
        didSet {
            self.prettyMetadata = self.prettify(self.metadata)
        }
    }

    /// Add, remove, or change the logging metadata.
    /// - parameters:
    ///    - metadataKey: the key for the metadata item.
    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set {
            self.metadata[metadataKey] = newValue
        }
    }

    private func prettify(_ metadata: Logger.Metadata) -> String? {
        if metadata.isEmpty {
            return nil
        }
        return metadata.map {
            "\($0) = \($1)"
        }.joined(separator: " ")
    }

}

extension OSLogType {
    static func from(loggerLevel: Logger.Level) -> Self {
        switch loggerLevel {
        case .trace:
            /// `OSLog` doesn't have `trace`, so use `debug`
            return .debug
        case .debug:
            return .debug
        case .info:
            return .info
        case .notice:
            /// `OSLog` doesn't have `notice`, so use `info`
            return .info
        case .warning:
            /// `OSLog` doesn't have `warning`, so use `info`
            return .info
        case .error:
            return .error
        case .critical:
            return .fault
        }
    }
}

private extension String {
    ///
    /// Extracts `subsystem` and `category` for Logger's `label`. The expected format is `"subsystem/category"`.
    ///
    func loggerConfig() -> (subsystem: String, category: String) {
        let segments = self.split(separator: "/")
        switch segments.count {
            case 1:
                return (subsystem: String(segments[0]), category: "")
            case 2:
                return (subsystem: String(segments[0]), category: String(segments[1]))
            default:
                return (subsystem: self, category: "")
        }
    }
}
