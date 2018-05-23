public enum Result<Object> {
    case success(Object)
    case failure(NRLWalletSDKError)
}
