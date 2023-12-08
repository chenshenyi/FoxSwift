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

    let appName = "FoxSwift"

    enum EndPoint: String {
        case meeting
    }

    // MARK: Read and create url
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

    func createUrlString(for endPoint: EndPoint, components: [String]) -> String {
        appName + "://" + endPoint.rawValue + "/" + components.joined(separator: "/")
    }

    // MARK: - Meeting
    func meeting(_ urlPathComponents: [String]) {
        guard let tabBarController = rootViewController as? FSTabBarController,
              let meetsVC = tabBarController.tabsDict[.meets] as? MeetsViewController,
              urlPathComponents.count == 2
        else { return }

        let meetingCode = urlPathComponents[1]
        meetsVC.joinMeet(meetingCode: meetingCode)
    }
}
