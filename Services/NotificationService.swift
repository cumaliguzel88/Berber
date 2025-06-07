import Foundation
import UserNotifications

protocol NotificationServiceProtocol {
    func requestAuthorization(completion: @escaping (Bool) -> Void)
    func scheduleNotification(for appointment: Appointment)
}

final class NotificationService: NotificationServiceProtocol {
    private let center = UNUserNotificationCenter.current()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            completion(granted)
        }
    }
    
    func scheduleNotification(for appointment: Appointment) {
        let content = UNMutableNotificationContent()
        content.title = "Randevu Yaklaşıyor"
        content.body = "⏰ \(appointment.customerName) için 10 dakika kaldı."
        content.sound = .default
        let triggerDate = Calendar.current.date(byAdding: .minute, value: -10, to: appointment.startDate) ?? appointment.startDate
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let request = UNNotificationRequest(
            identifier: appointment.id.uuidString,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        )
        center.add(request) { error in
            if let error = error {
                print("[NotificationService] Bildirim planlama hatası: \(error.localizedDescription)")
            } else {
                print("[NotificationService] Bildirim planlandı: \(appointment.customerName) - \(triggerDate)")
            }
        }
    }
} 