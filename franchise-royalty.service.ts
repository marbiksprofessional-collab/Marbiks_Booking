import { Injectable, HttpException, HttpStatus } from '@nestjs/common';

@Injectable()
export class FranchiseRoyaltyService {
  /**
     * 👑 1. AUTOMATED ROYALTIES CALCULATOR (5% Standard Flat Royalty Rate)
        * Tracks total branch gross revenue and deducts enterprise franchise shares
           */
             calculateBranchRoyalty(branchId: string, grossRevenue: number): any {
                 if (grossRevenue <= 0) {
                       throw new HttpException('Gross revenue tracking balance must be greater than zero.', HttpStatus.BAD_REQUEST);
                           }

                               const royaltyRate = 0.05; // 5% standard corporate royalty payout fee
                                   const corporateRoyaltyFee = grossRevenue * royaltyRate;
                                       const remainingNetProfit = grossRevenue - corporateRoyaltyFee;

                                           return {
                                                 branchId,
                                                       totalGrossRevenue: parseFloat(grossRevenue.toFixed(2)),
                                                             royaltyPayoutAmount: parseFloat(corporateRoyaltyFee.toFixed(2)),
                                                                   franchiseNetProfit: parseFloat(remainingNetProfit.toFixed(2)),
                                                                         calculatedAt: new Date().toISOString(),
                                                                             };
                                                                               }

                                                                                 /**
                                                                                    * 📈 2. CROSS-BRANCH SALES PERFORMANCE LEADERBOARD
                                                                                       * Evaluates and compares sales vectors metrics to highlight high-performing sectors
                                                                                          */
                                                                                            compareBranchPerformances(branchesData: Array<{ branchId: string; salesAmount: number }>): any {
                                                                                                if (!branchesData || branchesData.length === 0) {
                                                                                                      throw new HttpException('Multi-branch tracking evaluation array payload empty.', HttpStatus.BAD_REQUEST);
                                                                                                          }

                                                                                                              // Sorting elements descending based on highest transaction revenue
                                                                                                                  const sortedLeaderboard = [...branchesData].sort((a, b) => b.salesAmount - a.salesAmount);
                                                                                                                      
                                                                                                                          return {
                                                                                                                                topPerformingBranch: sortedLeaderboard[0],
                                                                                                                                      totalActiveNetworkSales: branchesData.reduce((total, branch) => total + branch.salesAmount, 0),
                                                                                                                                            leaderboardRankings: sortedLeaderboard,
                                                                                                                                                };
                                                                                                                                                  }
                                                                                                                                                  }
                                                                                                                                                  