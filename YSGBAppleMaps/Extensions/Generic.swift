//
//  Generic.swift
//  YSGBAppleMaps
//
//  Created by Ярослав on 21.03.2022.
//

import Foundation

extension Array {
    var middle: Element? {
        guard count != 0 else { return nil }

        let middleIndex = (count > 1 ? count - 1 : count) / 2
        return self[middleIndex]
    }

}
