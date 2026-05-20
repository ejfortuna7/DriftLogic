import UIKit

/// Makes Form/List cells transparent so the steelhead art background shows through.
enum DriftLogicAppearance {
    static func configure() {
        let clear = UIColor.clear

        UITableView.appearance().backgroundColor = clear
        UITableViewCell.appearance().backgroundColor = clear

        let grouped = UITableView.appearance(whenContainedInInstancesOf: [UIViewController.self])
        grouped.backgroundColor = clear

        UICollectionView.appearance().backgroundColor = clear
        UIScrollView.appearance().backgroundColor = clear
    }
}
