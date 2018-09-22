import Files // marathon:https://github.com/JohnSundell/Files.git
import ShellOut // marathon:https://github.com/JohnSundell/ShellOut.git
import Foundation

/// Returns the element at the specified index iff it is within bounds, otherwise nil.
extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

/// Handle to write to standard output
extension FileHandle: TextOutputStream {
  public func write(_ string: String) {
    guard let data = string.data(using: .utf8) else { return }
    self.write(data)
  }
}

/// Write to console's standard output
func stdout(_ string: String) {
    var out = FileHandle.standardOutput
    print(string, to:&out)
}


let arguments = CommandLine.arguments
let targetDirectoryPath = arguments[safe: 1] ?? "."
let bucketName = "fototropik" // could accept as another arg

func uploadImage(_ image: File) throws {
    assert(image.extension == "jpg")
    // print("image name: \(image.name)")
    // print("image path: \(image.path)")
    // print("image parent name: \(image.parent!.name)")

    let filePath = image.path
    let destinationPath = "albums/" + image.parent!.name + "/" + image.name

    stdout("UPLOADING")
    stdout("filePath: \(filePath)")
    stdout("destinationPath: \(destinationPath)")
    let output = try shellOut(to: "b2", arguments: ["upload_file", bucketName, filePath, destinationPath])
    stdout("UPLOADED: \(destinationPath)")
    stdout(output)
}

func uploadImages() throws {
    print("targetDirectoryPath: \(targetDirectoryPath)")
    let dir = try Folder(path: targetDirectoryPath)

    // Upload all images in directory
    for file in dir.files {
        guard file.extension == "jpg" else { continue }
        try uploadImage(file)
    }

    // Upload all images in all subdirectories
    try dir.makeSubfolderSequence(recursive: true).forEach { folder in
        stdout("folder.name: \(folder.name)")

        for file in folder.files {
            guard file.extension == "jpg" else { continue }
            try uploadImage(file)
        }
    }
}


func main() {

    do {
        try uploadImages()
    }
    catch {
        print(error)
    }

}

main()
