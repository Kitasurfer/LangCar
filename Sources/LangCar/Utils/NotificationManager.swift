#if os(iOS)
import UserNotifications

public actor NotificationManager {
    public static let shared = NotificationManager()
    private init() {}
    
    public func requestAuthorization() async {
        try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }
    
    /// Schedule reminder at explicit hour (0-23)
    public func scheduleDailyReminder(hour: Int, wordsDue: Int) async {
        let center = UNUserNotificationCenter.current()
        await center.removeAllPendingNotificationRequests()
        guard wordsDue > 0 else { return }
        var dc = DateComponents()
        dc.hour = hour
        let trig = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        let c = UNMutableNotificationContent()
        c.title = "LangCar"
        c.body = "Сегодня нужно повторить \(wordsDue) слов. За руль! 🚗"
        let req = UNNotificationRequest(identifier: "dailyReview", content: c, trigger: trig)
        await center.add(req)
    }

    /// Smart: если autoMode = true, час = ранее сохранённый час (<12 → 8, иначе 20)
    public func smartSchedule(autoMode: Bool, lastStudyHour: Int?, wordsDue: Int) async {
        let targetHour: Int = {
            if !autoMode { return 19 }
            guard let h = lastStudyHour else { return 19 }
            return h < 12 ? 8 : 20
        }()
        await scheduleDailyReminder(hour: targetHour, wordsDue: wordsDue)
    }
}
#endif
