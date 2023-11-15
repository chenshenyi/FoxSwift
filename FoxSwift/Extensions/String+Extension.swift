//
//  String + Extension.swift
//  STYLiSH
//
//  Created by chen shen yi on 2023/11/7.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

import Foundation


extension String {
    struct Signal {
        var emoji: String

        init(_ emoji: String) {
            self.emoji = emoji
        }

        static let black = Signal("⚫️")
        static let red = Signal("🔴")
        static let orange = Signal("🟠")
        static let green = Signal("🟢")
        static let yellow = Signal("🟡")
        static let blue = Signal("🔵")
        static let purple = Signal("🟣")
        static let brown = Signal("🟤")
        static let white = Signal("⚪️")
    }

    private func addSignal(_ signal: Signal) -> String {
        return signal.emoji + self + signal.emoji
    }


    var black: String { addSignal(.black) }

    var red: String { addSignal(.red) }

    var orange: String { addSignal(.orange) }

    var green: String { addSignal(.green) }

    var yellow: String { addSignal(.yellow) }

    var blue: String { addSignal(.blue) }

    var purple: String { addSignal(.purple) }

    var brown: String { addSignal(.brown) }

    var white: String { addSignal(.white) }
}
