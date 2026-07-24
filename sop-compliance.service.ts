import { Injectable, HttpException, HttpStatus } from '@nestjs/common';

@Injectable()
export class SopComplianceEngine {
  // Master SOP Checklists repository defined per department rules
    private departmentSopTemplates = new Map<string, string[]>(); // department -> [sop_steps]
      private activeAuditLogs: Array<{
          auditId: string;
              branchId: string;
                  department: string;
                      auditorId: string;
                          scorePercentage: number;
                              failedSteps: string[];
                                  timestamp: string;
                                    }> = [];

                                      constructor() {
                                          // Seeding default enterprise SOP checklists for instant branch testing
                                              this.departmentSopTemplates.set('FrontOffice', ['Verify Client Identity/OTP', 'Digital Consent Upload', 'Assign Verified Certified Staff']);
                                                  this.departmentSopTemplates.set('TherapyRoom', ['Sanitize Chair/Bed Toolsets', 'Pre-Service Weight Breakdown Check', 'Post-Service Gram Consumption Logging']);
                                                    }

                                                      /**
                                                         * 📋 1. CREATE/UPDATE DEPARTMENTAL SOP CHECKLISTS
                                                            * Allows the Admin to remotely change standard rules from the main menu dashboard
                                                               */
                                                                 configureSopTemplate(department: string, steps: string[]): any {
                                                                     this.departmentSopTemplates.set(department, steps);
                                                                         return { status: 'success', department, totalConfiguredSteps: steps.length };
                                                                           }

                                                                             /**
                                                                                * 🔍 2. LIVE SOP AUDIT SUBMISSION LOGGER
                                                                                   * Managers scan and score current department performance via their phone/tablet app interface
                                                                                      */
                                                                                        submitSopAudit(auditPayload: {
                                                                                            branchId: string;
                                                                                                department: string;
                                                                                                    auditorId: string;
                                                                                                        completedStepIndexes: number[]; // Array tracking checked pass indices
                                                                                                          }): any {
                                                                                                              const masterSteps = this.departmentSopTemplates.get(auditPayload.department);
                                                                                                                  if (!masterSteps) {
                                                                                                                        throw new HttpException('Target system operation department SOP schema profile not found.', HttpStatus.NOT_FOUND);
                                                                                                                            }

                                                                                                                                const failedSteps: string[] = [];
                                                                                                                                    masterSteps.forEach((step, index) => {
                                                                                                                                          if (!auditPayload.completedStepIndexes.includes(index)) {
                                                                                                                                                  failedSteps.push(step); // Log rule steps that failed validation parameters
                                                                                                                                                        }
                                                                                                                                                            });

                                                                                                                                                                const totalStepsCount = masterSteps.length;
                                                                                                                                                                    const passedStepsCount = totalStepsCount - failedSteps.length;
                                                                                                                                                                        const finalScore = (passedStepsCount / totalStepsCount) * 100;

                                                                                                                                                                            const auditResult = {
                                                                                                                                                                                  auditId: `AUDIT_${Math.floor(100000 + Math.random() * 900000)}`,
                                                                                                                                                                                        branchId: auditPayload.branchId,
                                                                                                                                                                                              department: auditPayload.department,
                                                                                                                                                                                                    auditorId: auditPayload.auditorId,
                                                                                                                                                                                                          scorePercentage: parseFloat(finalScore.toFixed(2)),
                                                                                                                                                                                                                failedSteps,
                                                                                                                                                                                                                      timestamp: new Date().toISOString()
                                                                                                                                                                                                                          };

                                                                                                                                                                                                                              this.activeAuditLogs.push(auditResult);

                                                                                                                                                                                                                                  // CRITICAL TRIGGER LOGIC: If audit score falls below 80%, system flags a high-priority corporate notice
                                                                                                                                                                                                                                      if (finalScore < 80) {
                                                                                                                                                                                                                                            console.warn(`[SOP CRITICAL WARNING] Branch: ${auditPayload.branchId} failed compliance parameters on Department: ${auditPayload.department}. Score: ${finalScore}%`);
                                                                                                                                                                                                                                                }

                                                                                                                                                                                                                                                    return auditResult;
                                                                                                                                                                                                                                                      }

                                                                                                                                                                                                                                                        /**
                                                                                                                                                                                                                                                           * 📊 3. HISTORICAL COMPLIANCE ANALYTICS LEADERBOARD
                                                                                                                                                                                                                                                              * Extracts historical analytics summaries to capture branch compliance trends
                                                                                                                                                                                                                                                                 */
                                                                                                                                                                                                                                                                   fetchBranchComplianceTrends(branchId: string): any {
                                                                                                                                                                                                                                                                       const records = this.activeAuditLogs.filter(log => log.branchId === branchId);
                                                                                                                                                                                                                                                                           if (records.length === 0) return { message: 'No historical compliance records found for this location.' };

                                                                                                                                                                                                                                                                               const overallAverageScore = records.reduce((sum, current) => sum + current.scorePercentage, 0) / records.length;

                                                                                                                                                                                                                                                                                   return {
                                                                                                                                                                                                                                                                                         branchId,
                                                                                                                                                                                                                                                                                               totalAuditsLoggedCount: records.length,
                                                                                                                                                                                                                                                                                                     historicalAverageComplianceScore: parseFloat(overallAverageScore.toFixed(2)),
                                                                                                                                                                                                                                                                                                           detailedLogs: records
                                                                                                                                                                                                                                                                                                               };
                                                                                                                                                                                                                                                                                                                 }
                                                                                                                                                                                                                                                                                                                 }
                                                                                                                                                                                                                                                                                                                 