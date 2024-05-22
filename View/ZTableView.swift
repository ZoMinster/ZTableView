//
//  ZTableView.swift
//  ZTableView
//
//  Created by 赖依娴 on 2024/5/19.
//

import UIKit



open class ZTableView: UITableView, UITableViewDelegate {
    public enum ZTableViewExpansionType {
        case multiple
        case single
    }
    open var expansionAnimation: UITableView.RowAnimation = .top
    open var expansionType: ZTableViewExpansionType = .multiple
    open var datas: [ZTableViewNodeProtocol] = [] {
        didSet {
            controller.datas = datas
        }
    }
    open var autoSolveDataSource: Bool = true
    open weak var zDelegate: ZTableViewDelegate? {
        didSet {
            controller.delegate = self.zDelegate
            self.delegate = controller
            self.dataSource = controller
            self.dragDelegate = controller
            self.dropDelegate = controller
        }
    }
    
    internal var controller: ZTableViewController = ZTableViewController()
    override public init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        controller.tableView = self
        self.register(ZTableViewCell.self, forCellReuseIdentifier: zCellID)
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        controller.tableView = self
    }
}
