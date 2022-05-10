//
//  HtmlConverter.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 10.04.2022.
//

import Foundation
import UIKit

class CertificateWorker {
    
    private static let pdfName = "certificate"
    
    public static let nameKey = "name1"
    public static let partnerNameKey = "name2"
    public static let addressKey = "address1"
    public static let partnerAddressKey = "address2"
    public static let timeKey = "timing"
    public static let dayNumKey = "day_num"
    public static let monthNumKey = "month_num"
    public static let yearNumKey = "year_num"
    public static let serialNumber = "serial_number"
    public static let blockHash = "block_hash"
    
    private static let pageWidth = 1152.0
    private static let pageHeight = 819.2
    
    private static let selfPictureMaxSize: Float = 800
    
    static func generateCertificatePdf(formatter: UIViewPrintFormatter) throws -> URL? {
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)
        let page = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        renderer.setValue(page, forKey: "paperRect")
        renderer.setValue(page, forKey: "printableRect")
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, page, nil)
        for i in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage();
            renderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext();
        let outputURL = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
            .appendingPathComponent(pdfName).appendingPathExtension("pdf")
        pdfData.write(to: outputURL, atomically: true)
        return outputURL
    }
    
    static func imageFromPdf(url: URL) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        guard let page = document.page(at: 1) else { return nil }

        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)

            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            ctx.cgContext.drawPDFPage(page)
        }
        return img
    }
    
    static func generateHtmlString(id: String,
                                   firstPersonName: String,
                                   secondPersonName: String,
                                   firstPersonAddress: String,
                                   secondPersonAddress: String,
                                   firstPersonImage: UIImage?,
                                   secondPersonImage: UIImage?,
                                   templateId: String,
                                   blockHash: String) -> String {
        let certPath = Bundle.main.path(forResource: "cert\(templateId)", ofType: "html")!
        let htmlTemplate = try! String(contentsOfFile: certPath) //TODO: handle?
        let now = Date()
        
        let htmlString = htmlTemplate
            .replacingOccurrences(of: CertificateWorker.nameKey, with: firstPersonName)
            .replacingOccurrences(of: CertificateWorker.partnerNameKey, with: secondPersonName)
            .replacingOccurrences(of: CertificateWorker.addressKey, with: firstPersonAddress)
            .replacingOccurrences(of: CertificateWorker.partnerAddressKey, with: secondPersonAddress)
            .replacingOccurrences(of: CertificateWorker.dayNumKey, with: now.dayOrdinal())
            .replacingOccurrences(of: CertificateWorker.monthNumKey, with: now.formattedDateString("LLLL").lowercased())
            .replacingOccurrences(of: CertificateWorker.yearNumKey, with: now.formattedDateString("yyyy"))
            .replacingOccurrences(of: CertificateWorker.timeKey, with: now.formattedDateString("HH:mm"))
            .replacingOccurrences(of: CertificateWorker.blockHash, with: blockHash)
            .replacingOccurrences(of: CertificateWorker.serialNumber, with: id)
        
        return htmlString
    }
    
    static func compressImage(image: UIImage, maxHeight: Float = selfPictureMaxSize,
                       maxWidth: Float = selfPictureMaxSize) -> UIImage {
        return compress(
            image: image,
            maxHeight: maxHeight,
            maxWidth: maxWidth)
    }
    
    private static func compress(image: UIImage, maxHeight: Float = selfPictureMaxSize,
                       maxWidth: Float = selfPictureMaxSize) -> UIImage {
        var actualHeight: Float = Float(image.size.height)
        var actualWidth: Float = Float(image.size.width)
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight

        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }

        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
}
