//
//  BrickZones.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 7/11/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

class BrickZones {
    var attributesZones: [Int: Set<UICollectionViewLayoutAttributes>] = [:] // Attributes zones keep track of which attributes are in which location
    var collectionViewSize: CGSize
    var scrollDirection: UICollectionViewScrollDirection

    init(collectionViewSize: CGSize, scrollDirection: UICollectionViewScrollDirection) {
        self.collectionViewSize = collectionViewSize
        self.scrollDirection = scrollDirection
    }

    func layoutAttributesForElementsInRect(rect: CGRect, for layout: UICollectionViewLayout) -> [UICollectionViewLayoutAttributes]? {
        let zones = calculateZonesForFrame(rect)

        var attributes = [UICollectionViewLayoutAttributes]()
        for zone in zones {
            if let zoneAttributes = attributesZones[zone] {
                for zoneA in zoneAttributes {
                    if !attributes.contains(zoneA) && zoneA.frame.height > 0 {
                        attributes.append(zoneA)
                    }
                }
            }
        }

        return attributes
    }

    func calculateZonesForFrame(frame: CGRect) -> [Int] {
        guard collectionViewSize.height > 0 && collectionViewSize.width > 0 else {
            //Avoid division by zero
            return []
        }

        guard frame.height > 0 else {
            //Avoid division by zero
            return []
        }

        let minZone = calculateZonesForPoint(CGPoint(x: frame.minX, y: frame.minY))
        let maxZone = calculateZonesForPoint(CGPoint(x: frame.maxX, y: frame.maxY))

        var zones = [Int]()
        for zone in minZone...maxZone {
            zones.append(zone)
        }
        return zones
    }

    private func calculateZonesForPoint(point: CGPoint) -> Int {
        switch scrollDirection {
        case .Vertical: return Int(point.y / collectionViewSize.height)
        case .Horizontal: return Int(point.x / collectionViewSize.width)
        }
    }

    func addAttributesToZones(attributes: UICollectionViewLayoutAttributes) {
        let zones = attributes.hidden ? [] : calculateZonesForFrame(attributes.frame)
        for zone in zones {
            addAttributes(attributes, toZone: zone)
        }
    }

    func addAttributes(attributes: UICollectionViewLayoutAttributes, toZone zone: Int) {
        if attributesZones[zone] == nil {
            attributesZones[zone] = []
        }

        attributesZones[zone]!.insert(attributes)
    }

    func removeAttributes(attributes: UICollectionViewLayoutAttributes) {
        let zones = calculateZonesForFrame(attributes.frame)
        for zone in zones {
            if attributesZones[zone]!.contains(attributes) {
                attributesZones[zone]!.remove(attributes)
            }
            if attributesZones[zone]!.isEmpty {
                attributesZones.removeValueForKey(zone)
            }
        }
    }

    func updateZones(for attributes: UICollectionViewLayoutAttributes, from fromFrame: CGRect? = nil) {
        let newZones = attributes.hidden ? [] : calculateZonesForFrame(attributes.frame)
        var oldZones: [Int]

        if let from = fromFrame {
            oldZones = calculateZonesForFrame(from)
        } else {
            oldZones = [Int]()
            for (zone, zoneAttributes) in attributesZones {
                if zoneAttributes.contains(attributes) {
                    oldZones.append(zone)
                }
            }
        }

        for newZone in newZones {
            if attributesZones[newZone] == nil {
                attributesZones[newZone] = []
            }
            attributesZones[newZone]!.insert(attributes)
        }

        for oldZone in oldZones {
            guard !newZones.contains(oldZone) else {
                continue
            }

            if attributesZones[oldZone] == nil {
                attributesZones[oldZone] = []
            }
            attributesZones[oldZone]!.remove(attributes)
        }
    }
    
}
