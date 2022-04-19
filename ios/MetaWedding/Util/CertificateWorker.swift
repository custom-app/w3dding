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
    
    public static let htmlTemplate2 = """
<h1 style="text-align: center;">MARRIAGE CERTIFICATE</h1>
<h2 style="text-align: center;">&nbsp;</h2>
<h2 style="text-align: center;"><span style="background-color: #000000; color: #ffffff;"><em><strong>&nbsp;name1&nbsp;</strong></em></span></h2>
<h3 style="text-align: center;"><span style="color: #000000;"><em>&nbsp;</em></span><span style="color: #333399;"><em>(address1)</em></span><span style="color: #000000;"><em><span style="color: #333333;">&nbsp;</span></em></span></h3>
<p style="text-align: center;"><span style="font-size: 500%;">+</span></p>
<h2 style="text-align: center;"><span style="color: #ffffff; background-color: #000000;"><em><strong>&nbsp;name2&nbsp;</strong></em></span></h2>
<h3 style="text-align: center;"><span style="color: #333399;"><em>(address2)</em></span></h3>
"""
    
    public static let nameKey = "name1"
    public static let partnerNameKey = "name2"
    public static let addressKey = "address1"
    public static let partnerAddressKey = "address2"
    private static let pageWidth = 595.2
    private static let pageHeight = 841.8
    
    static func generateCertificatePdf(formatter: UIViewPrintFormatter) throws -> URL? {
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)
        let page = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        renderer.setValue(page, forKey: "paperRect")
        renderer.setValue(page, forKey: "printableRect")
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
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
    
}
