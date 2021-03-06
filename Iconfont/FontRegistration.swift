import UIKit

private class Path {

  static func basename(path: String) -> String {
    return ((path as NSString).lastPathComponent as NSString).stringByDeletingPathExtension
  }

  static func dirname(path: String) -> String {
    return (path as NSString).stringByDeletingLastPathComponent
  }

  static func extname(path: String) -> String {
    return (path as NSString).pathExtension
  }

}


/**
 Font Registration.

 e.g.
   - UIFont.register("Assets/Fonts/FontAwesome.otf")
   - UIFont.register("Assets/Fonts/FontAwesome.otf", bundle: NSBundle(forClass: YourClass.self))
 */
public extension UIFont {

  public static func register(path: String, bundle: NSBundle = NSBundle.mainBundle()) {

    struct Static {
      static var onceToken: dispatch_once_t = 0
    }

    let basename = Path.basename(path)

    if UIFont.fontNamesForFamilyName(basename).isEmpty {
      // Ensure single instance
      dispatch_once(&Static.onceToken) {
        let data = getFontData(path, bundle: bundle)

        registerGraphicsFont(data)
      }
    }
  }


  private static func getFontData(path: String, bundle: NSBundle) -> NSData {
    let basename = Path.basename(path)
    let dirname = Path.dirname(path)
    let extname = Path.extname(path)

    if let
      fontURL = bundle.URLForResource(basename, withExtension: extname, subdirectory: dirname),
      data = NSData(contentsOfURL: fontURL)
    {
      return data
    }

    fatalError("`\(path)` is not found in \(bundle).")
  }

  private static func registerGraphicsFont(data: NSData) {
    var error: Unmanaged<CFError>?

    if let
      provider = CGDataProviderCreateWithCFData(data),
      font = CGFontCreateWithDataProvider(provider)
    where !CTFontManagerRegisterGraphicsFont(font, &error) {
      print(error)
    }
  }

}
