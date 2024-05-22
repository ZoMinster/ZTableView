//
//  ZTableViewNode.swift
//  ZTableView
//
//  Created by 赖依娴 on 2024/5/19.
//

import UIKit
import Foundation

public protocol ZTableViewNodeCopyable {
    func copy() -> ZTableViewNodeProtocol
}

public protocol ZTableViewNodeProtocol: ZTableViewNodeCopyable {
    var key: String {get set}
    var footerTitle: String? {get set}
    var isSectionHeader: Bool {get set} //only first node significant, if first node is section header, all first level node are section header
    var expanded: Bool {get set}
    var index: Int {get set}
    var depth: Int {get set}
    var children: [ZTableViewNodeProtocol] {get set}
    var indexPath: IndexPath {get set}
    var showingChildren: [ZTableViewNodeProtocol] {get set}
    init()
}
