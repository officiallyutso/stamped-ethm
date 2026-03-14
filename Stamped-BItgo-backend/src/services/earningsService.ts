import { db } from '../config/firebaseConfig';
import { WorkspaceWalletService } from './workspaceWalletService';

interface EarningsRecord {
  id: string;
  userId: string;
  workspaceId: string;
  date: string;
  totalMinutesWorked: number;
  hourlyRateWei: string;
  earnedAmountWei: string;
  earnedAmountEth: string;
  status: string;
  calculatedAt: Date;
  attendanceIds: string[];
}

interface UserEarningsSummary {
  userId: string;
  displayName: string;
  email: string;
  payoutAddress: string | null;
  totalEarnedWei: string;
  totalEarnedEth: string;
  totalPaidWei: string;
  totalPaidEth: string;
  pendingWei: string;
  pendingEth: string;
}

export class EarningsService {
  // Default hourly rate: 0.001 ETH/hour = 1000000000000000 wei/hour
  private defaultHourlyRateWei = '1000000000000000';
  private walletService = new WorkspaceWalletService();

  /* ============================================================
     1️⃣ Calculate Earnings from Attendance
  ============================================================ */

  public async calculateEarnings(
    workspaceId: string,
    userId: string,
    startDate: string,
    endDate: string
  ): Promise<EarningsRecord[]> {
    console.log(`[INFO] Calculating earnings for user ${userId} in workspace ${workspaceId} from ${startDate} to ${endDate}`);

    // Query attendance records
    const attendanceSnapshot = await db
      .collection('attendance')
      .where('workspaceId', '==', workspaceId)
      .where('userId', '==', userId)
      .where('timestamp', '>=', new Date(startDate))
      .where('timestamp', '<=', new Date(endDate + 'T23:59:59'))
      .orderBy('timestamp', 'asc')
      .get();

    if (attendanceSnapshot.empty) {
      console.log('[INFO] No attendance records found');
      return [];
    }

    // Group attendance by date
    const recordsByDate: { [date: string]: any[] } = {};
    attendanceSnapshot.docs.forEach((doc) => {
      const data = doc.data();
      const timestamp = data.timestamp?.toDate() || new Date();
      const dateKey = timestamp.toISOString().split('T')[0];

      if (!recordsByDate[dateKey]) {
        recordsByDate[dateKey] = [];
      }
      recordsByDate[dateKey].push({
        id: doc.id,
        type: data.type,
        timestamp,
      });
    });

    // Calculate earnings per date
    const earningsRecords: EarningsRecord[] = [];

    for (const [date, records] of Object.entries(recordsByDate)) {
      let totalMinutes = 0;
      const attendanceIds: string[] = [];

      // Sort by timestamp
      records.sort((a, b) => a.timestamp.getTime() - b.timestamp.getTime());

      let lastTimeIn: Date | null = null;
      let lastBreakStart: Date | null = null;
      let breakMinutes = 0;

      for (const record of records) {
        attendanceIds.push(record.id);

        switch (record.type) {
          case 'timeIn':
            lastTimeIn = record.timestamp;
            breakMinutes = 0;
            break;
          case 'breakStart':
            lastBreakStart = record.timestamp;
            break;
          case 'breakEnd':
            if (lastBreakStart) {
              breakMinutes += (record.timestamp.getTime() - lastBreakStart.getTime()) / 60000;
              lastBreakStart = null;
            }
            break;
          case 'timeOut':
            if (lastTimeIn) {
              const rawMinutes = (record.timestamp.getTime() - lastTimeIn.getTime()) / 60000;
              totalMinutes += rawMinutes - breakMinutes;
              lastTimeIn = null;
              breakMinutes = 0;
            }
            break;
        }
      }

      // Calculate earnings: totalMinutes / 60 * hourlyRate
      const hoursWorked = totalMinutes / 60;
      const hourlyRateWeiBig = BigInt(this.defaultHourlyRateWei);
      // Use integer math: ( totalMinutes * hourlyRateWei ) / 60
      const earnedWei = (BigInt(Math.round(totalMinutes)) * hourlyRateWeiBig) / BigInt(60);
      const earnedEth = (Number(earnedWei) / 1e18).toString();

      // Check if earnings already exist for this date
      const existingEarning = await db
        .collection('earnings')
        .where('workspaceId', '==', workspaceId)
        .where('userId', '==', userId)
        .where('date', '==', date)
        .limit(1)
        .get();

      let earningId: string;
      if (!existingEarning.empty) {
        // Update existing
        earningId = existingEarning.docs[0].id;
        await db.collection('earnings').doc(earningId).update({
          totalMinutesWorked: Math.round(totalMinutes),
          hourlyRateWei: this.defaultHourlyRateWei,
          earnedAmountWei: earnedWei.toString(),
          earnedAmountEth: earnedEth,
          calculatedAt: new Date(),
          attendanceIds,
        });
      } else {
        // Create new
        const ref = db.collection('earnings').doc();
        earningId = ref.id;
        await ref.set({
          userId,
          workspaceId,
          date,
          totalMinutesWorked: Math.round(totalMinutes),
          hourlyRateWei: this.defaultHourlyRateWei,
          earnedAmountWei: earnedWei.toString(),
          earnedAmountEth: earnedEth,
          status: 'pending',
          calculatedAt: new Date(),
          attendanceIds,
        });
      }

      earningsRecords.push({
        id: earningId,
        userId,
        workspaceId,
        date,
        totalMinutesWorked: Math.round(totalMinutes),
        hourlyRateWei: this.defaultHourlyRateWei,
        earnedAmountWei: earnedWei.toString(),
        earnedAmountEth: earnedEth,
        status: 'pending',
        calculatedAt: new Date(),
        attendanceIds,
      });
    }

    console.log(`[INFO] Calculated ${earningsRecords.length} earning records`);
    return earningsRecords;
  }

