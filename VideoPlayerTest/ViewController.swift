//
//  ViewController.swift
//  VideoPlayerTest
//
//  Created by Misha on 31.05.2022.
//

import UIKit
import AVFoundation

final class ViewController: UIViewController {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var items: [AVPlayerItem] = []
    
    private var isVideoPlaying = false
    
    private var videoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var forwardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.addTarget(self, action: #selector(forwardButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var backwardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.addTarget(self, action: #selector(backwardButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private var pastTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "00:00"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var timeLeftLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "00:00"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        view.addSubview(videoView)
        view.addSubview(playButton)
        view.addSubview(forwardButton)
        view.addSubview(backwardButton)
        view.addSubview(slider)
        view.addSubview(pastTimeLabel)
        view.addSubview(timeLeftLabel)
        setupConstraints()
        
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "1", ofType: "mp4")!)
        let url2 = URL(fileURLWithPath: Bundle.main.path(forResource: "2", ofType: "mp4")!)
        
        let playFirstItem = AVPlayerItem(url: url)
        let playSecondItem = AVPlayerItem(url: url2)
       
        items = [playFirstItem, playSecondItem]
        
        player = AVPlayer(playerItem: items.first)
        player?.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        
        addTimeObserver()
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resize
        
        videoView.layer.addSublayer(playerLayer!)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoView.bounds
    }

    func setupConstraints() {
        
        videoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        videoView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        videoView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        videoView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        playButton.topAnchor.constraint(equalTo: videoView.bottomAnchor, constant: 50).isActive = true
        playButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        backwardButton.topAnchor.constraint(equalTo: playButton.topAnchor).isActive = true
        backwardButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -20).isActive = true
        backwardButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        backwardButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        forwardButton.topAnchor.constraint(equalTo: playButton.topAnchor).isActive = true
        forwardButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 20).isActive = true
        forwardButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        forwardButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        slider.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 50).isActive = true
        slider.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 70).isActive = true
        slider.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -70).isActive = true
        slider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        pastTimeLabel.topAnchor.constraint(equalTo: slider.topAnchor).isActive = true
        pastTimeLabel.trailingAnchor.constraint(equalTo: slider.leadingAnchor, constant: -10).isActive = true
        
        timeLeftLabel.topAnchor.constraint(equalTo: slider.topAnchor).isActive = true
        timeLeftLabel.leadingAnchor.constraint(equalTo: slider.trailingAnchor, constant: 10).isActive = true
    }
    
    //Observers
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration", let duration = player?.currentItem?.duration.seconds, duration > 0.0 {
            guard let currentItem = self.player?.currentItem else { return }
            self.timeLeftLabel.text = getTimeString(from: (currentItem.duration))
        }
    }
    
    func getTimeString(from time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds/3600)
        let minutes = Int(totalSeconds/60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", arguments: [hours, minutes,seconds])
        } else {
            return String(format: "%02i:%02i", arguments: [minutes,seconds])
        }
    }
    
    func addTimeObserver() {
        
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        _ = player?.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] time in
            guard let currentItem = self?.player?.currentItem else { return }
            guard currentItem.status.rawValue == AVPlayerItem.Status.readyToPlay.rawValue else {return}
            self?.slider.maximumValue = Float(currentItem.duration.seconds)
            self?.slider.minimumValue = 0
            self?.slider.value = Float(currentItem.currentTime().seconds)
            self?.pastTimeLabel.text = self?.getTimeString(from: currentItem.currentTime())
             
        })
    }
    
    @objc func playButtonPressed() {
        if isVideoPlaying {
            player?.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player?.play()
            playButton.setImage(UIImage(systemName: "pause"), for: .normal)
        }
        
        isVideoPlaying = !isVideoPlaying
    }
    
    @objc func forwardButtonPressed() {
        player?.currentItem?.removeObserver(self, forKeyPath: "duration")
        player?.replaceCurrentItem(with: items[1])
    }
    
    @objc func backwardButtonPressed() {
        player?.replaceCurrentItem(with: items.first)
    }
}

