//
//  UrlRouteManager.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/7.
//

import UIKit

class UrlRouteManager {
    weak var rootViewController: UIViewController?

    static var shared = UrlRouteManager()

    enum EndPoint: String {
        case meeting
    }

    func canOpen(url: URL) -> Bool {
        let components = url.pathComponents
        guard let first = components.first,
              EndPoint(rawValue: first) != nil
        else {
            return false
        }
        return true
    }

    func open(url: URL) {
        let components = url.pathComponents
        guard let host = url.host(),
              let endpoint = EndPoint(rawValue: host) else { return }

        switch endpoint {
        case .meeting: meeting(components)
        }
    }

    func meeting(_ urlPathComponents: [String]) {
        guard let tabBarController = rootViewController as? FSTabBarController,
              let meetsVC = tabBarController.tabsDict[.meets] as? MeetsViewController,
              urlPathComponents.count == 2
        else { return }

        let meetingCode = urlPathComponents[1]
        meetsVC.joinMeet(meetingCode: meetingCode)
    }
}
