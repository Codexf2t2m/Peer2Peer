
// Unchanged — self-contained StatefulWidget with no provider dependencies.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShowcaseCardData {
  const ShowcaseCardData({
    required this.bankName,
    required this.label,
    required this.brand,
    required this.balance,
    required this.cardNumber,
    required this.colors,
  });

  final String bankName;
  final String label;
  final String brand;
  final String balance;
  final String cardNumber;
  final List<Color> colors;
}

const sampleCards = [
  ShowcaseCardData(
    bankName: 'FNB',
    label: 'Credit',
    brand: 'VISA',
    balance: 'P5 348.00',
    cardNumber: '****  -  ****  -  ****  -  **68',
    colors: [Color(0xFF2C2C2C), Color(0xFF181818)],
  ),
  ShowcaseCardData(
    bankName: 'Standard Bank',
    label: 'Savings',
    brand: 'VISA',
    balance: 'P12 200.00',
    cardNumber: '****  -  ****  -  ****  -  **42',
    colors: [Color(0xFF0E7C7B), Color(0xFF064E4D)],
  ),
  ShowcaseCardData(
    bankName: 'Absa',
    label: 'Cheque',
    brand: 'VISA',
    balance: 'P3 750.50',
    cardNumber: '****  -  ****  -  ****  -  **91',
    colors: [Color(0xFFB91C3A), Color(0xFF8B0020)],
  ),
];

class StackedCardCarousel extends StatefulWidget {
  const StackedCardCarousel({super.key});

  @override
  State<StackedCardCarousel> createState() =>
      _StackedCardCarouselState();
}

class _StackedCardCarouselState extends State<StackedCardCarousel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() => _dragOffset += details.delta.dx);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final velocity = details.primaryVelocity ?? 0;

    if (_dragOffset.abs() > screenWidth * 0.3 ||
        velocity.abs() > 600) {
      if (_dragOffset > 0 && _currentIndex > 0) {
        _swipeTo(-1);
      } else if (_dragOffset < 0 &&
          _currentIndex < sampleCards.length - 1) {
        _swipeTo(1);
      } else {
        _reset();
      }
    } else {
      _reset();
    }
  }

  void _swipeTo(int direction) {
    HapticFeedback.lightImpact();
    final end = direction == 1
        ? -MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.width;

    final animation =
        Tween<double>(begin: _dragOffset, end: end).animate(
      CurvedAnimation(
          parent: _controller, curve: Curves.easeOutCubic),
    );

    animation.addListener(
        () => setState(() => _dragOffset = animation.value));

    _controller.forward(from: 0).then((_) {
      setState(() {
        _currentIndex += direction;
        _dragOffset = 0;
      });
    });
  }

  void _reset() {
    final animation =
        Tween<double>(begin: _dragOffset, end: 0).animate(
      CurvedAnimation(
          parent: _controller, curve: Curves.elasticOut),
    );
    animation.addListener(
        () => setState(() => _dragOffset = animation.value));
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final progress =
        (_dragOffset.abs() / screenWidth).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          child: Container(
            height: 250,
            padding:
                const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (_currentIndex + 1 < sampleCards.length)
                  _buildBackCard(
                      sampleCards[_currentIndex + 1],
                      progress),
                Transform.translate(
                  offset: Offset(
                      _dragOffset, _dragOffset.abs() * -0.05),
                  child: Transform.rotate(
                    angle:
                        (_dragOffset / screenWidth) * 0.1,
                    child: CreditCardWidget(
                        card: sampleCards[_currentIndex]),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        _buildDots(),
      ],
    );
  }

  Widget _buildBackCard(ShowcaseCardData card, double progress) {
    return Transform.translate(
      offset: Offset(0, 15 * (1 - progress)),
      child: Transform.scale(
        scale: 0.9 + (0.1 * progress),
        child: Opacity(
          opacity: 0.4 + (0.6 * progress),
          child: CreditCardWidget(card: card),
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(sampleCards.length, (i) {
        final active = i == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: active ? 24 : 8,
          decoration: BoxDecoration(
            color: active
                ? Colors.grey[700]
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

class CreditCardWidget extends StatelessWidget {
  const CreditCardWidget({super.key, required this.card});

  final ShowcaseCardData card;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.58,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: card.colors,
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      stops: const [0.3, 0.5, 0.7],
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white
                            .withValues(alpha: 0.06),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.bankName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              card.label,
                              style: TextStyle(
                                color: Colors.white
                                    .withValues(alpha: 0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              card.brand,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const EMVChip(),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'Balance',
                      style: TextStyle(
                        color: Colors.white
                            .withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          card.balance,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.help_outline,
                          size: 14,
                          color: Colors.white
                              .withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      card.cardNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EMVChip extends StatelessWidget {
  const EMVChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFFE5D491),
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          colors: [Color(0xFFF3E5AB), Color(0xFFD4AF37)],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 25,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
                width: 0.5, height: 30, color: Colors.black12),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
                width: 40, height: 0.5, color: Colors.black12),
          ),
        ],
      ),
    );
  }
}