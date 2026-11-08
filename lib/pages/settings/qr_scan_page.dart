import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../generated/l10n.dart';

/// 二维码扫描页：识别成功后 pop 返回内容字符串。
class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.qrScanTitle)),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_handled) return;
              for (final code in capture.barcodes) {
                final value = code.rawValue;
                if (value != null && value.isNotEmpty) {
                  _handled = true;
                  Navigator.of(context).pop(value);
                  return;
                }
              }
            },
          ),
          // 扫描框指示
          IgnorePointer(
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(S.current.qrScanHint,
                  style: const TextStyle(color: Colors.white70)),
            ),
          ),
        ],
      ),
    );
  }
}
