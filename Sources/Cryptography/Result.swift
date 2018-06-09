public enum ResultCrypto<Object> {
    case success(Object)
    case failure(NRLWalletSDKError)
}
