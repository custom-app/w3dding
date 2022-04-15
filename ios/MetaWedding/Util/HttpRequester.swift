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
    static private let JPEG_MIME_TYPE = "image/jpeg"
    
    //TODO: generate new and store in gitignored config
    private let nftStorageKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweGI1N0NjMzQ4ZjE1RDQ4NUVEMjJkNWRBYWRiMmQ2RTg0NDhERjM2MDAiLCJpc3MiOiJuZnQtc3RvcmFnZSIsImlhdCI6MTY0OTk4MzYwMTAyNywibmFtZSI6InRlc3Rfa2V5In0.HTaOuxPjCtPdGMtOGQ6DHjp-OBDtSWvkpFqvGEIxYes"
    
    func uploadPictureToNftStorage(data: Data, onResult: @escaping (UploadResponse?, Error?) -> ()) {
        print("doRequest")
        var request = URLRequest(
            url: URL(string: "https://api.nft.storage/upload")!,
            cachePolicy: .reloadIgnoringLocalCacheData
        )
        request.httpMethod = "POST"
        request.addValue("image/jpeg", forHTTPHeaderField: HttpRequester.HEADER_CONTENT_TYPE)
        
        request.addValue("Bearer \(nftStorageKey)", forHTTPHeaderField: HttpRequester.HEADER_AUTHORIZATION)
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
                do {
                    let response = try JSONDecoder().decode(UploadResponse.self, from: data)
                    print("parsed response: \(response)")
                    
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

