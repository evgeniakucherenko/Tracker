import UIKit

final class DatePickerConfigurator {
    static func createDatePicker(
        locale: Locale = Locale(identifier: "ru_RU"),
        mode: UIDatePicker.Mode = .date,
        style: UIDatePickerStyle = .compact,
        
        cornerRadius: CGFloat = 8
    ) -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.locale = locale
        datePicker.datePickerMode = mode
        datePicker.preferredDatePickerStyle = style
        datePicker.layer.cornerRadius = cornerRadius
        datePicker.clipsToBounds = true
        datePicker.overrideUserInterfaceStyle = .light
        return datePicker
    }
}
