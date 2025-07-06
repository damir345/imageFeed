//
//  Array+Extensions.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 29/06/25.
//

import Foundation

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var newArray = self
        newArray[index] = newValue
        return newArray
    }
}
