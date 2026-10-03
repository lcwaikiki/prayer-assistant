import 'package:flutter/material.dart';

class AudioSpeedBar extends StatelessWidget {
  const AudioSpeedBar({
    super.key,
    required this.speed,
    required this.onSpeedChanged,
    this.minSpeed = 0.5,
    this.maxSpeed = 4.0,
    this.step = 0.05,
    this.presets = const [1.0, 1.25, 1.5, 2.0, 3.0, 4.0],
  });

  final double speed;
  final ValueChanged<double> onSpeedChanged;
  final double minSpeed;
  final double maxSpeed;
  final double step;
  final List<double> presets;

  double _roundToStep(double value) {
    final rounded = (value / step).round() * step;
    return double.parse(rounded.toStringAsFixed(2)).clamp(minSpeed, maxSpeed);
  }

  void _decreaseSpeed() {
    final next = _roundToStep(speed - step);
    onSpeedChanged(next);
  }

  void _increaseSpeed() {
    final next = _roundToStep(speed + step);
    onSpeedChanged(next);
  }

  String _formatSpeed(double val) {
    if (val == val.roundToDouble()) {
      return '${val.toInt()}x';
    }
    final str = val.toStringAsFixed(2);
    if (str.endsWith('0')) {
      return '${val.toStringAsFixed(1)}x';
    }
    return '${str}x';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedSpeed = speed.clamp(minSpeed, maxSpeed);
    final divisions = ((maxSpeed - minSpeed) / step).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row 1: Dedicated Presets Chips & Current Speed Badge
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: presets.map((preset) {
                    final isSelected = (clampedSpeed - preset).abs() < 0.01;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        key: Key('speed_preset_${_formatSpeed(preset)}'),
                        label: Text(
                          _formatSpeed(preset),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onSelected: (_) => onSpeedChanged(preset),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              constraints: const BoxConstraints(minWidth: 48),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${clampedSpeed.toStringAsFixed(2)}x',
                key: const Key('speed_value_text'),
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Row 2: Full-row Slider flanked by Minus and Plus 0.05 buttons
        Row(
          children: [
            IconButton.filledTonal(
              key: const Key('speed_decrease_button'),
              icon: const Icon(Icons.remove, size: 18),
              visualDensity: VisualDensity.compact,
              tooltip: '-0.05x',
              onPressed:
                  clampedSpeed > minSpeed + 0.001 ? _decreaseSpeed : null,
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 9),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 18),
                  activeTrackColor: theme.colorScheme.primary,
                  inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
                  thumbColor: theme.colorScheme.primary,
                ),
                child: Slider(
                  key: const Key('speed_slider'),
                  value: clampedSpeed,
                  min: minSpeed,
                  max: maxSpeed,
                  divisions: divisions > 0 ? divisions : null,
                  label: '${clampedSpeed.toStringAsFixed(2)}x',
                  onChanged: (val) => onSpeedChanged(_roundToStep(val)),
                ),
              ),
            ),
            IconButton.filledTonal(
              key: const Key('speed_increase_button'),
              icon: const Icon(Icons.add, size: 18),
              visualDensity: VisualDensity.compact,
              tooltip: '+0.05x',
              onPressed:
                  clampedSpeed < maxSpeed - 0.001 ? _increaseSpeed : null,
            ),
          ],
        ),
      ],
    );
  }
}
