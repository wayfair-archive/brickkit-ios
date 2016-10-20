# CollectionBrick

A `CollectionBrick` can be used for two purposes:

- Show bricks with a different scrolldirection
> For example when you main BrickCollectionView scrolls vertically, but you want to have some bricks scroll horizontally

- Create a brick that is constructed out of other bricks

## Different scroll direction

| Variable   |      Class      |  Description |
|----------|:-------------:|------:|
| scrollDirection |  UICollectionViewScrollDirection | Used for identifying the scroll direction of the collectionview (default: .Vertically) |
| dataSource |    CollectionBrickCellDataSource   |   DataSource that is needed to show content in the CollectionBrick |

## CollectionBrickCellDataSource

An object that adopts the `CollectionBrickCellDataSource` protocol is responsible for providing the data required by a `CollectionBrick`.

