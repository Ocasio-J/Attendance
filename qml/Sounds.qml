import QtQuick 2.5
import QtMultimedia 5.6

QtObject {
    property Audio audio: Audio {
        playlist: Playlist {}
    }

    readonly property string rfidGoodSource: "file:////var/opt/RFIDGood.wav"
    readonly property string rfidBadSource: "file:////var/opt/RFIDBad.wav"
    readonly property string clockedInSource: "file:////var/opt/clockedIn.wav"

    function playGoodRFID() {
        audio.playlist.clear()
        audio.playlist.addItem(rfidGoodSource)
        audio.play()
    }

    function playBadRFID() {
        audio.playlist.clear()
        audio.playlist.addItem(rfidBadSource)
        audio.play()
    }

    function playClockedIn() {
        audio.playlist.clear()
        audio.playlist.addItem(clockedInSource)
        audio.play()
    }

    function playUserGreeting(rfid) {
        audio.playlist.addItem("file:///" + RosterManager.audioDirectory + rfid)
        audio.play()
    }
}
