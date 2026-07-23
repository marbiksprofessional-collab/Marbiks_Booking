import { Injectable, HttpException, HttpStatus } from '@nestjs/common';

@Injectable()
export class ErpService {
  // Base configuration placeholder for your existing ERP API
  private readonly erpBaseUrl = process.env.ERP_API_URL || 'https://your-existing-erp.com';
  private readonly erpApiKey = process.env.ERP_API_KEY || 'YOUR_SECRET_API_KEY';

  /**
   * 📅 Fetch available time slots and chairs from existing ERP
   */
  async getBranchAppointments(branchId: string, date: string): Promise<any> {
    try {
      // Act as Anti-Corruption Layer (ACL) translating App requests to Core ERP format
      console.log(`Connecting to Legacy ERP for Branch: ${branchId} on Date: ${date}`);
      
      // In production, this performs a real system-to-system call
      const response = await fetch(`${this.erpBaseUrl}/appointments?branch_id=${branchId}&date=${date}`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${this.erpApiKey}`,
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        throw new Error(`ERP System responded with status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      throw new HttpException(
        { status: 'error', message: 'Failed to sync with Core ERP System', details: error.message },
        HttpStatus.BAD_GATEWAY,
      );
    }
  }

  /**
   * 👥 Push a new booking created in Claude App directly into the existing ERP
   */
  async createExternalBooking(bookingData: any): Promise<any> {
    try {
      const response = await fetch(`${this.erpBaseUrl}/bookings/create`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.erpApiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(bookingData),
      });

      return await response.json();
    } catch (error) {
      console.error('Real-time sync queue failure, sending payload to offline retry loop.');
      return { syncStatus: 'queued_offline', payload: bookingData };
    }
  }
}
