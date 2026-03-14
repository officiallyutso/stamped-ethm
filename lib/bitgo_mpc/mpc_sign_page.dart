// lib/bitgo_mpc/mpc_sign_page.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'commitment_service.dart';
import 'mpc_signing_service.dart';
import 'secure_key_storage.dart';
import 'package:stamped/core/theme/app_colors.dart';

class MpcSignPage extends StatefulWidget {
  const MpcSignPage({super.key});

  @override
  State<MpcSignPage> createState() => _MpcSignPageState();
}

class _MpcSignPageState extends State<MpcSignPage> {
  final MpcSigningService _mpcSigningService = MpcSigningService();
  final CommitmentService _commitmentService = CommitmentService();
  final SecureKeyStorage _keyStorage = SecureKeyStorage();

  String _commitmentHash = '';
  String _timestamp = '';
  String _deviceId = '';
  
  String _signature = '';
  String _walletAddress = '';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    String? id = await _keyStorage.getDeviceId();
    if (id == null) {
      id = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await _keyStorage.saveDeviceId(id);
    }
    setState(() {
      _deviceId = id!;
    });
  }

  void _generateCommitment() {
    final result = _commitmentService.generateCommitment('Sample Photo Data', _deviceId);
    setState(() {
      _commitmentHash = result['commitmentHash']!;
      _timestamp = result['timestamp']!;
      _signature = ''; 
      _errorMessage = null;
    });
  }

  Future<void> _signCommitment() async {
    if (_commitmentHash.isEmpty) {
      setState(() {
        _errorMessage = 'Please generate a commitment first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final signed = await _mpcSigningService.signCommitment('Sample Photo Data');
      setState(() {
        _signature = signed.signature;
        _walletAddress = signed.deviceWalletAddress;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Signing failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MPC SIGNING',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(
              title: 'DEVICE IDENTITY',
              value: _deviceId,
              icon: LucideIcons.smartphone,
            ),
            const SizedBox(height: 20),
            
            _buildActionSection(),

            if (_errorMessage != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertCircle, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),
            _buildResultCard(
              title: 'COMMITMENT HASH',
              value: _commitmentHash,
              isGenerated: _commitmentHash.isNotEmpty,
              subtitle: _timestamp.isNotEmpty ? 'Timestamp: $_timestamp' : null,
            ),
            const SizedBox(height: 16),
            _buildResultCard(
              title: 'BITGO SIGNATURE',
              value: _signature,
              isGenerated: _signature.isNotEmpty,
              isSignature: true,
              subtitle: _walletAddress.isNotEmpty ? 'Wallet: $_walletAddress' : null,
            ),
            
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'SECURED BY BITGO MPC',
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryRed, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Loading...' : value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Column(
      children: [
        _buildButton(
          label: 'GENERATE COMMITMENT',
          icon: LucideIcons.fingerprint,
          onPressed: _generateCommitment,
          isPrimary: false,
        ),
        const SizedBox(height: 12),
        _buildButton(
          label: _isLoading ? 'SIGNING...' : 'SIGN WITH BITGO',
          icon: LucideIcons.shieldCheck,
          onPressed: (_commitmentHash.isEmpty || _isLoading) ? null : _signCommitment,
          isPrimary: true,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isPrimary,
    bool isLoading = false,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.blueAccent : Colors.white10,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String value,
    required bool isGenerated,
    bool isSignature = false,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isGenerated ? (isSignature ? Colors.green.withOpacity(0.05) : Colors.white.withOpacity(0.03)) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGenerated ? (isSignature ? Colors.green.withOpacity(0.2) : Colors.white.withOpacity(0.1)) : Colors.white.withOpacity(0.05),
          style: isGenerated ? BorderStyle.solid : BorderStyle.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isGenerated ? (isSignature ? Colors.greenAccent : Colors.white70) : Colors.white24,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (subtitle != null && isGenerated) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ],
              ),
              if (isGenerated)
                Icon(
                  isSignature ? LucideIcons.checkCircle2 : LucideIcons.check,
                  color: isSignature ? Colors.greenAccent : Colors.white38,
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              isGenerated ? value : 'PENDING...',
              style: TextStyle(
                color: isGenerated ? Colors.white : Colors.white10,
                fontSize: 12,
                fontFamily: 'monospace',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

