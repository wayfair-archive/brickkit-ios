
import UIKit
import BrickKit

class SegmentHeaderBrick: Brick {
    weak var dataSource: SegmentHeaderBrickDataSource?
    weak var delegate: SegmentHeaderBrickDelegate?

    init(_ identifier: String = "", width: BrickDimension = .ratio(ratio: 1), height: BrickDimension = .auto(estimate: .fixed(size: 100)), backgroundColor: UIColor = UIColor.clear, backgroundView: UIView? = nil, dataSource: SegmentHeaderBrickDataSource? = nil, delegate: SegmentHeaderBrickDelegate? = nil) {
        self.dataSource = dataSource
        self.delegate = delegate
        super.init(identifier, size: BrickSize(width: width, height: height), backgroundColor: backgroundColor, backgroundView: backgroundView)
    }
}

class SegmentHeaderBrickCell: BrickCell, Bricklike {
    typealias BrickType = SegmentHeaderBrick
    
    @IBOutlet weak var segmentControl: UISegmentedControl!

    @IBAction func didSelectIndex(_ sender: AnyObject) {
        self.brick.delegate?.segementHeaderBrickCell(cell: self, didSelectIndex: segmentControl.selectedSegmentIndex)
    }

    override func updateContent() {
        super.updateContent()

        guard let dataSource = self.brick.dataSource else {
            return
        }

        dataSource.configure(cell: self)

        self.segmentControl.removeAllSegments()
        for (index, title) in dataSource.titles.enumerated() {
            self.segmentControl.insertSegment(withTitle: title, at: index, animated: false)
        }
        self.segmentControl.selectedSegmentIndex = dataSource.selectedSegmentIndex
    }
}

protocol SegmentHeaderBrickDataSource: class {
    var titles: [String] { get }
    var selectedSegmentIndex: Int { get }

    func configure(cell: SegmentHeaderBrickCell)
}

extension SegmentHeaderBrickDataSource {
    func configure(cell: SegmentHeaderBrickCell) {/*Optional*/}
}

protocol SegmentHeaderBrickDelegate: class {
    func segementHeaderBrickCell(cell: SegmentHeaderBrickCell, didSelectIndex index: Int)
}
