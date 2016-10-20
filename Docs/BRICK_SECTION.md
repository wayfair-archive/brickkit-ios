# BrickSection
A `BrickSection` groups bricks together. The height of the section is calculated based on the bricks inside of it _plus_ the edge insets.

A `BrickSection` has the following properties:

- bricks: An array of bricks that needs to be displayed on screen 
- inset: The distance (in pixels) between the bricks
- edgeInsets: The top/left/bottom/right distances that are around the edges of the sections

## Examples

```
let section = BrickSection(bricks: [
	LabelBrick(text: "Hello"),
	LabelBrick(text: "World")
], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
```

```
 --------------------------------
 |             20px             |
 |                              |
 |       ---------------        |
 | 20px  |    HELLO     |  20px |
 |       ---------------        |
 |             10px             |
 |       ---------------        |
 | 20px  |    WORLD     |  20px |
 |       ---------------        |
 |                              |
 |             20px             |
 --------------------------------
```


# Nested BrickSections
As a `BrickSection` is a subclass of `Brick`, you can nest the sections. 
> If you define a `.Ratio` width for a brick, it will always be a fraction of the BrickSection the brick is in. So a brick with a `.Ratio(ratio: 1/2)` width, contained in a section that has a `.Fixed(size: 50)` width, will result in the Brick being 25px

## Examples

```
let section = BrickSection(bricks: [
	LabelBrick(width: .Ratio(ratio: 1/2), text: "Hello"),
	BrickSection(width: .Ratio(ratio: 1/2), bricks: [
		LabelBrick(width: .Ratio(ratio: 1), text: "World"),
		LabelBrick(width: .Ratio(ratio: 1/2), text: "World"),
		LabelBrick(width: .Ratio(ratio: 1/2), text: "World")
	])
])
```

```
 ---------------------------------------
 |      HELLO      |       WORLD       |
 |                 |  WORLD  |  WORLD  |
 ---------------------------------------
```