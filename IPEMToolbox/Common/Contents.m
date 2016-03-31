% Common functions of the IPEM Toolbox
%
% IPEMToolbox\Common
% ------------------------------------------------------------------------------
%
% General:
%   IPEMAdaptLevel                  - Adapt RMS level of signal to specified dB level
%   IPEMBellShape                   - Generate bell-shaped curve
%   IPEMBlockDC                     - Blocks DC (very low frequencies)
%   IPEMCalcCentroid                - Calculate centroid of multi-channel over signal
%   IPEMCalcCentroidWidth           - Calculate centroid width over multi-channel signal
%   IPEMCalcFFT                     - Calculate (and show) FFT of signal
%   IPEMCalcFlux                    - Calculate flux over multi-channel signal
%   IPEMCalcMeanAndVariance         - Calculate mean and variance over signal
%   IPEMCalcPeakLevel               - Calculate signal peak levels
%   IPEMCalcRMS                     - Calculate RMS value over signal
%   IPEMCalcSpectrogram             - Calculate (and show) spectrogram of signal
%   IPEMCalcZeroCrossingRate        - Calculate zero-crossing rate over signal
%   IPEMClip                        - Clip signal at low and/or high limits
%   IPEMCombFilter                  - Filter signal with comb filter
%   IPEMConvertToAMNoise            - Convert signal to amplitude modulated noise (and play back)
%   IPEMCountZeroCrossings          - Count number of zero-crossings in signal
%   IPEMCreateMask                  - Create mask from given start times and amplitudes (exp. decay)
%   IPEMEnvelopeFollower            - Follow the envelope of a signal
%   IPEMExtractSegments             - Extract segments from signal given some time segments
%   IPEMFadeLinear                  - Fade signal in and out using linear ramp function
%   IPEMFindAllPeaks                - Find all peaks in signal
%   IPEMFindNearestMinima           - Find nearest minima to left and right of peak
%   IPEMGenerateFrameBasedSegments  - Generate time segments using overlapping frames
%   IPEMGetAllCombinations          - Gets all combinations of multidimensional set of values
%   IPEMGetCrestFactor              - Get crest factor of signal
%   IPEMGetKurtosis                 - Get kurtosis of given data
%   IPEMGetLevel                    - Get average RMS level in dB 
%   IPEMGetRolloff                  - Get rolloff point for given fraction
%   IPEMGetSkew                     - Get skew of given data
%   IPEMHandleInputArguments        - Simple but general input handling routine
%   IPEMLeakyIntegration            - Calculate leaky integration with specified half decay time
%   IPEMNormalize                   - Normalize signal between-1 and 1
%   IPEMRescale                     - Rescale signal between limits
%   IPEMReshape                     - Remap amplitude values with given shaper function
%   IPEMRippleFilter                - Filter signal with ripple filter
%   IPEMRotateMatrix                - Rotate matrix along its rows and/or columns
%
% Tone related:
%   IPEMAMTone                      - Generate amplitude modulated tone
%   IPEMCalcNoteFrequency           - Calculate frequency for note (also non-standard tone-scales)
%   IPEMConvertToMIDINoteNr         - Convert note string (like 'A#4') to (MIDI) note number
%   IPEMConvertToNoteString         - Convert (MIDI) note number to note string
%   IPEMFindNoteFromFrequency       - Find note nearest to given frequency
%   IPEMGenerateBandPassedNoise     - Generate band passed white noise
%   IPEMHarmonicTone                - Generate tone with 10 harmonics
%   IPEMHarmonicToneComplex         - Generate chord with IPEMHarmonicTone
%   IPEMShepardTone                 - Generate Shepard tone
%   IPEMShepardToneComplex          - Generate chord with IPEMShepardTone
%   IPEMSineComplex                 - Generate sound composed of sines
%   IPEMToneScaleComparison         - Compares tonescales with different subdivisions to ideal case
%
% Graphics related:
%   IPEMAnimateSlices               - Displays animated plots of a 2D matrix.
%   IPEMExportFigures               - Export figures to specified graphics format
%   IPEMPlotMultiChannel            - Show graph of multi-channel signal
%   IPEMSetFigureLayout             - Change layout of figure to IPEM settings
%   IPEMShowSoundFile               - Show sound file in new or current graph
%
% Auditory perception related:
% + Auditory Nerve Images
%   IPEMCalcANI                     - Calculate auditory nerve image from signal
%   IPEMCalcANIFromFile             - Calculate auditory nerve image directly from sound file
%   IPEMLoadANI                     - Load auditory nerve image from mat file
%   IPEMSaveANI                     - Save auditory nerve image to mat file
%
% + Contextuality
%   IPEMContextualityIndex          - Calculate contextuality index
%
% + MEC (Minimal Energy Change)
%   IPEMMECAnalysis                 - Perform periodicity analysis using MEC model
%   IPEMMECExtractPatterns          - Extract best pattern from original signal using IPEMMECAnalysis results
%   IPEMMECReSynthUI                - User interface for interactively handling resynthesis of MEC results
%   IPEMMECSaveResults              - Save results of MECAnalysis and ExtractPatterns for later resynthesis
%   IPEMMECSynthesis                - Generate AM modulated noise from extracted pattern
%
% + Onsets
%   IPEMCalcOnsets                  - Calculate onset times in sound signal
%   IPEMCalcOnsetsFromANI           - Calculate onset times in sound signal starting from an ANI
%   IPEMDoOnsets                    - Convenience function for detecting onsets in sound file
%   IPEMOnsetPattern                - Calculate onset pattern using Integrate-and-fire neural net
%   IPEMOnsetPatternFilter          - Filters output of IPEMOnsetPattern
%   IPEMOnsetPeakDetection          - Return pattern having non-zero values on moments of possible onset peaks
%   IPEMOnsetPeakDetection1Channel  - Find possible onset peaks in one channel
%   IPEMSnipSoundFileAtOnsets       - Sound file segmentation using onset detector
%
% + Periodicity Pitch
%   IPEMPeriodicityPitch            - Calculate periodicity pitch from nerve image
%
% + Roughness
%   IPEMCalcRoughnessOfToneComplex  - Calculate roughness for superposition of constant and chirping tone complex
%   IPEMCalcRoughnessOverSubParts   - Calculate roughness for mixed pitch shifted sound file
%   IPEMGetRoughnessFFTReference    - Get reference value for IPEMRoughnessFFT at specified dB level
%   IPEMRoughnessFFT                - Calculate roughness using synchronization index model
%   IPEMRoughnessOfSoundPairs       - Calculate roughness of 2-by-2 combinations of sounds
%
% Various:
%   IPEMBatchExtractSoundFragment   - Extracts fragments from sound files and writes them to new sound files
%   IPEMEnsureDirectory             - Ensure existence of directory
%   IPEMGeneratePitchShiftScript    - Generate CoolEdit2000 script to pitch shift sound file
%   IPEMGetFileList.m               - Gets list of files in directory using file name pattern
%   IPEMPlaySoundWithCursor         - Plays sound signal while showing a moving cursor
%   IPEMReadSoundFile               - Read (part of) a sound file into memory
%   IPEMReplaceSubStringInFileNames - Replaces substring in filenames by new string
%   IPEMSaveVar                     - Save variable with specified name to mat file
%   IPEMSnipSoundFile               - Snip sound file into segments
%   IPEMStripFileSpecification      - Strip file specification into name, extension, path, ...
%   IPEMToolboxVersion              - Return IPEM Toolbox version
%   IPEMWriteSoundFile              - Write (part of) an audio signal to a sound file
