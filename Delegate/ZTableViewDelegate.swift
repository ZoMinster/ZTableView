//
//  ZTableViewDelegate.swift
//  ZTableView
//
//  Created by 赖依娴 on 2024/5/21.
//

import UIKit

@objc public protocol ZTableViewDelegate : UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate, UITableViewDataSource {
    //data source
    @objc @available(iOS 2.0, *)
    optional func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    @objc @available(iOS 8.0, *)
    optional func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    
    // Provide items to begin a drag associated with a given index path.
    // You can use -[session locationInView:] to do additional hit testing if desired.
    // If an empty array is returned a drag session will not begin.
    @objc
    optional func tableView(_ tableView: UITableView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem]
    
    // Called when the user initiates the drop.
    // Use the drop coordinator to access the items in the drop and the final destination index path and proposal for the drop,
    // as well as specify how you wish to animate each item to its final position.
    // If your implementation of this method does nothing, default drop animations will be supplied and the table view will
    // revert back to its initial state before the drop session entered.
    @objc
    optional func tableView(_ tableView: UITableView, performDropWith coordinator: any UITableViewDropCoordinator)
}
