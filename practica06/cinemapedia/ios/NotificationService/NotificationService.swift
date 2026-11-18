import Foundation
import UserNotifications

final class NotificationService: UNNotificationServiceExtension {
  private let lock = NSLock()
  private var completion: ((UNNotificationContent) -> Void)?
  private var fallback: UNNotificationContent?
  private var download: URLSessionDownloadTask?

  override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler handler: @escaping (UNNotificationContent) -> Void
  ) {
    completion = handler
    fallback = request.content
    let options = request.content.userInfo["fcm_options"] as? [String: Any]
    guard let value = options?["image"] as? String
      ?? request.content.userInfo["image"] as? String,
      let url = URL(string: value), url.scheme == "https", url.host != nil,
      ["jpg", "jpeg", "png", "gif"].contains(url.pathExtension.lowercased())
    else {
      finish(request.content)
      return
    }

    let configuration = URLSessionConfiguration.ephemeral
    configuration.timeoutIntervalForRequest = 8
    configuration.timeoutIntervalForResource = 12
    let session = URLSession(configuration: configuration)
    download = session.downloadTask(with: url) { [weak self] location, response, _ in
      defer { session.finishTasksAndInvalidate() }
      guard let self else { return }
      guard let location, let response = response as? HTTPURLResponse,
        response.statusCode == 200, response.url?.scheme == "https",
        let size = try? location.resourceValues(forKeys: [.fileSizeKey]).fileSize,
        size <= 5 * 1024 * 1024,
        let content = request.content.mutableCopy() as? UNMutableNotificationContent
      else {
        self.finish(request.content)
        return
      }
      let attachment = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
        .appendingPathExtension(url.pathExtension)
      defer { try? FileManager.default.removeItem(at: attachment) }
      do {
        try FileManager.default.moveItem(at: location, to: attachment)
        content.attachments = [try UNNotificationAttachment(identifier: "movie", url: attachment)]
        self.finish(content)
      } catch {
        self.finish(request.content)
      }
    }
    download?.resume()
  }

  override func serviceExtensionTimeWillExpire() {
    download?.cancel()
    if let fallback { finish(fallback) }
  }

  private func finish(_ content: UNNotificationContent) {
    lock.lock()
    let handler = completion
    completion = nil
    lock.unlock()
    handler?(content)
  }
}
