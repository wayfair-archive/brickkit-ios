//
//  ViewController.swift
//  BrickDemoApp
//
//  Created by Yusheng Yang on 9/19/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit
import BrickKit

class TwitterDataProvider {

    var numberOfItems: Int {
        return 5
    }

    func item(at index: Int) -> [String: String]{
        let item = ["profile_image": "profile_image", "profile_name": "wayfair", "post_text": "akfhbajshkdbfsjdkhbgajhbgigfnfghnfghnfghndgfbnfgbdfgbftghnfnfhnfghnfghnfghnreioeabgoia", "post_image": "post_image"]

        return item
    }


    func whoToFollow(at index: Int) -> [String: String]? {
        return nil
    }
}


class MockTwitterViewController: BrickViewController, HasTitle {
    
    class var brickTitle: String {
        return "Twitter"
    }
    class var subTitle: String {
        return "Wayfair Twitter HomePage"
    }

    struct Identifiers {
        static let postBrick = "PostBrick"
        static let dailySalesHeader = "DailySalesHeader"
        static let dailySalesBrick = "DailySalesBrick"
        static let whoToFollowHeaderBrick = "whoToFollowHeaderBrick"
        static let whoToFollowBrick = "WhoToFollowBrick"
        static let profileHeaderBrick = "ProfileHeaderBrick"
        static let profileImageBrick = "ProfileImageBrick"
        static let segmentHeaderBrick = "SegmentHeaderBrick"
    }

    var behavior: BrickLayoutBehavior?
    var topView: UIView!
    
    let dataProvider = TwitterDataProvider()
    var postBrick: PostBrick!
    var collectionBrickDataSource: BrickCollectionViewDataSource!

    lazy var stickyBehavior: StickyLayoutBehavior = StickyLayoutBehavior(dataSource: self)
    lazy var minimumStickyBehavior: StickyLayoutBehavior = MinimumStickyLayoutBehavior(dataSource: self)

    var titleView: UIView!
    var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .brickBackground

