//
//  Data+Encoding.swift
//
//
//  Copied by Terry Yiu on 5/28/23 from https://github.com/planetary-social/nos/blob/main/Nos/Extensions/Data%2BEncoding.swift
//  Permission to redistribute this code under MIT license granted nostr:note1q39598qkdc093sdq4enudjf0dall76s7n779k07nutgd9r2zt6vq96l8c2
//  Created by Matthew Lorentz for Nos on 2/3/23.
//

import Foundation

extension Data {
    var hexString: String {
        let hexDigits = Array("0123456789abcdef".utf16)
        var hexChars = [UTF16.CodeUnit]()
        hexChars.reserveCapacity(bytes.count * 2)

        for byte in self {
            let (index1, index2) = Int(byte).quotientAndRemainder(dividingBy: 16)
            hexChars.append(hexDigits[index1])
            hexChars.append(hexDigits[index2])
        }

        return String(utf16CodeUnits: hexChars, count: hexChars.count)
    }

    /// Converts base two bytes to base 5
    var base5: Data {
        var outputSize = (count * 8) / 5
        if ((count * 8) % 5) != 0 {
            outputSize += 1
        }
        var outputArray: [UInt8] = []
        for i in (0..<outputSize) {
            let quotient = (i * 5) / 8
            let remainder = (i * 5) % 8
            var element = self[quotient] << remainder
            element >>= 3

            if (remainder > 3) && (i + 1 < outputSize) {
                element = element | (self[quotient + 1] >> (8 - remainder + 3))
            }

            outputArray.append(element)
        }

        return Data(outputArray)
    }

    var base8FromBase5: Data? {
        let destinationBase = 8
        let startingBase = 5
        let maxValueMask: UInt32 = ((UInt32(1)) << 8) - 1
        var value: UInt32 = 0
        var bits: Int = 0
        var output = Data()

        for i in (0..<count) {
            value = (value << startingBase) | UInt32(self[i])
            bits += startingBase
            while bits >= destinationBase {
                bits -= destinationBase
                output.append(UInt8((value >> bits) & maxValueMask))
            }
        }

        if ((value << (destinationBase - bits)) & maxValueMask) != 0 || bits >= startingBase {
            return nil
        }

        return output
    }
}
