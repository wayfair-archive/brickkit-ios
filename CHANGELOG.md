# Change Log

## [0.9.6](https://github.com/wayfair/brickkit-ios/tree/0.9.6) (2016-12-19)
[Full Changelog](https://github.com/wayfair/brickkit-ios/compare/0.9.5...0.9.6)

**Implemented enhancements:**

- BrickAlignment [\#42](https://github.com/wayfair/brickkit-ios/issues/42)
- alignRowHeights per BrickSection [\#41](https://github.com/wayfair/brickkit-ios/issues/41)
- BrickDimension: Remaining [\#39](https://github.com/wayfair/brickkit-ios/issues/39)
- Optimise calculations for larger quantities [\#19](https://github.com/wayfair/brickkit-ios/issues/19)

**Closed issues:**

- brickIsStickingWithPercentage not correct when stacking sticky bricks [\#51](https://github.com/wayfair/brickkit-ios/issues/51)
- Wrong identifier when appending a brick to the end and using repeatCount [\#50](https://github.com/wayfair/brickkit-ios/issues/50)
- Example app doesn't compile [\#47](https://github.com/wayfair/brickkit-ios/issues/47)
- Gap between Bricks on a iPad [\#33](https://github.com/wayfair/brickkit-ios/issues/33)

**Merged pull requests:**

- InvalidateRepeatCounts + identifiers [\#53](https://github.com/wayfair/brickkit-ios/pull/53) ([rubencagnie](https://github.com/rubencagnie))
- Fixed sticking percentage for stacking sticky bricks [\#52](https://github.com/wayfair/brickkit-ios/pull/52) ([rubencagnie](https://github.com/rubencagnie))
- BrickSize public init [\#45](https://github.com/wayfair/brickkit-ios/pull/45) ([jay18001](https://github.com/jay18001))
- Allows to set the alignment per row [\#44](https://github.com/wayfair/brickkit-ios/pull/44) ([rubencagnie](https://github.com/rubencagnie))
- alignRowHeights per BrickSection [\#43](https://github.com/wayfair/brickkit-ios/pull/43) ([rubencagnie](https://github.com/rubencagnie))
- Support for “Remainder” BrickDimension [\#40](https://github.com/wayfair/brickkit-ios/pull/40) ([rubencagnie](https://github.com/rubencagnie))
- Optimization for attributes calculation. Now the attributes will only… [\#38](https://github.com/wayfair/brickkit-ios/pull/38) ([rubencagnie](https://github.com/rubencagnie))
- Added Brick Size [\#26](https://github.com/wayfair/brickkit-ios/pull/26) ([jay18001](https://github.com/jay18001))

## [0.9.5](https://github.com/wayfair/brickkit-ios/tree/0.9.5) (2016-12-02)
[Full Changelog](https://github.com/wayfair/brickkit-ios/compare/0.9.4...0.9.5)

**Closed issues:**

- Wrong content size calculation when a brick's height shrinks [\#36](https://github.com/wayfair/brickkit-ios/issues/36)

**Merged pull requests:**

- Fixed wrong contentSize when Brick’s height changed [\#37](https://github.com/wayfair/brickkit-ios/pull/37) ([rubencagnie](https://github.com/rubencagnie))

## [0.9.4](https://github.com/wayfair/brickkit-ios/tree/0.9.4) (2016-11-28)
[Full Changelog](https://github.com/wayfair/brickkit-ios/compare/0.9.3...0.9.4)

**Merged pull requests:**

- Added imageDownloadHandler to ImageBrick and made tapGesture public o… [\#35](https://github.com/wayfair/brickkit-ios/pull/35) ([jay18001](https://github.com/jay18001))
- Fix all the memory issues [\#34](https://github.com/wayfair/brickkit-ios/pull/34) ([jay18001](https://github.com/jay18001))
- Removed incorrect information in deprecation statement [\#32](https://github.com/wayfair/brickkit-ios/pull/32) ([jay18001](https://github.com/jay18001))

## [0.9.3](https://github.com/wayfair/brickkit-ios/tree/0.9.3) (2016-11-10)
[Full Changelog](https://github.com/wayfair/brickkit-ios/compare/0.9.2...0.9.3)

**Fixed bugs:**

- Flickering CollectionBrick's [\#28](https://github.com/wayfair/brickkit-ios/issues/28)

**Closed issues:**

- Fix Spotlight Layout Behavior Issue [\#30](https://github.com/wayfair/brickkit-ios/issues/30)
- Carthage [\#20](https://github.com/wayfair/brickkit-ios/issues/20)

**Merged pull requests:**

- Fix spotlight layout behavior bug [\#31](https://github.com/wayfair/brickkit-ios/pull/31) ([djriefler](https://github.com/djriefler))
- Fixed reloading of CollectionBricks [\#29](https://github.com/wayfair/brickkit-ios/pull/29) ([rubencagnie](https://github.com/rubencagnie))
- Added data source method on collection brick to register bricks and array of bricks for collection brick [\#25](https://github.com/wayfair/brickkit-ios/pull/25) ([jay18001](https://github.com/jay18001))
- Update README.md [\#24](https://github.com/wayfair/brickkit-ios/pull/24) ([klundberg](https://github.com/klundberg))
- Update README.md [\#23](https://github.com/wayfair/brickkit-ios/pull/23) ([klundberg](https://github.com/klundberg))
- Added Carthage install in README.md [\#22](https://github.com/wayfair/brickkit-ios/pull/22) ([rubencagnie](https://github.com/rubencagnie))
- Added Flickr example [\#2](https://github.com/wayfair/brickkit-ios/pull/2) ([jay18001](https://github.com/jay18001))

## [0.9.2](https://github.com/wayfair/brickkit-ios/tree/0.9.2) (2016-10-27)
[Full Changelog](https://github.com/wayfair/brickkit-ios/compare/0.9.1...0.9.2)

**Fixed bugs:**

- alignRowHeights are not working correctly [\#17](https://github.com/wayfair/brickkit-ios/issues/17)
- ImageBrick dynamic size doesn't always refresh on screen [\#15](https://github.com/wayfair/brickkit-ios/issues/15)
- BrickDimension.Orientation has wrong value when orientation `isFlat` [\#13](https://github.com/wayfair/brickkit-ios/issues/13)

**Merged pull requests:**

- Reported changed attributes correctly [\#18](https://github.com/wayfair/brickkit-ios/pull/18) ([rubencagnie](https://github.com/rubencagnie))
- Wrapped `updateHeight` in `performBatchUpdates` [\#16](https://github.com/wayfair/brickkit-ios/pull/16) ([rubencagnie](https://github.com/rubencagnie))
- BrickDimension now checks on UIScreen bounds [\#14](https://github.com/wayfair/brickkit-ios/pull/14) ([rubencagnie](https://github.com/rubencagnie))

## [0.9.1](https://github.com/wayfair/brickkit-ios/tree/0.9.1) (2016-10-25)
[Full Changelog](https://github.com/wayfair/brickkit-ios/compare/0.9.0...0.9.1)

**Fixed bugs:**

- Sticky Footer for Sections didn't calculate correctly [\#8](https://github.com/wayfair/brickkit-ios/issues/8)
- Brick Dimension Size Classes Issue [\#6](https://github.com/wayfair/brickkit-ios/issues/6)
- SpotlightLayoutBehavior doesn't show the bottom bricks [\#4](https://github.com/wayfair/brickkit-ios/issues/4)

**Merged pull requests:**

- Travis fix [\#12](https://github.com/wayfair/brickkit-ios/pull/12) ([rubencagnie](https://github.com/rubencagnie))
- 0.9.1 [\#10](https://github.com/wayfair/brickkit-ios/pull/10) ([rubencagnie](https://github.com/rubencagnie))
- Sticky footer was wrongly calculated [\#9](https://github.com/wayfair/brickkit-ios/pull/9) ([rubencagnie](https://github.com/rubencagnie))
- Fix BrickDimension for iPad. [\#7](https://github.com/wayfair/brickkit-ios/pull/7) ([thevwu](https://github.com/thevwu))
- SpotlightLayoutBehavior now calls `attributesDidUpdate` [\#5](https://github.com/wayfair/brickkit-ios/pull/5) ([rubencagnie](https://github.com/rubencagnie))
- Integration with Travis [\#3](https://github.com/wayfair/brickkit-ios/pull/3) ([rubencagnie](https://github.com/rubencagnie))
- Added travis build badge [\#1](https://github.com/wayfair/brickkit-ios/pull/1) ([klundberg](https://github.com/klundberg))

## [0.9.0](https://github.com/wayfair/brickkit-ios/tree/0.9.0) (2016-10-20)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*