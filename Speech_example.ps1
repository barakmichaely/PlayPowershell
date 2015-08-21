$Path = "$env:temp\file.mp3"

Add-Type -AssemblyName System.Speech

$synthesizer = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer
$synthesizer.SetOutputToWaveFile($Path)
$synthesizer.Speak('This is a recording file for team client.')
$synthesizer.Speak('Adding more info later to it')
$synthesizer.Speak('Thank you for your time, ass hole')
$synthesizer.SetOutputToDefaultAudioDevice()

# Play back the recorded file
Invoke-Item $Path