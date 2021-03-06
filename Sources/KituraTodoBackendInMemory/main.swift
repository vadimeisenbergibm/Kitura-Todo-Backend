/**
 * Copyright IBM Corporation 2016,2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation

import Kitura
import LoggerAPI
import HeliumLogger
import Configuration

import TodoBackendInMemoryDataLayer
import TodoBackendRouter

Log.logger = HeliumLogger()

func getURLAndPort() -> (URL, Int) {
    let configurationManager = ConfigurationManager()
    configurationManager.load(.environmentVariables)

    let defaultPort = 8080
    let portString = configurationManager["PORT"] as? String ?? "\(defaultPort)"
    let port = Int(portString) ?? defaultPort

    let urlString: String
    if let cloudFoundryAppURI = configurationManager["VCAP_APPLICATION:application_uris:0"]
                                as? String {
        urlString = "https://" + cloudFoundryAppURI
    } else {
        urlString = "http://localhost:\(port)"
    }
    if let url = URL(string: urlString) {
        return (url, port)
    } else {
        Log.error("unable to create URL from \(urlString)")
        // in case of an error return a URL for the current path, as a null object
        return (URL(fileURLWithPath: ""), port)
    }
}

let (baseURL, port) = getURLAndPort()
let router = RouterCreator(dataLayer: DataLayer(), baseURL: baseURL).create()
Kitura.addHTTPServer(onPort: port, with: router)
Kitura.run()
