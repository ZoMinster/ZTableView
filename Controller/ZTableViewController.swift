//
//  ZTableViewController.swift
//  ZTableView
//
//  Created by 赖依娴 on 2024/5/21.
//

import UIKit

internal class ZTableViewController: ZTableViewDelegate {
    weak var delegate: ZTableViewDelegate?
    weak var tableView: ZTableView?
    var isFirstSetData: Bool = true
    var datas: [ZTableViewNodeProtocol] = [] {
        didSet {
            if let tv = tableView {
                if isFirstSetData {
                    tv.reloadData()
                    isFirstSetData = false
                }
                
            }
        }
    }
    var lastDatas: [ZTableViewNodeProtocol] = []
    var showingDatas: [ZTableViewNodeProtocol] = []
    
    
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: any UITableViewDropCoordinator) {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    func isEqual(_ object: Any?) -> Bool {
        <#code#>
    }
    
    var hash: Int = 0
    
    var superclass: AnyClass?
    
    func `self`() -> Self {
        <#code#>
    }
    
    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        <#code#>
    }
    
    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        <#code#>
    }
    
    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        <#code#>
    }
    
    func isProxy() -> Bool {
        <#code#>
    }
    
    func isKind(of aClass: AnyClass) -> Bool {
        <#code#>
    }
    
    func isMember(of aClass: AnyClass) -> Bool {
        <#code#>
    }
    
    func conforms(to aProtocol: Protocol) -> Bool {
        <#code#>
    }
    
    func responds(to aSelector: Selector!) -> Bool {
        <#code#>
    }
    
    var description: String = ""
    
    
}
