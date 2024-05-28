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
    
        // Allows the reorder accessory view to internally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
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
    internal func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // any zoom scale changes
        delegate?.scrollViewDidZoom?(scrollView)
    }
    
    
    // called on start of dragging (may require some time and or distance to move)
    @available(iOS 2.0, *)
    internal func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    // called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    @available(iOS 5.0, *)
    internal func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    // called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    @available(iOS 2.0, *)
    internal func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    // called on finger up as we are moving
    @available(iOS 2.0, *)
    internal func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    // called when scroll view grinds to a halt
    @available(iOS 2.0, *)
    internal func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
    @available(iOS 2.0, *)
    internal func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    // return a view that will be scaled. if delegate returns nil, nothing happens
    @available(iOS 2.0, *)
    internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return delegate?.viewForZooming?(in: scrollView)
    }
    
    // called before the scroll view begins zooming its content
    @available(iOS 3.2, *)
    internal func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        delegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }
    
    // scale between minimum and maximum. called after any 'bounce' animations
    @available(iOS 2.0, *)
    internal func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        delegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    
    // return a yes if you want to scroll to the top. if not defined, assumes YES
    @available(iOS 2.0, *)
    internal func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        guard let flag = delegate?.scrollViewShouldScrollToTop?(scrollView) else {
            return false
        }
        return flag
    }
    
    // called when scrolling animation finished. may be called immediately if already at top
    @available(iOS 2.0, *)
    internal func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScrollToTop?(scrollView)
    }
    
    
    /* Also see -[UIScrollView adjustedContentInsetDidChange]
     */
    @available(iOS 11.0, *)
    internal func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
    
    @available(iOS 8.0, *)
    internal func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }

    @available(iOS 6.0, *)
    internal func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        delegate?.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
    }

    @available(iOS 6.0, *)
    internal func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        delegate?.tableView?(tableView, willDisplayFooterView: view, forSection: section)
    }

    @available(iOS 6.0, *)
    internal func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }

    @available(iOS 6.0, *)
    internal func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        delegate?.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
    }

    @available(iOS 6.0, *)
    internal func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        delegate?.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
    }

    @available(iOS 8.0, *)
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = delegate?.tableView?(tableView, heightForRowAt: indexPath) else {
            return 40
        }
        return height
    }

    @available(iOS 2.0, *)
    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let height = delegate?.tableView?(tableView, heightForHeaderInSection: section) else {
            return 40
        }
        return height
    }

    @available(iOS 2.0, *)
    internal func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let height = delegate?.tableView?(tableView, heightForFooterInSection: section) else {
            return 40
        }
        return height
    }

    @available(iOS 7.0, *)
    internal func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = delegate?.tableView?(tableView, estimatedHeightForRowAt: indexPath) else {
            return 40
        }
        return height
    }

    @available(iOS 7.0, *)
    internal func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        guard let height = delegate?.tableView?(tableView, estimatedHeightForHeaderInSection: section) else {
            return 40
        }
        return height
    }

    @available(iOS 7.0, *)
    internal func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        guard let height = delegate?.tableView?(tableView, estimatedHeightForFooterInSection: section) else {
            return 40
        }
        return height
    }

    @available(iOS 2.0, *)
    internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return delegate?.tableView?(tableView, viewForHeaderInSection: section)
    }

    @available(iOS 2.0, *)
    internal func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return delegate?.tableView?(tableView, viewForFooterInSection: section)
    }

    @available(iOS 8.0, *)
    internal func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        delegate?.tableView?(tableView, accessoryButtonTappedForRowWith: indexPath)
    }

    @available(iOS 6.0, *)
    internal func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let flag = delegate?.tableView?(tableView, shouldHighlightRowAt: indexPath) else {
            return false
        }
        return flag
    }

    @available(iOS 6.0, *)
    internal func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        delegate?.tableView?(tableView, didHighlightRowAt: indexPath)
    }

    @available(iOS 6.0, *)
    internal func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        delegate?.tableView?(tableView, didUnhighlightRowAt: indexPath)
    }

    @available(iOS 8.0, *)
    internal func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return delegate?.tableView?(tableView, willSelectRowAt: indexPath)
    }

    @available(iOS 3.0, *)
    internal func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return delegate?.tableView?(tableView, willDeselectRowAt: indexPath)
    }

    @available(iOS 8.0, *)
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }

    @available(iOS 3.0, *)
    internal func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        delegate?.tableView?(tableView, didDeselectRowAt: indexPath)
    }

    /**
     * @abstract Called to determine if a primary action can be performed for the row at the given indexPath.
     * See @c tableView:performPrimaryActionForRowAtIndexPath: for more details about primary actions.
     *
     * @param tableView This UITableView
     * @param indexPath NSIndexPath of the row
     *
     * @return `YES` if the primary action can be performed; otherwise `NO`. If not implemented defaults to `YES` when not editing
     * and `NO` when editing.
     */
    @available(iOS 16.0, *)
    internal func tableView(_ tableView: UITableView, canPerformPrimaryActionForRowAt indexPath: IndexPath) -> Bool {
        guard let flag = delegate?.tableView?(tableView, canPerformPrimaryActionForRowAt: indexPath) else {
            return false
        }
        return flag
    }

    /**
     * @abstract Called when the primary action should be performed for the row at the given indexPath.
     *
     * @discussion Primary actions allow you to distinguish between a change of selection (which can be based on focus changes or
     * other indirect selection changes) and distinct user actions. Primary actions are performed when the user selects a cell without extending
     * an existing selection. This is called after @c willSelectRow and @c didSelectRow , regardless of whether the cell's selection
     * state was allowed to change.
     *
     * As an example, use @c didSelectRowAtIndexPath for updating state in the current view controller (i.e. buttons, title, etc) and
     * use the primary action for navigation or showing another split view column.
     *
     * @param tableView This UITableView
     * @param indexPath NSIndexPath of the row to perform the action on
     */
    @available(iOS 16.0, *)
    internal func tableView(_ tableView: UITableView, performPrimaryActionForRowAt indexPath: IndexPath) {
        delegate?.tableView?(tableView, performPrimaryActionForRowAt: indexPath)
    }

    @available(iOS 8.0, *)
    internal func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard let style = delegate?.tableView?(tableView, editingStyleForRowAt: indexPath) else {
            return .none
        }
        return style
    }

    @available(iOS 3.0, *)
    internal func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return delegate?.tableView?(tableView, titleForDeleteConfirmationButtonForRowAt: indexPath)
    }

    @available(iOS, introduced: 8.0, deprecated: 13.0)
    internal func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return delegate?.tableView?(tableView, editActionsForRowAt: indexPath)
    }

    @available(iOS 11.0, *)
    internal func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return delegate?.tableView?(tableView, leadingSwipeActionsConfigurationForRowAt: indexPath)
    }

    @available(iOS 11.0, *)
    internal func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?

    @available(iOS 8.0, *)
    internal func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool

    @available(iOS 8.0, *)
    internal func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath)

    @available(iOS 8.0, *)
    internal func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?)

    @available(iOS 8.0, *)
    internal func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath

    @available(iOS 8.0, *)
    internal func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int

    @available(iOS, introduced: 5.0, deprecated: 13.0)
    internal func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool

    @available(iOS, introduced: 5.0, deprecated: 13.0)
    internal func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool

    @available(iOS, introduced: 5.0, deprecated: 13.0)
    internal func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?)

    @available(iOS 9.0, *)
    internal func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool

    @available(iOS 9.0, *)
    internal func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool

    @available(iOS 9.0, *)
    internal func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)

    @available(iOS 9.0, *)
    internal func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath?

    /// Determines if the row at the specified index path should also become selected when focus moves to it.
    /// If the table view's global selectionFollowsFocus is enabled, this method will allow you to override that behavior on a per-index path basis. This method is not called if selectionFollowsFocus is disabled.
    @available(iOS 15.0, *)
    internal func tableView(_ tableView: UITableView, selectionFollowsFocusForRowAt indexPath: IndexPath) -> Bool

    @available(iOS 11.0, *)
    internal func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: any UISpringLoadedInteractionContext) -> Bool

    @available(iOS 13.0, *)
    internal func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool

    @available(iOS 13.0, *)
    internal func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath)

    @available(iOS 13.0, *)
    internal func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView)

    /**
     * @abstract Called when the interaction begins.
     *
     * @param tableView  This UITableView.
     * @param indexPath  IndexPath of the row for which a configuration is being requested.
     * @param point      Location of the interaction in the table view's coordinate space
     *
     * @return A UIContextMenuConfiguration describing the menu to be presented. Return nil to prevent the interaction from beginning.
     *         Returning an empty configuration causes the interaction to begin then fail with a cancellation effect. You might use this
     *         to indicate to users that it's possible for a menu to be presented from this element, but that there are no actions to
     *         present at this particular time.
     */
    @available(iOS 13.0, *)
    internal func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration?

    /**
     * @abstract Called when the interaction begins. Return a UITargetedPreview to override the default preview created by the table view.
     *
     * @param tableView      This UITableView.
     * @param configuration  The configuration of the menu about to be displayed by this interaction.
     */
    @available(iOS 13.0, *)
    internal func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?

    /**
     * @abstract Called when the interaction is about to dismiss. Return a UITargetedPreview describing the desired dismissal target.
     * The interaction will animate the presented menu to the target. Use this to customize the dismissal animation.
     *
     * @param tableView      This UITableView.
     * @param configuration  The configuration of the menu displayed by this interaction.
     */
    @available(iOS 13.0, *)
    internal func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?

    /**
     * @abstract Called when the interaction is about to "commit" in response to the user tapping the preview.
     *
     * @param tableView      This UITableView.
     * @param configuration  Configuration of the currently displayed menu.
     * @param animator       Commit animator. Add animations to this object to run them alongside the commit transition.
     */
    @available(iOS 13.0, *)
    internal func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: any UIContextMenuInteractionCommitAnimating)

    /**
     * @abstract Called when the table view is about to display a menu.
     *
     * @param tableView       This UITableView.
     * @param configuration   The configuration of the menu about to be displayed.
     * @param animator        Appearance animator. Add animations to run them alongside the appearance transition.
     */
    @available(iOS 14.0, *)
    internal func tableView(_ tableView: UITableView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: (any UIContextMenuInteractionAnimating)?)

    /**
     * @abstract Called when the table view's context menu interaction is about to end.
     *
     * @param tableView       This UITableView.
     * @param configuration   Ending configuration.
     * @param animator        Disappearance animator. Add animations to run them alongside the disappearance transition.
     */
    @available(iOS 14.0, *)
    internal func tableView(_ tableView: UITableView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: (any UIContextMenuInteractionAnimating)?)
    
    
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