        setupTitleView()
        registerBricks()

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "AddFriend"), style: .plain, target: self, action: #selector(MockTwitterViewController.backAction))

        brickCollectionView.layout.behaviors.insert(stickyBehavior)
        brickCollectionView.layout.behaviors.insert(minimumStickyBehavior)

        let mainSection = BrickSection(bricks: [
            setUpProfileHeaderSection(),
            SegmentHeaderBrick(MockTwitterViewController.Identifiers.segmentHeaderBrick, backgroundColor: UIColor.white),
            setupTextAndImageSection(),
            setWhotoFollowSection(),
            setupTextAndImageSection(),
            setupHorizontalScrollSection(),
            setupTextAndImageSection()
            ])
        
        self.brickCollectionView.setSection(mainSection)
    }

    func setupTitleView() {
        titleView = UIView(frame: self.navigationController?.navigationBar.frame ?? .zero)
        titleView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleView.clipsToBounds = true

        titleLabel = UILabel(frame: titleView.frame)
        titleLabel.text = "Wayfair"
        titleLabel.textAlignment = .center
        titleLabel.isHidden = true
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        titleView.addSubview(titleLabel)
        self.navigationItem.titleView = titleView
    }
    
    func registerBricks() {
        self.brickCollectionView.registerBrickClass(CollectionBrick.self)
        self.brickCollectionView.registerBrickClass(PostBrick.self)
        self.brickCollectionView.registerBrickClass(DailySalesBrick.self)
        self.brickCollectionView.registerBrickClass(WhoToFollowBrick.self)
        self.brickCollectionView.registerBrickClass(HeaderAndFooterBrick.self)
        self.brickCollectionView.registerNib(UINib(nibName: "ProfileHeaderBrick", bundle: nil), forBrickWithIdentifier: MockTwitterViewController.Identifiers.profileHeaderBrick)
        self.brickCollectionView.registerNib(UINib(nibName: "ProfileImageBrick", bundle: nil), forBrickWithIdentifier: MockTwitterViewController.Identifiers.profileImageBrick)
        registerBrickClass(SegmentHeaderBrick.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setUpProfileHeaderSection() -> BrickSection {
        let profileModel = ProfileHeaderModel(name: "Wayfair", handle: "@wayfair", description: "A Zillion tweets about everything home. Support hours are from 9am-5pm EST 7 days a week! For help outside of these hours, comtact service@wayfair.com", numberOfFollowing: 12345, numberOfFollowers: 54321)
        let imageModel = ProfileImageBrickModel(image: UIImage(named: "wayfair")!)
        let section = BrickSection(bricks: [
            BrickSection(bricks: [
                ProfileImageBrick(MockTwitterViewController.Identifiers.profileImageBrick, model: imageModel),
                ]),
            ProfileHeaderBrick(MockTwitterViewController.Identifiers.profileHeaderBrick, model: profileModel)
            ])
        return section
    }
    
    func setupTextAndImageSection() -> BrickSection {
        postBrick = PostBrick(MockTwitterViewController.Identifiers.postBrick, backgroundColor: UIColor.white, dataSource: self)
        let section = BrickSection(backgroundColor: UIColor.lightGray, bricks: [postBrick], inset: 1, edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0))
        section.repeatCountDataSource = self

        return section
    }
  
    func setupHorizontalScrollSection() -> BrickSection {
        let friendsRefBrick = DailySalesBrick(MockTwitterViewController.Identifiers.dailySalesBrick, width: .fixed(size: 140), height: .fixed(size: 140), backgroundColor: UIColor.white, dataSource: self)
        
        collectionBrickDataSource = BrickCollectionViewDataSource()
        let salesSection = BrickSection(bricks: [
            friendsRefBrick
            ], inset:2)
        salesSection.repeatCountDataSource = self
        collectionBrickDataSource!.setSection(salesSection)
        
        let section = BrickSection(width: .ratio(ratio: 1), backgroundColor: UIColor.lightGray, bricks: [
            HeaderAndFooterBrick(MockTwitterViewController.Identifiers.dailySalesHeader, width: .ratio(ratio: 1), /*height: .fixed(size: 40),*/ backgroundColor: UIColor.white, backgroundView: nil){ cell in
                cell.textLabel.text = "Daily Sales"
            },
            CollectionBrick(/*height: .fixed(size: 140), */scrollDirection: .horizontal, dataSource: self, brickTypes: [DailySalesBrick.self])
            ], inset: 1, edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0))
        section.repeatCountDataSource = self


        return section
    }
    
    func setWhotoFollowSection() -> BrickSection {
        let whoToFollowBrick = WhoToFollowBrick(MockTwitterViewController.Identifiers.whoToFollowBrick, backgroundColor: UIColor.white, dataSource: self)
        
        let headerAndFooterBrick = HeaderAndFooterBrick(MockTwitterViewController.Identifiers.whoToFollowHeaderBrick, backgroundColor: UIColor.white) { cell in
            cell.textLabel.text = "Who To Follow"
        }
        
        let section = BrickSection(backgroundColor: UIColor.lightGray, bricks: [headerAndFooterBrick, whoToFollowBrick], inset: 1, edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0))
        section.repeatCountDataSource = self

        return section
    }
    
    @objc func backAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

extension MockTwitterViewController: PostBrickCellDataSource {
    
    func textImageBrickProfile(cell: PostBrickCell) -> UIImage {
            return UIImage(named: "wayfair")!
    }
    func textImageBrickName(cell: PostBrickCell) -> String {
        return "Wayfair"
    }
    func textImageBrickText(cell: PostBrickCell) -> String {
        return "The Real reason why humans run the world!"
    }
    func textImageBrickImage(cell: PostBrickCell) -> UIImage {
        let index = cell.index
        return UIImage(named: "image\(index).png")!
    }
    
    func textImageBrickAtTag(cell: PostBrickCell) ->String {
        return "Wayfair"
    }
}

