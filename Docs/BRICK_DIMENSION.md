# BrickDimension

## Width

A brick's width can be set using a `BrickDimension`. This allows you to set the width either by `Ratio` or `Fixed`

So if you set the width to `LabelBrick(width: .Ratio(ratio: 1/2))`, the width will be calculated as a fraction of its content view, in this case the main section
> When calculating the ratio, the layout will base its calculations on the width of its section minus the insets and edgeInsets
   
If the width is set to `LabelBrick(width: .Fixed(size: 50))`, the width will be exactly 50.

> The `BrickLayout` will add bricks until the screen is fully filled. `Ratio` and `Fixed` can be used together, but might give different results in portrait vs landscape. 

### Examples

The following code will create a label that is half the width of the view and its height will be dynamically based on the text that is inside of the label.

```
 -------------------------------------
 |   LABEL BRICK   |                 |
 -------------------------------------
```

```swift
let section = BrickSection(bricks: [
	LabelBrick(text: "LABEL BRICK", width: .Ratio(ratio: 1/2))
	])
}
```

---

Following code will put two labels next to eachother and each will be a half fraction of the containing view

```
 -------------------------------------
 |   LABEL BRICK 1 |   LABEL BRICK 2 |
 -------------------------------------
```

```swift
let section = BrickSection(bricks: [
	LabelBrick(text: "LABEL BRICK 1", width: .Ratio(ratio: 1/2)),
	LabelBrick(text: "LABEL BRICK 2", width: .Ratio(ratio: 1/2))
])
```

---

Following code will put two labels next to eachother but the seconds label will have a fixed width of 50px

```
 -------------------------------------
 |   LABEL BRICK 1 |  LABEL  |        |
 |                 | BRICK 2 |        |
 -------------------------------------
```

```swift
let section = BrickSection(bricks: [
	LabelBrick(text: "LABEL BRICK 1", width: .Ratio(ratio: 1/2)),
	LabelBrick(text: "LABEL BRICK 2", width: .Fixed(size: 50))
])
```

## Height

A brick's height can also be set using a `BrickDimension`. This allows you to set the height as `Auto`, `Ratio` or `Fixed`.

When set to `Auto` (default), the brick will calculate its height using AutoLayout. This will either come from the xib or the cell programatically
> Setting the height to `Auto`, you'll need to specify an estimate. Ideally this is a rough estimate of how height the This will optimize the calculation of the layout's calculations

When set to `Ratio`, the height of the brick will be a fraction of the width of the brick. So for instance, if the width is `.Ratio(ratio: 1/2)` and the height is `.Ratio(ratio: 1)`, the height will be the same size as the width (which will be half the size of its section)

When set to `Fixed`, the brick will have a fixed height

### Examples

Auto: The height will be calculated based on its content

```
 --------------------------------
 | LABEL BRICK LABEL BRICK LABEL |
 |       BRICK LABEL BRICK       |
 --------------------------------
```

```swift
let section = BrickSection(bricks: [
	LabelBrick(text: "LABEL BRICK", height: .Auto(estimate: .Fixed(size: 50)))
	])
}
```

---

Fixed: The height will be fixed to 50px, no matter how the constraints are layed out

```
 --------------------------------
 | LABEL BRICK LABEL BRICK LA... |
 --------------------------------
```

```swift
let section = BrickSection(bricks: [
	LabelBrick(text: "LABEL BRICK", height: .Fixed(size: 50))
	])
}
```

---

Ratio: The height will have the same width as the width of the brick

```
 --------------------------------
 |                               |
 |                               |
 |                               |
 | LABEL BRICK LABEL BRICK LABEL |
 |       BRICK LABEL BRICK       |
 |                               |
 |                               |
 |                               |
 --------------------------------
```

```swift
let section = BrickSection(bricks: [
	LabelBrick(text: "LABEL BRICK", height: .Ratio(ratio: 1))
	])
}
```

# BrickDimension - Advanced
A dimension can also be complex and defined by "rules". This approach allows us to be extendable in the future

## Fill

The value of the dimension is the remainder of the row

In this example, there will be an ImageBrick with a size of 50px. The width of the LabelBrick will be the remainder of the width.
So if the screen is 320px, the LabelBrick will have a width of 270px

```swift
let section = BrickSection(bricks: [
	ImageBrick(width: .Fixed(size: 50)),
	LabelBrick(width: .Fill)
])
```

> Fill is only supported for `width`

## Orientation(landscape: BrickDimension, portrait: BrickDimension)
The value of the dimension is determined by the orientation of the device.

In this example, there will be 2 bricks per row in portrait and 3 bricks per row in landscape

```swift
let width: BrickDimension = .Orientation(landscape: .Ratio(ratio: 1/3), portrait: .Ratio(ratio: 1/2))
```

## HorizontalSizeClass(regular: BrickDimension, compact: BrickDimension)
The value of the dimension is determined by the horizontal size class of the view.

In this example, there will be 2 bricks per row in a regular trait class and 1 brick per row in a compact trait class

```swift
let width: BrickDimension = .HorizontalSizeClass(regular: .Ratio(ratio: 1/2), compact: .Ratio(ratio: 1))
```

## VerticalSizeClass(regular: BrickDimension, compact: BrickDimension)
The value of the dimension is determined by the vertical size class of the view.

In this example, there will be 2 bricks per row in a regular trait class and 1 brick per row in a compact trait class

```swift
let width: BrickDimension = . VerticalSizeClass(regular: .Ratio(ratio: 1/2), compact: .Ratio(ratio: 1))
```

## Mix and match
It's possible to mix and match the different type of BrickDimensions.

In this example, the width depends on the size class. If it's regular and landscape, there will be 3 bricks per row and in portrait, 2 per row. If the size class is compact, it always shows just 1 brick per row
 
```swift
let width: BrickDimension =
    .HorizontalSizeClass(
        regular: .Orientation(
            landscape: .Ratio(ratio: 1/3),
            portrait: .Ratio(ratio: 1/2)
        ),
        compact: .Ratio(ratio: 1)
        )

```
