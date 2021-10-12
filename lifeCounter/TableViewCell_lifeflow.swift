//
//  TableViewCell_lifeflow.swift
//  lifeCounter
//
//  Created by 倉知諒 on 2021/09/23.
//  Copyright © 2021 kurachi. All rights reserved.
//

import UIKit
class TableViewCell_lifeflow: UITableViewCell {
    @IBOutlet weak var p1life: UILabel!
    @IBOutlet weak var p2life: UILabel!
    func setCell(data: Data_lifeflow) {
        p1life.text = String(data.p1life)
        p2life.text = String(data.p2life)
    }
}
class Data_lifeflow {
    var p1life: Int
    var p2life: Int
    init(p1life: Int, p2life: Int) {
        self.p1life = p1life
        self.p2life = p2life
    }
}
