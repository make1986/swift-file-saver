//
//  ViewController.swift
//  FileLoader
//
//  Created by Марат Зайнуллин on 29.01.2020.
//  Copyright © 2020 TMT Soft. All rights reserved.
//

import UIKit
typealias Parameters = [String: String]

class ViewController: UIViewController {
    
    var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        self.toggleImagePicker()
    }
    
    
    private func saveImage(image: UIImage) {
            let boundary = self.generateBoundary()
            
            let parameters = ["name": "image"]
            
            guard let mediaImage = Media(withImage: image, forKey: "image") else { return }
            
            guard let url = URL(string: "http://localhost:8000/api/v1/challenges/image-before/") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//            request.addValue("application/json", forHTTPHeaderField: "Accept")
        
            
            let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
            request.httpBody = dataBody
            
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    print(error!)
                }
                if let httpResponse = response as? HTTPURLResponse {
                    print(httpResponse.statusCode)
                    if (httpResponse.statusCode >= 200) && (httpResponse.statusCode < 300) {
                        print("File uploaded")
                    }else {
                        print("Server error")
                    }
                }else {
                    print("Server error 2")
                }
            }.resume()
        }
    
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createDataBody(withParameters params: Parameters?, media: [Media]?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
        
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                print(photo.mimeType)
                body.append(photo.data)
                body.append(lineBreak)
            }
        }
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
    
    

    private func getData() {
        guard let url = URL(string: "http://localhost:8000/api/v1/challenges/user/none") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {(data, response, error) in
            if (error != nil) {
                print(error!)
                return
            }
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode(Response.self, from: data)
                print(response.data)
            } catch {
                print("err")
            }
            
        }.resume()
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func toggleImagePicker() {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancel")
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("info")
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            print("pickedImage created")
            self.saveImage(image: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}



struct Response: Decodable {
    let data: ResponseData
}

struct ResponseData: Decodable {
    let ok: Bool!
}

struct Media {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        self.mimeType = "image/jpeg"
        self.filename = "photo\(arc4random()).jpeg"
        
        guard let data = image.jpegData(compressionQuality: 0.75) else { return nil }
        self.data = data
    }
}


extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
