public struct Configuration {
    public let network: Network
    public let nodeEndpoint: String
    public let etherscanAPIKey: String
    
    public init(network: Network, nodeEndpoint: String, etherscanAPIKey: String) {
        self.network = network
        self.nodeEndpoint = nodeEndpoint
        self.etherscanAPIKey = etherscanAPIKey
    }
    
    public var etherscanURL: URL {
        switch network {
        case .main(.ethereum):
            return URL(string: "https://api.etherscan.io")!
            
        case .test(.ethereum):
            return URL(string: "https://ropsten.etherscan.io")!
        default:
            return URL(string: "https://api.etherscan.io")!
        }
    }
}
