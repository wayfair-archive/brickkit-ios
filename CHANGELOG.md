# Change Log

## [1.3.1](https://github.com/wayfair/brickkit-ios/tree/1.3.1) (2017-03-22)
[Full Changelog](https://github.com/wayfair/brickkit-ios/compare/1.3.0...1.3.1)

**Closed issues:**

- Bricks are offscreen [\#104](https://github.com/wayfair/brickkit-ios/issues/104)

**Merged pull requests:**

- Removed a line that modified an attribute’s height [\#112](https://github.com/wayfair/brickkit-ios/pull/112) ([willspurgeon](https://github.com/willspurgeon))

## [1.3.0](https://github.com/wayfair/brickkit-ios/tree/1.3.0) (2017-03-09)
[Full Changelog](https://github.com/wayfair/brickkit-ios/compare/1.2.1...1.3.0)

**Closed issues:**

- Brick's height is not updated correctly when invalidating repeat count [\#101](https://github.com/wayfair/brickkit-ios/issues/101)

**Merged pull requests:**

- SectionAttributes weren’t updated [\#105](https://github.com/wayfair/brickkit-ios/pull/105) ([rubencagnie](https://github.com/rubencagnie))
- Fix severe memory leak when using async resizable cells [\#103](https://github.com/wayfair/brickkit-ios/pull/103) ([klundberg](https://github.com/klundberg))
- Fixed invalidateRepeatCounts [\#102](https://github.com/wayfair/brickkit-ios/pull/102) ([rubencagnie](https://github.com/rubencagnie))

## [1.2.1](https://github.com/wayfair/brickkit-ios/tree/1.2.1) (2017-03-02)
[Full Changelog](https://github.com/wayfair/brickkit-ios/compare/1.2.0...1.2.1)

**Closed issues:**

- Bricks get unexpected heights [\#97](https://github.com/wayfair/brickkit-ios/issues/97)

**Merged pull requests:**

- Fix imagebrick closure [\#100](https://github.com/wayfair/brickkit-ios/pull/100) ([butkis93](https://github.com/butkis93))

## [1.2.0](https://github.com/wayfair/brickkit-ios/tree/1.2.0) (2017-03-02)
[Full Changelog](https://github.com/wayfair/brickkit-ios/compare/1.1.3...1.2.0)

**Closed issues:**

- Allow a Brick to hide individually [\#93](https://github.com/wayfair/brickkit-ios/issues/93)
- BrickSection should know what bricks/nibs to register [\#90](https://github.com/wayfair/brickkit-ios/issues/90)
- ImageView goes blank [\#88](https://github.com/wayfair/brickkit-ios/issues/88)
- Content offset for scrolling bricks upward needed [\#84](https://github.com/wayfair/brickkit-ios/issues/84)
- SnapToPointLayoutBehavior does not always ignore the overall CollectionBrick section [\#82](https://github.com/wayfair/brickkit-ios/issues/82)

**Merged pull requests:**

- Removed customHeightProvider [\#98](https://github.com/wayfair/brickkit-ios/pull/98) ([rubencagnie](https://github.com/rubencagnie))
- Update image brick delegate to pass back the corresponding image bric… [\#96](https://github.com/wayfair/brickkit-ios/pull/96) ([butkis93](https://github.com/butkis93))
- isHidden property on Brick [\#94](https://github.com/wayfair/brickkit-ios/pull/94) ([rubencagnie](https://github.com/rubencagnie))
- contentOffsetAdjustment on height change [\#92](https://github.com/wayfair/brickkit-ios/pull/92) ([rubencagnie](https://github.com/rubencagnie))
- Add `nibIdentifiers` to the BrickSection [\#91](https://github.com/wayfair/brickkit-ios/pull/91) ([rubencagnie](https://github.com/rubencagnie))
- Fixes GenericBrickCell by reusing view [\#89](https://github.com/wayfair/brickkit-ios/pull/89) ([rubencagnie](https://github.com/rubencagnie))
- Fixed generic brick [\#86](https://github.com/wayfair/brickkit-ios/pull/86) ([butkis93](https://github.com/butkis93))
- Fixed a bug that prevented the SnapToPointLayoutBehavior from filteri… [\#83](https://github.com/wayfair/brickkit-ios/pull/83) ([willspurgeon](https://github.com/willspurgeon))

## [1.1.3](https://github.com/wayfair/brickkit-ios/tree/1.1.3) (2017-02-14)
[Full Changelog](https://github.com/wayfair/brickkit-ios/compare/1.1.2...1.1.3)

## [1.1.2](https://github.com/wayfair/brickkit-ios/tree/1.1.2) (2017-02-14)
[Full Changelog](https://github.com/wayfair/brickkit-ios/compare/1.1.1...1.1.2)

**Closed issues:**

- GenericBrickCell is setting `backgroundColor` wrong [\#80](https://github.com/wayfair/brickkit-ios/issues/80)

## [1.1.1](https://github.com/wayfair/brickkit-ios/tree/1.1.1) (2017-02-13)
[Full Changelog](https://github.com/wayfair/brickkit-ios/compare/1.1.0...1.1.1)

**Closed issues:**

- invalidateRepeatCounts causes duplicate loading of newly added bricks [\#55](https://github.com/wayfair/brickkit-ios/issues/55)

**Merged pull requests:**

- Moved place where generic brick background color is set to clear [\#81](https://github.com/wayfair/brickkit-ios/pull/81) ([rubencagnie](https://github.com/rubencagnie))

## [1.1.0](https://github.com/wayfair/brickkit-ios/tree/1.1.0) (2017-02-10)
[Full Changelog](https://github.com/wayfair/brickkit-ios/compare/1.0.0...1.1.0)

**Closed issues:**

- Width ratio doesn't always work on iPad [\#77](https://github.com/wayfair/brickkit-ios/issues/77)
- Default ButtonBrick doesn't call `didTapOnButtonForButtonBrickCell`  [\#75](https://github.com/wayfair/brickkit-ios/issues/75)
- ImageBrick - Image is added on main thread [\#72](https://github.com/wayfair/brickkit-ios/issues/72)
- Bricks are not always displayed [\#70](https://github.com/wayfair/brickkit-ios/issues/70)
- Vertically Center Bricks in a BrickSection [\#69](https://github.com/wayfair/brickkit-ios/issues/69)
- LabelBrick should inherit from GenericBrick\<UILabel\> [\#66](https://github.com/wayfair/brickkit-ios/issues/66)
- Generic Brick [\#64](https://github.com/wayfair/brickkit-ios/issues/64)
- Move public functions in extensions into its respective class declaration [\#56](https://github.com/wayfair/brickkit-ios/issues/56)

**Merged pull requests:**

- Optimized brick calculation [\#78](https://github.com/wayfair/brickkit-ios/pull/78) ([rubencagnie](https://github.com/rubencagnie))
- Fixed ButtonBrick by adding action to UIButton [\#76](https://github.com/wayfair/brickkit-ios/pull/76) ([rubencagnie](https://github.com/rubencagnie))
- Horizontal and Vertical BrickAlignment [\#74](https://github.com/wayfair/brickkit-ios/pull/74) ([rubencagnie](https://github.com/rubencagnie))
- Add function to ImageDownloader protocol [\#73](https://github.com/wayfair/brickkit-ios/pull/73) ([rubencagnie](https://github.com/rubencagnie))
- Fixed operator order for continueCalculatingCells [\#71](https://github.com/wayfair/brickkit-ios/pull/71) ([rubencagnie](https://github.com/rubencagnie))
- Bug fix collection brick content offset calculation [\#68](https://github.com/wayfair/brickkit-ios/pull/68) ([wfsttam](https://github.com/wfsttam))
- Extend Label/Button/Image-Brick from GenericBrick [\#67](https://github.com/wayfair/brickkit-ios/pull/67) ([rubencagnie](https://github.com/rubencagnie))

## [1.0.0](https://github.com/wayfair/brickkit-ios/tree/1.0.0) (2017-01-26)
[Full Changelog](https://github.com/wayfair/brickkit-ios/compare/0.9.7...1.0.0)

**Closed issues:**

- Add support for UIAccessibility [\#59](https://github.com/wayfair/brickkit-ios/issues/59)

**Merged pull requests:**

- GenericBrick [\#65](https://github.com/wayfair/brickkit-ios/pull/65) ([rubencagnie](https://github.com/rubencagnie))
- Added changing the default nib [\#62](https://github.com/wayfair/brickkit-ios/pull/62) ([jay18001](https://github.com/jay18001))

## [0.9.7](https://github.com/wayfair/brickkit-ios/tree/0.9.7) (2017-01-12)
[Full Changelog](https://github.com/wayfair/brickkit-ios/compare/0.9.6...0.9.7)

**Closed issues:**

- Have BrickCells display different views based on appearance state [\#46](https://github.com/wayfair/brickkit-ios/issues/46)

**Merged pull requests:**

- Add UIAccessibility properties to Brick class to pass along to BrickC… [\#61](https://github.com/wayfair/brickkit-ios/pull/61) ([joleary1987](https://github.com/joleary1987))
- Provide a way to override brick cell content after the updateContent [\#58](https://github.com/wayfair/brickkit-ios/pull/58) ([wfsttam](https://github.com/wfsttam))
- Fixed Image brick when the readding it to the section [\#54](https://github.com/wayfair/brickkit-ios/pull/54) ([jay18001](https://github.com/jay18001))

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