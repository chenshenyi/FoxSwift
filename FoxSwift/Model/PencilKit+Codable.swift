//
//  PencilKit+Extension.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/18.
//

import PencilKit

extension PKStroke: Codable {
    enum CodingKeys: CodingKey {
        case ink
        case path
        case transform
        case mask
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let ink = try container.decode(PKInk.self, forKey: .ink)
        let path = try container.decode(PKStrokePath.self, forKey: .path)
        let transform = try container.decode(CGAffineTransform.self, forKey: .transform)

        self.init(ink: ink, path: path, transform: transform, mask: nil)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(ink, forKey: .ink)
        try container.encode(path, forKey: .path)
        try container.encode(transform, forKey: .transform)
    }
}

extension PKStrokePath: Codable {
    enum CodingKeys: CodingKey {
        case creationDate
        case controlPoints
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let creationDate = try container.decode(Date.self, forKey: .creationDate)
        let points = try container.decode([PKStrokePoint].self, forKey: .controlPoints)

        self.init(controlPoints: points, creationDate: creationDate)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(creationDate, forKey: .creationDate)

        let strokePoints = Array(self)
        try container.encode(strokePoints, forKey: .controlPoints)
    }
}

extension PKStrokePoint: Codable {
    enum CodingKeys: CodingKey {
        case location
        case timeOffset
        case altitude
        case azimuth
        case force
        case size
        case opacity
        case secondaryScale
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(location, forKey: .location)
        try container.encode(timeOffset, forKey: .timeOffset)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(azimuth, forKey: .azimuth)
        try container.encode(force, forKey: .force)
        try container.encode(size, forKey: .size)
        try container.encode(opacity, forKey: .opacity)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let location = try container.decode(CGPoint.self, forKey: .location)
        let timeOffset = try container.decode(Double.self, forKey: .timeOffset)
        let altitude = try container.decode(Double.self, forKey: .altitude)
        let azimuth = try container.decode(Double.self, forKey: .azimuth)
        let force = try container.decode(Double.self, forKey: .force)
        let size = try container.decode(CGSize.self, forKey: .size)
        let opacity = try container.decode(Double.self, forKey: .opacity)

        if #available(iOS 17.0, *) {
            let secondaryScale = try container.decode(Double.self, forKey: .secondaryScale)
            self.init(
                location: location,
                timeOffset: timeOffset,
                size: size,
                opacity: opacity,
                force: force,
                azimuth: azimuth,
                altitude: altitude,
                secondaryScale: 1
            )
        } else {
            // Fallback on earlier versions
            self.init(
                location: location,
                timeOffset: timeOffset,
                size: size,
                opacity: opacity,
                force: force,
                azimuth: azimuth,
                altitude: altitude
            )
        }
    }
}

extension PKInk: Codable {
    enum CodingKeys: CodingKey {
        case inkType
        case color
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inkType, forKey: .inkType)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        try container.encode(
            
            Color(red: red, green: green, blue: blue, alpha: alpha),
            forKey: .color
        )
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let inkType = try container.decode(InkType.self, forKey: .inkType)
        let color = try container.decode(Color.self, forKey: .color)
        self.init(inkType, color: color.uiColor)
    }
}

extension PKInk.InkType: Codable {}

struct Color: Codable {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat

    var uiColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
