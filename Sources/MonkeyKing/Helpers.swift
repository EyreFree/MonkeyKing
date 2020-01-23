
import UIKit

extension MonkeyKing {

    class func fetchWeChatOAuthInfoByCode(code: String, completionHandler: @escaping OAuthCompletionHandler) {
        var appID = ""
        var appKey = ""

        for case .weChat(let id, let key, _) in shared.accountSet {
            guard let key = key else {
                completionHandler(["code": code], nil, nil)
                return
            }

            appID = id
            appKey = key
        }

        var urlComponents = URLComponents(string: "https://api.weixin.qq.com/sns/oauth2/access_token")
        urlComponents?.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "appid", value: appID),
            URLQueryItem(name: "secret", value: appKey),
            URLQueryItem(name: "code", value: code),
        ]

        guard let accessTokenAPI = urlComponents?.string else {
            completionHandler(["code": code], nil, nil)
            return
        }

        // OAuth
        shared.request(accessTokenAPI, method: .get) { json, response, error in
            completionHandler(json, response, error)
        }
    }

    class func fetchWeiboOAuthInfoByCode(code: String, completionHandler: @escaping OAuthCompletionHandler) {
        var appID = ""
        var appKey = ""
        var redirectURL = ""

        for case .weibo(let id, let key, let url) in shared.accountSet {
            appID = id
            appKey = key
            redirectURL = url
        }

        var urlComponents = URLComponents(string: "https://api.weibo.com/oauth2/access_token")
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: appID),
            URLQueryItem(name: "client_secret", value: appKey),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "redirect_uri", value: redirectURL),
            URLQueryItem(name: "code", value: code),
        ]

        guard let accessTokenAPI = urlComponents?.string else {
            completionHandler(["code": code], nil, nil)
            return
        }

        shared.request(accessTokenAPI, method: .post) { json, response, error in
            completionHandler(json, response, error)
        }
    }

    func request(_ urlString: String, method: Networking.Method, parameters: [String: Any]? = nil, encoding: Networking.ParameterEncoding = .url, headers: [String: String]? = nil, completionHandler: @escaping Networking.NetworkingResponseHandler) {
        Networking.shared.request(urlString, method: method, parameters: parameters, encoding: encoding, headers: headers, completionHandler: completionHandler)
    }

    func upload(_ urlString: String, parameters: [String: Any], headers: [String: String]? = nil, completionHandler: @escaping Networking.NetworkingResponseHandler) {
        Networking.shared.upload(urlString, parameters: parameters, headers: headers, completionHandler: completionHandler)
    }

    class func openURL(urlString: String, options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:], completionHandler completion: ((Bool) -> Swift.Void)? = nil) {
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            completion?(false)
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: options) { flag in
                completion?(flag)
            }
        } else {
            completion?(UIApplication.shared.openURL(url))
        }
    }

    class func openURL(urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return UIApplication.shared.openURL(url)
    }

    func canOpenURL(urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}
