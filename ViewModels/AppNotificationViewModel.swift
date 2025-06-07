import Foundation
import UserNotifications

final class AppNotificationViewModel: ObservableObject {
    @Published var notificationPermissionGranted: Bool = false
    private let notificationService: NotificationServiceProtocol
    
    init(notificationService: NotificationServiceProtocol = NotificationService()) {
        self.notificationService = notificationService
    }
    
    func requestNotificationPermission() {
        notificationService.requestAuthorization { [weak self] granted in
            DispatchQueue.main.async {
                self?.notificationPermissionGranted = granted
                print("[AppNotificationViewModel] Bildirim izni: \(granted)")
            }
        }
    }
} 