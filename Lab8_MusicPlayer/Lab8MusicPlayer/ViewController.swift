import UIKit
import AVFoundation

struct Track {
    let title: String
    let artist: String
    let fileName: String
    let coverImageName: String
}

enum TrackLibrary {
    static let tracks: [Track] = [
        Track(title: "Арыс жағасында", artist: "Diana Sharapova", fileName: "track01", coverImageName: "Cover01"),
        Track(title: "Қайықта", artist: "Айгуль Гардисламова", fileName: "track02", coverImageName: "Cover02"),
        Track(title: "Әнім сен едің", artist: "Айдос Жабағин", fileName: "track03", coverImageName: "Cover03"),
        Track(title: "Қайдасың", artist: "Балуан Беркенов", fileName: "track04", coverImageName: "Cover04"),
        Track(title: "Бәрінен де сен сұлу", artist: "Дархан Жолдыбаев", fileName: "track05", coverImageName: "Cover05"),
        Track(title: "Бақыт құшағында", artist: "Расул Жармағамбетов", fileName: "track06", coverImageName: "Cover06"),
        Track(title: "Отан", artist: "Тахауи Рахметов", fileName: "track07", coverImageName: "Cover07"),
        Track(title: "Қуаныш вальсі", artist: "Төлеген Рахымбаев", fileName: "track08", coverImageName: "Cover08"),
        Track(title: "Шынарым", artist: "Фархат Кубиев", fileName: "track09", coverImageName: "Cover09"),
        Track(title: "Ол жалғыз, біз екеуміз", artist: "Бақтыгүл Бисембаева & Динара Надилбекова", fileName: "track10", coverImageName: "Cover10")
    ]
}

final class ViewController: UIViewController, AVAudioPlayerDelegate {
    @IBOutlet private weak var coverImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var artistLabel: UILabel!
    @IBOutlet private weak var playPauseButton: UIButton!

    private var player: AVAudioPlayer?
    private var trackIndex = 0
    private var isPlaying = false

    override func viewDidLoad() {
        super.viewDidLoad()
        coverImageView.layer.cornerRadius = 16
        coverImageView.clipsToBounds = true
        refreshUI()
        prepareCurrentTrack()
    }

    @IBAction private func previousTapped(_ sender: UIButton) {
        changeTrack(by: -1)
    }

    @IBAction private func playPauseTapped(_ sender: UIButton) {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            if player == nil { prepareCurrentTrack() }
            player?.play()
            isPlaying = player?.isPlaying ?? false
        }
        refreshUI()
    }

    @IBAction private func nextTapped(_ sender: UIButton) {
        changeTrack(by: 1)
    }

    private func changeTrack(by offset: Int) {
        let wasPlaying = isPlaying
        player?.stop()
        player = nil
        trackIndex = (trackIndex + offset + TrackLibrary.tracks.count) % TrackLibrary.tracks.count
        isPlaying = false
        prepareCurrentTrack()
        if wasPlaying {
            player?.play()
            isPlaying = player?.isPlaying ?? false
        }
        refreshUI()
    }

    private func prepareCurrentTrack() {
        let track = TrackLibrary.tracks[trackIndex]
        guard let url = Bundle.main.url(forResource: track.fileName, withExtension: "m4a", subdirectory: "Music") else {
            print("Missing audio file: \(track.fileName).m4a")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
        } catch {
            player = nil
            print("Unable to load audio: \(error)")
        }
    }

    private func refreshUI() {
        let track = TrackLibrary.tracks[trackIndex]
        titleLabel.text = track.title
        artistLabel.text = track.artist
        coverImageView.image = UIImage(named: track.coverImageName)
        let symbol = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: symbol), for: .normal)
        playPauseButton.accessibilityLabel = isPlaying ? "Pause" : "Play"
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard flag else {
            isPlaying = false
            refreshUI()
            return
        }
        // Keep playing continuously and wrap from the last track to the first.
        isPlaying = true
        changeTrack(by: 1)
    }
}
