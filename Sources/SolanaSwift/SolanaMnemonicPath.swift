//
//  SolanaMnemonicPath.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/20.
//
import Foundation

public enum SolanaMnemonicPathType {
    case SolanaMnemonicPathType44                          // m/44'/501'/0'/0
    case SolanaMnemonicPathType501                         // m/501'/0'/0/0
    case SolanaMnemonicPathTypNone                         // None
    case SolanaMnemonicPathType_Ed25519                    // m/44'/501'/0'/0'
    case SolanaMnemonicPathType_Ed25519_Old                // m/44'/501'/0'
    
    public func path() -> String {
        switch self {
        case .SolanaMnemonicPathType_Ed25519:
            return "m/44'/501'/0'/0'"
        case .SolanaMnemonicPathType_Ed25519_Old:
            return "m/44'/501'/0'"
        case .SolanaMnemonicPathType44:
            return "m/44'/501'/0'/0"
        case .SolanaMnemonicPathType501:
            return "m/501'/0'/0/0"
        default:
            return ""
        }
    }
}

public struct SolanaMnemonicPath {
    // Path Type
    public static func getMnemonicPathType(mnemonicPath:String) -> SolanaMnemonicPathType {
        if mnemonicPath.count==0 {
            return .SolanaMnemonicPathTypNone
        }
        let pathArray = mnemonicPath.components(separatedBy: "/");
        if pathArray.count == 4 {
            return .SolanaMnemonicPathType_Ed25519_Old
        } else if pathArray[1]=="501'"{
            return .SolanaMnemonicPathType501
        } else if pathArray[4]=="0'"{
            return .SolanaMnemonicPathType_Ed25519
        } else if pathArray[4]=="0"{
            return .SolanaMnemonicPathType44
        }
        return .SolanaMnemonicPathTypNone
    }
    
    // Check path
    public static func isValid(mnemonicPath:String) -> Bool {
        let pathArray = mnemonicPath.components(separatedBy: "/");
        if pathArray.count < 2 {return false}
        guard pathArray[0]=="m" else {return false}
        let predicate = NSPredicate(format: "SELF MATCHES %@","^\\d{0,}([0-9]|')$")
        for node in pathArray {
            guard predicate.evaluate(with: node) else {
                return false
            }
        }
        return true
    }
    
    
}
