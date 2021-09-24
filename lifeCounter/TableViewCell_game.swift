//
//  TableViewCell_game.swift
//  lifeCounter
//
//  Created by 倉知諒 on 2021/09/24.
//  Copyright © 2021 kurachi. All rights reserved.
//

import UIKit
class TableViewCell_game: UITableViewCell {
    @IBOutlet weak var gameDate: UILabel!
    @IBOutlet weak var time: UILabel!
    func setCell(data: Data_game) {
        gameDate.text = data.gameDate
        time.text = data.time
    }
}
class Data_game {
    var gameDate: String
    var time: String
    init(gameDate: String, time: String) {
        self.gameDate = gameDate
        self.time = time
    }
}
