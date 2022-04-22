//
//  HttpRequester.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 15.04.2022.
//

import Foundation

class HttpRequester {
    
    static let shared = HttpRequester()
    static let HTTP_OK = 200
    static private let HEADER_CONTENT_TYPE = "Content-Type"
    static private let HEADER_AUTHORIZATION = "Authorization"
    static private let IMAGE_MIME_TYPE = "image/*"
    static private let JSON_MIME_TYPE = "application/json"
    
    private let boundary: String = UUID().uuidString
    
    func uploadPictureToNftStorage(data: Data, onResult: @escaping (ImageUploadResponse?, Error?) -> ()) {
        print("uploading picture")
        var request = URLRequest(
            url: URL(string: "https://api.nft.storage/upload")!,
            cachePolicy: .reloadIgnoringLocalCacheData
        )
        request.httpMethod = "POST"
        request.addValue(HttpRequester.IMAGE_MIME_TYPE,
                         forHTTPHeaderField: HttpRequester.HEADER_CONTENT_TYPE)
        
        request.addValue("Bearer \(Config.nftStorageKey)",
                         forHTTPHeaderField: HttpRequester.HEADER_AUTHORIZATION)
        request.httpBody = data
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if let error = error {
                print("response error: \(error)")
                DispatchQueue.main.async {
                    onResult(nil, error)
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("error converting to httpresponse")
                DispatchQueue.main.async {
                    onResult(nil, InnerError.storeUploadParseError(
                        description: "error converting to httpresponse"))
                }
                return
            }
            
            guard let data = data else {
                print("got nil data")
                DispatchQueue.main.async {
                    onResult(nil, InnerError.nilDataError)
                }
                return
            }
            if httpResponse.statusCode == HttpRequester.HTTP_OK {
                print("response ok")
                print("response: \(String(decoding: data, as: UTF8.self))")
                do {
                    let response = try JSONDecoder().decode(ImageUploadResponse.self, from: data)
                    print("parsed response: \(response)")
                    DispatchQueue.main.async {
                        onResult(response, nil)
                    }
                } catch {
                    print("error decoding: \(error)")
                    DispatchQueue.main.async {
                        onResult(nil, error)
                    }
                }
            } else {
                let err = String(data: data, encoding: .utf8)! //TODO: handle
                print("response not ok: \(err)")
                DispatchQueue.main.async {
                    onResult(nil, InnerError.httpError(body: err))
                }
            }
        }
        task.resume()
    }
    
    func uploadMetaToNftStorage(meta: CertificateMeta, onResult: @escaping (MetaUploadResponse?, Error?) -> ()) {
        print("uploading meta")
        
        let encoder = JSONEncoder()
        let metaJson = try! encoder.encode(meta)
        print("Meta:\n\(String(data: metaJson, encoding: .utf8)!)")
        
        var request = URLRequest(
            url: URL(string: "https://api.nft.storage/store")!,
            cachePolicy: .reloadIgnoringLocalCacheData
        )
        request.httpMethod = "POST"
        request.addValue("multipart/form-data; boundary=\(boundary)",
                         forHTTPHeaderField: HttpRequester.HEADER_CONTENT_TYPE)
        request.addValue("Bearer \(Config.nftStorageKey)", forHTTPHeaderField: HttpRequester.HEADER_AUTHORIZATION)
        
        var data = Data()
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"meta\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: text/plain; charset=ISO-8859-1\r\n".data(using: .utf8)!)
        data.append("Content-Transfer-Encoding: 8bit\r\n\r\n".data(using: .utf8)!)
        data.append(metaJson)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if let error = error {
                print("response error: \(error)")
                DispatchQueue.main.async {
                    onResult(nil, error)
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("error converting to httpresponse")
                DispatchQueue.main.async {
                    onResult(nil, InnerError.storeUploadParseError(
                        description: "error converting to httpresponse"))
                }
                return
            }
            
            guard let data = data else {
                print("got nil data")
                DispatchQueue.main.async {
                    onResult(nil, InnerError.nilDataError)
                }
                return
            }
            if httpResponse.statusCode == HttpRequester.HTTP_OK {
                print("response ok")
                print("response: \(String(decoding: data, as: UTF8.self))")
                do {
                    let response = try JSONDecoder().decode(MetaUploadResponse.self, from: data)
                    print("parsed response: \(response)")
                    DispatchQueue.main.async {
                        onResult(response, nil)
                    }
                } catch {
                    print("error decoding: \(error)")
                    DispatchQueue.main.async {
                        onResult(nil, error)
                    }
                }
            } else {
                let err = String(data: data, encoding: .utf8)! //TODO: handle
                print("response not ok: \(err)")
                DispatchQueue.main.async {
                    onResult(nil, InnerError.httpError(body: err))
                }
            }
        }
        task.resume()
    }
    
    func loadMeta(url: URL, onResult: @escaping (CertificateMeta?, Error?) -> ()) {
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData
        )
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if let error = error {
                print("response error: \(error)")
                DispatchQueue.main.async {
                    onResult(nil, error)
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("error converting to httpresponse")
                DispatchQueue.main.async {
                    onResult(nil, InnerError.storeUploadParseError(
                        description: "error converting to httpresponse"))
                }
                return
            }
            
            guard let data = data else {
                print("got nil data")
                DispatchQueue.main.async {
                    onResult(nil, InnerError.nilDataError)
                }
                return
            }
            if httpResponse.statusCode == HttpRequester.HTTP_OK {
                print("response ok")
                print("response: \(String(decoding: data, as: UTF8.self))")
                do {
                    let response = try JSONDecoder().decode(CertificateMeta.self, from: data)
                    print("parsed response: \(response)")
                    DispatchQueue.main.async {
                        onResult(response, nil)
                    }
                } catch {
                    print("error decoding: \(error)")
                    DispatchQueue.main.async {
                        onResult(nil, error)
                    }
                }
            } else {
                let err = String(data: data, encoding: .utf8)! //TODO: handle
                print("response not ok: \(err)")
                DispatchQueue.main.async {
                    onResult(nil, InnerError.httpError(body: err))
                }
            }
        }
        task.resume()
    }
}

