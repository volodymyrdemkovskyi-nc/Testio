//
//  String + Extensions.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 27/06/2025.
//

import SwiftUI

extension String {
    var url: URL? {
        URL(string: self)
    }
}

extension String {
    var image: Image? {
        Image(self)
    }
}
