//
//  SolanaMnemonicPath.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/20.
//
import Foundation


public struct SolanaMnemonicPath {
    
    public enum PathType {
        case BIP32_44                   // m/44'/501'/index'/0
        case BIP32_501                  // m/501'/index'/0/0
        case None                       // None
        case Ed25519                    // m/44'/501'/index'/0'
        case Ed25519_Old                // m/44'/501'/index'
        
        public var `default`: String {
            switch self {
            case .BIP32_501:
                return "m/501'/0'/0/0"
            case .Ed25519_Old:
                return "m/44'/501'/0'"
            case .Ed25519:
                return "m/44'/501'/0'/0'"
            case .BIP32_44:
                return "m/44'/501'/0'/0"
            default:
                return ""
            }
        }
    }
    
    // Path Type
    public static func getType(mnemonicPath: String) -> PathType {
        guard mnemonicPath.count > 0 else {
            return .None
        }
        
        let pathArray = mnemonicPath.components(separatedBy: "/");
        
        if mnemonicPath.hasPrefix("m/501'/"){
            return .BIP32_501
        } else if mnemonicPath.hasPrefix("m/44'/501'/") && pathArray.count == 4  {
            return .Ed25519_Old
        } else if mnemonicPath.hasPrefix("m/44'/501'/") && pathArray.last == "0'" {
            return .Ed25519
        } else if mnemonicPath.hasPrefix("m/44'/501'/") && pathArray.last == "0" {
            return .BIP32_44
        }
        
        return .None
    }
}
