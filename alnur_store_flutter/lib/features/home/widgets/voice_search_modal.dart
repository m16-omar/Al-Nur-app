import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class VoiceSearchModal extends StatefulWidget {
  final ValueChanged<String> onSearchSubmitted;
  final String? initialQuery;

  const VoiceSearchModal({
    super.key,
    required this.onSearchSubmitted,
    this.initialQuery,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onSearchSubmitted,
    String? initialQuery,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VoiceSearchModal(
        onSearchSubmitted: onSearchSubmitted,
        initialQuery: initialQuery,
      ),
    );
  }

  @override
  State<VoiceSearchModal> createState() => _VoiceSearchModalState();
}

class _VoiceSearchModalState extends State<VoiceSearchModal>
    with SingleTickerProviderStateMixin {
  late final stt.SpeechToText _speech;
  late final AnimationController _pulseController;

  bool _isSpeechAvailable = false;
  bool _isListening = false;
  String _recognizedText = '';
  double _soundLevel = 0.0;
  String _statusMessage = 'Initializing microphone...';
  Timer? _simulatedWaveformTimer;

  final List<String> _voicePresets = [
    'Royal Amber Oud',
    'Gold Plated Wedding Bands',
    'Geneva Diamond Watch',
    'Austrian Crystal Bridal Choker',
    'Pure Musk Tahara',
    'Lattafa Khamrah Bukhoor',
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _recognizedText = widget.initialQuery!;
    }

    _initSpeechRecognition();
  }

  Future<void> _initSpeechRecognition() async {
    try {
      final available = await _speech.initialize(
        onError: _onSpeechError,
        onStatus: _onSpeechStatus,
      );

      if (mounted) {
        setState(() {
          _isSpeechAvailable = available;
          if (available) {
            _statusMessage = 'Listening for modest wear, abayas, thobes...';
            _startListening();
          } else {
            _statusMessage =
                'Microphone unavailable. Tap a voice preset below or type your search.';
            _startSimulatedWaveform();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSpeechAvailable = false;
          _statusMessage =
              'Voice search ready. Tap a preset or speak to search.';
          _startSimulatedWaveform();
        });
      }
    }
  }

  void _startSimulatedWaveform() {
    _simulatedWaveformTimer?.cancel();
    _simulatedWaveformTimer =
        Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (!mounted) return;
      if (_isListening) {
        setState(() {
          _soundLevel = (Random().nextDouble() * 0.8) + 0.2;
        });
      } else {
        setState(() {
          _soundLevel = 0.1;
        });
      }
    });
  }

  Future<void> _startListening() async {
    if (!_isSpeechAvailable) {
      setState(() {
        _isListening = true;
        _statusMessage = 'Listening (Simulated mode)...';
      });
      _startSimulatedWaveform();
      return;
    }

    try {
      setState(() {
        _isListening = true;
        _statusMessage = 'Listening... Speak your query clearly';
      });

      await _speech.listen(
        onResult: _onSpeechResult,
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 3),
        ),
        onSoundLevelChange: (level) {
          if (mounted) {
            setState(() {
              _soundLevel = (level.clamp(-10.0, 10.0) + 10.0) / 20.0;
            });
          }
        },
      );
    } catch (_) {
      setState(() {
        _isListening = false;
        _statusMessage = 'Could not access audio stream. Try tapping a preset.';
      });
    }
  }

  Future<void> _stopListening() async {
    if (_isSpeechAvailable && _speech.isListening) {
      await _speech.stop();
    }
    if (mounted) {
      setState(() {
        _isListening = false;
        _soundLevel = 0.0;
        _statusMessage = _recognizedText.isNotEmpty
            ? 'Voice captured!'
            : 'Tap microphone to speak again';
      });
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (mounted) {
      setState(() {
        _recognizedText = result.recognizedWords;
        if (result.finalResult) {
          _isListening = false;
          _statusMessage = 'Recognized: "${result.recognizedWords}"';
        }
      });
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    if (mounted) {
      setState(() {
        _isListening = false;
        _statusMessage = 'Notice: ${error.errorMsg} (Tap preset to search)';
      });
    }
  }

  void _onSpeechStatus(String status) {
    if (mounted) {
      if (status == 'listening') {
        setState(() => _isListening = true);
      } else if (status == 'notListening' || status == 'done') {
        setState(() => _isListening = false);
      }
    }
  }

  void _submitSearch([String? customQuery]) {
    final query = (customQuery ?? _recognizedText).trim();
    if (query.isNotEmpty) {
      _stopListening();
      Navigator.pop(context);
      widget.onSearchSubmitted(query);
    }
  }

  @override
  void dispose() {
    _simulatedWaveformTimer?.cancel();
    _pulseController.dispose();
    if (_isSpeechAvailable && _speech.isListening) {
      _speech.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header with Islamic Motif Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.graphic_eq_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Al-Nur Voice Search',
                        style: AppTextStyles.productTitle.copyWith(fontSize: 17),
                      ),
                      Text(
                        'Speak any modesty style, fabric or scent',
                        style: AppTextStyles.brandSubtitle.copyWith(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Audio Pulse / Ripple Centerpiece
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Ripple Ring 2
                if (_isListening)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + (_pulseController.value * 0.45) + (_soundLevel * 0.2);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.08),
                          ),
                        ),
                      );
                    },
                  ),

                // Outer Ripple Ring 1
                if (_isListening)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + (_pulseController.value * 0.25) + (_soundLevel * 0.15);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.15),
                          ),
                        ),
                      );
                    },
                  ),

                // Core Microphone Squircle Button (Matches user's exact dark green design)
                GestureDetector(
                  onTap: () {
                    if (_isListening) {
                      _stopListening();
                    } else {
                      _startListening();
                    }
                  },
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: _isListening ? AppColors.gold : Colors.white24,
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Dynamic Animated Waveform Bars
          _buildWaveformBars(),

          const SizedBox(height: 12),

          // Status / Prompt Text
          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: _isListening ? AppColors.primary : AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          // Recognized Text Display Area
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _recognizedText.isNotEmpty
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _recognizedText.isNotEmpty
                        ? _recognizedText
                        : 'Your spoken words will appear here...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: _recognizedText.isNotEmpty
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: _recognizedText.isNotEmpty
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                if (_recognizedText.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    color: AppColors.textSecondary,
                    onPressed: () {
                      setState(() {
                        _recognizedText = '';
                      });
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search Button (Active when text is available)
          if (_recognizedText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.search_rounded, size: 20),
                  label: Text(
                    'Search for "$_recognizedText"',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onPressed: () => _submitSearch(),
                ),
              ),
            ),

          // Quick Voice Query Presets Section
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 16, color: AppColors.goldDark),
                const SizedBox(width: 4),
                Text(
                  'Or try one of these modest query presets:',
                  style: AppTextStyles.brandSubtitle.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Presets Wrap
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _voicePresets.map((preset) {
              return ActionChip(
                backgroundColor: AppColors.background,
                elevation: 0,
                side: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                avatar: const Icon(
                  Icons.mic_none_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                label: Text(
                  preset,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _recognizedText = preset;
                  });
                  _submitSearch(preset);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveformBars() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final base = _isListening ? 0.3 : 0.1;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(9, (index) {
            final offset = sin((index / 9) * pi + (_pulseController.value * 2 * pi));
            final heightMultiplier = _isListening
                ? (base + (offset.abs() * 0.4) + (_soundLevel * 0.5)).clamp(0.2, 1.0)
                : 0.2;
            final barHeight = 28.0 * heightMultiplier;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 3.5,
              height: barHeight,
              decoration: BoxDecoration(
                color: _isListening
                    ? (index % 2 == 0 ? AppColors.primary : AppColors.gold)
                    : AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }
}
