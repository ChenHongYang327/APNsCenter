

import UIKit
import RealmSwift




class Secure {
    
    static let shard = Secure()
    
    func isKey (keyStr: String) -> Bool{
        
        // 解碼回去，拿到realm 的key
        guard let keyStr = getRealmDecodeKey(userdefaultKeyName: keyStr) else {
            print("Fail to get EnccodeDataStr")
            return false
        }
        // 拿到解碼後key
        let realmKeyData = Data(base64Encoded: keyStr)!
        
        let config = Realm.Configuration(encryptionKey: realmKeyData)
        
        do {
            _ = try Realm(configuration: config)
            print()
            // 接下來正常使用realm
            return true
            
        } catch let error {
            print("Fail to openRealm: \(error.localizedDescription)")
            return false
        }
        
    }
    
    func createRealm() {
        
        // 建立64位元組的加密金鑰
        var keyForRealmData = Data(count: 64)
        // 排除重複
        keyForRealmData.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, 64, bytes)
        }
        
        
        do {
            // 建立加密 realm
            let config = Realm.Configuration(encryptionKey: keyForRealmData)
            _ = try Realm(configuration: config)
            
            // 成功創立後，把 key 存去 Secure Enclave
            let encodeKey = keyForRealmData.base64EncodedString()
            encryptKeyToSecureEnclave(encodeRealmKeyStr: encodeKey)
            
            
        } catch let error as NSError {
            print("create realm error: \(error)")
        }
        
    }
    
    func openRealm ()-> Realm?{
        
        let key = UserDefaults.standard.object(forKey: UserKeys.secKey.rawValue) as! String
        
        // 解碼回去，拿到realm 的key
        guard let keyStr = getRealmDecodeKey(userdefaultKeyName: key) else {
            print("Fail to get EnccodeDataStr")
            return nil
        }
        // 拿到解碼後key
        let realmKeyData = Data(base64Encoded: keyStr)!
        
        
        let config = Realm.Configuration(encryptionKey: realmKeyData)
        
        do {
            let realm = try Realm(configuration: config)
            // 接下來正常使用realm
            return realm
            
        } catch let error {
            print("Fail to openRealm: \(error.localizedDescription)")
            return nil
        }
        
    }
    
    
    // 非對稱加密
    // 把keyName 存去 userdefault
    private func encryptKeyToSecureEnclave(encodeRealmKeyStr: String){
        
        var privatekey: SecKey?
        let keyName = "keychain-sample.sampleKey"
        
        do {
            privatekey = try makeAndStoreKey(name: keyName, requiresBiometry: false)
            
            guard let publicKey = SecKeyCopyPublicKey(privatekey!) else {
                print("get publicKey fail!")
                return
            }
            
            // 橢圓加密
            let algorithm = SecKeyAlgorithm.eciesEncryptionCofactorVariableIVX963SHA256AESGCM
            // 確認否可以加密
            guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
                print("Fail to encrypt")
                return
            }
            
            var error: Unmanaged<CFError>?
            // 把要存的資料轉檔
            let clearTextData = encodeRealmKeyStr.data(using: .utf8)!
            
            // 資料加密
            let cipherTextData = SecKeyCreateEncryptedData(publicKey, algorithm, clearTextData as CFData, &error) as Data?
            
            guard cipherTextData != nil else {
                print("Fail to encrypt")
                return
            }
            
            // 把keyname 存進 userdefault
            UserDefaults.standard.set(keyName, forKey: UserKeys.secKey.rawValue)
            // 把 加密的資料存起來 ，後續要跟key 一起解碼
            UserDefaults.standard.set(cipherTextData, forKey: UserKeys.cipherData.rawValue)
            
        } catch let error {
            print("Fail to create public key:\(error)")
        }
        
    }
    
    private func getRealmDecodeKey (userdefaultKeyName: String) -> String? {
        
        let publickey = loadKey(name: userdefaultKeyName)
        guard publickey != nil else {
            print("Fail to get Seckey form \(userdefaultKeyName)")
            return nil
        }
        
        // 橢圓加密
        let algorithm = SecKeyAlgorithm.eciesEncryptionCofactorVariableIVX963SHA256AESGCM
        guard SecKeyIsAlgorithmSupported(publickey!, .decrypt, algorithm) else {
            print("Fail to decrypt")
            return nil
        }
        
        // 上密資料
        guard let cipherData = UserDefaults.standard.object(forKey: UserKeys.cipherData.rawValue) as? Data else {
            print("Fail to get cipherData")
            return nil
        }
        
        var error: Unmanaged<CFError>?
        // 把data解密
        let clearTextData = SecKeyCreateDecryptedData(publickey!, algorithm, cipherData as CFData, &error) as Data?
        // 解碼
        let encodeRealmKeyStr = String(decoding: clearTextData!, as: UTF8.self)
        
        return encodeRealmKeyStr
        
    }
    
    
    
    
}
extension Secure {
    
    private func makeAndStoreKey(name: String, requiresBiometry: Bool = false) throws -> SecKey {
        
        removeKey(name: name)
        
        let flags: SecAccessControlCreateFlags
        // 判斷版本是否有生物辨識
        if #available(iOS 11.3, *) {
            flags = requiresBiometry ?
            [.privateKeyUsage, .biometryCurrentSet] : .privateKeyUsage
        } else {
            flags = requiresBiometry ?
            [.privateKeyUsage, .touchIDCurrentSet] : .privateKeyUsage
        }
        let access =
        SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                        kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                        flags,
                                        nil)!
        let tag = name.data(using: .utf8)!
        let attributes: [String: Any] = [
            kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
            kSecAttrKeySizeInBits as String     : 256,
            kSecAttrTokenID as String           : kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String : [
                kSecAttrIsPermanent as String       : true,
                kSecAttrApplicationTag as String    : tag,
                kSecAttrAccessControl as String     : access
            ]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        
        return privateKey
    }
    
    private func loadKey(name: String) -> SecKey? {
        let tag = name.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : tag,
            kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
            kSecReturnRef as String             : true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            return nil
        }
        return (item as! SecKey)
    }
    
    private func removeKey(name: String) {
        let tag = name.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : tag
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    
    
}
