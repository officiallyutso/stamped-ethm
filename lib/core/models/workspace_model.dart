import 'package:cloud_firestore/cloud_firestore.dart';

class WorkspaceModel {
  final String id;
  final String name;
  final String ownerId;
  final List<String> memberIds;
  final String? joinCode;
  final DateTime createdAt;
  // Wallet fields
  final String? walletId;
  final String? walletAddress;
  final String? walletBalance;
  final String? walletBalanceWei;
  final DateTime? walletLastSynced;

  WorkspaceModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.memberIds,
    this.joinCode,
    required this.createdAt,
    this.walletId,
    this.walletAddress,
    this.walletBalance,
    this.walletBalanceWei,
    this.walletLastSynced,
  });

  factory WorkspaceModel.fromMap(Map<String, dynamic> data, String documentId) {
    return WorkspaceModel(
      id: documentId,
      name: data['name'] ?? '',
      ownerId: data['ownerId'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      joinCode: data['joinCode'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      walletId: data['walletId'] as String?,
      walletAddress: data['walletAddress'] as String?,
      walletBalance: data['walletBalance'] as String?,
      walletBalanceWei: data['walletBalanceWei'] as String?,
      walletLastSynced: (data['walletLastSynced'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'joinCode': joinCode,
      'createdAt': Timestamp.fromDate(createdAt),
      if (walletId != null) 'walletId': walletId,
      if (walletAddress != null) 'walletAddress': walletAddress,
      if (walletBalance != null) 'walletBalance': walletBalance,
      if (walletBalanceWei != null) 'walletBalanceWei': walletBalanceWei,
      if (walletLastSynced != null)
        'walletLastSynced': Timestamp.fromDate(walletLastSynced!),
    };
  }
}