  /* ============================================================
     2️⃣ Get Pending Earnings (All Users in Workspace)
  ============================================================ */

  public async getPendingEarnings(workspaceId: string): Promise<UserEarningsSummary[]> {
    console.log(`[INFO] Fetching pending earnings for workspace: ${workspaceId}`);

    // Get workspace members
    const workspaceDoc = await db.collection('workspaces').doc(workspaceId).get();
    if (!workspaceDoc.exists) {
      throw new Error(`Workspace ${workspaceId} not found`);
    }
    const memberIds: string[] = workspaceDoc.data()?.memberIds || [];

    const summaries: UserEarningsSummary[] = [];

    for (const memberId of memberIds) {
      // Get user info
      const userDoc = await db.collection('users').doc(memberId).get();
      const userData = userDoc.data() || {};

      // Get auto-generated wallet from workspace_members
      let memberWalletQuery = await db
        .collection('workspace_members')
        .where('workspaceId', '==', workspaceId)
        .where('userId', '==', memberId)
        .limit(1)
        .get();

      // AUTO-FIX: If member has no wallet in this workspace, create one now
      if (memberWalletQuery.empty) {
        console.log(`[INFO] Member ${memberId} has no wallet in workspace ${workspaceId}, auto-creating...`);
        try {
          await this.walletService.createUserWallet(
            workspaceId,
            memberId,
            userData.displayName || 'User'
          );
          // Re-query after creation
          memberWalletQuery = await db
            .collection('workspace_members')
            .where('workspaceId', '==', workspaceId)
            .where('userId', '==', memberId)
            .limit(1)
            .get();
        } catch (err: any) {
          console.log(`[WARN] Could not auto-create wallet for ${memberId}: ${err.message}`);
        }
      }

      const memberWallet = memberWalletQuery.empty ? null : memberWalletQuery.docs[0].data();

      summaries.push({
        userId: memberId,
        displayName: userData.displayName || 'Unknown',
        email: userData.email || '',
        payoutAddress: memberWallet?.walletAddress || null,
        totalEarnedWei: '0',
        totalEarnedEth: '0',
        totalPaidWei: '0',
        totalPaidEth: '0',
        pendingWei: '0',
        pendingEth: '0',
      });
    }

    return summaries;
  }

  /* ============================================================
     3️⃣ Get Earnings for a Specific User
  ============================================================ */

  public async getUserEarnings(workspaceId: string, userId: string): Promise<EarningsRecord[]> {
    const snapshot = await db
      .collection('earnings')
      .where('workspaceId', '==', workspaceId)
      .where('userId', '==', userId)
      .orderBy('date', 'desc')
      .get();

    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
      calculatedAt: doc.data().calculatedAt?.toDate() || new Date(),
    })) as EarningsRecord[];
  }
}
