//
//  ZTableViewNode.swift
//  ZTableView
//
//  Created by 赖依娴 on 2024/5/19.
//

import UIKit

public protocol ZTableViewNodeProtocol {
    var title: String {get set}
    var isSection: Bool {get set}
    var expanded: Bool {get set}
    var index: Int {get set}
    var depth: Int {get set}
    var indexPath: IndexPath {get set}
    var children: [ZTableViewNodeProtocol] {get set}
}
