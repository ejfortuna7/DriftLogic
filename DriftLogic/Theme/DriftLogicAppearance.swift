import UIKit

/// Makes Form/List cells transparent so the steelhead art background shows through.
enum DriftLogicAppearance {
    static func configure() {
        let clear = UIColor.clear

        UITableView.appearance().backgroundColor = clear
        UITableViewCell.appearance().backgroundColor = clear

        // Prevent grouped Form rows from clipping the first characters of custom content.
        let cellMargins = UIEdgeInsets(top: 11, left: 20, bottom: 11, right: 20)
        UITableViewCell.appearance().layoutMargins = cellMargins
        UITableViewCell.appearance().preservesSuperviewLayoutMargins = true
        UITableViewCell.appearance().separatorInset = UIEdgeInsets(
            top: 0, left: cellMargins.left, bottom: 0, right: cellMargins.right
        )

        let grouped = UITableView.appearance(whenContainedInInstancesOf: [UIViewController.self])
        grouped.backgroundColor = clear

        UICollectionView.appearance().backgroundColor = clear
        UIScrollView.appearance().backgroundColor = clear
    }
}
