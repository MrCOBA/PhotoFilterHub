import Foundation
import UIKit

final class NetworkProcessing {

    private let apiURL: String

    init(apiURL: String) {
        self.apiURL = apiURL
    }

    func GET(data: Data?, withSerializer serializer: ((Any) -> Bool)?, completition: (() -> Void)?) {
        var request  = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let data = data {
            request.httpBody = data
        }

        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            if let error = error {
                print("Error took place \(error)")
                return
            }

            if let data = data {
                if let serializer = serializer {
                    print(serializer(data))
                }
            }

            if let completition = completition {
                completition()
            }
        }
        task.resume()
    }

    func GETimage(from url: String, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: completion).resume()
    }

    func POSTimage(image: UIImage?, description: String?, withSerializer serializer: ((Any) -> Bool)?, completition: (() -> Void)?) {
        guard let image = image else {
            return
        }

        var request  = URLRequest(url: URL(string: "https://filterhub.pythonanywhere.com/images/upload_image/")!)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createBody(parameters: ["description": description ?? ""],
                                      boundary: boundary,
                                      data: image.jpegData(compressionQuality: 0.7)!,
                                      mimeType: "image/jpg",
                                      fileName: "image.jpg")

        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            if let error = error {
                print("Error took place \(error)")
                return
            }

            if let data = data {
                if let serializer = serializer {
                    print(serializer(data))
                }
            }

            if let completition = completition {
                completition()
            }
        }

        task.resume()
    }

    private func createBody(parameters: [String: String], boundary: String, data: Data, mimeType: String, fileName: String) -> Data? {
        let body = NSMutableData()

        let boundaryPrefix = "--\(boundary)\r\n"

        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }

        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))

        return body as Data
    }

}

// MARK: - Helper

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}
