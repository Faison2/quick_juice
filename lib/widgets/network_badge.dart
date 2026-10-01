import 'package:flutter/material.dart';
import '../models/network.dart';

class NetworkBadge extends StatelessWidget {
  final Network network;
  final double size;

  const NetworkBadge({super.key, required this.network, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [network.color, network.colorDark],
        ),
      ),
      child: Icon(network.icon, color: Colors.white, size: size * 0.5),
    );
  }
}
