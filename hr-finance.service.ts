import { Injectable, HttpException, HttpStatus } from '@nestjs/common';

@Injectable()
export class HrFinanceService {
  /**
     * 👥 1. UPGRADED HR PAYROLL CALCULATOR (With Automatic Penalty Deductions)
        */
          calculateStaffSalary(payrollPayload: {
              baseSalary: number;
                  incentives: number;
                      leavesTaken: number;
                          workingDays: number;
                              missedTurnPenalties: number; // Added dynamic admin configured penalty total
                                }): any {
                                    if (payrollPayload.workingDays <= 0) {
                                          throw new HttpException('Invalid total monthly working days input.', HttpStatus.BAD_REQUEST);
                                              }

                                                  // Deduct salary proportionally based on unapproved leaves taken
                                                      const perDaySalary = payrollPayload.baseSalary / payrollPayload.workingDays;
                                                          const totalLeaveDeductions = perDaySalary * payrollPayload.leavesTaken;
                                                              
                                                                  // Core Logic: Gross Salary includes incentives but subtracts leaves AND missed turn penalties
                                                                      const grossSalary = (payrollPayload.baseSalary + payrollPayload.incentives) - (totalLeaveDeductions + payrollPayload.missedTurnPenalties);
                                                                          
                                                                              // Standard Enterprise Deductions: PF (12%) and ESI (0.75%)
                                                                                  const pfContribution = grossSalary > 0 ? grossSalary * 0.12 : 0;
                                                                                      const esiContribution = grossSalary > 0 ? grossSalary * 0.0075 : 0;
                                                                                          const netTakeHomeSalary = grossSalary - (pfContribution + esiContribution);

                                                                                              return {
                                                                                                    grossSalary: parseFloat(grossSalary.toFixed(2)),
                                                                                                          totalLeaveDeductions: parseFloat(totalLeaveDeductions.toFixed(2)),
                                                                                                                turnPenaltiesDeducted: parseFloat(payrollPayload.missedTurnPenalties.toFixed(2)),
                                                                                                                      providentFund: parseFloat(pfContribution.toFixed(2)),
                                                                                                                            esiAmount: parseFloat(esiContribution.toFixed(2)),
                                                                                                                                  netPayableTakeHome: parseFloat(netTakeHomeSalary.toFixed(2) < "0" ? "0" : netTakeHomeSalary.toFixed(2)),
                                                                                                                                        timestamp: new Date().toISOString(),
                                                                                                                                            };
                                                                                                                                              }

                                                                                                                                                /**
                                                                                                                                                   * 📊 2. AUTOMATED GST & TAX RECONCILIATION GATEWAY
                                                                                                                                                      */
                                                                                                                                                        generateTaxInvoiceMetrics(invoiceAmount: number): any {
                                                                                                                                                            if (invoiceAmount <= 0) {
                                                                                                                                                                  throw new HttpException('Invoice base amount must be greater than zero.', HttpStatus.BAD_REQUEST);
                                                                                                                                                                      }

                                                                                                                                                                          const gstRate = 0.18; 
                                                                                                                                                                              const calculatedTax = invoiceAmount * gstRate;
                                                                                                                                                                                  const cgst = calculatedTax / 2; 
                                                                                                                                                                                      const sgst = calculatedTax / 2; 
                                                                                                                                                                                          const grandTotal = invoiceAmount + calculatedTax;

                                                                                                                                                                                              return {
                                                                                                                                                                                                    baseAmount: parseFloat(invoiceAmount.toFixed(2)),
                                                                                                                                                                                                          totalGst: parseFloat(calculatedTax.toFixed(2)),
                                                                                                                                                                                                                cgstSplit: parseFloat(cgst.toFixed(2)),
                                                                                                                                                                                                                      sgstSplit: parseFloat(sgst.toFixed(2)),
                                                                                                                                                                                                                            payableInvoiceTotal: parseFloat(grandTotal.toFixed(2)),
                                                                                                                                                                                                                                };
                                                                                                                                                                                                                                  }
                                                                                                                                                                                                                                  }
                                                                                                                                                                                                                                  