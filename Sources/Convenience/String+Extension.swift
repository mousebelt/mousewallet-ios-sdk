import Foundation

extension String {
    var fullRange: Range<Index> {
        return startIndex..<endIndex
    }
    
    var fullNSRange: NSRange {
        return NSRange(fullRange, in: self)
    }

    func lastIndex(of char: Character) -> Index? {
        guard let range = range(of: String(char), options: .backwards) else {
            return nil
        }
        return range.lowerBound
    }
    
    func index(of char: Character) -> Index? {
        guard let range = range(of: String(char)) else {
            return nil
        }
        return range.lowerBound
    }

    func split(intoChunksOf chunkSize: Int) -> [String] {
        var output = [String]()
        let splittedString = self
            .map { $0 }
            .split(intoChunksOf: chunkSize)
        splittedString.forEach {
            output.append($0.map { String($0) }.joined(separator: ""))
        }
        return output
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(self.startIndex, offsetBy: bounds.lowerBound)
        let end = index(self.startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(self.startIndex, offsetBy: bounds.lowerBound)
        let end = index(self.startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }
    
    func interpretAsBinaryData() -> Data? {
        let padded = self.padding(toLength: ((self.count + 7) / 8) * 8, withPad: "0", startingAt: 0)
        let byteArray = padded.split(intoChunksOf: 8).map { UInt8(strtoul($0, nil, 2)) }
        return Data(byteArray)
    }
    
    func hasHexPrefix() -> Bool {
        return self.hasPrefix("0x")
    }
    
    func stripHexPrefix() -> String {
        if self.hasPrefix("0x") {
            let indexStart = self.index(self.startIndex, offsetBy: 2)
            return String(self[indexStart...])
        }
        return self
    }
    
    func addHexPrefix() -> String {
        if !self.hasPrefix("0x") {
            return "0x" + self
        }
        return self
    }
    
    func stripLeadingZeroes() -> String? {
        let hex = self.addHexPrefix()
        guard let matcher = try? NSRegularExpression(pattern: "^(?<prefix>0x)0*(?<end>[0-9a-fA-F]*)$", options: NSRegularExpression.Options.dotMatchesLineSeparators) else {return nil}
        let match = matcher.captureGroups(string: hex, options: NSRegularExpression.MatchingOptions.anchored)
        guard let prefix = match["prefix"] else {return nil}
        guard let end = match["end"] else {return nil}
        if (end != "") {
            return prefix + end
        }
        return "0x0"
    }
    
    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map { result.range(at: $0).location != NSNotFound
                ? nsString.substring(with: result.range(at: $0))
                : ""
            }
        }
    }
    
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: utf16.endIndex),
            let from = from16.samePosition(in: self),
            let to = to16.samePosition(in: self)
            else { return nil }
        return from ..< to
    }
}

extension String {
    func toData() -> Data {
        return decomposedStringWithCompatibilityMapping.data(using: .utf8)!
    }
}

public extension String {
    
    func hash160() -> String? {
        //NEO Address hash160
        //skip the first byte which is 0x17, revert it then convert to full hex
        let bytes = self.base58CheckDecodedBytes!
        let reverse = Data(bytes: bytes[1...bytes.count - 1].reversed())
        return reverse.fullHexString
    }
    
    func hashFromAddress() -> String {
        let bytes = self.base58CheckDecodedBytes!
        let shortened = bytes[0...20] //need exactly twenty one bytes
        let finalKeyData = Data(bytes: shortened[1...shortened.count - 1])
        return finalKeyData.fullHexString
    }
    
    func scriptHash() -> Data {
        let bytes = self.base58CheckDecodedBytes!
        let shortened = bytes[0...20] //need exactly twenty one bytes
        let finalKeyData = Data(bytes: shortened[1...shortened.count - 1])
        return finalKeyData
    }
    
    func toHexString() -> String {
        let data = self.data(using: .utf8)!
        let hexString = data.map{ String(format:"%02x", $0) }.joined()
        return hexString
    }
    
    func dataWithHexString() -> Data {
        var hex = self
        var data = Data()
        while(hex.characters.count > 0) {
            let c: String = hex.substring(to: hex.index(hex.startIndex, offsetBy: 2))
            hex = hex.substring(from: hex.index(hex.startIndex, offsetBy: 2))
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return data
    }
}