extension MockTwitterViewController: DailySalesBrickDataSource {
    func image(cell: DailySalesBrickCell) -> UIImage {
        let index = cell.index
        return UIImage(named: "image\(index).png")!
    }
    func buttonTitle(cell: DailySalesBrickCell) -> String {
        return "Buy"
    }
}

extension MockTwitterViewController: WhoToFollowBrickDataSource {
    func whoToFollowImage(cell: WhoToFollowBrickCell) -> UIImage {
        return UIImage(named: "wayfair")!
    }
    
    func whoToFollowTitle(cell: WhoToFollowBrickCell) -> String {
        return "Wayfair"
    }
    func whoToFollowDescription(cell: WhoToFollowBrickCell) -> String {
        return "The Real reason why humans run the world!"
    }
    
    func whoToFollowAtTag(cell: WhoToFollowBrickCell) -> String{
        return "Wayfair"
    }
}

extension MockTwitterViewController: CollectionBrickCellDataSource {
    
    func configure(for brickCollectionCell: CollectionBrickCell) {
        
        brickCollectionCell.brickCollectionView.delegate = self
      //  brickCollectionCell.brickCollectionView.pagingEnabled = false
        brickCollectionCell.brickCollectionView.showsHorizontalScrollIndicator = true
    }
    
    func dataSourceForCollectionBrickCell(brickCollectionCell: CollectionBrickCell) -> BrickCollectionViewDataSource {
        return collectionBrickDataSource
    }
}

extension MockTwitterViewController: BrickRepeatCountDataSource {
    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        if identifier == MockTwitterViewController.Identifiers.postBrick {
            return 5
        } else if identifier == MockTwitterViewController.Identifiers.dailySalesBrick {
            return 5
        } else if identifier == MockTwitterViewController.Identifiers.whoToFollowBrick {
            return 4
        }
        
        return 1
    }
}

extension MockTwitterViewController: MinimumStickyLayoutBehaviorDataSource {
    func stickyLayoutBehavior(_ behavior: StickyLayoutBehavior, minimumStickingHeightForItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGFloat? {
        return 30
    }
}

extension MockTwitterViewController: StickyLayoutBehaviorDataSource {
    func stickyLayoutBehavior(_ stickyLayoutBehavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        if stickyLayoutBehavior == minimumStickyBehavior {
            return identifier == MockTwitterViewController.Identifiers.profileImageBrick
        } else {
            switch identifier {
            case MockTwitterViewController.Identifiers.whoToFollowHeaderBrick, MockTwitterViewController.Identifiers.dailySalesHeader, MockTwitterViewController.Identifiers.segmentHeaderBrick:
                return true
            default: return false
            }
        }
    }
}

extension MockTwitterViewController: StickyLayoutBehaviorDelegate {
    func stickyLayoutBehavior(_ behavior: StickyLayoutBehavior, brickIsStickingWithPercentage percentage: CGFloat, forItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) {
        print(percentage)
    }
}

extension MockTwitterViewController {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard let navigationBar = self.navigationController?.navigationBar else {
            return
        }

        guard let indexPath = brickCollectionView.indexPathsForBricksWithIdentifier(MockTwitterViewController.Identifiers.profileHeaderBrick).first else {
            return
        }

        guard let cell = brickCollectionView.cellForItem(at: indexPath) as? ProfileHeaderBrickCell else {
            return
        }


        let frame = cell.nameLabel.superview!.convert(cell.nameLabel.frame, to: self.brickCollectionView)

        let difference = brickCollectionView.contentOffset.y + brickCollectionView.contentInset.top - frame.origin.y

        if difference < 0 {
            titleLabel.isHidden = true
        } else {
            titleLabel.isHidden = false
            titleLabel.frame.size.height = cell.nameLabel.frame.size.height
            titleLabel.font = cell.nameLabel.font
            titleLabel.text = cell.nameLabel.text

            titleLabel.textColor = .brickGray1

            let centerY = navigationBar.frame.height - difference + (titleLabel.frame.height / 2)
            titleLabel.center.y = max(titleView.frame.height / 2, centerY)
        }
    }
}
