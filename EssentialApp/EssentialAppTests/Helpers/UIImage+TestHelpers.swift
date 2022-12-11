//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit

extension UIImage {
	static func make(withColor color: UIColor) -> UIImage {
        let imageSize = CGSize(width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat(for: .current)
        format.scale = 1
        let renderer = UIGraphicsImageRenderer.init(size: imageSize, format: format)
        
        return renderer.image { context in
            color.setFill()
            context.fill(.init(origin: .zero, size: imageSize))
        }
	}
}
