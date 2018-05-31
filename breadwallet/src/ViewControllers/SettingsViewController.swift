//
//  SettingsViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-03-30.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//
import UIKit
import LocalAuthentication

enum SettingsSections: String {
    case wallet
    case preferences
    case currencies
    case other
    case currency
    case network
    
    var title: String {
        switch self {
        case .wallet:
            return S.Settings.wallet
        case .preferences:
            return S.Settings.preferences
        case .currencies:
            return S.Settings.currencySettings
        case .other:
            return S.Settings.other
        default:
            return ""
        }
    }
}

class SettingsViewController : UITableViewController {
    
    init(sections: [SettingsSections], rows: [SettingsSections: [Setting]], optionalTitle: String? = nil) {
        self.sections = sections
        if UserDefaults.isBiometricsEnabled {
            self.rows = rows
        } else {
            var tempRows = rows
            let biometricsLimit = LAContext.biometricType() == .face ? S.Settings.faceIdLimit : S.Settings.touchIdLimit
            tempRows[.preferences] = tempRows[.preferences]?.filter { $0.title != biometricsLimit }
            self.rows = tempRows
        }
        self.optionalTitle = optionalTitle
        super.init(style: .plain)
    }

    private let sections: [SettingsSections]
    private let rows: [SettingsSections: [Setting]]
    private let cellIdentifier = "CellIdentifier"
    private let optionalTitle: String?
    private let sectionHeaderHeight: CGFloat = 30.0

    override func viewDidLoad() {
        title = optionalTitle ?? S.Settings.title
        tableView.register(SeparatorCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .whiteBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[sections[section]]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SeparatorCell, let setting = rows[sections[indexPath.section]]?[indexPath.row] else { return UITableViewCell() }
        cell.setSetting(setting)
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: sectionHeaderHeight))
        view.backgroundColor = .lightTableViewSectionHeaderBackground
        let label = UILabel(font: .customMedium(size: 12.0), color: .mediumGray)
        view.addSubview(label)
        label.text = sections[section].title.uppercased()
        let separator = UIView()
        separator.backgroundColor = .separator
        view.addSubview(separator)
        separator.constrain([
            separator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            separator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.0) ])
        label.constrain([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
            label.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: -C.padding[1]) ])
        return view
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let setting = rows[sections[indexPath.section]]?[indexPath.row] {
            setting.callback()
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
