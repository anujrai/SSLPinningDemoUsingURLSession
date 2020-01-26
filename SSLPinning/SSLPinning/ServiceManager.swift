//
//  ServiceManager.swift
//  SSLPinning
//
//  Created by Anuj Rai on 26/01/20.
//  Copyright © 2020 Anuj Rai. All rights reserved.
//

import Foundation

class ServiceManager: NSObject {
    
    private func getSSLCertificate() -> [SecCertificate] {
        guard let bundle = Bundle.main.url(forResource: "google", withExtension: "cer") else {
            return []
        }
        
        let certificateAsCfData = try! Data(contentsOf: bundle) as CFData
        guard let sslCertificate = SecCertificateCreateWithData(nil, certificateAsCfData) else {
            return []
        }
        return [sslCertificate]
    }
    func callAPI(withURL url: URL) {
        let session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                       print("error: \(error!.localizedDescription): \(error!)")
                   } else if data != nil {
                       if let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                           print("Received data:\n\(str)")
                       } else {
                           print("Unable to convert data to text")
                       }
                   }
        }
        task.resume()

    }
//    func certificatePinning() {
//        let certificate = self.getSSLCertificate()
////        let serverTrustPolicies: [String: SecPolicy] = [
////            "www.google.co.uk": .pin
////        ]
//    }
    
}

extension ServiceManager: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil);
            return
        }
        
        let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
        
        // SSL Policies for domain name check
        let policy = NSMutableArray()
        policy.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
        
        //evaluate server certifiacte
        let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
        
        //Local and Remote certificate Data
        let remoteCertificateData:NSData =  SecCertificateCopyData(certificate!)
        //let LocalCertificate = Bundle.main.path(forResource: "github.com", ofType: "cer")
        let pathToCertificate = Bundle.main.path(forResource: "google", ofType: "cer")
        let localCertificateData:NSData = NSData(contentsOfFile: pathToCertificate!)!
        
        //Compare certificates
        if(isServerTrusted && remoteCertificateData.isEqual(to: localCertificateData as Data)){
            let credential:URLCredential =  URLCredential(trust:serverTrust)
            print("pinning is successfully completed")
            completionHandler(.useCredential,credential)
        }
        else{
            completionHandler(.cancelAuthenticationChallenge,nil)
        }
        
    }
    
}
