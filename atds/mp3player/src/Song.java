import javax.sound.sampled.*;
import java.io.IOException;
import java.util.Objects;

public class Song {

    private String filename;
    private String altName;

    private boolean isPlaying = false;
    
    private double duration = 0.0; // length in seconds
    private double priority = 0.0;

    private final AudioInputStream audioIn;
    private final Clip audioClip;

    public Song(String filename) throws UnsupportedAudioFileException, IOException, LineUnavailableException {
        audioIn = AudioSystem.getAudioInputStream(Objects.requireNonNull(Song.class.getResource("music.wav")));
        audioClip = AudioSystem.getClip();
        audioClip.open(audioIn);
        duration = audioIn.getFrameLength() / audioIn.getFormat().getFrameRate();
    }

    public void start() { // resume can also call this
        audioClip.start();
        isPlaying = true;
    }

    public void stop() {
        audioClip.stop();
        isPlaying = false;
        try {
            audioClip.open(audioIn);
        } catch (Exception e) {
            ; // will never happen, since it would have errored on constructor
        }
    }

    public void pause() {
        audioClip.stop();
        isPlaying = false;
    }

    public void setAltName(String altName) {
        this.altName = altName;
    }

    public String getFilename() {
        return filename;
    }

    public void setFilename(String filename) {
        this.filename = filename;
    }

    public String getAltName() {
        return altName;
    }

    public double getDuration() {
        return duration;
    }

    public double getPriority() {
        return priority;
    }

    public void setPriority(double priority) {
        this.priority = priority;
    }

    public boolean isPlaying() {
        return isPlaying;
    }

    public void setPlaying(boolean playing) {
        isPlaying = playing;
    }
}
