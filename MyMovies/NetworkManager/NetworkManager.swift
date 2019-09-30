//
//  NetworkManager.swift
//  MyMovies
//
//  Created by Abdul Hoque Nuri on 27/09/19.
//  Copyright © 2019 Abdul Hoque Nuri. All rights reserved.
//

import Foundation
import Alamofire
import Security
class NetworkManager {
    var sessionManager: SessionManager?
}

extension SessionManager {
    static func getManager() -> Alamofire.SessionManager{
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "google.com": .pinCertificates(
                certificates: ServerTrustPolicy.certificates(),
                validateCertificateChain: true,
                validateHost: true
            )
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        
        return Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }
    
}
