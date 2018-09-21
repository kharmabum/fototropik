import Files // marathon:https://github.com/JohnSundell/Files.git
import Foundation

func renameImageFiles() throws {

    let albumsDir = try Folder(path: "../albums")

    for album in albumsDir.subfolders {
        let imageFiles = album.files.filter({ $0.extension != "md" }).sorted(by: {
            return $0.name.localizedStandardCompare($1.name) == .orderedAscending
        })

        for (index, file) in imageFiles.enumerated().reversed() { // reversed order reduce likelihood of name conflicts
            try file.rename(to: "\(album.name)-\(index + 1)")
        }

        let indexContents = """
        ---
        album_id: \(album.name)
        layout: album-page
        count: \(imageFiles.count)
        ---
        """

        let indexFile = try album.createFileIfNeeded(withName: "index.md")
        try indexFile.write(string: indexContents)
    }
}

func main() {

    do {
        try renameImageFiles()
    }
    catch {
        print(error)
    }

}

main()
