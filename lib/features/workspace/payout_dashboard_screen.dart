import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:stamped/core/services/backend_api_service.dart';
import 'package:stamped/core/theme/app_colors.dart';
import 'package:stamped/features/workspace/workspace_provider.dart';

class PayoutDashboardScreen extends StatefulWidget {
  const PayoutDashboardScreen({super.key});

  @override
  State<PayoutDashboardScreen> createState() => _PayoutDashboardScreenState();
}

class _PayoutDashboardScreenState extends State<PayoutDashboardScreen> {
  final BackendApiService _apiService = BackendApiService();
  bool _isLoading = true;
  bool _isSendingPayout = false;
  String? _error;
  List<dynamic> _earningsSummaries = [];
  List<dynamic> _payoutHistory = [];
  String _treasuryBalance = '0';
  String _treasuryBalanceWei = '0';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final wp = Provider.of<WorkspaceProvider>(context, listen: false);
    final workspace = wp.currentWorkspace;
    if (workspace == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch balance
      final balance = await _apiService.getWalletBalance(
        workspaceId: workspace.id,
      );
      
      // Fetch earnings
      final earnings = await _apiService.getWorkspaceEarnings(
        workspaceId: workspace.id,
      );

      // Fetch payout history
      final history = await _apiService.getPayoutHistory(
        workspaceId: workspace.id,
      );

      if (mounted) {
        setState(() {
          _treasuryBalance = balance['balanceEth'] ?? '0';
          _treasuryBalanceWei = balance['balanceWei'] ?? '0';
          _earningsSummaries = earnings;
          _payoutHistory = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendPayout(Map<String, dynamic> member) async {
    final wp = Provider.of<WorkspaceProvider>(context, listen: false);
    final workspace = wp.currentWorkspace;
    if (workspace == null) return;

    final payoutAddress = member['payoutAddress'];
    final pendingWei = member['pendingWei'];
    final pendingEth = member['pendingEth'];
    final displayName = member['displayName'] ?? 'Unknown';

    if (payoutAddress == null || payoutAddress.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$displayName has not set a payout address')),
      );
      return;
    }

    if (pendingWei == '0' || pendingWei == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$displayName has no pending earnings')),
      );
      return;
    }

    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Payout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send $pendingEth ETH to $displayName?'),
            const SizedBox(height: 8),
            Text(
              'Address: ${payoutAddress.toString().substring(0, 10)}...${payoutAddress.toString().substring(payoutAddress.toString().length - 6)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
            child: const Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSendingPayout = true);

    try {
      await _apiService.sendPayout(
        workspaceId: workspace.id,
        userId: member['userId'],
        toAddress: payoutAddress,
        amountWei: pendingWei,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payout sent to $displayName!')),
        );
        _loadData(); // Refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payout failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingPayout = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payout Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: _isLoading ? null : _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.alertCircle, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Treasury Balance Card
                      _buildTreasuryCard(),
                      const SizedBox(height: 24),

                      // Members section
                      const Text('Members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (_earningsSummaries.isEmpty)
                        const Text('No members found.', style: TextStyle(color: Colors.grey))
                      else
                        ..._earningsSummaries.map((m) => _buildMemberCard(m)),

                      const SizedBox(height: 24),

                      // Payout History
                      const Text('Payout History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (_payoutHistory.isEmpty)
                        const Text('No payouts yet.', style: TextStyle(color: Colors.grey))
                      else
                        ..._payoutHistory.map((p) => _buildPayoutHistoryItem(p)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTreasuryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.wallet, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              const Text('Treasury Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$_treasuryBalance ETH',
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '$_treasuryBalanceWei wei',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(dynamic member) {
    final name = member['displayName'] ?? 'Unknown';
    final email = member['email'] ?? '';
    final pendingEth = member['pendingEth'] ?? '0';
    final totalEarnedEth = member['totalEarnedEth'] ?? '0';
    final totalPaidEth = member['totalPaidEth'] ?? '0';
    final payoutAddress = member['payoutAddress'];
    final hasPayout = payoutAddress != null && payoutAddress.toString().isNotEmpty;
    final hasPending = pendingEth != '0' && pendingEth != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryRed.withOpacity(0.1),
                child: Text(
                  name.toString().isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (email.toString().isNotEmpty)
                      Text(email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Earnings info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _earningsChip('Earned', '$totalEarnedEth ETH', Colors.blue),
              _earningsChip('Paid', '$totalPaidEth ETH', Colors.green),
              _earningsChip('Pending', '$pendingEth ETH', Colors.orange),
            ],
          ),

          const SizedBox(height: 12),

          // Payout address
          if (hasPayout)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.mapPin, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      payoutAddress.toString(),
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          else
            Text('⚠️ No payout address set', style: TextStyle(color: Colors.orange.shade700, fontSize: 12)),

          const SizedBox(height: 12),

          // Send Payout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (hasPending && hasPayout && !_isSendingPayout) 
                  ? () => _sendPayout(member as Map<String, dynamic>)
                  : null,
              icon: _isSendingPayout
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(LucideIcons.send, size: 16),
              label: Text(_isSendingPayout ? 'Sending...' : 'Send Payout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _earningsChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildPayoutHistoryItem(dynamic payout) {
    final amountEth = payout['amountEth'] ?? '0';
    final txHash = payout['txHash'] ?? '';
    final status = payout['status'] ?? 'unknown';
    final createdAt = payout['createdAt'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: status == 'completed' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              status == 'completed' ? LucideIcons.checkCircle : LucideIcons.clock,
              size: 16,
              color: status == 'completed' ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$amountEth ETH', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (txHash.toString().isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: txHash));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('TX hash copied!')),
                      );
                    },
                    child: Text(
                      'TX: ${txHash.toString().substring(0, 10)}...',
                      style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'monospace'),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'completed' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status.toString().toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: status == 'completed' ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
