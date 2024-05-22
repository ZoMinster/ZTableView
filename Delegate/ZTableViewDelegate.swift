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
}
