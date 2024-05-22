//
//  ZTableViewController.swift
//  ZTableView
//
//  Created by 赖依娴 on 2024/5/21.
//

import UIKit

internal let zCellID = "z.cell.id.default"

internal class ZTableViewController: ZTableViewDelegate {
    weak var delegate: ZTableViewDelegate?
    weak var tableView: ZTableView?
    var hasSectionHeader: Bool = false
    var datas: [ZTableViewNodeProtocol] = [] {
        didSet {
            self.solveDatas()
        }
    }
    var lastDatas: [ZTableViewNodeProtocol] = []
    var showingDatas: [ZTableViewNodeProtocol] = []
    
    func solveDatas() {
        showingDatas = []
        if datas.isEmpty {
            return
        }
        hasSectionHeader = datas.first!.isSectionHeader
        var parentDic = [String:ZTableViewNodeProtocol]()
        var zdatas: [ZTableViewNodeProtocol] = []
        zdatas += datas
        var firstLevelIndex = 0
        while(!zdatas.isEmpty) {
            var node = zdatas.first!
            zdatas.removeFirst()
            if node.key.isEmpty {
                node.index = firstLevelIndex
                firstLevelIndex += 1
                node.key = "\(node.index)"
            }
            var parent = parentDic[node.key]
            if parent == nil {
                node.depth = 0
            } else {
                node.depth = parent!.depth + 1
            }
            if node.children.isEmpty {
                continue
            }
            var index = 0
            for var subNode in node.children {
                subNode.index = index
                index += 1
                subNode.key = "\(node.key).\(subNode.index)"
                parentDic[subNode.key] = node
                zdatas.append(subNode)
            }
        }
        if !hasSectionHeader {
            let sectionIndex = 0
            var rowIndex = 0
            zdatas += datas
            while(!zdatas.isEmpty){
                var node = zdatas.first!
                zdatas.removeFirst()
                node.indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                rowIndex += 1
                showingDatas.append(node)
                if node.children.isEmpty || !node.expanded {
                    continue
                }
                var children = node.children.reversed()
                for subNode in children {
                    zdatas.insert(subNode, at: 0)
                }
            }
        } else {
            var tShowingDatas = [ZTableViewNodeProtocol]()
            for section in datas {
                tShowingDatas.append(section.copy())
            }
            var sectionIndex = 0
            var rowIndex = 0
            for var section in tShowingDatas {
                if section.children.isEmpty || !section.expanded {
                    section.children.removeAll()
                    showingDatas.append(section.copy())
                    continue
                }
                zdatas += section.children
                var currentSection = section.copy()
                currentSection.children.removeAll()
                currentSection.indexPath = IndexPath(row: 0, section: sectionIndex)
                rowIndex = 0
                while(!zdatas.isEmpty) {
                    var node = zdatas.first!
                    zdatas.removeFirst()
                    node.indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                    currentSection.children.append(node)
                    rowIndex += 1
                    if node.children.isEmpty || !node.expanded {
                        continue
                    }
                    var children = node.children.reversed()
                    for subNode in children {
                        zdatas.insert(subNode, at: 0)
                    }
                }
                showingDatas.append(currentSection)
                sectionIndex += 1
            }
        }
        
        
        
    }
    
    
    // MARK: tableview data source
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.tableView!.autoSolveDataSource) {
            return showingDatas[section].children.count
        }
        guard let rows = delegate?.tableView?(tableView, numberOfRowsInSection: section) else {
            return 0
        }
        return rows
    }
    
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    @available(iOS 8.0, *)
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = delegate?.tableView?(tableView, cellForRowAt: indexPath) else {
            return tableView.dequeueReusableCell(withIdentifier: zCellID, for: indexPath)
        }
        return cell
    }
    
    
    @available(iOS 2.0, *)
    internal func numberOfSections(in tableView: UITableView) -> Int {
        // Default is 1 if not implemented
        if (self.tableView!.autoSolveDataSource) {
            return showingDatas.count
        }
        guard let sections = delegate?.numberOfSections?(in: tableView) else {
            return 1
        }
        return sections
    }
    
    
    @available(iOS 2.0, *)
    internal func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // fixed font style. use custom view (UILabel) if you want something different
        guard let title = delegate?.tableView?(tableView, titleForHeaderInSection: section) else {
            if hasSectionHeader {
                return showingDatas[section].key
            } else {
                return nil
            }
        }
        return title
    }
    
    @available(iOS 2.0, *)
    internal func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let title = delegate?.tableView?(tableView, titleForFooterInSection: section) else {
            return showingDatas[section].footerTitle
        }
        return title
    }
    
    
    // Editing

    // Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
    @available(iOS 8.0, *)
    internal func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let flag = delegate?.tableView?(tableView, canEditRowAt: indexPath) else {
            return false
        }
        return flag
    }
    
    
        // Moving/reordering
    
        // Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
    @available(iOS 8.0, *)
    internal func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        guard let flag = delegate?.tableView?(tableView, canMoveRowAt: indexPath) else {
            return false
        }
        return flag
    }
    
    
        // Index
    
    @available(iOS 2.0, *)
    internal func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        // return list of section titles to display in section index view (e.g. "ABCD...Z#")
        guard let titles = delegate?.sectionIndexTitles?(for: tableView) else {
            return showingDatas.map({$0.key})
        }
        return titles
    }
    
    @available(iOS 2.0, *)
    internal func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        // tell table which section corresponds to section title/index (e.g. "B",1))
        guard let section = delegate?.tableView?(tableView, sectionForSectionIndexTitle:title, at:index) else {
            return index
        }
        return section
    }
    
    
    // Data manipulation - insert and delete support

    // After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
    // Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
    @available(iOS 8.0, *)
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        delegate?.tableView?(tableView, commit:editingStyle, forRowAt: indexPath)
    }
    
    
    // Data manipulation - reorder / moving support
    @available(iOS 8.0, *)
    internal func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        delegate?.tableView?(tableView, moveRowAt:sourceIndexPath, to: destinationIndexPath)
    }
    
    // MARK: tableview scroll delegate
    @available(iOS 2.0, *)
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // any offset changes
        delegate?.scrollViewDidScroll?(scrollView)
    }
    
    @available(iOS 3.2, *)
    optional func scrollViewDidZoom(_ scrollView: UIScrollView) // any zoom scale changes
    
    
        // called on start of dragging (may require some time and or distance to move)
    @available(iOS 2.0, *)
    optional func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    
        // called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    @available(iOS 5.0, *)
    optional func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    
        // called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    @available(iOS 2.0, *)
    optional func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    
    
    @available(iOS 2.0, *)
    optional func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) // called on finger up as we are moving
    
    @available(iOS 2.0, *)
    optional func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) // called when scroll view grinds to a halt
    
    
    @available(iOS 2.0, *)
    optional func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
    
    
    @available(iOS 2.0, *)
    optional func viewForZooming(in scrollView: UIScrollView) -> UIView? // return a view that will be scaled. if delegate returns nil, nothing happens
    
    @available(iOS 3.2, *)
    optional func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) // called before the scroll view begins zooming its content
    
    @available(iOS 2.0, *)
    optional func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) // scale between minimum and maximum. called after any 'bounce' animations
    
    
    @available(iOS 2.0, *)
    optional func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool // return a yes if you want to scroll to the top. if not defined, assumes YES
    
    @available(iOS 2.0, *)
    optional func scrollViewDidScrollToTop(_ scrollView: UIScrollView) // called when scrolling animation finished. may be called immediately if already at top
    
    
    /* Also see -[UIScrollView adjustedContentInsetDidChange]
     */
    @available(iOS 11.0, *)
    optional func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView)
    
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: any UITableViewDropCoordinator) {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
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
