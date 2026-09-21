import mongoose from 'mongoose';
import fs from 'fs';
import path from 'path';
import { connectDB, disconnectDB } from '../src/config/db';
import { AuthService } from '../src/services/auth.service';
import { FarmService } from '../src/services/farm.service';
import { SuitabilityService } from '../src/services/suitability.service';
import { DesignService } from '../src/services/design.service';
import { VisualizationService } from '../src/services/visualization.service';
import { EconomicsService } from '../src/services/economics.service';
import { ReportService } from '../src/reports/../services/report.service';
import { DashboardService } from '../src/services/dashboard.service';
import { UserService } from '../src/services/user.service';
import { SupportService } from '../src/services/support.service';
import { NotificationService } from '../src/services/notification.service';
import { SunPositionEngine } from '../src/calculations/sunPositionEngine';
import { AgriPvEngine } from '../src/calculations/agriPvEngine';
import { SuitabilityEngine } from '../src/calculations/suitabilityEngine';
import { User } from '../src/models/user.model';
import { Farm } from '../src/models/farm.model';
import { AgriPvDesign } from '../src/models/design.model';
import { SuitabilityAnalysis } from '../src/models/suitability.model';
import { Report } from '../src/models/report.model';

let totalTests = 0;
let passedTests = 0;

function assert(condition: boolean, testName: string) {
  totalTests++;
  if (condition) {
    passedTests++;
    console.log(`  ✓ PASS: ${testName}`);
  } else {
    console.error(`  ✗ FAIL: ${testName}`);
    throw new Error(`Test assertion failed: ${testName}`);
  }
}

