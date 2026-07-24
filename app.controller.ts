import { Controller, Get, Post, Body } from '@nestjs/common';
import { AppService } from './app.service';
import { UserService } from './user.service';
import { BookingEngine } from './booking-engine';
import { HrFinanceService } from './hr-finance.service';
import { SecurityAuditService } from './security-audit.service';
import { NotificationHubService } from './notification-hub.service';
import { BiometricAttendanceService } from './biometric-attendance.service';
import { FranchiseRoyaltyService } from './franchise-royalty.service';
import { AcademyService } from './academy.service';
import { ServiceWorkflowEngine } from './service-workflow.service';
import { AdvancedAutomationEngine } from './advanced-automation.service';
import { FraudControlService } from './fraud-control.service';
import { SopComplianceEngine } from './sop-compliance.service';

@Controller()
export class AppController {
  constructor(
      private readonly appService: AppService,
          private readonly userService: UserService,
              private readonly bookingEngine: BookingEngine,
                  private readonly hrFinanceService: HrFinanceService,
                      private readonly securityAuditService: SecurityAuditService,
                          private readonly notificationHubService: NotificationHubService,
                              private readonly biometricAttendanceService: BiometricAttendanceService,
                                  private readonly franchiseRoyaltyService: FranchiseRoyaltyService,
                                      private readonly academyService: AcademyService,
                                          private readonly serviceWorkflowEngine: ServiceWorkflowEngine,
                                              private readonly advancedAutomationEngine: AdvancedAutomationEngine,
                                                  private readonly fraudControlService: FraudControlService,
                                                      private readonly sopComplianceEngine: SopComplianceEngine,
                                                        ) {}

                                                          @Get('health') getHealthCheck() { return this.appService.checkSystemHealth(); }
                                                            @Post('auth/otp/request') async requestOtp(@Body() body: { phoneNumber: string }) { return await this.userService.generateOtp(body.phoneNumber); }
                                                              @Post('auth/otp/verify') async verifyOtp(@Body() body: { phoneNumber: string; otpCode: string }) {
                                                                  const isValid = await this.userService.verifyOtp(body.phoneNumber, body.otpCode);
                                                                      if (isValid) return this.securityAuditService.generateSessionToken('user_id_placeholder', 'Customer', 'branch_id_placeholder');
                                                                          return { success: false, message: 'Authentication verification failed.' };
                                                                            }
                                                                              @Post('appointments/book') async bookAppointment(@Body() body: any) { return await this.bookingEngine.validateAndRouteBooking(body); }
                                                                                @Post('hr/payroll/calculate') calculatePayroll(@Body() body: any) { return this.hrFinanceService.calculateStaffSalary(body); }
                                                                                  @Post('finance/invoice/gst-reconcile') reconcileGstInvoice(@Body() body: { baseAmount: number }) { return this.hrFinanceService.generateTaxInvoiceMetrics(body.baseAmount); }
                                                                                    @Post('security/audit/log') createAuditLog(@Body() body: any) { this.securityAuditService.logAdminAction(body.actorId, body.role, body.action, body.branchId, body.changes); return { status: 'success' }; }
                                                                                      @Post('notifications/push/send') async triggerPush(@Body() body: any) { return await this.notificationHubService.sendPushNotification(body.userId, body.title, body.body); }
                                                                                        @Post('notifications/whatsapp/alert') async triggerWhatsApp(@Body() body: any) { return await this.notificationHubService.sendWhatsAppAlert(body.phoneNumber, body.template, body.variables); }
                                                                                          @Post('biometric/device/scan') logBiometricScan(@Body() body: any) { return this.biometricAttendanceService.logDeviceScan(body.staffId, body.deviceId, body.type); }
                                                                                            @Post('biometric/facial/verify') logFacialAttendance(@Body() body: any) { return this.biometricAttendanceService.verifyFacialAttendance(body.staffId, body.faceVector); }
                                                                                              @Post('franchise/royalty/calculate') processRoyalty(@Body() body: any) { return this.franchiseRoyaltyService.calculateBranchRoyalty(body.branchId, body.grossRevenue); }
                                                                                                @Post('franchise/network/compare') compareNetworkPerformances(@Body() body: any) { return this.franchiseRoyaltyService.compareBranchPerformances(body.branches); }
                                                                                                  @Post('academy/student/enroll') enrollStudent(@Body() body: any) { return this.academyService.processStudentAdmission(body); }
                                                                                                    @Post('academy/student/issue-certificate') generateCertificate(@Body() body: any) { return this.academyService.issueCourseCertificate(body.studentId, body.examScore, body.courseName); }
                                                                                                      @Post('automation/scheduler/optimize') async optimizeScheduler(@Body() body: any) { return await this.advancedAutomationEngine.optimizeResourceAllocation(body); }
                                                                                                        @Post('automation/inventory/log-grams') logGramsUsed(@Body() body: any) { this.advancedAutomationEngine.logMaterialConsumption(body.serviceId, body.staffId, body.product, body.grams); return { status: 'success' }; }
                                                                                                          @Post('automation/reports/performance') getPerformanceReport(@Body() body: any) { return this.advancedAutomationEngine.generateCustomPerformanceReport(body.start, body.end); }
                                                                                                            @Post('fraud/iot/chair-sensor') syncChairSensor(@Body() body: any) { this.fraudControlService.logChairSensorState(body.branchId, body.chairId, body.occupied); return { status: 'synced' }; }
                                                                                                              @Post('fraud/audit/verify-transparency') auditFrontOffice(@Body() body: any) { return this.fraudControlService.verifyWalkInTransparency(body.branchId, body.activeBillingIds); }

                                                                                                                // 📋 20. SOP Configurator Endpoint
                                                                                                                  @Post('sop/template/configure')
                                                                                                                    setupSop(@Body() body: { department: string; steps: string[] }) {
                                                                                                                        return this.sopComplianceEngine.configureSopTemplate(body.department, body.steps);
                                                                                                                          }

                                                                                                                            // 🔍 21. Live SOP Audit Submission Endpoint
                                                                                                                              @Post('sop/audit/submit')
                                                                                                                                executeSopAudit(@Body() body: { branchId: string; department: string; auditorId: string; completedStepIndexes: number[] }) {
                                                                                                                                    return this.sopComplianceEngine.submitSopAudit(body);
                                                                                                                                      }

                                                                                                                                        // 📊 22. Branch Historic Compliance Tracking Analytics Endpoint
                                                                                                                                          @Post('sop/analytics/branch-trends')
                                                                                                                                            getSopTrends(@Body() body: { branchId: string }) {
                                                                                                                                                return this.sopComplianceEngine.fetchBranchComplianceTrends(body.branchId);
                                                                                                                                                  }
                                                                                                                                                  }
                                                                                                                                                  