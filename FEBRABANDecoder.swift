//
//  FEBRABANDecoder
//  FEBRABANDecoder
//
//  Created by Vitor Mesquita on 26/04/17.
//  Copyright © 2017 Vitor Mesquita. All rights reserved.
//

import UIKit

class FEBRABANDecoder {
    
    static func decode(barcode: String) -> String? {
        let fiveIndex = barcode.index(barcode.startIndex, offsetBy: 4)
        let sixIndex = barcode.index(barcode.startIndex, offsetBy: 5)
        let nineIndex = barcode.index(barcode.startIndex, offsetBy: 9)
        let nineteenIndex = barcode.index(barcode.startIndex, offsetBy: 19)
        let twentyFourIndex = barcode.index(barcode.startIndex, offsetBy: 24)
        let thirtyFourIndex = barcode.index(barcode.startIndex, offsetBy: 34)
        let fortyFourIndex = barcode.index(barcode.startIndex, offsetBy: 44)
        
        var mutableBarcode = barcode
        mutableBarcode.remove(at: fiveIndex)
        
        guard let mainDigit = verigyingMainDigit(barcode: mutableBarcode) else { return nil }
        
        let firstFreeRange = nineteenIndex..<twentyFourIndex
        let secondFreeRange = twentyFourIndex..<thirtyFourIndex
        let thirdFreeRange = thirtyFourIndex..<fortyFourIndex
        let dateRange = sixIndex..<nineIndex
        let titleNominalRange = nineIndex..<nineteenIndex
        
        var firstField = barcode.substring(to: fiveIndex)
        var secondField = barcode[secondFreeRange]
        var thirdField = barcode[thirdFreeRange]
        var factorExpirationField = barcode[dateRange]
        
        firstField += barcode[firstFreeRange]
        factorExpirationField += barcode[titleNominalRange]
        
        if let firstVerifyingDigit = verifyingDigit(barcode: firstField) {
            firstField += firstVerifyingDigit
        } else {
            return nil
        }
        
        if let secondVerifyingDigit = verifyingDigit(barcode: secondField) {
            secondField += secondVerifyingDigit
        } else {
            return nil
        }
        
        if let thirdVerifyingDigit = verifyingDigit(barcode: thirdField) {
            thirdField += thirdVerifyingDigit
        } else {
            return nil
        }
        
        return "\(firstField)\(secondField)\(thirdField)\(mainDigit)\(factorExpirationField)"
    }
    
    private static func verifyingDigit(barcode: String) -> String? {
        
        var total = 0
        var multiplyForTwo = true
        for char in barcode.characters.reversed() {
            guard let number = Int(String(char)) else {
                return nil
            }
            
            var numberMultiplied = 0
            
            if multiplyForTwo {
                multiplyForTwo = false
                numberMultiplied = (number*2)
                
            } else {
                multiplyForTwo = true
                numberMultiplied = (number*1)
            }
            
            if numberMultiplied >= 9 {
                
                let numberMultipliedString = "\(numberMultiplied)"
                
                for numberMultipliedChar in numberMultipliedString.characters {
                    guard let numberMultiplied = Int(String(numberMultipliedChar)) else {
                        return nil
                    }
                    total += numberMultiplied
                }
            } else {
                total += numberMultiplied
            }
        }
        
        let rest = total%10
        var result = 0
        if rest != 0 {
            result = 10 - rest
        }
        return "\(result)"
    }
    
    private static func verigyingMainDigit(barcode: String) -> String? {
        var total = 0
        var numberToMultiply = 2
        
        print(barcode.characters.reversed())
        for char in barcode.characters.reversed() {
            
            guard let number = Int(String(char)) else {return nil}
            
            total += (number*numberToMultiply)
            
            if numberToMultiply == 9 {
                numberToMultiply = 2
            } else {
                numberToMultiply += 1
            }
        }
        
        
        var result = 11 - (total%11)
        
        if result > 9 || result == 0 {
            result = 1
        }
        
        return "\(result)"
    }
}
