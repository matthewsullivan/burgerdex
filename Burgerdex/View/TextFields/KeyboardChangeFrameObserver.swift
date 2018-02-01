import UIKit

/**
	Created for answer on StackOverflow: https://stackoverflow.com/a/48217755/4532985

	Don't forget to call `observeKeyboardFrameChanges()`.

	### Example usage with tableView:

	```
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		observeKeyboardFrameChanges()
	}

	func willChangeKeyboardFrame(height: CGFloat, animationDuration: TimeInterval, animationOptions: UIViewAnimationOptions) {
		var adjustedHeight = height

		if let tabBarHeight = self.tabBarController?.tabBar.frame.height {
			adjustedHeight -= tabBarHeight
		} else if let toolbarHeight = navigationController?.toolbar.frame.height, navigationController?.isToolbarHidden == false {
			adjustedHeight -= toolbarHeight
		}

		if adjustedHeight < 0 { adjustedHeight = 0 }

		UIView.animate(withDuration: animationDuration, animations: {
			let newInsets = UIEdgeInsets(top: 0, left: 0, bottom: adjustedHeight, right: 0)
			self.tableView.contentInset = newInsets
			self.tableView.scrollIndicatorInsets = newInsets
		})
	}
	```
**/
protocol KeyboardChangeFrameObserver: class {

	func willChangeKeyboardFrame(height: CGFloat, animationDuration: TimeInterval, animationOptions: UIViewAnimationOptions)
	
}

extension KeyboardChangeFrameObserver {
	
	func observeKeyboardFrameChanges() {
		let center = NotificationCenter.default
		
		var willChangeFrameObserver: NSObjectProtocol?
		willChangeFrameObserver = center.addObserver(forName: .UIKeyboardWillChangeFrame, object: nil, queue: .main) { [weak self] (notification) in
			guard let me = self else {
				if let observer = willChangeFrameObserver {
					center.removeObserver(observer)
				}
				return
			}
			
			me.sendDelegate(notification: notification, willHide: false)
		}
		
		var willHideObserver: NSObjectProtocol?
		willHideObserver = center.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: .main) { [weak self] (notification) in
			guard let me = self else {
				if let observer = willHideObserver {
					center.removeObserver(observer)
				}
				return
			}
			
			me.sendDelegate(notification: notification, willHide: true)
		}
	}
	
	private func sendDelegate(notification: Notification, willHide: Bool) {
		guard let userInfo = notification.userInfo,
			let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double,
			let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
			let rawAnimationCurveNumber = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber else { return }
		
		let rawAnimationCurve = rawAnimationCurveNumber.uint32Value << 16
		let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
		
		let keyboardHeight = willHide ? 0 : keyboardEndFrame.height

		willChangeKeyboardFrame(height: keyboardHeight,
						animationDuration: animationDuration,
						animationOptions: [.beginFromCurrentState, animationCurve])
	}

}