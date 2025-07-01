//
//  AlertInfo.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 29/06/2025.
//

struct AlertInfo {
    enum AlertType {
        case simple
        case withActions
    }

    let title: String
    let message: String
    let type: AlertType 
}