async function run() {
  console.log('\n========================================');
  console.log('  AGRI-PV NAVIGATOR BACKEND TEST SUITE  ');
  console.log('========================================\n');

  await connectDB();

  const testEmailA = `test_user_a_${Date.now()}@example.com`;
  const testEmailB = `test_user_b_${Date.now()}@example.com`;

  try {
    // ── 1. AUTHENTICATION & SECURITY ──
    console.log('[Test Group 1: Authentication & Token Management]');

    // 1.1 Registration
    const regResA = await AuthService.register({
      firstName: 'Ramesh',
      lastName: 'Verma',
      email: testEmailA,
      password: 'StrongPassword123!',
      phone: '+91 9988776655',
    });
    assert(!!regResA.user.id, 'User A registered with valid MongoDB ID');
    assert(regResA.user.email === testEmailA, 'User email matches normalized input');
    assert(regResA.user.initials === 'RV', 'Initials generated correctly');
    assert(!!regResA.tokens.accessToken, 'Access token generated');
    assert(!!regResA.tokens.refreshToken, 'Refresh token generated');

    // 1.2 Duplicate Registration Rejection
    let duplicateRejected = false;
    try {
      await AuthService.register({
        firstName: 'Duplicate',
        lastName: 'User',
        email: testEmailA,
        password: 'Password123!',
      });
    } catch (e: any) {
      duplicateRejected = e.statusCode === 409;
    }
    assert(duplicateRejected, 'Duplicate email registration rejected with 409 Conflict');

    // 1.3 Login
    const loginRes = await AuthService.login({
      email: testEmailA,
      password: 'StrongPassword123!',
    });
    assert(loginRes.user.id === regResA.user.id, 'User logged in successfully');
    assert(!!loginRes.tokens.accessToken, 'New access token issued upon login');

    // 1.4 Invalid Password Rejection
    let invalidPassRejected = false;
    try {
      await AuthService.login({ email: testEmailA, password: 'WrongPassword' });
    } catch (e: any) {
      invalidPassRejected = e.statusCode === 401;
    }
    assert(invalidPassRejected, 'Invalid password rejected with 401 Unauthorized');

    // 1.5 Token Refresh
    const newTokens = await AuthService.refreshToken(loginRes.tokens.refreshToken);
    assert(!!newTokens.accessToken, 'Access token refreshed successfully');

    // 1.6 User B Registration for Authorization Tests
    const regResB = await AuthService.register({
      firstName: 'Suresh',
      lastName: 'Yadav',
      email: testEmailB,
      password: 'Password456!',
    });
    assert(!!regResB.user.id, 'User B registered for authorization checks');

    // ── 2. FARM CRUD & ISOLATION ──
    console.log('\n[Test Group 2: Farm Management & User Isolation]');

    const farmA = await FarmService.createFarm(regResA.user.id, {
      name: 'Ganga Valley Farm',
      locationName: 'Phulpur, Prayagraj',
      state: 'Uttar Pradesh, India',
      areaAcres: 2.5,
      cropType: 'Wheat',
      soilType: 'Loamy',
      slope: '1.8% (Almost flat)',
      irrigation: 'Available',
      gridProximityKm: 2.2,
      latitude: 25.5484,
      longitude: 82.0833,
    });
    assert(!!farmA._id, 'Farm created for User A with MongoDB ID');
    assert(farmA.suitabilityScore > 70, `Initial suitability calculated dynamically: ${farmA.suitabilityScore}/100`);

    // Verify User A can fetch farm
    const fetchedFarm = await FarmService.getFarmById(regResA.user.id, farmA._id.toString());
    assert(fetchedFarm.name === 'Ganga Valley Farm', 'User A can retrieve their own farm');

    // Verify User B CANNOT access User A's farm
    let crossAccessBlocked = false;
    try {
      await FarmService.getFarmById(regResB.user.id, farmA._id.toString());
    } catch (e: any) {
      crossAccessBlocked = e.statusCode === 404;
    }
    assert(crossAccessBlocked, 'User B blocked from accessing User A farm (Ownership Verification)');

    // Update farm
    const updatedFarm = await FarmService.updateFarm(regResA.user.id, farmA._id.toString(), {
      name: 'Ganga Valley Farm (Updated)',
      areaAcres: 3.0,
    });
    assert(updatedFarm.name === 'Ganga Valley Farm (Updated)', 'Farm name updated in MongoDB');
    assert(updatedFarm.areaAcres === 3.0, 'Farm acreage updated in MongoDB');

    // ── 3. SITE SUITABILITY ENGINE ──
    console.log('\n[Test Group 3: Real Site Suitability Business Logic]');

    const evalResult = SuitabilityEngine.evaluate({
      solarIrradiationKwh: 5.1,
      slopePercent: 1.5,
      soilType: 'Loamy',
      hasIrrigation: true,
      crop: 'Wheat',
      gridDistanceKm: 2.0,
    });
    assert(evalResult.overallScore >= 80, `Calculated suitability score ${evalResult.overallScore} >= 80`);
    assert(evalResult.factors.length === 6, 'All 6 suitability factors evaluated');
    assert(evalResult.recommendations.length > 0, 'Actionable recommendations generated');

    const savedSuitability = await SuitabilityService.getByFarm(regResA.user.id, farmA._id.toString());
    assert(savedSuitability.overallScore === farmA.suitabilityScore, 'Stored suitability matches farm score');

    // ── 4. AGRI-PV DESIGN CALCULATIONS & COMPARISON ──
    console.log('\n[Test Group 4: Agri-PV System Design & Calculations]');

    const designs = await DesignService.getDesignsByFarm(regResA.user.id, farmA._id.toString());
    assert(designs.length >= 3, `Saved designs generated for farm: ${designs.length} designs available`);

    const primaryDesign = designs.find((d) => d.isDefaultOrPrimary) || designs[0];
    assert(primaryDesign.pvCapacityKw > 0, `PV capacity calculated: ${primaryDesign.pvCapacityKw} kW`);
    assert(primaryDesign.annualEnergyMwh > 0, `Annual generation: ${primaryDesign.annualEnergyMwh} MWh/yr`);
    assert(primaryDesign.landEquivalentRatio > 1.0, `LER > 1.0 (Dual productivity): ${primaryDesign.landEquivalentRatio}`);
    assert(primaryDesign.projectCostCr > 0, `Project cost calculated: ₹ ${primaryDesign.projectCostCr} Cr`);
    assert(primaryDesign.isMachineryCompatible, 'Machinery clearance verified for elevated stilt design');

    // ── 5. 3D VISUALIZATION CONFIG & SUN POSITION ──
    console.log('\n[Test Group 5: 3D Scene Config & Sun Trajectory]');

    const visConfig = await VisualizationService.getVisualizationConfig(
      regResA.user.id,
      primaryDesign._id.toString()
    );
    assert(visConfig.panelTilt === primaryDesign.tiltDegrees, '3D config returns saved panel tilt');
    assert(visConfig.panelHeight === primaryDesign.panelHeightMeters, '3D config returns saved panel height');
    assert(visConfig.rowSpacing === primaryDesign.rowSpacingMeters, '3D config returns saved row spacing');

    const sunAtNoon = SunPositionEngine.calculateSun(12.0, 25.5, 82.0);
    const sunAtMorning = SunPositionEngine.calculateSun(7.5, 25.5, 82.0);
    assert(sunAtNoon.solarAltitudeDeg > sunAtMorning.solarAltitudeDeg, 'Noon solar altitude is higher than morning');
    assert(sunAtNoon.solarIrradianceWm2 > sunAtMorning.solarIrradianceWm2, 'Noon solar irradiance is higher than morning');

    // ── 6. TECHNO-ECONOMIC ASSESSMENT ──
    console.log('\n[Test Group 6: Techno-Economic Financial Analysis]');

    const economics = await EconomicsService.getEconomics(regResA.user.id, primaryDesign._id.toString());
    assert(economics.annualRevenueLakhs > 0, `Annual revenue projected: ₹ ${economics.annualRevenueLakhs} Lakh`);
    assert(economics.paybackPeriodYears > 0, `Payback period projected: ${economics.paybackPeriodYears} years`);
    assert(economics.internalRateOfReturn > 10.0, `IRR projected: ${economics.internalRateOfReturn}%`);

    // ── 7. PROPOSAL PDF GENERATION & FILE DOWNLOAD ──
    console.log('\n[Test Group 7: Real PDF Report Generation]');

    const report = await ReportService.generateReport(
      regResA.user.id,
      farmA._id.toString(),
      primaryDesign._id.toString(),
      'proposal'
    );
    assert(!!report._id, 'Report record created in MongoDB');
    assert(fs.existsSync(report.filePath), `Physical PDF file exists on disk: ${report.filePath}`);
    const fileSize = fs.statSync(report.filePath).size;
    assert(fileSize > 1000, `Generated PDF is non-empty (${fileSize} bytes)`);

    const userReports = await ReportService.getReports(regResA.user.id);
    assert(userReports.length > 0, 'User reports list retrieved from MongoDB');

    // ── 8. DASHBOARD SUMMARY STATISTICS ──
    console.log('\n[Test Group 8: Dynamic Live Dashboard Summary]');

    const summary = await DashboardService.getSummary(regResA.user.id);
    assert(summary.totalFarms >= 1, `Total farms computed: ${summary.totalFarms}`);
    assert(summary.totalAreaAcres >= 3.0, `Total area computed: ${summary.totalAreaAcres} ac`);
    assert(summary.totalPvCapacityKw > 0, `Total PV capacity computed: ${summary.totalPvCapacityKw} kW`);
    assert(summary.recentFarms.length >= 1, 'Recent farms list populated from database');

    // ── 9. PROFILE, SETTINGS & SUPPORT ──
    console.log('\n[Test Group 9: Preferences, Notifications & Support]');

    // Preferences update
    const updatedPref = await UserService.updatePreferences(regResA.user.id, {
      language: 'Hindi (हिंदी)',
      theme: 'Dark',
      notificationsEnabled: false,
    });
    assert(updatedPref.preferences.language === 'Hindi (हिंदी)', 'Language preference persisted');
    assert(updatedPref.preferences.theme === 'Dark', 'Theme preference persisted');

    // Support ticket
    const ticket = await SupportService.createTicket(regResA.user.id, {
      subject: 'Inverter sizing inquiry',
      message: 'Need advice on 250 kW string inverter compatibility.',
    });
    assert(ticket.status === 'open', 'Support ticket created with open status');

    const faqs = await SupportService.getFaqs();
    assert(faqs.length >= 5, `Default FAQs retrieved: ${faqs.length} articles`);

    // Notifications
    const notifications = await NotificationService.getNotifications(regResA.user.id);
    assert(notifications.length > 0, 'User notification received for report generation');
    await NotificationService.markAllAsRead(regResA.user.id);
    const unreadAfter = (await NotificationService.getNotifications(regResA.user.id)).filter((n) => !n.read);
    assert(unreadAfter.length === 0, 'All notifications marked as read');

    console.log('\n========================================');
    console.log(`ALL TESTS PASSED! (${passedTests}/${totalTests} assertions)`);
    console.log('========================================\n');
  } catch (error) {
    console.error('\nTest execution encountered an error:', error);
    process.exit(1);
  } finally {
    // Cleanup test users and related records
    try {
      const uA = await User.findOne({ email: testEmailA });
      if (uA) {
        await Farm.deleteMany({ userId: uA._id });
        await AgriPvDesign.deleteMany({ userId: uA._id });
        await SuitabilityAnalysis.deleteMany({ userId: uA._id });
        await Report.deleteMany({ userId: uA._id });
        await User.deleteOne({ _id: uA._id });
      }
      await User.deleteOne({ email: testEmailB });
    } catch (e) {
      console.error('Cleanup warning:', e);
    }
    await disconnectDB();
  }
}

run();
